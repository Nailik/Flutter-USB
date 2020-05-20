#include "usbdevice.h"

USBDevice::USBDevice(string new_name, string new_description, string new_bstr)
{
    name = new_name;
    description = new_description;
    bstr = new_bstr;
}

string USBDevice::toString()
{
    return "{\"name\":\"" + name + "\",\"description\":\"" + description + "\",\"bstr\":\"" + bstr + "\"}";
}
