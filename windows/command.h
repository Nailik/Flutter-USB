#ifndef COMMAND_H
#define COMMAND_H

#include <string>
#include <vector>
using namespace std;

class Command {
public:
	int command_length;
	int result_length;
	std::vector<uint8_t> byte_list;
	Command(std::vector<uint8_t>& value, int new_result_length);
};
#endif // COMMAND_H