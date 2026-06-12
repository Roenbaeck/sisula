#
# Sisulator.ps1 - Modern PowerShell-based ETL Generation Tool (Jint Edition)
#
# Replaces the legacy Sisulate.bat and Sisulator.hta with a single, self-contained script.
# Uses Jint JavaScript engine instead of headless Edge for better enterprise compatibility.
#
# Version: 2.0.3 (Optimized & Bundled)
#

[CmdletBinding()]
param(
    [Parameter(Position = 0, HelpMessage = "The folder where your configuration files (sources, targets, etc.) are located.")]
    [string]$FolderPath,

    [Parameter(Position = 1, HelpMessage = "Optional. The name of the database server to install the generated SQL files on.")]
    [string]$Server,

    [Parameter(Position = 2, HelpMessage = "Optional. Filters to run only specific parts: S=sources, T=targets, W=workflows.")]
    [string]$Filters = "STW" # Default from the original batch file
)

$VERSION = "2.0.3"

# --- REFACTORED ---
# The JsConsole class is now defined once at the script level for clarity.
class JsConsole {
    Log([object]$arg1) {
        Write-Host ("Jint> " + $arg1) -ForegroundColor Magenta
    }
    Log([object[]]$arguments) {
        Write-Host ("Jint> " + ($arguments -join " ")) -ForegroundColor Magenta
    }
}

#-------------------------------------------------------------------
# Initialize Jint JavaScript Engine
#-------------------------------------------------------------------
# --- REFACTORED ---
# This function no longer downloads. It loads the bundled Jint.dll from the 'lib' subfolder.
function Initialize-JintEngine {
    [CmdletBinding()]
    param()

    Write-Host "  * Initializing Jint JavaScript engine..."

    # Check if the Jint assembly is already loaded in this session.
    if ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetName().Name -eq 'Jint' }) {
        Write-Host "  * Jint assembly is already loaded." -ForegroundColor Green
        return
    }

    try {
        # --- DYNAMIC LOADING LOGIC ---
        # Use the built-in $PSVersionTable to check the major version of PowerShell.
        $psMajorVersion = $PSVersionTable.PSVersion.Major

        if ($psMajorVersion -ge 7) {
            # Running in modern PowerShell (7 or higher)
            # The 2.x version runs fast enough for now and requires less dependencies so we will use it here as well
            Write-Host "  * PowerShell 7+ detected. Loading compatible Jint 2.x..."
            $jintDllPath = Join-Path -Path $PSScriptRoot -ChildPath "code\DLL\Jint.2.11.58.dll"
        }
        else {
            # Running in legacy Windows PowerShell (5.1 or lower)
            Write-Host "  * Legacy PowerShell detected. Loading compatible Jint 2.x..."
            $jintDllPath = Join-Path -Path $PSScriptRoot -ChildPath "code\DLL\Jint.2.11.58.dll"
        }
        # --- END DYNAMIC LOADING LOGIC ---

        if (-not (Test-Path $jintDllPath)) {
            throw "Jint.dll not found. Please ensure 'Jint.dll' is located in the 'lib' subfolder: $jintDllPath"
        }

        Write-Host "  * Loading Jint from: $jintDllPath"
        Add-Type -Path $jintDllPath
        Write-Host "  * Jint engine initialized successfully." -ForegroundColor Green
    }
    catch {
        throw "Failed to initialize Jint engine: $($_.Exception.Message)"
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
    $variableMap = @{}
    Get-Content $BatchFilePath | ForEach-Object {
        if ($_ -match '^\s*set\s+([^=]+?)\s*=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            $variableMap[$name] = $value
        }
    }
    return $variableMap
}

#-------------------------------------------------------------------
# Helper Function to run a Sisulator transformation using Jint
#-------------------------------------------------------------------
# --- REFACTORED ---
# The function now accepts a pre-configured Jint engine as a parameter.
function Invoke-Sisulation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Jint.Engine]$Engine,

        [Parameter(Mandatory = $true)]
        [string]$XmlFilePath,

        [Parameter(Mandatory = $true)]
        [string]$MappingType,
        
        [Parameter(Mandatory = $true)]
        [string]$DirectiveFilePath,

        [Parameter(Mandatory = $true)]
        [hashtable]$ContextVariables
    )

    try {
        # 1. Prepare per-file content in PowerShell
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
            Get-Content -Path $sisuletPath -Raw -Encoding UTF8
        }
        $directiveContent = $directiveContent -join [Environment]::NewLine

        # --- REFACTORED ---
        # Engine creation and library loading are now done outside this function.
        # We only set the values that change for each file.

        # 2. Set up the transformation parameters in the existing engine's global scope
        $Engine.SetValue("xmlDoc", $xmlDoc) | Out-Null
        $Engine.SetValue("mappingType", $MappingType) | Out-Null
        $Engine.SetValue("directiveContent", $directiveContent) | Out-Null
        $Engine.SetValue("variablesHashtable", $ContextVariables) | Out-Null

        # 3. Execute the transformation
        $jsExecutionCode = @"
try {
    var result = Sisulator.sisulate(); 
    result;
} catch (error) {
    throw new Error('Transformation failed: ' + error.message + ' Stack: ' + (error.stack || 'no stack'));
}
"@
        try {
            $result = $Engine.Execute($jsExecutionCode)
            $completionValue = $result.GetCompletionValue()
            
            if ($null -eq $completionValue) {
                throw "JavaScript execution returned null result"
            }
            
            return $completionValue.AsString()
        }
        catch [Jint.Runtime.JavaScriptException] {
            $jsError = $_.Exception
            throw "JavaScript execution error: $($jsError.Message) at line $($jsError.LineNumber)."
        }
        catch {
            throw "Failed to execute JavaScript: $($_.Exception.Message)."
        }
    }
    catch {
        throw "JavaScript transformation failed: $($_.Exception.Message)"
    }
}

#-------------------------------------------------------------------
# Helper Function to safely write text files
#-------------------------------------------------------------------
function Write-TextFileUtf8NoBom {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter(Mandatory = $true)]
        [string]$Content
    )
    
    # Get an absolute path without requiring the target file to already exist.
    $resolvedFilePath = [System.IO.Path]::GetFullPath($FilePath)

    # Ensure the target directory exists.
    $directory = Split-Path -Path $resolvedFilePath -Parent
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -Path $directory)) {
        New-Item -Path $directory -ItemType Directory -Force | Out-Null
    }

    # Write the file using UTF-8 without BOM.
    [System.IO.File]::WriteAllText($resolvedFilePath, $Content, (New-Object System.Text.UTF8Encoding($false)))
}

#===================================================================
# SCRIPT ENTRY POINT
#===================================================================
# Check if the script was invoked without any parameters.
if (-not $PSBoundParameters.ContainsKey('FolderPath')) {      
    Write-Host "Error: The -FolderPath parameter is required either as the first parameter or a named parameter." -ForegroundColor Red
    Write-Host "Please provide the path to your configuration folder." -ForegroundColor Yellow
    Write-Host "" # Add a blank line for spacing
    
    # Display the script's own built-in help documentation.
    $sisulaScript = $MyInvocation.MyCommand
    Get-Help $PSScriptRoot\$sisulaScript -Full
    
    # Exit the script gracefully.
    exit
}

# --- Print Header ---
Write-Host "-------------------------------------------------------------------"
Write-Host " sisula ETL Metadata Driven DW Automation Framework (v$VERSION)"
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

# --- REFACTORED ---
# ONE-TIME JINT ENGINE SETUP
Write-Host "`n  * Creating and configuring the Jint engine for the session..."
# Create a hashtable of the .NET XmlNodeType enum values.
$xmlNodeTypeConstants = @{
    Element = [System.Xml.XmlNodeType]::Element
    Text = [System.Xml.XmlNodeType]::Text
    Document = [System.Xml.XmlNodeType]::Document
}

# Create an instance of our console logger class.
$consoleInstance = [JsConsole]::new()

# Create the single, persistent engine instance.
$jintEngine = New-Object Jint.Engine

# Inject the helper objects into the engine's global scope.
$jintEngine.SetValue("console", $consoleInstance) | Out-Null
$jintEngine.SetValue("XmlNodeType", $xmlNodeTypeConstants) | Out-Null

# Load the main Sisulator.js library into the engine once.
$sisulatorJsPath = Join-Path -Path $PSScriptRoot -ChildPath "Sisulator4PS.js"
if (-not (Test-Path $sisulatorJsPath)) {
    throw "The required helper file 'Sisulator.js' was not found."
}
$sisulatorJavaScript = Get-Content -Path $sisulatorJsPath -Raw -Encoding UTF8
Write-Host "  * Executing: $sisulatorJsPath"
$jintEngine.Execute($sisulatorJavaScript) | Out-Null
Write-Host "  * Jint engine is configured and ready." -ForegroundColor Green


# --- Source project specific variables ---
$scriptContextVariables = @{}
Write-Host "`n  * Loading environment variables..."
Get-ChildItem -Path "env:" | ForEach-Object { $scriptContextVariables[$_.Name] = $_.Value }
Write-Host "  * Loaded $($scriptContextVariables.Keys.Count) environment variables."
$variablesBatPath = Join-Path -Path $FolderPath -ChildPath "Variables.BAT"
if (Test-Path $variablesBatPath) {
    $importedVariables = Import-VariablesFromBatchFile -BatchFilePath $variablesBatPath
    foreach ($key in $importedVariables.Keys) { $scriptContextVariables[$key] = $importedVariables[$key] }
    Write-Host "  * Parsed and merged $($importedVariables.Keys.Count) variables from 'Variables.BAT'."
}

# --- Setup Sisula Path and Working Directory ---
$sisulaPath = $PSScriptRoot
# Explicitly add the script's own path to the context variables (with a trailing slash)
$slash = [System.IO.Path]::DirectorySeparatorChar
$scriptContextVariables['SisulaPath'] = "$sisulaPath$slash"
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
            Write-Host "`n  + Creating bulk format files and..." -ForegroundColor Cyan
            foreach ($file in (Get-ChildItem -Path $sourcesDir -Filter "*.xml")) {
                $outputFile = Join-Path -Path $formatsDir -ChildPath "$($file.BaseName).xml"
                Write-Host "  * Transforming $($file.Name) -> $($outputFile.Replace($FolderPath, '...'))"
                # --- REFACTORED --- Pass the single engine instance to the function
                $result = Invoke-Sisulation -Engine $jintEngine -XmlFilePath $file.FullName -MappingType "Source" -DirectiveFilePath "format.directive" -ContextVariables $scriptContextVariables
                Write-TextFileUtf8NoBom -FilePath $outputFile -Content $result            }
        }
    }

    # Create source loading SQL code
    if ($filtersNormalized -like '*S*') {
        $sourcesDir = Join-Path -Path $FolderPath -ChildPath "sources"
        $formatsDir = Join-Path -Path $FolderPath -ChildPath "formats"
        if (Test-Path $sourcesDir) {
            Write-Host "`n  + Creating source loading procedures..." -ForegroundColor Cyan
            foreach ($file in (Get-ChildItem -Path $sourcesDir -Filter "*.xml")) {
                $outputFile = Join-Path -Path $sourcesDir -ChildPath "$($file.BaseName).sql"
                $formatFile = Join-Path -Path $formatsDir -ChildPath "$($file.BaseName).xml"
                $scriptContextVariables['FormatFile'] = "$formatFile"
                Write-Host "  * Transforming $($file.Name) -> $($outputFile.Replace($FolderPath, '...'))"
                $result = Invoke-Sisulation -Engine $jintEngine -XmlFilePath $file.FullName -MappingType "Source" -DirectiveFilePath "source.directive" -ContextVariables $scriptContextVariables
                Write-TextFileUtf8NoBom -FilePath $outputFile -Content $result
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
                $result = Invoke-Sisulation -Engine $jintEngine -XmlFilePath $file.FullName -MappingType "Target" -DirectiveFilePath "target.directive" -ContextVariables $scriptContextVariables
                Write-TextFileUtf8NoBom -FilePath $outputFile -Content $result
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
                $result = Invoke-Sisulation -Engine $jintEngine -XmlFilePath $file.FullName -MappingType "Target" -DirectiveFilePath "biml.directive" -ContextVariables $scriptContextVariables
                Write-TextFileUtf8NoBom -FilePath $outputFile -Content $result
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
                $result = Invoke-Sisulation -Engine $jintEngine -XmlFilePath $file.FullName -MappingType "Workflow" -DirectiveFilePath "workflow.directive" -ContextVariables $scriptContextVariables
                Write-TextFileUtf8NoBom -FilePath $outputFile -Content $result
                $sqlFiles.Add($outputFile)
            }
        }
    }
    
    # Install the generated SQL files
    if ($Server) {
        Write-Host "`n  + Installing SQL files on server '$Server'..." -ForegroundColor Yellow
        foreach ($sqlFile in $sqlFiles) {
            Write-Host "  * Installing $($sqlFile.Replace($FolderPath, '...'))"
            
            # Copy the SQL file to a local temp directory to avoid UNC path issues with sqlcmd
            $tempFile = Join-Path -Path $env:TEMP -ChildPath ([System.IO.Path]::GetRandomFileName() + ".sql")
            try {
                Copy-Item -Path $sqlFile -Destination $tempFile -Force
                
                sqlcmd -S $Server -i $tempFile -f 65001 -I -x -b -r1 
                if ($LASTEXITCODE -ne 0) {
                    throw "sqlcmd failed with exit code $LASTEXITCODE while installing $sqlFile"
                }
            }
            finally {
                # Clean up the temporary file
                if (Test-Path $tempFile) {
                    Remove-Item -Path $tempFile -Force
                }
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
# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3S1qrl6fVgDTnwKIfAzREhQj
# 5aygggMQMIIDDDCCAfSgAwIBAgIQHU3dWBuwiqpO+545AJHyKTANBgkqhkiG9w0B
# AQUFADAeMRwwGgYDVQQDDBNTaXN1bGF0ZUNvZGVTaWduaW5nMB4XDTI1MDkxMjEw
# MzUwMloXDTMwMDkxMjEwNDUwMlowHjEcMBoGA1UEAwwTU2lzdWxhdGVDb2RlU2ln
# bmluZzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALbnGJEww67aPRwR
# +BsD/MY57GdRdFQCVO3XIeagZiIydc8o17oUL9aIZJ29LdXtvJmBcwg69iOQ8xV7
# WtG4lg6wf4GZJ8VWQCvpuPZVyY4OPLZjbH6au82cTzDvPJspDuwNIEllebqcVP/e
# DZA+N4TEA4UQ40ajay+HHykC+xBOfCdEqbbLBnix/LxbYupG9YY/ttJja0oqvryb
# cVkDKFNnmW3UVVxf5Bz294QhIUaemwjpdXwUwSj7+eMrGvPdyHk+SLdUaIp73QRt
# i214PROMdsQm5OCGEc5pxzsSj0TBTtbmePJ7Cy8Mrcx1JiR917M3hFdBCjqILr3r
# tjm5GR0CAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMB0GA1UdDgQWBBSha3nEvNvddhH1v1vS+fQYXP7C9jANBgkqhkiG9w0BAQUF
# AAOCAQEAIVuzXhOWitzwaW6cXrpaXMpKrX3RDxoAgEuueJlR2EAoNqR5bsdFSFHJ
# xSF+Pq8jm+2wgt+CicrgEZWO1Qvv+bYEq7+t7l6V9KZ/m+pZjjV7hCZdv/eNWav8
# KDDtQJP+PY/Cxjj3P/gCjq1crNtPXhqmKv2fyiotYy/tNOlzLV/Oho+CPQBi5Cot
# tBE30AR/x1XACGoc6siTkrfzVq3/NQWhUeK0EpX6B7+sPxoRs3rHEbI+DaQN/Rfs
# GEdGL9/o4IV5Oy2Fl3XJ0YYWglw66PlRhVjPL6deKTlXVt7OJRKfr9WFhm6iVgHq
# cmzCkB7zWbu36x9UXC9w7EIL0+ykozGCAdMwggHPAgEBMDIwHjEcMBoGA1UEAwwT
# U2lzdWxhdGVDb2RlU2lnbmluZwIQHU3dWBuwiqpO+545AJHyKTAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQUiq8t1MdEYwqbQM77xQE7xmvOTs4wDQYJKoZIhvcNAQEBBQAEggEAPfBo
# 5KTSHRkj1NK9aVrtanIbnE2HpMtP0hxfK5eZTZbznd9rsCCwgOJMYhsi1/qhQ38N
# My22Pk0XOV/2WGDVYnFdBL531XOrXBssd5bPiHontArpCXZ3H5PrlXKWBU/ayguc
# YCcRUv/nUbr5sa5noChPgF8SoZBFI1aYy+xqZ2ylhNG5ThqXTP20ML+xnRqrXi8+
# 3XeD5Apq1xGl/yPYdzXFmulh4J1tMY4RmTfVZbV6ekX2pJj/F+KnsuhLIJMPmr4t
# zuyQAITc82BI6ccuorB3QiOMWNyBiwEBKAvql7YXZeUMP+SCOLaOEg25tSR27vIc
# YQ9wex2iK24G4Md48w==
# SIG # End signature block
