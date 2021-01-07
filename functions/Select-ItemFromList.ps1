function Select-ItemFromList {
    <#
        .Synopsis
        Offers the possibility to select multible values in a cli based menu list.

        .DESCRIPTION
        Offers the possibility to select multible values in a cli based menu list.
        A filter, cancel, multiselect and empty return option is available.
        The function will return the selected items.

        .PARAMETER ListTitle
        The title of the list.

        .PARAMETER Items
        The items to show in the list.

        .PARAMETER PropertyName
        The name of the property to render in the list.

        .PARAMETER MultiselectOption
        Enables the multiselect option.

        .PARAMETER CancelOption
        Enables the cancel option.

        .PARAMETER FilterOption
        Enables the filter option.

        .PARAMETER AllowEmptyReturn
        Enables the empty return option.

        .INPUTS
        None. You cannot pipe objects to Select-ItemFromList.

        .OUTPUTS
        System.Management.Automation.PSObject[]
        Select-ItemFromList returns the selected items as an object in the following format.

        [PSCustomObject]@{
                Items = $null # Array of the items
                State = $null # %OK% / %CANCEL%
            }

        .EXAMPLE
        # Select an applicaiton to start
        [System.Array]$Applications = @(
            [PSCustomObject]@{Name = 'Notepad'; Path = "$($env:windir)\System32\notepad.exe" },
            [PSCustomObject]@{Name = 'Calc'; Path = "$($env:windir)\System32\calc.exe" },
            [PSCustomObject]@{Name = 'Explorer'; Path = "$($env:windir)\System32\Explorer.exe" }
        )

        [PSCustomObject]$Application = Select-ItemFromList -ListTitle 'Please select an applicaiton to start' -Items $Applications -PropertyName 'Name'
        Start-Process -FilePath $Application.Items.Path

        .EXAMPLE
        # Select multiple processes to get furhter detailes later
        $Processes = Select-ItemFromList -ListTitle "Select process, press 'd' if done" -Items (Get-Process | Select-Object -First 10) -PropertyName 'ProcessName' -MultiselectOption -CancelOption -FilterOption
        if ($Processes.State -eq '%OK%')
        {
            foreach ($Process in $Processes.Items)
            {
                $Process | Select-Object -Property Id, ProcessName
            }
        }

        .LINK
        https://github.com/netcloud/powershell-cli-menu-helpers
    #>
    [OutputType([System.Management.Automation.PSObject[]])]
    Param(
        [System.String]$ListTitle,
        [System.Management.Automation.PSObject[]]$Items,
        [Parameter(Mandatory = $true)]
        [System.String]$PropertyName,
        [System.Management.Automation.SwitchParameter]$MultiselectOption,
        [System.Management.Automation.SwitchParameter]$CancelOption,
        [System.Management.Automation.SwitchParameter]$FilterOption,
        [System.Management.Automation.SwitchParameter]$AllowEmptyReturn = $false
    )
    Begin {
        # Prepare the output object
        [PSCustomObject]$ReturnObj = [PSCustomObject]@{
            Items = $null
            State = $null # %OK% / %CANCEL%
        }

        # Define the possible options
        [System.Array]$Options = @(
            [PSCustomObject]@{display = $MultiselectOption; letter = 'a'; description = 'Select all' },
            [PSCustomObject]@{display = $MultiselectOption; letter = 'u'; description = 'Unselect all' },
            [PSCustomObject]@{display = $FilterOption; letter = 'f'; description = 'Apply filter' },
            [PSCustomObject]@{display = $FilterOption; letter = 'r'; description = 'Reset filter' },
            [PSCustomObject]@{display = ($MultiselectOption -or $AllowEmptyReturn); letter = 'd'; description = 'Done selecting' },
            [PSCustomObject]@{display = $CancelOption; letter = 'c'; description = 'Cancel' }
        )

        # Add internal needed properties to the items
        for ($i = 1; $i -le $Items.Count; $i ++) {
            Add-Member -InputObject $Items[$i - 1] -MemberType NoteProperty -Name '_id' -Value $i -Force
            Add-Member -InputObject $Items[$i - 1] -MemberType NoteProperty -Name '_selected' -Value $false -Force
        }

        # Set filters
        filter Get-SelectedItem {
            if ($_._selected) {
                $_
            }
        }

        filter Get-FilteredItem {
            if ($_.$PropertyName -like "*$Filter*") {
                $_
            }
        }
    }
    Process {
        # Display the list in a loop
        [System.Boolean]$RunMenu = $true
        [System.String]$Filter = ''

        Clear-Host
        Write-Host -Object ''
        Write-Host -Object ''

        while ($RunMenu) {
            # Render the list title
            if ($ListTitle -ne '') {
                Write-Host -Object $ListTitle
            }

            # Display filter if applied
            if ($Filter -ne '') {
                Write-Host -Object "Filter: $Filter"
                Write-Host -Object ''
            }

            # Render the list items
            foreach ($Item in ($Items | Get-FilteredItem)) {
                if ($Item._selected) {
                    Write-Host -Object "$($Item._id)*) $($Item.$PropertyName)" -ForegroundColor Green
                }
                else {
                    Write-Host -Object "$($Item._id)) $($Item.$PropertyName)"
                }
            }

            Write-Host -Object ''
            Write-Host -Object ''

            # Render the list options
            foreach ($Option in $Options) {
                if ($Option.display) {
                    Write-Host -Object "$($Option.letter)" -ForegroundColor Yellow -NoNewline
                    Write-Host -Object ": $($Option.description)"
                }
            }

            Write-Host -Object ''
            Write-Host -Object ''

            # Get user input
            [System.String]$UserInputPrompt = 'Enter selection'
            if ($MultiselectOption) {
                $UserInputPrompt = "Enter selection ($(($Items | Get-SelectedItem | Measure-Object).Count) selections)"
            }

            [System.String]$UserInput = Read-Host -Prompt $UserInputPrompt

            # Process the user input
            switch ($UserInput) {
                # Add filter if option is enabled
                { ($_ -eq 'f') -and ($FilterOption) } {
                    $Filter = Read-Host -Prompt 'Enter filter'
                    Clear-Host
                    Write-Host -Object ''
                    Write-Host -Object ''
                }

                # Reset filter if option is enabled
                { ($_ -eq 'r') -and ($FilterOption) } {
                    $Filter = ''
                    Clear-Host
                    Write-Host -Object ''
                    Write-Host -Object ''
                }

                # Select item in multi select mode / return item in single select mode
                { ($_ -match '^\d+$') -and (($Items | Get-FilteredItem)._id -contains $_) } {
                    # Save the item id
                    $ItemId = $_

                    # Get the item and set selected to true
                    $Item = $Items | Where-Object -FilterScript { $_._id -eq $ItemId }
                    $Item._selected = !$Item._selected

                    # Return the item if single select mode
                    if (!$MultiselectOption) {
                        if (((($Items | Get-SelectedItem).Count -eq 0) -and $AllowEmptyReturn) -or (($Items | Get-SelectedItem).Count -ne 0)) {
                            $ReturnObj.State = '%OK%'
                            return
                        }
                        else {
                            Clear-Host
                            Write-Host -Object "Please select an item!" -ForegroundColor Yellow
                            Write-Host -Object ''
                        }
                    }

                    Clear-Host
                    Write-Host -Object ''
                    Write-Host -Object ''
                }

                # Select all items if multi select is enabled
                { ($_ -eq 'a') -and $MultiselectOption } {
                    foreach ($Item in ($Items | Get-FilteredItem)) {
                        $Item._selected = $true
                    }

                    Clear-Host
                    Write-Host -Object ''
                    Write-Host -Object ''
                }

                # Unselect all items if multi select is enabled
                { ($_ -eq 'u') -and $MultiselectOption } {
                    foreach ($Item in ($Items | Get-FilteredItem)) {
                        $Item._selected = $false
                    }

                    Clear-Host
                    Write-Host -Object ''
                    Write-Host -Object ''
                }

                # Cancel the selection if option is activated
                { ($_ -eq 'c' -and $CancelOption) } {
                    $ReturnObj.State = '%CANCEL%'
                    $RunMenu = $false
                }

                # Return all selected items if multi select mode is activated or empty return is allowed
                { ($_ -eq 'd' -and $MultiselectOption) -or ($_ -eq 'd' -and $AllowEmptyReturn) } {
                    if (((($Items | Get-SelectedItem).Count -eq 0) -and $AllowEmptyReturn) -or (($Items | Get-SelectedItem).Count -ne 0)) {
                        $ReturnObj.State = '%OK%'
                        return
                    }
                    else {
                        Clear-Host
                        Write-Host -Object "Please select at least one item!" -ForegroundColor Yellow
                        Write-Host -Object ''
                    }
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
        # Return the selected items only if run menu equals true
        if ($RunMenu) {
            $ReturnObj.Items = @() + $Items | Get-SelectedItem
        }

        return $ReturnObj
    }
}