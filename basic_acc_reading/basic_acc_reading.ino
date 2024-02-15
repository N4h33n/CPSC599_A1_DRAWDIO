// Basic demo for accelerometer readings from Adafruit MPU6050

#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
//#include <cmath>

Adafruit_MPU6050 mpu;

void setup(void) {
  Serial.begin(115200);
  while (!Serial)
    delay(10); // will pause Arduino until serial console opens

  // Try to initialize!
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }


  mpu.setAccelerometerRange(MPU6050_RANGE_4_G);

  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  delay(100);
}

// filter noise threshold
const float threshold = 0.5;

void loop() {

  /* Get new sensor events with the readings */
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

// for device to be upright, gyro y value has to round up to about 10. Otherwise, set readings to 0
  if (ceil(g.gyro.y) <10) {
          Serial.print("x");
      Serial.print(0);
            Serial.print("y");
      Serial.print(0);
            Serial.print("z");
      Serial.print(0);
  }


// if upright, check whether motions are within threshold
  if (abs(g.gyro.x) <= threshold) {
      Serial.print("x");
      Serial.print(0);
  } else {
      Serial.print("x");
    Serial.print(a.acceleration.x);
  }
    if (abs(g.gyro.y) <= threshold) {
      Serial.print("y");
      Serial.print(0);
  } else {
      Serial.print("y");
    Serial.print(a.acceleration.y);
  }
    if (abs(g.gyro.z) <= threshold) {
      Serial.print("z");
      Serial.print(0);
  } else {
      Serial.print("z");
    Serial.print(a.acceleration.z);
  }

  delay(10);
}