# Load the rdp connections
if (Test-Path -Path $user_rdp_connections) {
    [System.Array]$connections = Get-Content -Path $user_rdp_connections | ConvertFrom-Json
}
else {
    [System.Array]$connections = @()
}

# Get the rdp connections to remove
$userSelection = Select-ItemFromTable -TableTitle "Select the rdp connections to remove, press 'd' if done" -Items $connections -PropertyName 'Hostname', 'Description' -MultiselectOption -CancelOption -FilterOption

# Remove selected rdp connections
if ($userSelection.State -eq '%OK%') {
    # Remove selected item form array
    foreach ($item in $userSelection.Items) {
        $connections = $connections | Where-Object -FilterScript { ($_.Description -ne $item.Description) -and ($_.Hostname -ne $item.Hostname) }
    }

    # Remove file if no rdp conneciton is left
    if ($null -eq $connections) {
        Remove-Item -Path $user_rdp_connections
    }
    else {
        $connections | ConvertTo-Json | Set-Content -Path $user_rdp_connections
    }
}