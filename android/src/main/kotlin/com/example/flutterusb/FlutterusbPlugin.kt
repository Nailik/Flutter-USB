package com.example.flutterusb

import android.content.Context
import android.hardware.usb.UsbManager
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlutterusbPlugin */
public class FlutterusbPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var usbDevice: FUsbDevice? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutterusb")
        channel.setMethodCallHandler(this);
        this.context = flutterPluginBinding.applicationContext;
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutterusb")
            channel.setMethodCallHandler(FlutterusbPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        context?.let { ctx ->
            if (call.method == "getPlatformVersion") {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            } else if (call.method == "getUsbDevices") {
                result.success(getUsbDevices(ctx))
            } else if (call.method == "connectToUsbDevice") {
                if (call.arguments !is String) {
                    result.error("wrong args", "should be string", "should be string")
                } else {
                    connectToUsbDevice(ctx, call.arguments.toString(), result)
                }
            } else {
                //all other calls need a connected usb device
                usbDevice?.let {
                    if (call.method == "sendCommand") {
                        if (call.arguments !is ByteArray) {
                            result.error("wrong args", "should be string", "should be string")
                        } else {
                            sendCommand(call.arguments as ByteArray, result)
                        }
                    } else {
                        result.notImplemented()
                    }
                } ?: run {
                    result.error("device null", "camera device is null", "camera device has not been connected")
                }
            }
        }
        result.error("context null", "context null", "context null")
    }

    private fun getUsbDevices(context: Context): String {
        val mUsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        val deviceList = mUsbManager.deviceList
        //TODO json decode/encode
        var json = "[";
        for (device in deviceList) {
            json += "{\"name\":\"${device.value.deviceName}\",\"description\":\"${device.value.deviceClass}\",\"bstr\":\"${device.key}\"},";
        }
        return json.dropLast(1) + "]";
    }

    private fun connectToUsbDevice(context: Context, brts: String, result: Result) {
        val mUsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        val deviceList = mUsbManager.deviceList
        deviceList.entries.find { dev -> dev.key == brts }?.apply {
            Connector(context)
                    .onConnected { dev ->
                        usbDevice = dev
                    }.onError { err ->
                        result.error(err, err, err)
                    }.connect(this.value)
        }
    }

    private fun sendCommand(ints: ByteArray, result: Result) {
        usbDevice?.onTransferred {
            //log?
        }?.onResponse {
            result.success(it.toString())
        }?.sendData(ints)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        this.context = null
        channel.setMethodCallHandler(null)
    }
}
