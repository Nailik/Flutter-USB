#ifndef USBDEVICE_H
#define USBDEVICE_H

#include <string>
using namespace std;

class USBDevice {
private:
	string name;
	string description;
	string bstr;

public:
	USBDevice(string new_name, string new_description, string new_bstr);
	string toString();
};
#endif // USBDEVICE_H