#Requires -Version 5.1
#Requires -Modules @{ ModuleName = 'powershell-cli-menu-helpers'; ModuleVersion = '0.0.1' }

# Set the error action preference, load all for the menu needed vars and helper functions
$ErrorActionPreference = 'Stop'
. '.\vars\menu_vars.ps1'
. '.\vars\user_vars.ps1'

foreach ($Item in (Get-ChildItem -Path ($menu_funciton_dir + '\*.ps1'))) {
    . $Item.FullName
}

# Set a menu location var for navigation
[System.String]$current_menu_location = $menu_menu_dir

# Run the menu inside a while loop until exit
while ($true) {
    # Get all directories from the current menu location
    $Items = @()
    $Items += Get-ChildItem -Path $current_menu_location -Directory

    # Get all powershell scripts from the current menu location
    $Items += Get-ChildItem -Path "$current_menu_location\*.ps1"

    # Get the name of the folders and scripts
    # The names will be used to display inside the menu
    [System.String[]]$MenuEntries = $Items.Name | Sort-Object

    # Get the title of the menu based on the name of the current folder
    [System.String]$MenuTitle = "=============== $(Split-Path -Path $current_menu_location -Leaf) ==============="

    # Show the menu and wait for the user selection
    if ($current_menu_location -eq $menu_menu_dir) {
        # Show the exit option inside the menu because the current location equals the menu root
        $SelectedMenuEntry = Select-MenuEntryFromList -MenuTitle $MenuTitle -MenuEntries $MenuEntries -ExitOption 
    }
    else {
        # Show the back option because the current location does not equals to the menu root
        $SelectedMenuEntry = Select-MenuEntryFromList -MenuTitle $MenuTitle -MenuEntries $MenuEntries -BackOption
    }

    # Process the user selection
    switch ($SelectedMenuEntry.State) {
        # Navigate to the next folder or execute the script
        '%OK%' {
            # Get the selected item
            $SelectedItem = $Items | Where-Object -FilterScript { $_.Name -eq $SelectedMenuEntry.MenuEntry }

            # Navigate to the next folder
            if ($SelectedItem.PSIsContainer) {
                $current_menu_location = $SelectedItem.FullName
            }
            # Execute the powershell script
            else {
                Clear-Host
                try {
                    . $SelectedItem.FullName
                }
                catch {
                    Write-Error -Message "Error occured in script '$($SelectedItem.FullName)'`r`n$($_ | Out-String)"
                    Write-Host -Object ' '
                    Write-Host -Object ' '
                    Read-Host -Prompt 'Press any key to return to the menu'
                }

                # Return to the menu
                Clear-Host
            }
        }

        # Navigate back
        '%BACK%' {
            $current_menu_location = (Split-Path -Path $current_menu_location -Parent)
        }

        # End script
        '%EXIT%' {
            $current_menu_location = (Split-Path -Path $menu_menu_dir -Parent)
            return
        }

        # Throw an error if the state is not defined
        default {
            throw ("State '$_' is not defined!")
        }
    }
}