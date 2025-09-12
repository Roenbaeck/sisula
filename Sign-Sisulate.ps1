# Sign-Sisulate.ps1 - Creates and installs a self-signed certificate, signs Sisulate.ps1, and exports certificate files
#
# Usage: .\Sign-Sisulate.ps1 -ScriptPath "C:\Path\To\Sisulate.ps1" [-OutputDir "C:\Temp"] [-SetExecutionPolicy] [-UseTimestamp]
#
# Parameters:
#   -ScriptPath: Path to the Sisulate.ps1 script to sign (required).
#   -OutputDir: Directory to save certificate files (.cer and .pfx) (default: script's directory).
#   -SetExecutionPolicy: Switch to set execution policy to AllSigned for CurrentUser.
#   -UseTimestamp: Switch to enable timestamping during signing (optional).

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Path to the Sisulate.ps1 script to sign.")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ScriptPath,

    [Parameter(HelpMessage = "Directory to save certificate files (.cer and .pfx).")]
    [string]$OutputDir,

    [Parameter(HelpMessage = "Set execution policy to AllSigned for CurrentUser.")]
    [switch]$SetExecutionPolicy,

    [Parameter(HelpMessage = "Use timestamp server during signing.")]
    [switch]$UseTimestamp
)

# --- Helper Function: Generate a new UUID ---
function New-Guid {
    return [System.Guid]::NewGuid().ToString()
}

# --- Initialize ---
Write-Host "Starting certificate creation and script signing process..." -ForegroundColor Cyan
$ErrorActionPreference = "Stop"

# Resolve paths to get clean string values immediately.
try {
    $ScriptPath = (Resolve-Path -LiteralPath $ScriptPath).ProviderPath
}
catch {
    Write-Error "Could not resolve the script path: '$ScriptPath'. Error: $($_.Exception.Message)"
    exit 1
}

# Set default OutputDir if not provided, then resolve it.
if (-not $PSBoundParameters.ContainsKey('OutputDir')) {
    $OutputDir = Split-Path -Path $ScriptPath -Parent
}

if (-not (Test-Path -LiteralPath $OutputDir)) {
    try {
        New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
    }
    catch {
        Write-Error "Failed to create output directory: '$OutputDir'. Error: $($_.Exception.Message)"
        exit 1
    }
}
$OutputDir = (Resolve-Path -LiteralPath $OutputDir).ProviderPath

Write-Host "Script Path: $ScriptPath"
Write-Host "Output Directory: $OutputDir"

# --- Check if running on a network share and copy to local temp ---
$localTempDir = Join-Path -Path $env:TEMP -ChildPath "SisulateSign_$(New-Guid)"
$localScriptPath = Join-Path -Path $localTempDir -ChildPath (Split-Path -Leaf $ScriptPath)

if ($ScriptPath.StartsWith('\\')) {
    Write-Host "`nDetected script on network share. Copying to local temp directory: $localTempDir" -ForegroundColor Yellow
    try {
        New-Item -Path $localTempDir -ItemType Directory -Force | Out-Null
        $retryCount = 3
        $success = $false
        for ($i = 1; $i -le $retryCount; $i++) {
            try {
                Copy-Item -Path $ScriptPath -Destination $localScriptPath -Force -Verbose -ErrorAction Stop
                if (Test-Path $localScriptPath -PathType Leaf) {
                    $success = $true
                    break
                }
                Write-Warning "Copy attempt $i failed: File not found at $localScriptPath. Retrying..."
                Start-Sleep -Milliseconds 500
            }
            catch {
                Write-Warning "Copy attempt $i failed: $($_.Exception.Message). Retrying..."
                Start-Sleep -Milliseconds 500
            }
        }
        if (-not $success) {
            Write-Error "Failed to copy script to local temp directory after $retryCount attempts: $localScriptPath"
            exit 1
        }
        Write-Host "Script copied to: $localScriptPath" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
    }
    catch {
        Write-Error "Failed to copy script to local temp directory: $($_.Exception.Message)"
        exit 1
    }
}
else {
    $localScriptPath = $ScriptPath
}

# --- Ensure script is UTF-8 without BOM and validate content ---
Write-Host "`nEnsuring script is UTF-8 without BOM..." -ForegroundColor Cyan
try {
    if (-not (Test-Path $localScriptPath -PathType Leaf)) {
        Write-Error "Local script path is not accessible: $localScriptPath"
        exit 1
    }
    # Validate file readability
    try {
        $content = Get-Content -Path $localScriptPath -Raw -Encoding UTF8 -ErrorAction Stop
        if (-not $content) {
            Write-Error "Script file is empty or unreadable: $localScriptPath"
            exit 1
        }
    }
    catch {
        Write-Error "Failed to read script file: $($_.Exception.Message)"
        exit 1
    }
    $psMajorVersion = $PSVersionTable.PSVersion.Major
    if ($psMajorVersion -ge 7) {
        Write-Host "PowerShell 7+ detected. Using Set-Content with utf8NoBOM." -ForegroundColor Yellow
        Set-Content -Path $localScriptPath -Value $content -Encoding utf8NoBOM -Force
    }
    else {
        Write-Host "Windows PowerShell 5.1 or lower detected. Using System.IO.File.WriteAllText for UTF-8 without BOM." -ForegroundColor Yellow
        [System.IO.File]::WriteAllText($localScriptPath, $content, (New-Object System.Text.UTF8Encoding($false)))
    }
    Write-Host "Script encoding verified/updated." -ForegroundColor Green
}
catch {
    Write-Error "Failed to verify/update script encoding: $($_.Exception.Message)"
    exit 1
}

# --- Step 1: Create Self-Signed Certificate with Enhanced Parameters ---
Write-Host "`nCreating self-signed code-signing certificate..." -ForegroundColor Cyan
try {
    # Remove any existing certificates with the same subject
    Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=SisulateCodeSigning" } | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path Cert:\CurrentUser\TrustedPublisher | Where-Object { $_.Subject -eq "CN=SisulateCodeSigning" } | Remove-Item -Force -ErrorAction SilentlyContinue

    # Create certificate with explicit key parameters
    $cert = New-SelfSignedCertificate `
        -Subject "CN=SisulateCodeSigning" `
        -CertStoreLocation Cert:\CurrentUser\My `
        -KeyUsage DigitalSignature `
        -Type CodeSigningCert `
        -FriendlyName "Sisulate Script Signing" `
        -NotAfter (Get-Date).AddYears(5) `
        -KeyAlgorithm RSA `
        -KeyLength 2048 `
        -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
        -KeyExportPolicy Exportable `
        -KeyProtection None

    Write-Host "Certificate created with Thumbprint: $($cert.Thumbprint)" -ForegroundColor Green

    # Enhanced private key validation
    if (-not $cert.HasPrivateKey) {
        Write-Error "Certificate does not have a private key."
        exit 1
    }
    
    # Try to access the private key more robustly
    try {
        $privateKey = $cert.PrivateKey
        if ($null -eq $privateKey) {
            # Try alternative method for newer PowerShell versions
            $privateKey = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
        }
        if ($null -eq $privateKey) {
            Write-Error "Unable to access the certificate's private key."
            exit 1
        }
        Write-Host "Private key validated successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to validate private key: $($_.Exception.Message)"
        exit 1
    }

    # Validate code signing EKU
    $codeSigningEkuOid = "1.3.6.1.5.5.7.3.3"
    $enhancedKeyUsageExtension = $cert.Extensions | Where-Object { $_.Oid.Value -eq '2.5.29.37' }
    if (-not ($enhancedKeyUsageExtension.EnhancedKeyUsages | Where-Object { $_.Value -eq $codeSigningEkuOid })) {
        Write-Error "Certificate is not configured for code signing. The 'Code Signing' EKU is missing."
        exit 1
    }

    # Force refresh of certificate store to ensure certificate is available for signing
    Write-Host "Refreshing certificate stores..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
    # Verify certificate is in the store and accessible
    $certFromStore = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $cert.Thumbprint }
    if (-not $certFromStore) {
        Write-Error "Certificate not found in store after creation."
        exit 1
    }
    Write-Host "Certificate verified in store." -ForegroundColor Green
}
catch {
    Write-Error "Failed to create or verify certificate: $($_.Exception.Message)"
    exit 1
}

# --- Step 2: Export Certificate (.cer for distribution) ---
Write-Host "`nExporting certificate to .cer file..." -ForegroundColor Cyan
$cerPath = Join-Path -Path $OutputDir -ChildPath "SisulateCert.cer"
try {
    Export-Certificate -Cert $cert -FilePath $cerPath -Force | Out-Null
    Write-Host "Certificate exported to: $cerPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to export .cer file: $($_.Exception.Message)"
    exit 1
}

# --- Step 3: Export Certificate with Private Key (.pfx for backup, optional) ---
Write-Host "`nExporting certificate with private key to .pfx file..." -ForegroundColor Cyan
$pfxPath = Join-Path -Path $OutputDir -ChildPath "SisulateCert.pfx"
$pfxPassword = ConvertTo-SecureString -String "Sisulate2025" -Force -AsPlainText
try {
    Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $pfxPassword -Force | Out-Null
    Write-Host "Certificate with private key exported to: $pfxPath" -ForegroundColor Green
    Write-Host "Note: .pfx password is 'Sisulate2025'. Store securely." -ForegroundColor Yellow
}
catch {
    Write-Warning "Failed to export .pfx file: $($_.Exception.Message). Continuing without .pfx."
}

# --- Step 4: Trust the Certificate ---
Write-Host "`nAdding certificate to Root and TrustedPublisher stores..." -ForegroundColor Cyan
try {
    # Add to Root store first to establish trust chain
    Import-Certificate -FilePath $cerPath -CertStoreLocation Cert:\CurrentUser\Root | Out-Null
    Write-Host "Certificate added to Root store." -ForegroundColor Green
    
    # Add to TrustedPublisher store for code signing
    Import-Certificate -FilePath $cerPath -CertStoreLocation Cert:\CurrentUser\TrustedPublisher | Out-Null
    Write-Host "Certificate added to TrustedPublisher store." -ForegroundColor Green
}
catch {
    Write-Error "Failed to import certificate to trust stores: $($_.Exception.Message)"
    exit 1
}

# --- Step 5: Sign the Script with Enhanced Error Handling ---
Write-Host "`nSigning Sisulate.ps1..." -ForegroundColor Cyan
try {
    $signature = $null
    $timestampServer = 'http://timestamp.digicert.com'
    $retryCount = 2
    $success = $false

    # Get the certificate directly from the store for signing
    $signingCert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $cert.Thumbprint } | Select-Object -First 1
    if (-not $signingCert) {
        Write-Error "Signing certificate not found in store."
        exit 1
    }

    Write-Host "Using certificate from store with thumbprint: $($signingCert.Thumbprint)" -ForegroundColor Gray

    for ($i = 1; $i -le $retryCount; $i++) {
        Write-Host "Signing attempt $i..." -ForegroundColor Gray
        try {
            if ($UseTimestamp) {
                Write-Host "Using timestamp server: $timestampServer" -ForegroundColor Gray
                $signature = Set-AuthenticodeSignature -FilePath $localScriptPath -Certificate $signingCert -TimestampServer $timestampServer -ErrorAction Stop
            }
            else {
                Write-Host "Signing without timestamp..." -ForegroundColor Gray
                $signature = Set-AuthenticodeSignature -FilePath $localScriptPath -Certificate $signingCert -ErrorAction Stop
            }
            
            Write-Host "Signature attempt completed with status: $($signature.Status)" -ForegroundColor Gray
            
            if ($signature.Status -eq "Valid") {
                $success = $true
                Write-Host "Script signed successfully at: $localScriptPath" -ForegroundColor Green
                break
            }
            elseif ($signature.Status -eq "UnknownError") {
                Write-Warning "UnknownError encountered. This may be due to certificate store issues or private key access problems."
                # Try to get more detailed error information
                if ($signature.StatusMessage) {
                    Write-Host "Status Message: $($signature.StatusMessage)" -ForegroundColor Yellow
                }
            }
            else {
                Write-Warning "Signature attempt $i failed with status: $($signature.Status)"
                if ($signature.StatusMessage) {
                    Write-Host "Status Message: $($signature.StatusMessage)" -ForegroundColor Yellow
                }
            }
            
            Start-Sleep -Seconds 1
        }
        catch {
            Write-Warning "Signature attempt $i threw exception: $($_.Exception.Message)"
            Start-Sleep -Seconds 1
        }
    }

    if (-not $success) {
        Write-Host "`nTroubleshooting information:" -ForegroundColor Yellow
        Write-Host "- Certificate Subject: $($signingCert.Subject)" -ForegroundColor Yellow
        Write-Host "- Certificate HasPrivateKey: $($signingCert.HasPrivateKey)" -ForegroundColor Yellow
        Write-Host "- Certificate NotBefore: $($signingCert.NotBefore)" -ForegroundColor Yellow
        Write-Host "- Certificate NotAfter: $($signingCert.NotAfter)" -ForegroundColor Yellow
        Write-Host "- Current User: $($env:USERNAME)" -ForegroundColor Yellow
        Write-Host "- File Path: $localScriptPath" -ForegroundColor Yellow
        Write-Host "- File Exists: $(Test-Path $localScriptPath)" -ForegroundColor Yellow
        
        Write-Error "Failed to sign script. This could be due to corporate security policies, certificate store permissions, or network restrictions."
        exit 1
    }

    if ($localScriptPath -ne $ScriptPath) {
        try {
            Copy-Item -Path $localScriptPath -Destination $ScriptPath -Force -Verbose
            Write-Host "Signed script copied back to: $ScriptPath" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to copy signed script back to original location: $($_.Exception.Message)"
            exit 1
        }
    }
}
catch {
    Write-Error "Failed to sign script: $($_.Exception.Message)"
    exit 1
}

# --- Step 6: Verify the Signature ---
Write-Host "`nVerifying script signature..." -ForegroundColor Cyan
try {
    $signature = Get-AuthenticodeSignature -FilePath $ScriptPath
    Write-Host "Signature Status: $($signature.Status)"
    Write-Host "Signer Certificate: $($signature.SignerCertificate.Subject)"
    Write-Host "Thumbprint: $($signature.SignerCertificate.Thumbprint)"
    if ($signature.Status -ne "Valid") {
        Write-Warning "Signature verification status: $($signature.Status)"
        if ($signature.StatusMessage) {
            Write-Host "Status Message: $($signature.StatusMessage)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Signature verified successfully." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to verify signature: $($_.Exception.Message)"
    exit 1
}

# --- Step 7: Clean Up ---
Write-Host "`nCleaning up temporary files..." -ForegroundColor Cyan
try {
    if ($localScriptPath -ne $ScriptPath -and (Test-Path $localTempDir)) {
        Remove-Item -Path $localTempDir -Recurse -Force
        Write-Host "Temporary directory removed: $localTempDir" -ForegroundColor Green
    }
}
catch {
    Write-Warning "Failed to clean up temporary directory: $($_.Exception.Message)"
}

# --- Step 8: Set Execution Policy (Optional) ---
if ($SetExecutionPolicy) {
    Write-Host "`nSetting execution policy to AllSigned for CurrentUser..." -ForegroundColor Cyan
    try {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy AllSigned -Force
        Write-Host "Execution policy set to AllSigned." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to set execution policy: $($_.Exception.Message). You may need to set it manually."
    }
} else {
    Write-Host "`nNote: Execution policy not changed. Use -SetExecutionPolicy to set to AllSigned." -ForegroundColor Yellow
    Write-Host "To set manually, run: Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy AllSigned -Force" -ForegroundColor Yellow
}

# --- Step 9: Final Instructions ---
Write-Host "`n-------------------------------------------------------------------"
Write-Host "Script signing completed." -ForegroundColor Green
Write-Host "Generated files:"
Write-Host "  - Certificate (.cer): $cerPath"
Write-Host "  - Certificate with private key (.pfx): $pfxPath (Password: Sisulate2025)"
Write-Host "Signed script: $ScriptPath"
Write-Host "To run the script, ensure execution policy is AllSigned and the certificate is trusted."
Write-Host "Test the script with: .\$($ScriptPath | Split-Path -Leaf) -FolderPath <YourConfigFolder>"
Write-Host "-------------------------------------------------------------------"