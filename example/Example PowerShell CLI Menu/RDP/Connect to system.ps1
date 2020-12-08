# Load the rdp connections
if (Test-Path -Path $user_rdp_connections) {
    [System.Array]$connections = Get-Content -Path $user_rdp_connections | ConvertFrom-Json
}
else {
    [System.Array]$connections = @()
}

# Get the rdp connections to connecto to
$userSelection = Select-ItemFromTable -TableTitle 'Select the rdp connection to connect' -Items $connections -PropertyName 'Hostname', 'Description' -CancelOption -FilterOption

# Open the rdp connection
if ($userSelection.State -eq '%OK%') {

    Start-Process -FilePath ($env:windir + '\system32\mstsc.exe') -ArgumentList "/v:$($userSelection.Items.Hostname)"
}