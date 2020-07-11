package de.kilianeller.flutter_usb

import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import java.nio.ByteBuffer
import java.nio.ByteOrder

class FUsbDevice(private val epIn: UsbEndpoint, private val epOut: UsbEndpoint, private val connection: UsbDeviceConnection) {

    private val sendTimeout = 30000
    private val receiveTimeout = 100
    private var transferred = 0
    private var onResponseCallback: ((result: Response) -> Unit)? = null
    private var onTransferredCallback: (() -> Unit)? = null

    fun sendData(inData: Int, data: ByteArray) {
        //TODO in thread?
        transferred = connection.bulkTransfer(epOut, data, data.size, sendTimeout)
        //transferred < 0 is failure
        if (inData > 0) { //only wait for data if user wants
            waitForResponse(inData)
        } else {
            onResponseCallback?.invoke(Response("ok", transferred, ByteArray(0)));
        }
    }

    private fun waitForResponse(inData: Int) {
        var long = System.currentTimeMillis()
        println("start wait for response")
        var response = false
        val inb = ByteBuffer.allocate(inData).order(ByteOrder.LITTLE_ENDIAN)
        var res = 0
        var transfer = true
        while (!response) {
            inb.position(0)
            while (transfer) { //until result is -1
                println("loop start bulk $res")
                val ress = connection.bulkTransfer(epIn, inb.array(), inData-res, receiveTimeout)
                if(ress == -1){
                    transfer = false
                }else{
                    res += ress;
                }
                println("loop end bulk $ress and $res")
            }
            if (res >= 0) {
                response = true
            }
        }
        println("finished response after ${System.currentTimeMillis() - long} millis")
        onResponseCallback?.invoke(Response("ok", transferred, inb.array().copyOf(res)));
    }

    fun onResponse(callback: (result: Response) -> Unit = {}): FUsbDevice {
        onResponseCallback = callback
        return this
    }

    fun onTransferred(callback: () -> Unit = {}): FUsbDevice {
        onTransferredCallback = callback
        return this
    }

}