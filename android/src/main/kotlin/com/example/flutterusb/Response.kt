package com.example.flutterusb

//result may contains error
class Response(val result: String,val dataSendLength: Int, val dataReceived: ByteArray){

    override fun toString(): String {
        return super.toString()
    }

    /*

      string toString() {
          std::stringstream ss;
          ss << "{\"result\":" << result << "\"data_send_length\":\"" << data_send_length << "\",\"byte_list\":\"[";
          for (int i(0); i < sizeof(byte_list) - 1; ++i) {
              ss << (int)byte_list[i] << ",";
          }
          ss << (int)byte_list[sizeof(byte_list)-1] << "]\"}";
          return ss.str();
      }
     */

}