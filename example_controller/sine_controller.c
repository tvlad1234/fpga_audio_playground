/*
    Control program for the sine wave generator example
    Serial port handling code based on the example at https://batchloaf.wordpress.com/2013/02/13/writing-bytes-to-a-serial-port-in-c/

    Usage:
        sine_controller.exe [COM port] [frequency in Hz] (optional)[phase shift in degrees]
*/

#include <windows.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

int send_bytes(HANDLE port, char *bytes_to_send, int n)
{
    DWORD bytes_written;
    if (!WriteFile(port, bytes_to_send, n, &bytes_written, NULL))
        return -1;
    return 0;
}

HANDLE open_port(char port[])
{
    char filename[64] = "\\\\.\\";
    strncat(filename, port, 10);

    // Declare variables and structures
    HANDLE hSerial;
    DCB dcbSerialParams = {0};
    COMMTIMEOUTS timeouts = {0};

    // Open the highest available serial port number
    fprintf(stderr, "Opening serial port...");
    hSerial = CreateFile(
        filename, GENERIC_READ | GENERIC_WRITE, 0, NULL,
        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hSerial == INVALID_HANDLE_VALUE)
    {
        fprintf(stderr, "Error\n");
        return 0;
    }
    else
        fprintf(stderr, "OK\n");

    // Set device parameters (9600 baud, 1 start bit,
    // 1 stop bit, no parity)
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (GetCommState(hSerial, &dcbSerialParams) == 0)
    {
        fprintf(stderr, "Error getting device state\n");
        CloseHandle(hSerial);
        return 0;
    }

    dcbSerialParams.BaudRate = CBR_9600;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity = NOPARITY;
    if (SetCommState(hSerial, &dcbSerialParams) == 0)
    {
        fprintf(stderr, "Error setting device parameters\n");
        CloseHandle(hSerial);
        return 0;
    }

    // Set COM port timeout settings
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;
    if (SetCommTimeouts(hSerial, &timeouts) == 0)
    {
        fprintf(stderr, "Error setting timeouts\n");
        CloseHandle(hSerial);
        return 0;
    }

    return hSerial;
}

int main(int argc, char *argv[])
{

    if (argc < 3)
    {
        fprintf(stderr, "Not enough arguments!");
        return 1;
    }

    HANDLE hSerial = open_port(argv[1]);
    if (!hSerial)
    {
        fprintf(stderr, "Error opening serial port %s", argv[1]);
        return 1;
    }

    char bytes_to_send[6] = {0};

    // Frequency
    uint16_t freq = atoi(argv[2]);
    uint16_t div = 25000000 / (2048 * freq);
    printf("Actual frequency: %d Hz\n", (25000000 / div) / 2048);
    bytes_to_send[0] = 1;
    bytes_to_send[1] = div & (0xFF);
    bytes_to_send[2] = (div >> 8) & (0xFF);

    if (argc > 3)
    {
        // Phase
        uint16_t phase = atoi(argv[3]);
        phase = (2048 * phase) / 360;
        bytes_to_send[3] = 2;
        bytes_to_send[4] = phase & (0xFF);
        bytes_to_send[5] = (phase >> 8) & (0xFF);
    }
    else
        bytes_to_send[3] = 0;

    fprintf(stderr, "Sending bytes...\n");
    if (send_bytes(hSerial, bytes_to_send, 6))
        goto tx_err;

    // Close serial port
    fprintf(stderr, "Closing serial port...");
    if (CloseHandle(hSerial) == 0)
    {
        fprintf(stderr, "Error\n");
        return 1;
    }
    fprintf(stderr, "OK\n");
    // exit normally
    return 0;

tx_err:
    fprintf(stderr, "Error\n");
    CloseHandle(hSerial);
    return 1;
}