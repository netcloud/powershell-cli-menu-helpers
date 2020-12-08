#PowerShell.exe -noninteractive {Invoke-Pester -Show All}
BeforeAll -Scriptblock {
    # Get the function file path and function name
    [System.String]$FunctionFilePath = '.\functions\' + (Split-Path -Path $PSCommandPath.Replace('.Tests.ps1', '.ps1') -Leaf)
    [System.String]$FunctionName = (Get-Item -Path $FunctionFilePath).BaseName

    # Load the function
    . $FunctionFilePath

    # Set value to test with
    [System.String]$MenuTitle = 'Test list title'
    [System.String[]]$MenuEntries = @('Item 1', 'Item 2', 'Item 3')
}

Describe -Name "Test input parameters" {
    Context -Name " Check MenuTitle input parameter" {
        It -Name " MenuTitle ParameterType should be String" {
            (Get-Command -Name $FunctionName).Parameters.MenuTitle.ParameterType.Name | Should -BeExactly -ExpectedValue 'String'
        }

        It -Name " Items IsMandatory should be true" {
            (Get-Command -Name $FunctionName).Parameters.MenuTitle.ParameterSets.__AllParameterSets.IsMandatory | Should -Be $false
        }
    }

    Context -Name " Check MenuEntries input parameter" {
        It " MenuEntries ParameterType should be String[]" {
            (Get-Command -Name $FunctionName).Parameters.MenuEntries.ParameterType.Name | Should -BeExactly -ExpectedValue 'String[]'
        }

        It -Name " MenuEntries IsMandatory should be false" {
            (Get-Command -Name $FunctionName).Parameters.MenuEntries.ParameterSets.__AllParameterSets.IsMandatory | Should -Be -ExpectedValue $false
        }
    }

    Context -Name " Check BackOption input parameter" {
        It -Name " BackOption ParameterType should be SwitchParameter" {
            (Get-Command -Name $FunctionName).Parameters.BackOption.ParameterType.Name | Should -BeExactly -ExpectedValue 'SwitchParameter'
        }
    }

    Context -Name " Check ExitOption input parameter" {
        It -Name " ExitOption ParameterType should be SwitchParameter" {
            (Get-Command -Name $FunctionName).Parameters.ExitOption.ParameterType.Name | Should -BeExactly -ExpectedValue 'SwitchParameter'
        }
    }
}

Describe -Name "Test if MenuTitle and MenuEntries were displayed and returned" {
    BeforeAll -Scriptblock {
        $global:counter = 0
        Mock -CommandName Read-Host -MockWith {
            $global:counter ++
            switch ($global:counter) {
                1 {
                    return 10
                }

                2 {
                    return 'e'
                }

                3 {
                    return 'b'
                }

                default {
                    return 2
                }
            }
        }

        Mock -CommandName Write-Host -MockWith {}
        Mock -CommandName Clear-Host -MockWith {}
        $result = Select-MenuEntryFromList -MenuTitle $MenuTitle -MenuEntries $MenuEntries
    }

    It -Name " List menu title should be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq $MenuTitle }
    }

    It -Name " ExitOption should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq 'e: Exit' }
    }

    It -Name " BackOption should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq 'b: Back' }
    }

    It -Name " Invalid input should be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input '10' is not valid!" }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input 'e' is not valid!" }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input 'b' is not valid!" }
    }

    It -Name " Menu entries should be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq '1) Item 1' }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq '2) Item 2' }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq '3) Item 3' }
    }

    It -Name " Return status should be %OK%" {
        $result.State | Should -Be -ExpectedValue '%OK%'
    }

    It -Name " Return MenuEntry should be item 2" {
        $result.MenuEntry | Should -Be -ExpectedValue 'Item 2'
    }
}
Describe -Name "Test the select menu entry from list functions with BackOption, no MenuTitle and no MenuEntries" {
    BeforeAll -Scriptblock {
        $global:counter = 0
        Mock -CommandName Read-Host -MockWith {
            $global:counter ++
            switch ($global:counter) {
                1 {
                    return 'e'
                }

                2 {
                    return 1
                }

                default {
                    return 'b'
                }
            }
        }

        Mock -CommandName Write-Host -MockWith {}
        Mock -CommandName Clear-Host -MockWith {}
        $result = Select-MenuEntryFromList -BackOption
    }

    It -Name " List menu title should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq $MenuTitle }
    }

    It -Name " ExitOption should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq 'e' }
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq ': Exit' }
    }

    It -Name " BackOption should be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq 'b' }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq ': Back' }
    }

    It -Name " Invalid input should be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input 'e' is not valid!" }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input '1' is not valid!" }
    }

    It -Name " Return status should be %BACK%" {
        $result.State | Should -Be -ExpectedValue '%BACK%'
    }

    It -Name " Return MenuEntry should be null" {
        $result.MenuEntry | Should -Be -ExpectedValue $null
    }
}

Describe -Name "Test the select menu entry from list functions with ExitOption, no MenuTitle and no MenuEntries" {
    BeforeAll -Scriptblock {
        $global:counter = 0
        Mock -CommandName Read-Host -MockWith {
            $global:counter ++
            switch ($global:counter) {
                1 {
                    return 'b'
                }

                2 {
                    return 1
                }

                default {
                    return 'e'
                }
            }
        }

        Mock -CommandName Write-Host -MockWith {}
        Mock -CommandName Clear-Host -MockWith {}
        $result = Select-MenuEntryFromList -ExitOption
    }

    It -Name " List menu title should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq $MenuTitle }
    }

    It -Name " ExitOption should be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq 'e' }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq ': Exit' }
    }

    It -Name " BackOption should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq 'b' }
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq ': Back' }
    }

    It -Name " Invalid input should be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input 'b' is not valid!" }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input '1' is not valid!" }
    }

    It -Name " Return status should be %EXIT%" {
        $result.State | Should -Be -ExpectedValue '%EXIT%'
    }

    It -Name " Return MenuEntry should be null" {
        $result.MenuEntry | Should -Be -ExpectedValue $null
    }
}