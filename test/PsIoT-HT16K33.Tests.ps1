$ModuleManifestName = 'PsIoT-HT16K33.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Import-Module $ModuleManifestPath
Import-Module Microsoft.PowerShell.IoT

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

Describe "HT16K33 tests" {
    Mock -ModuleName PsIoT-HT16K33 Get-I2CDevice { return [Microsoft.PowerShell.IoT.I2CDevice]::new($null, 112, "LEDMatrix") }
    Mock -ModuleName PsIoT-HT16K33 Set-I2CRegister {}
    Mock -ModuleName PsIoT-HT16K33 Get-I2CRegister {}

    Context "Select default device" {
        Select-Ht16k33Device
        It "Gets the correct device at address 0x70" {
            Assert-MockCalled Get-I2CDevice -Times 1 -ModuleName PsIoT-HT16K33 -ParameterFilter {$Id -eq 0x70}
        }
        It "Initializes internal Oscillator" {
            Assert-MockCalled Get-I2CRegister -Times 1 -ParameterFilter {$Register -eq 0x21} -ModuleName PsIoT-HT16K33
        }
        It "Clears the Display" {
            Assert-MockCalled Set-I2CRegister -Times 8 -ModuleName PsIoT-HT16K33
        }
    }

    Context "Select custom device at address 0x71" {
        Select-Ht16k33Device -DeviceAddress 0x71
        It "Gets the correct device" {
            Assert-MockCalled Get-I2CDevice -Times 1 -ModuleName PsIoT-HT16K33 -ParameterFilter {$Id -eq 0x71}
        }
        It "Initializes internal Oscillator" {
            Assert-MockCalled Get-I2CRegister -Times 1 -ParameterFilter {$Register -eq 0x21} -ModuleName PsIoT-HT16K33
        }
        It "Clears the Display" {
            Assert-MockCalled Set-I2CRegister -Times 8 -ModuleName PsIoT-HT16K33
        }
    }

    Context "Set display power on" {
        Set-Ht16k33Display -Power On
        It "Sets blinkrate off" {
            Assert-MockCalled Get-I2CRegister -Times 1 -ParameterFilter {$Register -eq 0x81} -ModuleName PsIot-HT16K33
        }
        It "Sets brightness to 15" {
            Assert-MockCalled Get-I2CRegister -Times 1 -ParameterFilter {$Register -eq 0xe0 + 15} -ModuleName PsIot-HT16K33
        }
        It "only touches two registers" {
            Assert-MockCalled Get-I2CRegister -Times 2 -Exactly -ModuleName PsIoT-HT16K33
        }
    }

    Context "Set blinkrate off" {
        Set-Ht16k33Display -BlinkRate Off
        It "Sets blinkrate off" {
            Assert-MockCalled Get-I2CRegister -Times 1 -ParameterFilter {$Register -eq 0x81} -ModuleName PsIot-HT16K33
        }
        It "only sets blinkrate" {
            Assert-MockCalled Get-I2CRegister -Times 1 -Exactly -ModuleName PsIot-HT16K33
        }
    }

    Context "Set blinkrate 1Hz" {
        Set-Ht16k33Display -BlinkRate 1Hz
        It "Sets blinkrate 1Hz" {
            Assert-MockCalled Get-I2CRegister -Times 1 -ParameterFilter {$Register -eq 0x85} -ModuleName PsIot-HT16K33
        }
        It "only sets blinkrate" {
            Assert-MockCalled Get-I2CRegister -Times 1 -Exactly -ModuleName PsIot-HT16K33
        }
    }

    Context "Set blinkrate 2Hz" {
        Set-Ht16k33Display -BlinkRate 2Hz
        It "Sets blinkrate 2Hz" {
            Assert-MockCalled Get-I2CRegister -Times 1 -ParameterFilter {$Register -eq 0x87} -ModuleName PsIot-HT16K33
        }
        It "only sets blinkrate" {
            Assert-MockCalled Get-I2CRegister -Times 1 -Exactly -ModuleName PsIot-HT16K33
        }
    }

    Context "Set blinkrate 0.5Hz" {
        Set-Ht16k33Display -BlinkRate 0.5Hz
        It "Sets blinkrate 0.5Hz" {
            Assert-MockCalled Get-I2CRegister -Times 1 -ParameterFilter {$Register -eq 0x83} -ModuleName PsIot-HT16K33
        }
        It "only sets blinkrate" {
            Assert-MockCalled Get-I2CRegister -Times 1 -Exactly -ModuleName PsIot-HT16K33
        }
    }

    foreach ($i in 0..15) {
        Context "Set Brightness to $i" {
            Set-Ht16k33Display -Brightness $i
            It "sets brightness to $i" {
                Assert-MockCalled Get-I2CRegister -Times 1 -ParameterFilter {$Register -eq 0xe0 + $i} -ModuleName PsIot-HT16K33
            }
            It "only sets blinkrate" {
                Assert-MockCalled Get-I2CRegister -Times 1 -Exactly -ModuleName PsIot-HT16K33
            }
        }
    }

    Context "Turn on LEDs by x and y" {
        Mock Get-I2CRegister {
            return [PsCustomObject]@{
                "Data" = 0
            }
        }
        New-Variable -Name "Columns" -Value 0x80, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40
        New-Variable -Name "Rows" -Value 0x0, 0x2, 0x4, 0x6, 0x8, 0xA, 0xC, 0xE

        foreach ($x in 0..7) {
            foreach ($y in 0..7) {
                It "Turns on $x,$y" {
                    Set-Ht16k33LedOn $x $y
                    Assert-MockCalled -Scope It -CommandName Set-I2CRegister -Times 1 -Exactly -ParameterFilter {$Register -eq $Rows[$x] -and $Data -eq $Columns[$y] } -ModuleName PsIot-HT16K33
                }
            }
        }
    }

    Context "Turn on LEDs by Columns sprite" {
        $Pslogo = @( "00100000",
            "00100000",
            "00100100",
            "00001110",
            "00011111",
            "10111011",
            "10110001",
            "10100000"
        )
        New-Variable -Name "Rows" -Value 0x0, 0x2, 0x4, 0x6, 0x8, 0xA, 0xC, 0xE

        Context "Using the -Columns parameter" {
            Set-Ht16k33LedOn -Columns $Pslogo
            $i = 0
            foreach ($column in $Pslogo) {
                It "Turns on column $($Rows[$i]/2)" {
                    Assert-MockCalled -ModuleName PsIoT-HT16K33 -CommandName Set-I2CRegister -Times 1 -Exactly -Scope Context -ParameterFilter {$Register -eq $Rows[$i] -and $Data -eq [convert]::toint32($column, 2)}
                }
                $i++
            }
        }

        Context "Columns over pipeline" {
            $Pslogo | Set-Ht16k33LedOn
            $i = 0
            foreach ($column in $Pslogo) {
                It "Turns on column $($Rows[$i]/2)" {
                    Assert-MockCalled -ModuleName PsIoT-HT16K33 -CommandName Set-I2CRegister -Times 1 -Exactly -Scope Context -ParameterFilter {$Register -eq $Rows[$i] -and $Data -eq [convert]::toint32($column, 2)}
                }
                $i++
            }
        }
    }

    Context "Clear the display" {
        Clear-Ht16k33Display
        New-Variable -Name "Rows" -Value 0x0, 0x2, 0x4, 0x6, 0x8, 0xA, 0xC, 0xE

        foreach ($column in 0..7) {
            It "clears column $column" {
                Assert-MockCalled -ModuleName PsIoT-HT16K33 -CommandName Set-I2CRegister -Times 1 -Exactly -ParameterFilter {$Register -eq $Rows[$column]}
            }
        }
    }
}
