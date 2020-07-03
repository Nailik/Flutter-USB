package de.kilianeller.flutter_usb

import android.content.Context
import android.hardware.usb.UsbManager
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlutterUsbPlugin */
public class FlutterUsbPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var usbDevice: FUsbDevice? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext;
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_usb")
        channel.setMethodCallHandler(this);
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
            val channel = MethodChannel(registrar.messenger(), "flutter_usb")
            channel.setMethodCallHandler(FlutterUsbPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        context?.let { ctx ->
            if (call.method == "initializeUsb") {
                result.success("ok")
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
                        if (call.arguments !is List<*>) {
                            result.error("wrong args", "should be List", "should be List")
                        } else {
                            sendCommand((call.arguments as List<*>)[0] as Int, (call.arguments as List<*>)[1] as ByteArray, result)
                        }
                    } else {
                        result.notImplemented()
                    }
                } ?: run {
                    result.error("device null", "camera device is null", "camera device has not been connected")
                }
            }
        } ?: run {
            result.error("context null", "context null", "context null")
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun getUsbDevices(context: Context): String {
        val mUsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        val deviceList = mUsbManager.deviceList
        //TODO json decode/encode
        var json = "";
        var isEmpty = true
        for (device in deviceList) {
            json += "{\"name\":\"${device.value.deviceName}\",\"description\":\"${device.value.deviceClass}\",\"bstr\":\"${device.key}\"},"
            isEmpty = false;
        }
        if (!isEmpty) {
            json = json.dropLast(1)
        }
        return "[$json]"
    }

    private fun connectToUsbDevice(context: Context, brts: String, result: Result) {
        val mUsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        val deviceList = mUsbManager.deviceList
        deviceList.entries.find { dev -> dev.key == brts }?.apply {
            Connector(context)
                    .onConnected { dev ->
                        usbDevice = dev
                        result.success("ok")
                    }.onError { err ->
                        result.error(err, err, err)
                    }.connect(this.value)
        }
    }

    private fun sendCommand(inLength: Int, ints: ByteArray, result: Result) {
        usbDevice?.onTransferred {
            //log?
        }?.onResponse {
            result.success(it.toString())
        }?.sendData(inLength, ints)
    }
}

