# Rows are accessed through registers 0x0, 0x2, 0x4, 0x6, 0x8, 0xA, 0xC, 0xE
New-Variable -Name "Rows" -Value 0x0, 0x2, 0x4, 0x6, 0x8, 0xA, 0xC, 0xE -Option Constant -Scope Script

# To light a given LED in a row, add the value for that LED to the existing ones in the row.
# Column    Value   Bit number
# 0         0x80    8
# 1         0x01    1
# 2         0x02    2
# 3         0x04    3
# 4         0x08    4
# 5         0x10    5
# 6         0x20    6
# 7         0x40    7
New-Variable -Name "Columns" -Value 0x80, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40 -Option Constant -Scope Script
New-Variable -Name "Device" -Scope Script

# Default I2C address for a HT16K33 is 0x70
function Select-Ht16k33Device {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [int]$DeviceAddress = 0x70
    )

    $Script:Device = Get-I2CDevice -Id $DeviceAddress -FriendlyName LedMatrix

    $Device
}

function Set-Ht16k33Display {
    [CmdletBinding()]
    param (
        [ValidateSet('On', 'Off')]
        [string]$Power,
        [ValidateSet('Off', '2Hz', '1Hz', '0.5Hz')]
        [string]$BlinkRate = "Off",
        [ValidateRange(0, 15)]
        [int]$Brightness = 15
    )

    # The registers that control the inbuilt features on the pack are like quantum
    # particles. They change state by being interacted with. Hence the Get- commands
    # in stead of Set-
    Begin {
        $BlinkRegister = @{
            "Off"   = "0x81"
            "0.5Hz" = "0x83"
            "1Hz"   = "0x85"
            "2Hz"   = "0x87"
        }
        $BrightnessBase = [int]0xe0
    }

    process {
        if ($Power -eq "Off") {
            Get-I2CRegister -Device $Device -Register 0x80
        }
        else {
            Get-I2CRegister -Device $Device -Register $BlinkRegister[$BlinkRate]
            Get-I2CRegister -Device $Device -Register ($BrightnessBase + $Brightness)
        }
    }
}

function Set-Ht16k33LedOn {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName="xy")]
        [ValidateRange(0, 7)][int]$x,
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true, ParameterSetName="xy")]
        [ValidateRange(0, 7)][int]$y,
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName="Columns")]
        [string[]]$Columns
    )

    process {
        switch ($PsCmdlet.ParameterSetName) {
            "xy" {
                $ExistingLeds = (Get-I2CRegister -Device $Device -Register $Script:Rows[$x]).Data
                $Existing = 0
                foreach ($ExistingLed in $ExistingLeds) {
                    $Existing += $ExistingLed
                }
                Set-I2CRegister -Device $Device -Register $Script:Rows[$x] -Data ($Existing + $Script:Columns[$y])
            }
            "Columns" {
                foreach ($line in $lines) {
                    # Need to convert a string of bits to a number
                    $convertedColumn = [convert]::toint32($line,2)

                    foreach ($Row in $Script:Rows) {
                        Set-I2CRegister -Device $Device -Register $Row -Data $ConvertedColumn
                    }
                }
            }
        }
    }
}

function Clear-Ht16k33Display {
    [CmdletBinding()]
    Param()

    foreach ($Row in $Rows) {
        Set-I2CRegister $Device -Register $Row -Data 0
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
