New-Variable -Name "Rows" -Value [0x0, 0x2, 0x4, 0x6, 0x8, 0xA, 0xC, 0xE] -Option Constant
New-Variable -Name "Device"

function Select-Ht16k33Device {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [int]$DeviceAddress = 0x70
    )

    $Device = Get-I2CDevice -Id $DeviceAddress -FriendlyName LedMatrix

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
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateRange(0, 7)][int]$x,
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [ValidateRange(0, 7)][int]$y
    )

    begin {
    }

    process {
    }

    end {
    }
}

function Clear-Ht16k33Screen {
    [CmdletBinding()]
    Param(
    )

    foreach ($Row in $Rows) {
        Set-I2CRegister $Device -Register $Row -Value 0
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
