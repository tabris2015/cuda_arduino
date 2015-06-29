
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <Windows.h>
#include <stdio.h>

int main()
{
	HANDLE hSerial;
	DCB dcbSerialParams = {0};
	COMMTIMEOUTS timeouts = {0};


	fprintf(stderr, "abriendo puerto serial...");
	hSerial = CreateFile(
						"\\\\.\\COM21", GENERIC_READ|GENERIC_WRITE, 0, NULL,
						OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

	if(hSerial == INVALID_HANDLE_VALUE)
	{
		fprintf(stderr, "Error\n");
		return 1;
	}
	else fprintf(stderr, "OK\n");

	//set device params ( 9600 baud
	dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (GetCommState(hSerial, &dcbSerialParams) == 0)
    {
        fprintf(stderr, "Error getting device state\n");
        CloseHandle(hSerial);
        return 1;
    }
     
	dcbSerialParams.BaudRate = CBR_9600;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity = NOPARITY;
    if(SetCommState(hSerial, &dcbSerialParams) == 0)
    {
        fprintf(stderr, "Error setting device parameters\n");
        CloseHandle(hSerial);
        return 1;
    }
 
    // Set COM port timeout settings
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;
    if(SetCommTimeouts(hSerial, &timeouts) == 0)
    {
        fprintf(stderr, "Error setting timeouts\n");
        CloseHandle(hSerial);
        return 1;
    }
 
    // Send specified text (remaining command line arguments)
    DWORD tamano = 10;
	char bytes_recibidos[10];

	BYTE dato[10];
	DWORD temp;

    
	for(int i = 0; i<200000; i++)
	{
		if(!ReadFile(hSerial, &dato, tamano, &temp, NULL))
		{
			fprintf(stderr, "Error\n");
			CloseHandle(hSerial);
			return 1;
		}
   
		//fprintf(stderr, "%d recibidos: \n", tamano);
		for( int j = 0; j < 5; j++) printf("%c", dato[j]);
		printf("\n");
	}
    // Close serial port
    fprintf(stderr, "Closing serial port...");
    if (CloseHandle(hSerial) == 0)
    {
        fprintf(stderr, "Error\n");
        return 1;
    }
    fprintf(stderr, "OK\n");
 
    // exit normally
	getchar();
    return 0;
}