#include "flutter_usb_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <string.h>
#include <map>
#include <memory>
#include <sstream>
#include <VersionHelpers.h>
#include <iostream>
#include <wia_xp.h>
#include <tchar.h>
#include <process.h>
#include <list>
#include <.plugin_symlinks\flutterusb\windows\JSON.h>
using namespace std;

namespace {

class FlutterUsbPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterUsbPlugin();

  virtual ~FlutterUsbPlugin();

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void FlutterUsbPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "flutter_usb",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterUsbPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterUsbPlugin::FlutterUsbPlugin() {}

FlutterUsbPlugin::~FlutterUsbPlugin() {}

HRESULT usbDevice;
IWiaItemExtras* ppWiaExtra = NULL;
IWiaDevMgr* pWiaDevMgr = NULL;
IWiaItem* ppWiaDevice = NULL;

void FlutterUsbPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  // Replace "getPlatformVersion" check with your plugin's method.
  // See:
  // https://github.com/flutter/engine/tree/master/shell/platform/common/cpp/client_wrapper/include/flutter
  // and
  // https://github.com/flutter/engine/tree/master/shell/platform/glfw/client_wrapper/include/flutter
  // for the relevant Flutter APIs.
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    flutter::EncodableValue response(version_stream.str());
    result->Success(&response);
  }
  else  if (method_call.method_name().compare("initializeUsb") == 0) {
      initialize(&pWiaDevMgr);
      flutter::EncodableValue response("Test");
      result->Success(&response);
  }
  else  if (method_call.method_name().compare("getUsbDevices") == 0) {
      std::list<USBDevice>* mylist = new list<USBDevice>;
      getDevices(pWiaDevMgr, mylist);

      string values = "[";
      boolean empty = true;

      std::list<USBDevice>::iterator it;
      for (it = (*mylist).begin(); it != (*mylist).end(); ++it) {
          empty = false;
          values += it->toString() + ",";
      }
      if (!empty) {
          values = values.substr(0, values.size() - 1);
      }
      values += "]";

      flutter::EncodableValue response(values);
      result->Success(&response);
  } else  if (method_call.method_name().compare("connectToUsbDevice") == 0) {
      if (!method_call.arguments() || !method_call.arguments()->IsString()) {
          result->Error("Bad arguments", "Expected string");
          return;
      }

      //convert string to BSTR
      string bstr = method_call.arguments()->StringValue();
      std::wstring str1(bstr.begin(), bstr.end());

      const wchar_t* s = str1.c_str();

      BSTR bstrDeviceID = SysAllocString(s);
      if(connectToDevice(pWiaDevMgr, bstrDeviceID, ppWiaDevice)){
        flutter::EncodableValue response("version");
        result->Success(&response);
      }else{
          result->Error("Could not connect", "Error connecting");
      }
      //TODO result
  }
  else  if (method_call.method_name().compare("sendCommand") == 0) {
      int outLength = method_call.arguments()[0].IntValue();
      std::vector<uint8_t> inData = method_call.arguments()[0].ByteListValue();
      Response command_response = sendCommand(Command(inData, outLength));

      std::vector<flutter::EncodableValue> response;
      response.push_back(flutter::EncodableValue(command_response.result));
      response.push_back(flutter::EncodableValue(((int)command_response.data_send_length)));
      response.push_back(flutter::EncodableValue(command_response.byte_list));
      flutter::EncodableValue resultValue(response);
      result->Success(&resultValue);
  } else {
    result->NotImplemented();
  }
}
}  // namespace

void FlutterUsbPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  FlutterUsbPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

// wiacusb.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

HRESULT CreateWiaDeviceManager(IWiaDevMgr** ppWiaDevMgr) //Vista or later
{
    //
    // Validate arguments
    //
    if (NULL == ppWiaDevMgr)
    {
        return E_INVALIDARG;
    }

    //
    // Initialize out variables
    //
    *ppWiaDevMgr = NULL;

    //
    // Create an instance of the device manager
    //

    //Vista or later:
    HRESULT hr = CoCreateInstance(CLSID_WiaDevMgr, NULL, CLSCTX_LOCAL_SERVER, IID_IWiaDevMgr, (void**)ppWiaDevMgr);

    //
    // Return the result of creating the device manager
    //
    return hr;
}

HRESULT ReadSomeWiaProperties(IWiaPropertyStorage* pWiaPropertyStorage, PROPVARIANT* PropVar2)
{
    //
    // Validate arguments
    //
    if (NULL == pWiaPropertyStorage)
    {
        return E_INVALIDARG;
    }

    //
    // Declare PROPSPECs and PROPVARIANTs, and initialize them to zero.
    //
    PROPSPEC PropSpec[3] = { 0 };
    PROPVARIANT PropVar[3] = { 0 };

    //
    // How many properties are you querying for?
    //
    const ULONG c_nPropertyCount = sizeof(PropSpec) / sizeof(PropSpec[0]);

    //
    // Device Name
    //
    PropSpec[0].ulKind = PRSPEC_PROPID;
    PropSpec[0].propid = WIA_DIP_DEV_NAME;

    //
    // Device description
    //
    PropSpec[1].ulKind = PRSPEC_PROPID;
    PropSpec[1].propid = WIA_DIP_DEV_DESC;

    //
    // Define which properties you want to read:
    // Device ID.  This is what you would use to create
    // the device.
    //
    PropSpec[2].ulKind = PRSPEC_PROPID;
    PropSpec[2].propid = WIA_DIP_DEV_ID;


    //
    // Ask for the property values
    //
    HRESULT hr = pWiaPropertyStorage->ReadMultiple(c_nPropertyCount, PropSpec, PropVar);

    PropVar2[0] = PropVar[0];
    PropVar2[1] = PropVar[1];
    PropVar2[2] = PropVar[2];

    if (SUCCEEDED(hr))
    {
        //
        // IWiaPropertyStorage::ReadMultiple will return S_FALSE if some
        // properties could not be read, so you have to check the return
        // types for each requested item.
        //

        //
        // Check the return type for the device ID
        //
        if (VT_BSTR == PropVar[0].vt)
        {
            //*bstrDeviceID = PropVar[0].bstrVal;
            //
            // Do something with the device ID
            //
            _tprintf(TEXT("WIA_DIP_DEV_ID: %ws\n"), PropVar[2].bstrVal);
            //     if (0 == wcscmp(PropVar[0].bstrVal, L"ILCE-6300")) {
                   //  *bstrDeviceID = PropVar[2].bstrVal;
             //    }
        }

        //
        // Check the return type for the device name
        //
        if (VT_BSTR == PropVar[1].vt)
        {
            //
            // Do something with the device name
            //
            _tprintf(TEXT("WIA_DIP_DEV_NAME: %ws\n"), PropVar[0].bstrVal);
        }

        //
        // Check the return type for the device description
        //
        if (VT_BSTR == PropVar[2].vt)
        {
            //
            // Do something with the device description
            //
            _tprintf(TEXT("WIA_DIP_DEV_DESC: %ws\n"), PropVar[1].bstrVal);
        }

        //
        // Free the returned PROPVARIANTs
        //
        FreePropVariantArray(c_nPropertyCount, PropVar);
    }

    //
    // Return the result of reading the properties
    //
    return hr;
}

HRESULT EnumerateWiaDevices(IWiaDevMgr* pWiaDevMgr, std::list<USBDevice>* mylist) //Vista or later
{
    //
    // Validate arguments
    //
    if (NULL == pWiaDevMgr)
    {
        return E_INVALIDARG;
    }

    //
    // Get a device enumerator interface

    IEnumWIA_DEV_INFO* pWiaEnumDevInfo = NULL;
    HRESULT hr = pWiaDevMgr->EnumDeviceInfo(WIA_DEVINFO_ENUM_LOCAL, &pWiaEnumDevInfo);
    if (SUCCEEDED(hr))
    {
        //
        // Loop until you get an error or pWiaEnumDevInfo->Next returns
        // S_FALSE to signal the end of the list.
        //
        while (S_OK == hr)
        {
            //
            // Get the next device's property storage interface pointer
            //
            IWiaPropertyStorage* pWiaPropertyStorage = NULL;
            hr = pWiaEnumDevInfo->Next(1, &pWiaPropertyStorage, NULL);

            //
            // pWiaEnumDevInfo->Next will return S_FALSE when the list is
            // exhausted, so check for S_OK before using the returned
            // value.
            //
            if (hr == S_OK)
            {
                //
                // Do something with the device's IWiaPropertyStorage*
                //
                PROPVARIANT PropVar[3] = { 0 };
                ReadSomeWiaProperties(pWiaPropertyStorage, PropVar);

                // Your wchar_t*
                wstring ws0(PropVar[0].bstrVal);
                // your new String
                string str0(ws0.begin(), ws0.end());

                // Your wchar_t*
                wstring ws1(PropVar[1].bstrVal);
                // your new String
                string str1(ws1.begin(), ws1.end());

                // Your wchar_t*
                wstring ws2(PropVar[2].bstrVal);
                // your new String
                string str2(ws2.begin(), ws2.end());

                mylist->push_back(USBDevice(str0, str1, str2));
                //
                // Release the device's IWiaPropertyStorage*
                //
                pWiaPropertyStorage->Release();
                pWiaPropertyStorage = NULL;
            }
        }

        //
        // If the result of the enumeration is S_FALSE (which
        // is normal), change it to S_OK.
        //
        if (S_FALSE == hr)
        {
            hr = S_OK;
        }

        //
        // Release the enumerator
        //
        pWiaEnumDevInfo->Release();
        pWiaEnumDevInfo = NULL;
    }

    //
    // Return the result of the enumeration
    //
    return hr;
}

//Vista or later:
HRESULT CreateWiaDevice(IWiaDevMgr* pWiaDevMgr, BSTR bstrDeviceID, IWiaItem** ppWiaDevice)
{
    //
    // Validate arguments
    //
    if (NULL == pWiaDevMgr || NULL == bstrDeviceID || NULL == ppWiaDevice)
    {
        return E_INVALIDARG;
    }

    //
    // Initialize out variables
    //
    *ppWiaDevice = NULL;

    //
    // Create the WIA Device
    //
    HRESULT hr = pWiaDevMgr->CreateDevice(bstrDeviceID, ppWiaDevice);

    //
    // Return the result of creating the device
    //
    return hr;
}

HRESULT EnumerateItems(IWiaItem* pWiaItem) //XP or earlier
{
    //
    // Validate arguments
    //
    if (NULL == pWiaItem)
    {
        return E_INVALIDARG;
    }

    //
    // Get the item type for this item.
    //
    LONG lItemType = 0;
    HRESULT hr = pWiaItem->GetItemType(&lItemType);

    // _tprintf(TEXT("FoundItem: %ws\n"), &lItemType);

    if (SUCCEEDED(hr))
    {
        //
        // If it is a folder, or it has attachments, enumerate its children.
        //
        if (lItemType & WiaItemTypeFolder || lItemType & WiaItemTypeHasAttachments)
        {
            //
            // Get the child item enumerator for this item.
            //
            IEnumWiaItem* pEnumWiaItem = NULL; //XP or earlier

            hr = pWiaItem->EnumChildItems(&pEnumWiaItem);
            if (SUCCEEDED(hr))
            {
                //
                // Loop until you get an error or pEnumWiaItem->Next returns
                // S_FALSE to signal the end of the list.
                //
                while (S_OK == hr)
                {
                    //
                    // Get the next child item.
                    //
                    IWiaItem* pChildWiaItem = NULL; //XP or earlier

                    hr = pEnumWiaItem->Next(1, &pChildWiaItem, NULL);

                    //
                    // pEnumWiaItem->Next will return S_FALSE when the list is
                    // exhausted, so check for S_OK before using the returned
                    // value.
                    //
                    if (S_OK == hr)
                    {
                        //
                        // Recurse into this item.
                        //
                        hr = EnumerateItems(pChildWiaItem);

                        //
                        // Release this item.
                        //
                        pChildWiaItem->Release();
                        pChildWiaItem = NULL;
                    }
                }

                //
                // If the result of the enumeration is S_FALSE (which
                // is normal), change it to S_OK.
                //
                if (S_FALSE == hr)
                {
                    hr = S_OK;
                }

                //
                // Release the enumerator.
                //
                pEnumWiaItem->Release();
                pEnumWiaItem = NULL;
            }
        }
    }
    return  hr;
}

Response sendCommand(Command command) {

    BYTE* lpInData = &(command.byte_list)[0];

    BYTE* pOutData = new unsigned char[command.result_length];
    DWORD pdwActualDataSize;
    //see https://docs.microsoft.com/en-us/windows/win32/api/wia_xp/nf-wia_xp-iwiaitemextras-escape
    HRESULT hr = ppWiaExtra->Escape(256, lpInData, command.command_length, pOutData, command.result_length, &pdwActualDataSize);
    std::string message = std::system_category().message(hr);

    return Response(message, pdwActualDataSize, pOutData);
}

void initialize(IWiaDevMgr** pWiaDevMgr) {
    //initialize wia
    HRESULT h = CoInitialize(NULL);
    //create wia device manager
    HRESULT hr = CreateWiaDeviceManager(pWiaDevMgr);
    //TODO result (worked/error)
}

void getDevices(IWiaDevMgr* pWiaDevMgr, std::list<USBDevice>* mylist) {
    //show connected devices and get deviceId
    HRESULT hr2 = EnumerateWiaDevices(pWiaDevMgr, mylist);
}

bool connectToDevice(IWiaDevMgr* pWiaDevMgr, BSTR bstrDeviceID, IWiaItem* ppWiaDevice) {
    usbDevice = CreateWiaDevice(pWiaDevMgr, bstrDeviceID, &ppWiaDevice);
    if(ppWiaDevice != 0 && usbDevice == S_OK){
        // IWiaTransfer* pWiaTransfer = NULL;
        HRESULT result = ppWiaDevice->QueryInterface(IID_IWiaItemExtras, (void**)&ppWiaExtra);
        return result == S_OK;
    }
    return false;
}