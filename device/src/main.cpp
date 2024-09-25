#include <WiFi.h> 
#include <ESPAsyncWebServer.h>
#include <RCSwitch.h>
#include <MQTTClient.h>


#ifndef MY_SSID
#define MY_SSID ""
#endif

#ifndef MY_PASSWORD
#define MY_PASSWORD ""
#endif

const int ledPin = 2;
void setup() {
	Serial.begin(9600);
	pinMode(ledPin, OUTPUT);
} 
void loop() {
	Serial.println(MY_SSID);
	Serial.println(MY_PASSWORD);
	digitalWrite(ledPin, HIGH); // Turn the LED on
	delay(500);                 // Wait for half a second
	digitalWrite(ledPin, LOW);  // Turn the LED off
	delay(500);                 // Wait for half a second
} 
