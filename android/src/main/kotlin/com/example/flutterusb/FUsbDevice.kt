package com.example.flutterusb

import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import java.nio.ByteBuffer
import java.nio.ByteOrder

class FUsbDevice(private val epIn: UsbEndpoint, private val epOut: UsbEndpoint, private val connection: UsbDeviceConnection) {

    private val sendTimeout = 30000
    private val receiveTimeout = 30000
    private val receiveCapacity = 512
    private var transferred = 0
    private var onResponseCallback: ((result: Response) -> Unit)? = null
    private var onTransferredCallback: (() -> Unit)? = null
    private val inb = ByteBuffer.allocate(receiveCapacity).order(ByteOrder.LITTLE_ENDIAN)

    fun sendData(data: ByteArray) {
        //TODO in thread?
        transferred = connection.bulkTransfer(epOut, data, data.size, sendTimeout)
        waitForResponse()
    }

    private fun waitForResponse() {
        var response = false
        inb.clear()
        while (!response) {
            inb.position(0)
            var res = 0
            while (res == 0) {
                res = connection.bulkTransfer(epIn, inb.array(), receiveCapacity, receiveTimeout)
            }
            if (res >= 1) {
                response = true
            }
        }
        onResponseCallback?.invoke(Response("ok", transferred, inb.array()));
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