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

<#
.SYNOPSIS
    Selects the HT16K33 device that should be managed.
.DESCRIPTION
    The default I2C address for a HT16K33 LED matrix is 0x70, but can also be 0x71-0x72 based on the
    shorting of the A0, A1 or A2 points on the back of the board.
.EXAMPLE
    PS C:\> Select-Ht16k33Device
    Will select the default device at address 0x70
.EXAMPLE
    PS C:\> Select-Ht16k33Device -DeviceAddress 0x71
    Will select the device at address 0x71
.INPUTS
    $DeviceAddress
    [int] with the correct address
#>
function Select-Ht16k33Device {
    [CmdletBinding()]
    param (
        # Default I2C address for a HT16K33 is 0x70
        [Parameter(Position = 0)]
        [int]$DeviceAddress = 0x70
    )

    $Script:Device = Get-I2CDevice -Id $DeviceAddress -FriendlyName LedMatrix

    #Initialize the oscillator and clean the display
    Get-I2CRegister -Device $script:Device -Register 0x21 | Out-Null
    Clear-Ht16k33Display

    $Script:Device
}

<#
.SYNOPSIS
    Used to toggle features of the HT16K33 header
.DESCRIPTION
    The HT16K33 header has a couple of inbuilt features that can be controlled with
    this command.
.EXAMPLE
    PS C:\> Set-Ht16k33Display -Power On -BlinkRate 1Hz -Brightness 15
    Turns the display on, sets blinkrate to 1Hz and brightness to 15.
    Possible values for -BlinkRate are Off, 1Hz, 2Hz and 0.5Hz. Brightness can be set on a scale
    from 0 to 15.
#>
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
            Get-I2CRegister -Device $Script:Device -Register 0x80
        }
        else {
            Get-I2CRegister -Device $Script:Device -Register $BlinkRegister[$BlinkRate]
            Get-I2CRegister -Device $Script:Device -Register ($BrightnessBase + $Brightness)
        }
    }
}

<#
.SYNOPSIS
    Turns LEDs on in the matrix.
.DESCRIPTION
    Used to turn LEDs on. Either individually or from an array of bits representing columns on the matrix
.EXAMPLE
    PS C:\> Set-Ht16k33LedOn -x 0 -y 0
    Turns on the LED at position 0,0
.EXAMPLE
    PS C:\> $Pslogo = @( "00100000",
    >>                   "00100000",
    >>                   "00100100",
    >>                   "00001110",
    >>                   "00011111",
    >>                   "10111011",
    >>                   "10110001",
    >>                   "10100000"
    >>      )
    PS C:\> Set-Ht16k33LedOn -Columns $Pslogo
    Will turn on the LEDs based on the 8 8-bit strings from the array.
#>
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
                $ExistingLeds = (Get-I2CRegister -Device $Script:Device -Register $Script:Rows[$x]).Data
                $Existing = 0
                foreach ($ExistingLed in $ExistingLeds) {
                    $Existing += $ExistingLed
                }
                Set-I2CRegister -Device $Script:Device -Register $Script:Rows[$x] -Data ($Existing + $Script:Columns[$y])
            }
            "Columns" {
                $i = 0
                foreach ($Column in $Columns) {
                    # Need to convert a string of bits to a number
                    $convertedColumn = [convert]::toint32($Column,2)

                    Set-I2CRegister -Device $Script:Device -Register $Script:Rows[$i] -Data $ConvertedColumn
                    $i++
                }
            }
        }
    }
}

<#
.SYNOPSIS
    Clears the display.
.DESCRIPTION
    Will turn off all lit LEDs on the matrix.
.EXAMPLE
    PS C:\> Clear-Ht16k33Display
#>
function Clear-Ht16k33Display {
    [CmdletBinding()]
    Param()

    foreach ($Row in $Script:Rows) {
        Set-I2CRegister $Script:Device -Register $Row -Data 0
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
