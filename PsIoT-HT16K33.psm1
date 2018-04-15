# Implement your module commands in this script.
function Set-Ht16k33Display {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Microsoft.PowerShell.IoT.I2CDevice]$Device,
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

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
