#
# Sisulator.ps1 - Modern PowerShell-based ETL Generation Tool (Jint Edition)
#
# Replaces the legacy Sisulate.bat and Sisulator.hta with a single, self-contained script.
# Uses Jint JavaScript engine instead of headless Edge for better enterprise compatibility.
#
# Version: 3.0 (Jint Edition)
#

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The folder where your configuration files (sources, targets, etc.) are located.")]
    [string]$FolderPath,

    [Parameter(Position = 1, HelpMessage = "Optional. The name of the database server to install the generated SQL files on.")]
    [string]$Server,

    [Parameter(Position = 2, HelpMessage = "Optional. Filters to run only specific parts: S=sources, T=targets, W=workflows.")]
    [string]$Filters = "STW" # Default from the original batch file
)

#-------------------------------------------------------------------
# Initialize Jint JavaScript Engine
#-------------------------------------------------------------------
function Initialize-JintEngine {
    [CmdletBinding()]
    param()

    Write-Host "  * Initializing Jint JavaScript engine..."
    
    $jintVersion = "2.11.58"  # Last stable 2.x version compatible with .NET Framework
    $tempDir = "$env:TEMP\JintDownload_Sisulate"

    # Check if Jint is already loaded
    try {
        $testEngine = New-Object Jint.Engine
        $testEngine.Dispose()
        Write-Host "  * Jint already available." -ForegroundColor Green
        return
    }
    catch {
        Write-Host "  * Jint not found, downloading version $jintVersion..."
    }

    try {
        # Create temp directory
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

        # Download Jint 2.x
        $nugetUrl = "https://www.nuget.org/api/v2/package/Jint/$jintVersion"
        $nupkgPath = "$tempDir\jint.$jintVersion.nupkg"
        Invoke-WebRequest -Uri $nugetUrl -OutFile $nupkgPath -UseBasicParsing

        # Extract the package
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($nupkgPath, $tempDir)

        # Find and load the Jint DLL
        $jintDllPath = Get-ChildItem -Path $tempDir -Recurse -Filter "Jint.dll" | Select-Object -First 1 -ExpandProperty FullName
        if (-not $jintDllPath) {
            throw "Could not find Jint.dll in the downloaded package."
        }

        Write-Host "  * Loading Jint from: $jintDllPath"
        Add-Type -Path $jintDllPath

        Write-Host "  * Jint engine initialized successfully." -ForegroundColor Green
    }
    catch {
        throw "Failed to initialize Jint engine: $($_.Exception.Message)"
    }
    finally {
        # Clean up temp directory
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

#-------------------------------------------------------------------
# Parse Variables.BAT (which we keep for legacy reasons)
#-------------------------------------------------------------------
function Import-VariablesFromBatchFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BatchFilePath
    )

    Write-Host "  * Parsing variables from legacy configuration file: $BatchFilePath"
    
    # Create a hashtable to hold the variables.
    $variableMap = @{}

    Get-Content $BatchFilePath | ForEach-Object {
        if ($_ -match '^\s*set\s+([^=]+?)\s*=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()

            # Add the key and value directly to our hashtable.
            $variableMap[$name] = $value
            Write-Verbose "  - Parsed: $name = $value"
        }
    }
    
    # Return the completed hashtable.
    return $variableMap
}

#-------------------------------------------------------------------
# Load the external JavaScript Engine from file
#-------------------------------------------------------------------
$sisulatorJsPath = Join-Path -Path $PSScriptRoot -ChildPath "Sisulator4PS.js"
if (-not (Test-Path $sisulatorJsPath)) {
    throw "The required helper file 'Sisulator4PS.js' was not found in the same directory as the main script."
}
# Use -Raw to read the entire file into a single string
$sisulatorJavaScript = Get-Content -Path $sisulatorJsPath -Raw -Encoding UTF8

#-------------------------------------------------------------------
# Helper Function to run a Sisulator transformation using Jint
#-------------------------------------------------------------------
function Invoke-Sisulation {
    [CmdletBinding()]
    param(
        [string]$XmlFilePath,
        [string]$MappingType,
        [string]$DirectiveFilePath,
        [hashtable]$ContextVariables
    )

    try {
        # 1. Prepare all content in PowerShell first
        $xmlContentAsString = Get-Content -Raw -Path $XmlFilePath -Encoding UTF8
        $xmlDoc = [xml]$xmlContentAsString
        
        $resolvedDirectivePath = Resolve-Path -Path $DirectiveFilePath
        $directiveBasePath = Split-Path -Path $resolvedDirectivePath -Parent
        $sisuletFiles = Get-Content -Path $resolvedDirectivePath | Where-Object { $_.Trim() -and -not $_.Trim().StartsWith("#") }
        $directiveContent = foreach ($file in $sisuletFiles) {
            $sisuletPath = Join-Path -Path $directiveBasePath -ChildPath $file.Trim()
            if (-not (Test-Path $sisuletPath)) {
                throw "The template file specified in '$($resolvedDirectivePath.split('\')[-1])' could not be found at path: $sisuletPath"
            }
            Get-Content -Path $sisuletPath -Raw
        }
        $directiveContent = $directiveContent -join [Environment]::NewLine

        # 2. Create Jint engine and load the Sisulator JavaScript
        $engine = New-Object Jint.Engine

        # Define a simple class to act as our console.
        # This creates a standard .NET object that Jint can easily understand.
        class JsConsole {
            # Jint will call this method for console.log()
            Log([object]$arg1) {
                Write-Host ("Jint> " + $arg1) -ForegroundColor Magenta
            }
            Log([object[]]$arguments) {
                Write-Host ("Jint> " + ($arguments -join " ")) -ForegroundColor Magenta
            }
        }

        # Create a hashtable of the .NET XmlNodeType enum values.
        # This allows the JavaScript code to do reliable, readable comparisons.
        $xmlNodeTypeConstants = @{
            Element = [System.Xml.XmlNodeType]::Element
            Text = [System.Xml.XmlNodeType]::Text
            Document = [System.Xml.XmlNodeType]::Document
            # Add any other types you might need in the future here
        }

        # 2. Create Jint engine
        $engine = New-Object Jint.Engine
        
        # Create an INSTANCE of our class.
        $consoleInstance = [JsConsole]::new()

        # Inject this simple object into the Jint engine.
        # Jint's interop is excellent at calling methods on host objects.
        $engine.SetValue("console", $consoleInstance)

        # Inject the enum constants object into Jint's global scope.
        $engine.SetValue("XmlNodeType", $xmlNodeTypeConstants)

        $engine.Execute($sisulatorJavaScript) | Out-Null
        Write-Host "  * Sisulator loaded." -ForegroundColor Green

        # 3. Set up the transformation parameters in Jint's global scope
        $engine.SetValue("xmlDoc", $xmlDoc) 
        $engine.SetValue("mappingType", $MappingType)
        $engine.SetValue("directiveContent", $directiveContent)

        # Pass the variables hashtable directly as a navigable object. 
        $engine.SetValue("VARIABLES", $scriptContextVariables)

        # 4. Execute the transformation
        # The sisulate function will now find its dependencies in the global scope.
$jsExecutionCode = @"
try {
    // Call the refactored function, which no longer needs parameters for context.
    var result = Sisulator.sisulate(); 
    result;
} catch (error) {
    throw new Error('Transformation failed: ' + error.message + ' Stack: ' + (error.stack || 'no stack'));
}
"@

        # Build the complete JavaScript code for debugging
        $completeJsCode = $sisulatorJavaScript + [Environment]::NewLine + [Environment]::NewLine + $jsExecutionCode
        
        # Save debugging JavaScript file
        $xmlBaseName = [System.IO.Path]::GetFileNameWithoutExtension($XmlFilePath)
        $debugJsPath = Join-Path -Path (Split-Path $XmlFilePath -Parent) -ChildPath "$xmlBaseName.debug.js"
        try {
            [System.IO.File]::WriteAllText($debugJsPath, $completeJsCode, [System.Text.Encoding]::UTF8)
            Write-Verbose "  - Debug JavaScript saved to: $debugJsPath"
        }
        catch {
            Write-Warning "  - Could not save debug JavaScript file: $($_.Exception.Message)"
        }

        try {
            $result = $engine.Execute($jsExecutionCode)
            $completionValue = $result.GetCompletionValue()
            
            if ($completionValue -eq $null) {
                throw "JavaScript execution returned null result"
            }
            
            $output = $completionValue.AsString()
            return $output
        }
        catch [Jint.Runtime.JavaScriptException] {
            $jsError = $_.Exception
            throw "JavaScript execution error: $($jsError.Message) at line $($jsError.LineNumber). Debug file saved at: $debugJsPath"
        }
        catch {
            throw "Failed to execute JavaScript: $($_.Exception.Message). Debug file saved at: $debugJsPath"
        }
    }
    catch {
        throw "JavaScript transformation failed: $($_.Exception.Message)"
    }
    finally {
        # Jint 2.x engines are automatically garbage collected, no explicit disposal needed
        $engine = $null
    }
}

#===================================================================
# SCRIPT ENTRY POINT
#===================================================================

# --- Print Header ---
Write-Host "-------------------------------------------------------------------"
Write-Host " sisula ETL Metadata Driven DW Automation Framework (v3.0)         "
Write-Host "-------------------------------------------------------------------"

# --- Validate FolderPath ---
$FolderPath = Resolve-Path -Path $FolderPath -ErrorAction SilentlyContinue
if (-not $FolderPath) {
    Write-Error "The specified folder path does not exist: '$($PSBoundParameters['FolderPath'])'"
    exit 1
}

# --- Initialize Jint Engine ---
try {
    Initialize-JintEngine
}
catch {
    Write-Error "Failed to initialize JavaScript engine: $($_.Exception.Message)"
    exit 1
}

# --- Source project specific variables ---
# --- Source project specific variables ---
# Create a single context hashtable to hold all variables.
$scriptContextVariables = @{}

# 1. Load all environment variables first.
Write-Host "  * Loading environment variables..."
Get-ChildItem -Path "env:" | ForEach-Object {
    $scriptContextVariables[$_.Name] = $_.Value
}
Write-Host "  * Loaded $($scriptContextVariables.Keys.Count) environment variables." -ForegroundColor Green

# 2. Load variables from the BAT file, overwriting any environment variables with the same name.
$variablesBatPath = Join-Path -Path $FolderPath -ChildPath "Variables.BAT"
if (Test-Path $variablesBatPath) {
    $importedVariables = Import-VariablesFromBatchFile -BatchFilePath $variablesBatPath
    foreach ($key in $importedVariables.Keys) {
        $scriptContextVariables[$key] = $importedVariables[$key]
    }
    Write-Host "  * Parsed and merged $($importedVariables.Keys.Count) variables from 'Variables.BAT'." -ForegroundColor Green
}

# --- Setup Sisula Path and Working Directory ---
$sisulaPath = $PSScriptRoot
Write-Host "`n  * Path to Sisulator script: $sisulaPath"
Write-Host "  * Path to configuration folder: $FolderPath"
Push-Location -Path $sisulaPath
Write-Host "  * Entered script directory: $(Get-Location)"

try {
    # --- Main Processing Logic (from Sisulate.bat) ---
    $sqlFiles = [System.Collections.Generic.List[string]]::new()
    $filtersNormalized = $Filters.ToUpper()

    # Create bulk format files
    if ($filtersNormalized -like '*S*') {
        $sourcesDir = Join-Path -Path $FolderPath -ChildPath "sources"
        $formatsDir = Join-Path -Path $FolderPath -ChildPath "formats"
        if ((Test-Path $sourcesDir) -and (Test-Path $formatsDir)) {
            Write-Host "`n  + Creating bulk format files..." -ForegroundColor Cyan
            foreach ($file in (Get-ChildItem -Path $sourcesDir -Filter "*.xml")) {
                $outputFile = Join-Path -Path $formatsDir -ChildPath "$($file.BaseName).xml"
                Write-Host "  * Transforming $($file.Name) -> $($outputFile.Replace($FolderPath, '...'))"
                $result = Invoke-Sisulation -XmlFilePath $file.FullName -MappingType "Source" -DirectiveFilePath "format.directive" -ContextVariables $scriptContextVariables
                [System.IO.File]::WriteAllText((Convert-Path $outputFile), $result, (New-Object System.Text.UTF8Encoding($false)))
            }
        }
    }

    # Create source loading SQL code
    if ($filtersNormalized -like '*S*') {
        $sourcesDir = Join-Path -Path $FolderPath -ChildPath "sources"
        if (Test-Path $sourcesDir) {
            Write-Host "`n  + Creating source loading procedures..." -ForegroundColor Cyan
            foreach ($file in (Get-ChildItem -Path $sourcesDir -Filter "*.xml")) {
                $outputFile = Join-Path -Path $sourcesDir -ChildPath "$($file.BaseName).sql"
                Write-Host "  * Transforming $($file.Name) -> $($outputFile.Replace($FolderPath, '...'))"
                $result = Invoke-Sisulation -XmlFilePath $file.FullName -MappingType "Source" -DirectiveFilePath "source.directive" -ContextVariables $scriptContextVariables
                [System.IO.File]::WriteAllText((Convert-Path $outputFile), $result, (New-Object System.Text.UTF8Encoding($false)))
                $sqlFiles.Add($outputFile)
            }
        }
    }

    # Create target loading SQL code
    if ($filtersNormalized -like '*T*') {
        $targetsDir = Join-Path -Path $FolderPath -ChildPath "targets"
        if (Test-Path $targetsDir) {
            Write-Host "`n  + Creating target loading procedures..." -ForegroundColor Cyan
            foreach ($file in (Get-ChildItem -Path $targetsDir -Filter "*.xml")) {
                $outputFile = Join-Path -Path $targetsDir -ChildPath "$($file.BaseName).sql"
                Write-Host "  * Transforming $($file.Name) -> $($outputFile.Replace($FolderPath, '...'))"
                $result = Invoke-Sisulation -XmlFilePath $file.FullName -MappingType "Target" -DirectiveFilePath "target.directive" -ContextVariables $scriptContextVariables
                [System.IO.File]::WriteAllText((Convert-Path $outputFile), $result, (New-Object System.Text.UTF8Encoding($false)))
                $sqlFiles.Add($outputFile)
            }
        }
    }

    # Create BIML files
    if ($filtersNormalized -like '*T*') {
        $targetsDir = Join-Path -Path $FolderPath -ChildPath "targets"
        $bimlDir = Join-Path -Path $FolderPath -ChildPath "biml"
        if ((Test-Path $targetsDir) -and (Test-Path $bimlDir)) {
            Write-Host "`n  + Creating BIML files..." -ForegroundColor Cyan
            foreach ($file in (Get-ChildItem -Path $targetsDir -Filter "*.xml")) {
                $outputFile = Join-Path -Path $bimlDir -ChildPath "$($file.BaseName).biml"
                Write-Host "  * Transforming $($file.Name) -> $($outputFile.Replace($FolderPath, '...'))"
                $result = Invoke-Sisulation -XmlFilePath $file.FullName -MappingType "Target" -DirectiveFilePath "biml.directive" -ContextVariables $scriptContextVariables
                [System.IO.File]::WriteAllText((Convert-Path $outputFile), $result, (New-Object System.Text.UTF8Encoding($false)))
            }
        }
    }

    # Create SQL Server Agent job code
    if ($filtersNormalized -like '*W*') {
        $workflowsDir = Join-Path -Path $FolderPath -ChildPath "workflows"
        if (Test-Path $workflowsDir) {
            Write-Host "`n  + Creating SQL Server Agent jobs..." -ForegroundColor Cyan
            foreach ($file in (Get-ChildItem -Path $workflowsDir -Filter "*.xml")) {
                $outputFile = Join-Path -Path $workflowsDir -ChildPath "$($file.BaseName).sql"
                Write-Host "  * Transforming $($file.Name) -> $($outputFile.Replace($FolderPath, '...'))"
                $result = Invoke-Sisulation -XmlFilePath $file.FullName -MappingType "Workflow" -DirectiveFilePath "workflow.directive" -ContextVariables $scriptContextVariables
                [System.IO.File]::WriteAllText((Convert-Path $outputFile), $result, (New-Object System.Text.UTF8Encoding($false)))
                $sqlFiles.Add($outputFile)
            }
        }
    }

    # Install the generated SQL files
    if ($Server) {
        Write-Host "`n  + Installing SQL files on server '$Server'..." -ForegroundColor Yellow
        foreach ($sqlFile in $sqlFiles) {
            Write-Host "  * Installing $($sqlFile.Replace($FolderPath, '...'))"
            # Using -f 65001 for UTF-8 codepage, -I for Quoted Identifiers
            # -b for batch termination on error, -r1 for redirecting messages to stderr
            sqlcmd -S $Server -i $sqlFile -f 65001 -I -b -r1 
            if ($LASTEXITCODE -ne 0) {
                throw "sqlcmd failed with exit code $LASTEXITCODE while installing $sqlFile"
            }
        }
    }

    Write-Host "`n-------------------------------------------------------------------"
    Write-Host " sisula finished successfully               $(Get-Date)"
    Write-Host "-------------------------------------------------------------------"

}
catch {
    Write-Host "`n"
    Write-Error "A critical error occurred: $($_.Exception.Message)"
    exit 1
}
finally {
    # --- Clean up resources ---
    Write-Host "Cleaning up resources..."
    Pop-Location
}