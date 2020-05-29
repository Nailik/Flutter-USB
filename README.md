# flutterusb

This is a plugin that supports sending commands to USB devices on Windows (with WIA Api) and Android.
It's a really early test project without any released versions yet.

## Getting Started

this enables to log send and received commands as hex
FlutterUsb.enableLogger();


this is necessary on windows to initialize wia
FlutterUsb.initializeUsb;

this returns the found devices
FlutterUsb.getUsbDevices;

on android connect will prompt user to allow connection
endpoints for command are set here and at the moment it's hardcoded
FlutterUsb.connectToUsbDevice(device);

send command will send the given array and return a Response
FlutterUsb.sendCommand(Command([0x02, 0x02]));

**NOTE:**
When it crashes on windows you may need to disconnect and reconnect USB Device.
If it still doesn't work only rebooting will help because the WIA Api crashed.
