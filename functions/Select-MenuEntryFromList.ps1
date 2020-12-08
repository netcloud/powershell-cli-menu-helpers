function Select-MenuEntryFromList {
    <#
        .Synopsis
        Offers the possibility to render a menu inside the cli and to select one entry.

        .DESCRIPTION
        Offers the possibility to render a menu inside the cli and to select one entry.
        The function will return the selected menu entry.

        .PARAMETER MenuTitle
        The title of the menu.

        .PARAMETER MenuEntries
        The entries to show inside the menu.

        .PARAMETER BackOption
        Enables the back option.

        .PARAMETER ExitOption
        Enables the exit option.

        .INPUTS
        None. You cannot pipe objects to Select-MenuEntryFromList.

        .OUTPUTS
        System.String
        Select-MenuEntryFromList returns the selected menu item as string in the following format.

        [PSCustomObject]@{
            MenuEntry = $null # System.String
            State     = $null # %OK% / %BACK% / %EXIT%
        }

        .EXAMPLE
        # Render a menu with back and exit option

        # Set the menu title and the menu entries
        [System.String[]]$MenuEntries = @('Menu 1', 'Menu 2', 'Menu 3')
        [System.String]$MenuTitle = "=============== Test Menu ==============="

        # Ask user for the menu entry
        [PSCustomObject]$SelectedMenuEntry = Select-MenuEntryFromList -MenuTitle $MenuTitle -MenuEntries $MenuEntries -ExitOption -BackOption

        # Do the action based on the selection
        switch ($SelectedMenuEntry.State)
        {
            '%OK%'
            {
                Write-Host -Object "Selected menu entry: $($SelectedMenuEntry.MenuEntry)"
            }

            '%BACK%'
            {
                Write-Host -Object "Back option selected"
            }

            '%EXIT%'
            {
                Write-Host -Object "Exit option selected"
            }
        }

        .LINK
        https://github.com/netcloudag/powershell-cli-menu-helpers
    #>
    [OutputType([System.Management.Automation.PSObject[]])]
    Param(
        [System.String]$MenuTitle,
        [System.String[]]$MenuEntries,
        [System.Management.Automation.SwitchParameter]$BackOption,
        [System.Management.Automation.SwitchParameter]$ExitOption
    )
    Begin {
        # Prepare the output object
        [PSCustomObject]$ReturnObj = [PSCustomObject]@{
            MenuEntry = $null
            State     = $null # %OK% / %BACK% / %EXIT%
        }

        # Define the possible options
        [System.Array]$Options = @(
            [PSCustomObject]@{display = $BackOption; letter = 'b'; description = 'Back' },
            [PSCustomObject]@{display = $ExitOption; letter = 'e'; description = 'Exit' }
        )
    }
    Process {
        # Display the list in a loop
        [System.Boolean]$RunMenu = $true

        Clear-Host
        Write-Host -Object ''
        Write-Host -Object ''

        while ($RunMenu) {
            # Render the menu title
            if ($MenuTitle -ne '') {
                Write-Host -Object $MenuTitle
            }

            # Render the menu entries
            for ($i = 1; $i -le $MenuEntries.Count; $i ++) {
                Write-Host -Object "$i) $($MenuEntries[$i - 1])"
            }

            Write-Host -Object ''
            Write-Host -Object ''

            # Render the list options
            foreach ($Option in $Options) {
                if ($Option.display) {
                    Write-Host -Object "$($Option.letter)" -NoNewline -ForegroundColor Yellow
                    Write-Host -Object ": $($Option.description)"
                }
            }

            Write-Host -Object ''
            Write-Host -Object ''

            # Get user input
            [System.String]$UserInput = Read-Host -Prompt 'Enter selection'

            # Get all menu entry id's
            [System.Int32[]]$MenuEntryIDs = @()
            if ($MenuEntries.Count -ne 0) {
                $MenuEntryIDs = (1..$MenuEntries.Count)
            }

            # Process the user input
            switch ($UserInput) {
                # Return selected menu entry
                { ($_ -match '^\d+$') -and ($MenuEntryIDs -contains $_) } {
                    # Add the item to the return object
                    $ReturnObj.State = '%OK%'
                    $ReturnObj.MenuEntry = $MenuEntries[$_ - 1]
                    return
                }

                # Return back if the option is activated
                { ($_ -eq 'b' -and $BackOption) } {
                    $ReturnObj.State = '%BACK%'
                    return
                }

                # Return exit if the option is activated
                { ($_ -eq 'e' -and $ExitOption) } {
                    $ReturnObj.State = '%EXIT%'
                    return
                }

                # If user input is not valid
                default {
                    Clear-Host
                    Write-Host -Object "Input '$_' is not valid!" -ForegroundColor Yellow
                    Write-Host -Object ''
                }
            }
        }
    }
    End {
        # Return the object
        return $ReturnObj
    }
}