#ifndef RESPONSE_H
#define RESPONSE_H

#include <string>
#include <windows.h>
using namespace std;

class Response {
private:
	DWORD data_send_length;
	BYTE* byte_list;
	string result;
public:
	Response(string new_result, DWORD new_data_send_length, BYTE* new_byte_list);
	string toString();
};
#endif // RESPONSE_H