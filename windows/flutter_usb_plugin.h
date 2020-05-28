#ifndef FLUTTER_PLUGIN_FLUTTER_USB_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_USB_PLUGIN_H_

#include <flutter_plugin_registrar.h>

#include <map>
#include <memory>
#include <sstream>
#include <iostream>
#include <wia_xp.h>
#include <tchar.h>
#include <process.h>

#include <list>
#include <.plugin_symlinks\flutterusb\windows\response.h>
#include <.plugin_symlinks\flutterusb\windows\command.h>
#include <.plugin_symlinks\flutterusb\windows\usbdevice.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif
HRESULT CreateWiaDeviceManager(IWiaDevMgr** ppWiaDevMgr);
HRESULT EnumerateWiaDevices(IWiaDevMgr* pWiaDevMgr, std::list<USBDevice>* mylist);
HRESULT CreateWiaDevice(IWiaDevMgr* pWiaDevMgr, BSTR bstrDeviceID, IWiaItem** ppWiaDevice);
HRESULT EnumerateItems(IWiaItem* pWiaItem);
void initialize(IWiaDevMgr** pWiaDevMgr);
void getDevices(IWiaDevMgr* pWiaDevMgr, std::list<USBDevice>* mylist);
Response sendCommand(Command command);
void connectToDevice(IWiaDevMgr* pWiaDevMgr, BSTR bstrDeviceID, IWiaItem* ppWiaDevice);

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void FlutterUsbPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);


#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_FLUTTER_USB_PLUGIN_H_