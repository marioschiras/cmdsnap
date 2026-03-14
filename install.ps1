# cmdsnap Windows Installer
# Run: irm https://raw.githubusercontent.com/marioschiras/cmdsnap/master/install.ps1 | iex

$ErrorActionPreference = "Stop"

$installDir = "$env:USERPROFILE\.cmdsnap"
$scriptUrl = "https://raw.githubusercontent.com/marioschiras/cmdsnap/master/integrations/cmdsnap.ps1"

Write-Host "Installing cmdsnap..." -ForegroundColor Cyan

# Create install directory
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# Download the script
Write-Host "Downloading cmdsnap.ps1..."
Invoke-WebRequest -Uri $scriptUrl -OutFile "$installDir\cmdsnap.ps1"

# Get or create PowerShell profile
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Check if already installed
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
$sourceLine = ". `"$installDir\cmdsnap.ps1`""

if ($profileContent -notmatch [regex]::Escape($sourceLine)) {
    Write-Host "Adding cmdsnap to PowerShell profile..."
    Add-Content -Path $PROFILE -Value "`n# cmdsnap - terminal command capture`n$sourceLine"
} else {
    Write-Host "cmdsnap already in profile, skipping..."
}

Write-Host ""
Write-Host "✓ cmdsnap installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "To start using cmdsnap, either:" -ForegroundColor Yellow
Write-Host "  1. Restart PowerShell"
Write-Host "  2. Run: . `$PROFILE"
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  cmdsnap        # Copy last command"
Write-Host "  cmdsnap 3      # Copy last 3 commands"
Write-Host "  cmdsnap list   # Show recent commands"
Write-Host "  cmdsnap @2     # Copy command #2 from list"
