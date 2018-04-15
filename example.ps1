Set-I2CRegister -Device $dev -Register 0x00 -Data 0x20
Set-I2CRegister -Device $dev -Register 0x02 -Data 0x20
Set-I2CRegister -Device $dev -Register 0x04 -Data 0x24
Set-I2CRegister -Device $dev -Register 0x06 -Data 0xe
Set-I2CRegister -Device $dev -Register 0x08 -Data 0x1f
Set-I2CRegister -Device $dev -Register 0xa -Data 0xbb
Set-I2CRegister -Device $dev -Register 0xc -Data 0xb1
Set-I2CRegister -Device $dev -Register 0xe -Data 0xa0

Set-Ht16k33LedOn 0 6
Set-Ht16k33LedOn 1 6
Set-Ht16k33LedOn 2 3
Set-Ht16k33LedOn 2 6
Set-Ht16k33LedOn 3 2
Set-Ht16k33LedOn 3 3
Set-Ht16k33LedOn 3 4
Set-Ht16k33LedOn 4 1
Set-Ht16k33LedOn 4 2
Set-Ht16k33LedOn 4 3
Set-Ht16k33LedOn 4 4
Set-Ht16k33LedOn 4 5
Set-Ht16k33LedOn 5 0
Set-Ht16k33LedOn 5 1
Set-Ht16k33LedOn 5 2
Set-Ht16k33LedOn 5 4
Set-Ht16k33LedOn 5 5
Set-Ht16k33LedOn 5 6
Set-Ht16k33LedOn 6 0
Set-Ht16k33LedOn 6 1
Set-Ht16k33LedOn 6 5
Set-Ht16k33LedOn 6 6
Set-Ht16k33LedOn 7 0
Set-Ht16k33LedOn 7 6

$positions = @(
    [pscustomobject]@{x = 0; y = 6}
    [pscustomobject]@{x = 1; y = 6}
    [pscustomobject]@{x = 2; y = 3}
    [pscustomobject]@{x = 2; y = 6}
    [pscustomobject]@{x = 3; y = 2}
    [pscustomobject]@{x = 3; y = 3}
    [pscustomobject]@{x = 3; y = 4}
    [pscustomobject]@{x = 4; y = 1}
    [pscustomobject]@{x = 4; y = 2}
    [pscustomobject]@{x = 4; y = 3}
    [pscustomobject]@{x = 4; y = 4}
    [pscustomobject]@{x = 4; y = 5}
    [pscustomobject]@{x = 5; y = 1}
    [pscustomobject]@{x = 5; y = 2}
    [pscustomobject]@{x = 5; y = 4}
    [pscustomobject]@{x = 5; y = 5}
    [pscustomobject]@{x = 5; y = 6}
    [pscustomobject]@{x = 6; y = 0}
    [pscustomobject]@{x = 6; y = 1}
    [pscustomobject]@{x = 6; y = 5}
    [pscustomobject]@{x = 6; y = 6}
    [pscustomobject]@{x = 7; y = 0}
    [pscustomobject]@{x = 7; y = 6}
)