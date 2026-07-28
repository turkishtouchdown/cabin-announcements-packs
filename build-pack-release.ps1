<#
.SYNOPSIS
  Builds a release ZIP for an airline sound pack and prints catalog.json fields.

.EXAMPLE
  .\build-pack-release.ps1 -PackId RYR -Version 1.0.0 -SourceDirectory "..\..\sounds\RYR"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PackId,

    [Parameter(Mandatory = $true)]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [string]$SourceDirectory
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourceDirectory)) {
    throw "Source directory not found: $SourceDirectory"
}

$audio = Get-ChildItem -LiteralPath $SourceDirectory -File |
    Where-Object { $_.Extension -in '.wav', '.mp3', '.ogg' }
if (-not $audio) {
    throw "No audio files found in $SourceDirectory"
}

$staging = Join-Path ([System.IO.Path]::GetTempPath()) ("cabin-pack-" + [Guid]::NewGuid().ToString('N'))
$packRoot = Join-Path $staging $PackId
New-Item -ItemType Directory -Path $packRoot -Force | Out-Null

Copy-Item -LiteralPath (Join-Path $SourceDirectory '*') -Destination $packRoot -Recurse -Force

$zipName = "$PackId-$Version.zip"
$zipPath = Join-Path (Get-Location) $zipName
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -LiteralPath $packRoot -DestinationPath $zipPath

$sizeBytes = (Get-Item $zipPath).Length
$hash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host ""
Write-Host "Pack archive ready:" -ForegroundColor Green
Write-Host "  $zipPath"
Write-Host "  Size: $sizeBytes bytes"
Write-Host "  SHA256: $hash"
Write-Host ""
Write-Host "Add this entry to catalog.json after uploading the ZIP to GitHub Releases:" -ForegroundColor Cyan
Write-Host @"
{
  "id": "$PackId",
  "icao": "$PackId",
  "name": "$PackId",
  "version": "$Version",
  "description": "Replace with airline name/description.",
  "downloadUrl": "https://github.com/YOUR_GITHUB_USERNAME/cabin-announcements-packs/releases/download/$PackId-$Version/$zipName",
  "sizeBytes": $sizeBytes,
  "sha256": "$hash",
  "iconUrl": null,
  "minAppVersion": "1.0.0"
}
"@

Remove-Item -LiteralPath $staging -Recurse -Force
