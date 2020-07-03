#include "command.h"

Command::Command(std::vector<uint8_t>& value, int new_result_length)
{
    byte_list = value;
    result_length = new_result_length;
    command_length = (int)byte_list.size();
}
