#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# Load the config.json
$Config = Get-Content -Path '.\config.json' | ConvertFrom-Json

# Check if build is available
if (-not (Test-Path -Path ('.\build\' + $Config.ModuleName))) {
    Write-Error -Message "Build '$('.\build\' + $Config.ModuleName)' is not available!"
}

# Get the api key
[System.String]$NuGetApiKey = Read-Host -Prompt 'Please enter the NuGetApiKey'

# Publish the build to PSGallery
Publish-Module -Path ('.\build\' + $Config.ModuleName) `
    -Repository 'PSGallery' `
    -NuGetApiKey $NuGetApiKey -Verbose