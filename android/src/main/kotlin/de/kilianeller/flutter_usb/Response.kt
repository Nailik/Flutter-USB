package de.kilianeller.flutter_usb

//result may contains error
class Response(val result: String,val dataSendLength: Int, val dataReceived: ByteArray){

    override fun toString(): String {
        return super.toString()
    }
}