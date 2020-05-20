#include "command.h"

Command::Command(std::vector<uint8_t>& value)
{
    byte_list = value;
    command_length = byte_list.size();
}
