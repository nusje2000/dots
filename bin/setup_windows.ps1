#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Installs development tools on Windows using winget.
.DESCRIPTION
    Installs Claude Code, Python 3, Node.js (with npm), FFmpeg, ImageMagick, and wget.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n=> $Message" -ForegroundColor Cyan
}

function Install-WingetPackage {
    param(
        [string]$Id,
        [string]$Name
    )

    $installed = winget list --id $Id 2>$null | Select-String $Id
    if ($installed) {
        Write-Host "  $Name is already installed, skipping." -ForegroundColor Yellow
    } else {
        Write-Host "  Installing $Name..."
        winget install --id $Id --accept-source-agreements --accept-package-agreements --silent --disable-interactivity
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Failed to install $Name." -ForegroundColor Red
            return $false
        }
        Write-Host "  $Name installed." -ForegroundColor Green
    }
    return $true
}

# Verify winget is available (ships with Windows 11)
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Error: winget not found. Update 'App Installer' from the Microsoft Store and retry." -ForegroundColor Red
    exit 1
}

Write-Step "Installing Node.js & npm"
Install-WingetPackage -Id "OpenJS.NodeJS.LTS" -Name "Node.js LTS"

Write-Step "Installing Claude Code"
$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npmCmd) {
    # Refresh PATH to pick up newly installed Node.js
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    $npmCmd = Get-Command npm -ErrorAction SilentlyContinue
}
if ($npmCmd) {
    Write-Host "  Installing Claude Code via npm..."
    npm install -g @anthropic-ai/claude-code
} else {
    Write-Host "  npm not found, cannot install Claude Code. Install Node.js first and re-run." -ForegroundColor Red
}

Write-Step "Installing Python 3"
Install-WingetPackage -Id "Python.Python.3.12" -Name "Python 3.12"

Write-Step "Installing FFmpeg"
Install-WingetPackage -Id "Gyan.FFmpeg" -Name "FFmpeg"

Write-Step "Installing ImageMagick"
Install-WingetPackage -Id "ImageMagick.ImageMagick" -Name "ImageMagick"

Write-Step "Installing wget"
Install-WingetPackage -Id "JernejSimoncic.Wget" -Name "wget"

Write-Host "`nAll done! You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Green
