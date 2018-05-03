
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PsIot-Ht16K33.svg)](https://www.powershellgallery.com/packages/PsIoT-Ht16k33/) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PsIot-Ht16K33.svg)](https://www.powershellgallery.com/packages/PsIoT-Ht16k33/)[![Build status](https://ci.appveyor.com/api/projects/status/ikt5okq1g4avag34?svg=true)](https://ci.appveyor.com/project/tomlarse/psiot-ht16k33)

# Simple HT16K33 driver for Powershell-IoT
Requires https://github.com/PowerShell/PowerShell-IoT

Remember to turn on the I2C register on the pi before use. This is done under "Interfacing Options" in `sudo raspi-config`

## Example

```powershell
#Install from Powershell Gallery
Install-Module PsIoT-HT16K33 -Scope CurrentUser
Import-Module PsIoT-HT16k33

#This selects the device on the default 0x70 address. The address can be changed by soldering short A0, A1 or A2 points on the back of the headerboard. Other devices can be selected with the -DeviceAdress parameter.
Select-Ht16k33Device

#Turn display on and set no blinking and half brightness
Set-Ht16k33Display -Power On -BlinkRate Off -Brightness 7

#Turn Leds on
Set-Ht16k33LedOn -x 0 -y 0

#Clear display
Clear-Ht16k33Display

```
