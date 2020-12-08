#Requires -Version 5.1
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.4' }, @{ ModuleName = 'PSScriptAnalyzer'; ModuleVersion = '1.19.1' }

# Run PSScriptAnalyzer
Start-Process -FilePath ($env:windir + '\System32\WindowsPowerShell\v1.0\powershell.exe') -ArgumentList '-NoExit', '-NonInteractive', "-Command &{Invoke-ScriptAnalyzer -Path '.\functions' -Settings '.\PSScriptAnalyzerSettings.psd1' -Recurse}"

# Run pester tests
Start-Process -FilePath ($env:windir + '\System32\WindowsPowerShell\v1.0\powershell.exe') -ArgumentList '-NoExit', '-NonInteractive', "-Command &{Invoke-Pester -Path '.\tests' -Show All}"