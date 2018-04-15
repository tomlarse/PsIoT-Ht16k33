Set-I2CRegister -Device $dev -Register 0x00 -Data 0x20
Set-I2CRegister -Device $dev -Register 0x02 -Data 0x20
Set-I2CRegister -Device $dev -Register 0x04 -Data 0x24
Set-I2CRegister -Device $dev -Register 0x06 -Data 0xe
Set-I2CRegister -Device $dev -Register 0x08 -Data 0x1f
Set-I2CRegister -Device $dev -Register 0xa -Data 0xbb
Set-I2CRegister -Device $dev -Register 0xc -Data 0xb1
Set-I2CRegister -Device $dev -Register 0xe -Data 0xa0
