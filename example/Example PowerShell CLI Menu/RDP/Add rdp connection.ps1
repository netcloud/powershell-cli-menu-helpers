# Get the input
[System.String]$hostname = Read-Host -Prompt 'Please enter the hostname'
[System.String]$description = Read-Host -Prompt 'Please enter the description'

# Create an object
[PSCustomObject]$connection = [PSCustomObject]@{ Description = $description; Hostname = $hostname; }

# Add the connection to the file
if (Test-Path -Path $user_rdp_connections) {
    [System.Array]$connections = Get-Content -Path $user_rdp_connections | ConvertFrom-Json
    $connections += $connection
    $connections | ConvertTo-Json | Set-Content -Path $user_rdp_connections
}
else {
    $connection | ConvertTo-Json | Out-File -FilePath $user_rdp_connections
}