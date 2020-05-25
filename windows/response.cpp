#include "response.h"

#include <sstream>

Response::Response(string new_result, DWORD new_data_send_length, BYTE* new_byte_list)
{
    data_send_length = new_data_send_length;
    byte_list = new_byte_list;
    result = new_result;
}

string Response::toString()
{
    std::stringstream ss;
    ss << "{\"result\":\"" << result << "\",\"outDataLength\":" << data_send_length << ",\"inData\":[";
    for (int i(0); i < sizeof(byte_list) - 1; ++i) {
        ss << (int)byte_list[i] << ",";
    }
    ss << (int)byte_list[sizeof(byte_list) - 1] << "]}";
    return ss.str();
}