#include <WiFiClientSecure.h> 
#include <RCSwitch.h>
#include <MQTTClient.h>
#include "secrets.h"

const int ledPin = 2;
void setup() {
	Serial.begin(9600);
	pinMode(ledPin, OUTPUT);
} 
void loop() {
	Serial.println(MY_SSID);
	Serial.println(MY_PASSWORD);
	Serial.println(MQTT_ENDPOINT);
	Serial.println(AWS_CERT_CA);
	digitalWrite(ledPin, HIGH); // Turn the LED on
	delay(500);                 // Wait for half a second
	digitalWrite(ledPin, LOW);  // Turn the LED off
	delay(500);                 // Wait for half a second
} 
