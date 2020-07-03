#include "response.h"

#include <sstream>

Response::Response(string new_result, int new_data_send_length, std::vector<uint8_t> new_byte_list)
{
    data_send_length = new_data_send_length;
    byte_list = new_byte_list;
    result = new_result;
}