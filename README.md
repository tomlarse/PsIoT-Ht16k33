# Simple HT16K33 driver for Powershell-IoT

## Example

```powershell
Import-Module .\PsIoT-HT16K33.psd1

#This selects the device on the default 0x70 address. The address can be changed by soldering short A0, A1 or A2 points on the back of the headerboard. Other devices can be selected with the -DeviceAdress parameter.
Select-Ht16k33Device

#Turn display on and set no blinking and half brightness
Set-Ht16k33Display -Power On -BlinkRate Off -Brightness 7

#Turn Leds on
Set-Ht16k33LedOn -x 0 -y 0

#Clear display
Clear-Ht16k33Display

```