import serial
import time

# Open the serial port
ser = serial.Serial('/dev/ttyUSB3', 115200) 
print(f"Connected to: {ser.name}")

ser.reset_input_buffer()
ser.reset_output_buffer()

message = b'Hello FPGA!\n'
print(f"Sending: {message}")

# FIX: Send character-by-character with a tiny delay
for byte in message:
    ser.write(bytes([byte]))
    time.sleep(0.002) 

time.sleep(0.1)

bytes_waiting = ser.in_waiting
if bytes_waiting > 0:
    response = ser.read(bytes_waiting)
    print(f"Received back cleanly: {response}")
else:
    print("No data received back.")

ser.close()

