#include <WiFi.h> 
#include <ESPAsyncWebServer.h>
#include <RCSwitch.h>
#include <MQTTClient.h>


const int ledPin = 2;
void setup() {
	pinMode(ledPin, OUTPUT);
} 
void loop() {
	digitalWrite(ledPin, HIGH); // Turn the LED on
	delay(500);                 // Wait for half a second
	digitalWrite(ledPin, LOW);  // Turn the LED off
	delay(500);                 // Wait for half a second
} 
