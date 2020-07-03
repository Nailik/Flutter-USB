#ifndef RESPONSE_H
#define RESPONSE_H

#include <string>
#include <windows.h>
#include <vector>
using namespace std;

class Response {
public:
	int data_send_length;
	std::vector<uint8_t> byte_list;
	string result;
	Response(string new_result, int new_data_send_length, std::vector<uint8_t> new_byte_list);
	string toString();
};
#endif // RESPONSE_H