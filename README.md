# RemoteControlCar
An iOS app to control a toy car through bluetooth. It supports button control as well as gyroscope control. 
For gyro control, tilt the device in the XY direction to turn left or right. Tilt the device in the XZ direction to forward or backward with different speed. 

Tested on iPhone 5 and iPhone 4s.

### How it works
Control signals are constructed based on the accelerator and gyroscope data, i.e. how the device is tilted. 

Service UUID and Characteristic UUID are defined in `PairingViewController` as `SUUID` and `CUUID`.
The app sends instructions to the car by using `WriteWithoutResponse` to change the value of a certain characteristic of the bluetooth chip on the car. The microcontrollers on the car read the value and take actions. 

It uses `CoreBluetooth`, thus the bluetooth chip needs to support Bluetooth 4.0 LE.

### Screenshots
![Get Started](http://i.imgur.com/SSWB9qI.jpg)
![Pairing](http://i.imgur.com/uafNTX6.jpg)
![Button Control](http://i.imgur.com/LIcjI9V.jpg)
![Gyroscope Control](http://i.imgur.com/INOZ9go.jpg)

### License
RemoteControlCar is released under [MIT License](http://www.opensource.org/licenses/MIT)
