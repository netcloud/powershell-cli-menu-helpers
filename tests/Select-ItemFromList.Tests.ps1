#PowerShell.exe -noninteractive {Invoke-Pester -Show All}
BeforeAll -Scriptblock {
    # Get the function file path and function name
    [System.String]$FunctionFilePath = '.\functions\' + (Split-Path -Path $PSCommandPath.Replace('.Tests.ps1', '.ps1') -Leaf)
    [System.String]$FunctionName = (Get-Item -Path $FunctionFilePath).BaseName

    # Load the function
    . $FunctionFilePath

    # Set value to test with
    [System.String]$ListTitle = 'Test list title'
    [System.String]$PropertyName = 'Name'
    [System.Array]$Items = @(
        [PSCustomObject]@{Name = 'Item 1'; Value = 'Value 1' },
        [PSCustomObject]@{Name = 'Item 2'; Value = 'Value 2' },
        [PSCustomObject]@{Name = 'Item 3'; Value = 'Value 3' }
    )
}

Describe -Name "Test input parameters" {
    Context -Name " When no input parameters were provided" {
        It -Name " Should throw an error because of one or more missing mandatory parameters" {
            $err = { Select-ItemFromList } |  Should -Throw -PassThru
            $err | Should -BeLike -ExpectedValue "Cannot process command because of one or more missing mandatory parameters: *."
        }
    }

    Context -Name " Check ListTitle input parameter" {
        It -Name " ListTitle ParameterType should be String" {
            (Get-Command -Name $FunctionName).Parameters.ListTitle.ParameterType.Name | Should -BeExactly -ExpectedValue 'String'
        }

        It -Name " Items IsMandatory should be true" {
            (Get-Command -Name $FunctionName).Parameters.ListTitle.ParameterSets.__AllParameterSets.IsMandatory | Should -Be $false
        }
    }

    Context -Name " Check Items input parameter" {
        It " Items ParameterType should be PSObject[]" {
            (Get-Command -Name $FunctionName).Parameters.Items.ParameterType.Name | Should -BeExactly -ExpectedValue 'PSObject[]'
        }

        It -Name " Items IsMandatory should be false" {
            (Get-Command -Name $FunctionName).Parameters.Items.ParameterSets.__AllParameterSets.IsMandatory | Should -Be -ExpectedValue $false
        }
    }

    Context -Name " Check PropertyName input parameter" {
        It -Name " PropertyName ParameterType should be String" {
            (Get-Command -Name $FunctionName).Parameters.PropertyName.ParameterType.Name | Should -BeExactly -ExpectedValue 'String'
        }

        It -Name " PropertyName IsMandatory should be true" {
            (Get-Command -Name $FunctionName).Parameters.PropertyName.ParameterSets.__AllParameterSets.IsMandatory | Should -Be -ExpectedValue $true
        }
    }

    Context -Name " Check MultiselectOption input parameter" {
        It -Name " MultiselectOption ParameterType should be SwitchParameter" {
            (Get-Command -Name $FunctionName).Parameters.MultiselectOption.ParameterType.Name | Should -BeExactly -ExpectedValue 'SwitchParameter'
        }
    }

    Context -Name " Check CancelOption input parameter" {
        It -Name " CancelOption ParameterType should be SwitchParameter" {
            (Get-Command -Name $FunctionName).Parameters.CancelOption.ParameterType.Name | Should -BeExactly -ExpectedValue 'SwitchParameter'
        }
    }

    Context -Name " Check FilterOption input parameter" {
        It -Name " FilterOption ParameterType should be SwitchParameter" {
            (Get-Command -Name $FunctionName).Parameters.FilterOption.ParameterType.Name | Should -BeExactly -ExpectedValue 'SwitchParameter'
        }
    }

    Context -Name " Check AllowEmptyReturn input parameter" {
        It -Name " AllowEmptyReturn ParameterType should be SwitchParameter" {
            (Get-Command -Name $FunctionName).Parameters.AllowEmptyReturn.ParameterType.Name | Should -BeExactly -ExpectedValue 'SwitchParameter'
        }
    }

    Context -Name " When no option is enabled" {
        BeforeAll -Scriptblock {
            $global:counter = 0
            Mock -CommandName Read-Host -MockWith {
                $global:counter ++
                switch ($global:counter) {
                    1 {
                        return 'a'
                    }

                    2 {
                        return 'u'
                    }

                    3 {
                        return 'f'
                    }

                    4 {
                        return 'r'
                    }

                    5 {
                        return 'd'
                    }

                    6 {
                        return 'c'
                    }

                    default {
                        return 1
                    }
                }
            }

            Mock -CommandName Write-Host -MockWith {}
            Mock -CommandName Clear-Host -MockWith {}
            $result = Select-ItemFromList -ListTitle $ListTitle -Items $Items -PropertyName $PropertyName
        }

        It -Name " Select all should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'a' is not valid!" }
        }

        It -Name " Select all should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'a' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Select all' }
        }

        It -Name " Unselect all should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'u' is not valid!" }
        }

        It -Name " Unselect all should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'u' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Unselect all' }
        }

        It -Name " Apply filter should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'f' is not valid!" }
        }

        It -Name " Apply filter should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'f' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Apply filter' }
        }

        It -Name " Reset filter should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'r' is not valid!" }
        }

        It -Name " Reset filter should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'r' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Reset filter' }
        }

        It -Name " Done selecting should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'd' is not valid!" }
        }

        It -Name " Done selecting should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'd' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Done selecting' }
        }

        It -Name " Cancel should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'c' is not valid!" }
        }

        It -Name " Cancel should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'c' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Cancel' }
        }
    }

    Context -Name " When MultiselectOption is enabled and AllowEmptyReturn disabled" {
        BeforeAll -Scriptblock {
            $global:counter = 0
            Mock -CommandName Read-Host -MockWith {
                $global:counter ++
                switch ($global:counter) {
                    1 {
                        return 'a'
                    }

                    2 {
                        return 'u'
                    }

                    3 {
                        return 'f'
                    }

                    4 {
                        return 'r'
                    }

                    5 {
                        return 'c'
                    }

                    6 {
                        return 'd'
                    }

                    7 {
                        return 'a'
                    }

                    default {
                        return 'd'
                    }
                }
            }

            Mock -CommandName Write-Host -MockWith {}
            Mock -CommandName Clear-Host -MockWith {}
            $result = Select-ItemFromList -ListTitle $ListTitle -Items $Items -PropertyName $PropertyName -MultiselectOption
        }

        It -Name " Select all should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq "Input 'a' is not valid!" }
        }

        It -Name " Select all should be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'a' }
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq ': Select all' }
        }

        It -Name " Unselect all should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq "Input 'u' is not valid!" }
        }

        It -Name " Unselect all should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'u' }
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq ': Unselect all' }
        }

        It -Name " Apply filter should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'f' is not valid!" }
        }

        It -Name " Apply filter should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'f' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Apply filter' }
        }

        It -Name " Reset filter should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'r' is not valid!" }
        }

        It -Name " Reset filter should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'r' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Reset filter' }
        }

        It -Name " Done selecting should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq "Input 'd' is not valid!" }
        }

        It -Name " Done selecting should be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'd' }
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq ': Done selecting' }
        }

        It -Name " Cancel should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'c' is not valid!" }
        }

        It -Name " Cancel should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'c' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Cancel' }
        }

        It -Name " Done selecting with no selected item should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'Please select at least one item!' }
        }
    }

    Context -Name " When MultiselectOption and AllowEmptyReturn is enabled" {
        BeforeAll -Scriptblock {
            $global:counter = 0
            Mock -CommandName Read-Host -MockWith {
                $global:counter ++
                switch ($global:counter) {
                    1 {
                        return 'a'
                    }

                    2 {
                        return 'u'
                    }

                    3 {
                        return 'f'
                    }

                    4 {
                        return 'r'
                    }

                    5 {
                        return 'c'
                    }

                    default {
                        return 'd'
                    }
                }
            }

            Mock -CommandName Write-Host -MockWith {}
            Mock -CommandName Clear-Host -MockWith {}
            $result = Select-ItemFromList -ListTitle $ListTitle -Items $Items -PropertyName $PropertyName -MultiselectOption -AllowEmptyReturn
        }

        It -Name " Select all should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq "Input 'a' is not valid!" }
        }

        It -Name " Select all should be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'a' }
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq ': Select all' }
        }

        It -Name " Unselect all should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq "Input 'u' is not valid!" }
        }

        It -Name " Unselect all should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'u' }
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq ': Unselect all' }
        }

        It -Name " Apply filter should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'f' is not valid!" }
        }

        It -Name " Apply filter should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'f' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Apply filter' }
        }

        It -Name " Reset filter should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'r' is not valid!" }
        }

        It -Name " Reset filter should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'r' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Reset filter' }
        }

        It -Name " Done selecting should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq "Input 'd' is not valid!" }
        }

        It -Name " Done selecting should be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'd' }
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq ': Done selecting' }
        }

        It -Name " Cancel should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'c' is not valid!" }
        }

        It -Name " Cancel should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'c' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Cancel' }
        }

        It -Name " Done selecting with no selected item should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'Please select at least one item!' }
        }
    }

    Context -Name " When CancelOption is enabled" {
        BeforeAll -Scriptblock {
            $global:counter = 0
            Mock -CommandName Read-Host -MockWith {
                $global:counter ++
                switch ($global:counter) {
                    1 {
                        return 'a'
                    }

                    2 {
                        return 'u'
                    }

                    3 {
                        return 'f'
                    }

                    4 {
                        return 'r'
                    }

                    5 {
                        return 'd'
                    }

                    default {
                        return 'c'
                    }
                }
            }

            Mock -CommandName Write-Host -MockWith {}
            Mock -CommandName Clear-Host -MockWith {}
            $result = Select-ItemFromList -ListTitle $ListTitle -Items $Items -PropertyName $PropertyName -CancelOption
        }

        It -Name " Select all should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'a' is not valid!" }
        }

        It -Name " Select all should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'a' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Select all' }
        }

        It -Name " Unselect all should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'u' is not valid!" }
        }

        It -Name " Unselect all should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'u' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Unselect all' }
        }

        It -Name " Apply filter should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'f' is not valid!" }
        }

        It -Name " Apply filter should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'f' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Apply filter' }
        }

        It -Name " Reset filter should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'r' is not valid!" }
        }

        It -Name " Reset filter should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'r' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Reset filter' }
        }

        It -Name " Done selecting should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'd' is not valid!" }
        }

        It -Name " Done selecting should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'd' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Done selecting' }
        }

        It -Name " Cancel should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq "Input 'c' is not valid!" }
        }

        It -Name " Cancel should be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'c' }
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq ': Cancel' }
        }
    }

    Context -Name " When FilterOption is enabled" {
        BeforeAll -Scriptblock {
            $global:counter = 0
            Mock -CommandName Read-Host -MockWith {
                $global:counter ++
                switch ($global:counter) {
                    1 {
                        return 'a'
                    }

                    2 {
                        return 'u'
                    }

                    3 {
                        return 'f'
                    }

                    4 {
                        return 'Item 1'
                    }

                    5 {
                        return 'r'
                    }

                    6 {
                        return 'd'
                    }

                    7 {
                        return 'c'
                    }

                    default {
                        return 1
                    }
                }
            }

            Mock -CommandName Write-Host -MockWith {}
            Mock -CommandName Clear-Host -MockWith {}
            $result = Select-ItemFromList -ListTitle $ListTitle -Items $Items -PropertyName $PropertyName -FilterOption
        }

        It -Name " Select all should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'a' is not valid!" }
        }

        It -Name " Select all should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'a' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Select all' }
        }

        It -Name " Unselect all should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'u' is not valid!" }
        }

        It -Name " Unselect all should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'u' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Unselect all' }
        }

        It -Name " Apply filter should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq "Input 'f' is not valid!" }
        }

        It -Name " Apply filter should be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'f' }
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq ': Apply filter' }
        }

        It -Name " Reset filter should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq "Input 'r' is not valid!" }
        }

        It -Name " Reset filter should be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'r' }
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq ': Reset filter' }
        }

        It -Name " Applyed filter should be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'Filter: Item 1' }
        }

        It -Name " Done selecting should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'd' is not valid!" }
        }

        It -Name " Done selecting should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'd' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Done selecting' }
        }

        It -Name " Cancel should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'c' is not valid!" }
        }

        It -Name " Cancel should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'c' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Cancel' }
        }
    }

    Context -Name " When AllowEmptyReturn is enabled" {
        BeforeAll -Scriptblock {
            $global:counter = 0
            Mock -CommandName Read-Host -MockWith {
                $global:counter ++
                switch ($global:counter) {
                    1 {
                        return 'a'
                    }

                    2 {
                        return 'u'
                    }

                    3 {
                        return 'f'
                    }

                    4 {
                        return 'r'
                    }

                    5 {
                        return 'c'
                    }

                    default {
                        return 'd'
                    }
                }
            }

            Mock -CommandName Write-Host -MockWith {}
            Mock -CommandName Clear-Host -MockWith {}
            $result = Select-ItemFromList -ListTitle $ListTitle -Items $Items -PropertyName $PropertyName -AllowEmptyReturn
        }

        It -Name " Select all should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'a' is not valid!" }
        }

        It -Name " Select all should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'a' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Select all' }
        }

        It -Name " Unselect all should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'u' is not valid!" }
        }

        It -Name " Unselect all should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'u' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Unselect all' }
        }

        It -Name " Apply filter should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'f' is not valid!" }
        }

        It -Name " Apply filter should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'f' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Apply filter' }
        }

        It -Name " Reset filter should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'r' is not valid!" }
        }

        It -Name " Reset filter should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'r' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Reset filter' }
        }

        It -Name " Done selecting should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq "Input 'd' is not valid!" }
        }

        It -Name " Done selecting should be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq 'd' }
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq ': Done selecting' }
        }

        It -Name " Cancel should not be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Context -ParameterFilter { $Object -eq "Input 'c' is not valid!" }
        }

        It -Name " Cancel should not be displayed" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'c' }
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq ': Cancel' }
        }

        It -Name " Done selecting with no selected item should be possible" {
            Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Context -ParameterFilter { $Object -eq 'Please select at least one item!' }
        }
    }
}

Describe -Name "Test the select item from list functions with only mandatory options and one selected item" {
    BeforeAll -Scriptblock {
        $global:counter = 0
        Mock -CommandName Read-Host -MockWith {
            $global:counter ++
            switch ($global:counter) {
                1 {
                    return 'a'
                }

                2 {
                    return 'u'
                }

                3 {
                    return 'f'
                }

                4 {
                    return 'r'
                }

                5 {
                    return 'd'
                }

                6 {
                    return 'c'
                }

                default {
                    return 1
                }
            }
        }

        Mock -CommandName Write-Host -MockWith {}
        Mock -CommandName Clear-Host -MockWith {}
        $result = Select-ItemFromList -Items $Items -PropertyName $PropertyName
    }

    It -Name " List title should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq $ListTitle }
    }

    It -Name " Items should be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq '1) Item 1' }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq '2) Item 2' }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq '3) Item 3' }
    }

    It -Name " Return status should be %OK%" {
        $result.State | Should -Be -ExpectedValue '%OK%'
    }

    It -Name " Return item count should be 1" {
        ($result.Items | Measure-Object).Count | Should -Be -ExpectedValue 1
    }

    It -Name " Return item should be item 1" {
        $result.Items.Name | Should -Be -ExpectedValue 'Item 1'
        $result.Items.Value | Should -Be -ExpectedValue 'Value 1'
    }

    It -Name " Select all should not be possible" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input 'a' is not valid!" }
    }

    It -Name " Select all should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq 'a' }
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq ': Select all' }
    }

    It -Name " Unselect all should not be possible" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input 'u' is not valid!" }
    }

    It -Name " Unselect all should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq 'u' }
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq ': Unselect all' }
    }

    It -Name " Apply filter should not be possible" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input 'f' is not valid!" }
    }

    It -Name " Apply filter should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq 'f' }
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq ': Apply filter' }
    }

    It -Name " Reset filter should not be possible" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input 'r' is not valid!" }
    }

    It -Name " Reset filter should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq 'r' }
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq ': Reset filter' }
    }

    It -Name " Done selecting should not be possible" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input 'd' is not valid!" }
    }

    It -Name " Done selecting should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq 'd' }
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq ': Done selecting' }
    }

    It -Name " Cancel should not be possible" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq "Input 'c' is not valid!" }
    }

    It -Name " Cancel should not be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq 'c' }
        Assert-MockCalled -CommandName Write-Host -Times 0 -Scope Describe -ParameterFilter { $Object -eq ': Cancel' }
    }
}

Describe -Name "Test the select item from list functions with title, multiselect, filter and two selected items" {
    BeforeAll -Scriptblock {
        $global:counter = 0
        Mock -CommandName Read-Host -MockWith {
            $global:counter ++
            switch ($global:counter) {

                1 {
                    return 'f'
                }

                2 {
                    return 'Item 1'
                }

                3 {
                    return 'a'
                }

                4 {
                    return 'r'
                }

                5 {
                    return 2
                }

                default {
                    return 'd'
                }
            }
        }

        Mock -CommandName Write-Host -MockWith {}
        Mock -CommandName Clear-Host -MockWith {}
        $result = Select-ItemFromList -ListTitle $ListTitle -Items $Items -PropertyName $PropertyName -MultiselectOption -FilterOption
    }

    It -Name " List title should be displayed" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq $ListTitle }
    }

    It -Name " Input promt should show 'Enter selection (0 selections)'" {
        Assert-MockCalled -CommandName Read-Host -Times 1 -Scope Describe -ParameterFilter { $Prompt -eq 'Enter selection (0 selections)' }
    }

    It -Name " Input promt should show 'Enter selection (1 selections)'" {
        Assert-MockCalled -CommandName Read-Host -Times 1 -Scope Describe -ParameterFilter { $Prompt -eq 'Enter selection (1 selections)' }
    }

    It -Name " Selected Items should be displayed with a *" {
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq '1*) Item 1' }
        Assert-MockCalled -CommandName Write-Host -Times 1 -Scope Describe -ParameterFilter { $Object -eq '2*) Item 2' }
    }

    It -Name " Return status should be %OK%" {
        $result.State | Should -Be -ExpectedValue '%OK%'
    }

    It -Name " Return item count should be 2" {
        ($result.Items | Measure-Object).Count | Should -Be -ExpectedValue 2
    }

    It -Name " Return item 1 should be item 1" {
        $result.Items[0].Name | Should -Be -ExpectedValue 'Item 1'
        $result.Items[0].Value | Should -Be -ExpectedValue 'Value 1'
    }

    It -Name " Return item 2 should be item 2" {
        $result.Items[1].Name | Should -Be -ExpectedValue 'Item 2'
        $result.Items[1].Value | Should -Be -ExpectedValue 'Value 2'
    }
}

Describe -Name "Test the select item from list functions with CancelOption" {
    BeforeAll -Scriptblock {
        $global:counter = 0
        Mock -CommandName Read-Host -MockWith {
            $global:counter ++
            switch ($global:counter) {
                default {
                    return 'c'
                }
            }
        }

        Mock -CommandName Write-Host -MockWith {}
        Mock -CommandName Clear-Host -MockWith {}
        $result = Select-ItemFromList -Items $Items -PropertyName $PropertyName -CancelOption
    }

    It -Name " Return status should be %CANCEL%" {
        $result.State | Should -Be -ExpectedValue '%CANCEL%'
    }

    It -Name " Return item count should be 0" {
        ($result.Items | Measure-Object).Count | Should -Be -ExpectedValue 0
    }
}

Describe -Name "Test the select item from list functions with AllowEmptyReturn" {
    BeforeAll -Scriptblock {
        $global:counter = 0
        Mock -CommandName Read-Host -MockWith {
            $global:counter ++
            switch ($global:counter) {
                default {
                    return 'd'
                }
            }
        }

        Mock -CommandName Write-Host -MockWith {}
        Mock -CommandName Clear-Host -MockWith {}
        $result = Select-ItemFromList -Items $Items -PropertyName $PropertyName -AllowEmptyReturn
    }

    It -Name " Return status should be %OK%" {
        $result.State | Should -Be -ExpectedValue '%OK%'
    }

    It -Name " Return item count should be 0" {
        ($result.Items | Measure-Object).Count | Should -Be -ExpectedValue 0
    }
}

Describe -Name "Test the select item from list FilterOption with MultiselectOption" {
    BeforeAll -Scriptblock {
        $global:counter = 0
        Mock -CommandName Read-Host -MockWith {
            $global:counter ++
            switch ($global:counter) {
                1 {
                    return 3
                }

                2 {
                    return 'f'
                }

                3 {
                    return 'Item 3'
                }

                4 {
                    return 'u'
                }


                5 {
                    return 'f'
                }

                6 {
                    return 'Item 2'
                }

                7 {
                    return 2
                }

                default {
                    return 'd'
                }
            }
        }

        Mock -CommandName Write-Host -MockWith {}
        Mock -CommandName Clear-Host -MockWith {}
        $result = Select-ItemFromList -Items $Items -PropertyName $PropertyName -FilterOption -MultiselectOption
    }

    It -Name " Return status should be %OK%" {
        $result.State | Should -Be -ExpectedValue '%OK%'
    }

    It -Name " Return item count should be 1" {
        ($result.Items | Measure-Object).Count | Should -Be -ExpectedValue 1
    }

    It -Name " Return item should be item 2" {
        $result.Items.Name | Should -Be -ExpectedValue 'Item 2'
        $result.Items.Value | Should -Be -ExpectedValue 'Value 2'
    }
}