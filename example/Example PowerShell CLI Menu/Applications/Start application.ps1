# Set the applications to choose from
[System.Array]$Applications = @(
    [PSCustomObject]@{Name = 'Notepad'; Path = "$($env:windir)\System32\notepad.exe" },
    [PSCustomObject]@{Name = 'Calc'; Path = "$($env:windir)\System32\calc.exe" },
    [PSCustomObject]@{Name = 'Explorer'; Path = "$($env:windir)\System32\Explorer.exe" },
    [PSCustomObject]@{Name = 'MSTSC'; Path = "$($env:windir)\System32\mstsc.exe" },
    [PSCustomObject]@{Name = 'PowerShell'; Path = "$($env:windir)\System32\WindowsPowerShell\v1.0\powershell.exe" }
)

# Ask user which application to start
[PSCustomObject]$userSelection = Select-ItemFromList -ListTitle 'Please select an applicaiton to start' -Items $Applications -PropertyName 'Name' -CancelOption

# Start the application if the return state equals '%OK%'
if ($userSelection.State -eq '%OK%') {
    Start-Process -FilePath $userSelection.Items.Path
}