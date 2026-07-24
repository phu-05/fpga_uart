import serial
import time

# Open the serial port
ser = serial.Serial('/dev/ttyUSB3', 115200) 
print(f"Connected to: {ser.name}")

#reset buffer
ser.reset_input_buffer()
ser.reset_output_buffer()

message = input("Type message: ").encode(encoding="utf-8",errors="replace")
print(f"Sending: {message.decode(encoding="utf-8",errors="replace")}")

for byte in message:
    ser.write(bytes([byte]))
    
time.sleep(0.05)

bytes_waiting = ser.in_waiting
if bytes_waiting > 0:
    response = ser.read(bytes_waiting)
    decoded_response= response.decode(encoding="utf-8",errors="replace")
    print(f"Received: {decoded_response}")
else:
    print("No data")

ser.close()
