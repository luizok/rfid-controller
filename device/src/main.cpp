#include <WiFiClientSecure.h> 
#include <RCSwitch.h>
#include <MQTTClient.h>
#include "secrets.h"

const int ledPin = 2;
WiFiClientSecure net = WiFiClientSecure();
MQTTClient client = MQTTClient(512);

void blink(int ledPin, int duration) {
	digitalWrite(ledPin, HIGH);
	delay(duration);
	digitalWrite(ledPin, LOW);
}

void messageHandler(String &topic, String &payload) {
  Serial.println("incoming: " + topic + " - " + payload);
}

void connectAWS() {
	blink(ledPin, 1000);
	WiFi.mode(WIFI_STA);
	WiFi.begin(MY_SSID, MY_PASSWORD);

	Serial.println("Connecting to Wi-Fi");

	while (WiFi.status() != WL_CONNECTED){
		blink(ledPin, 500);
		Serial.print(".");
	}

	// Configure WiFiClientSecure to use the AWS IoT device credentials
	net.setCACert(AWS_CERT_CA);
	net.setCertificate(AWS_CERT_CRT);
	net.setPrivateKey(AWS_CERT_PRIVATE);

	// Connect to the MQTT broker on the AWS endpoint we defined earlier
	client.begin(MQTT_ENDPOINT, 8883, net);

	// Create a message handler
	client.onMessage(messageHandler);

	Serial.print("Connecting to AWS IOT");

	while (!client.connect(CLIENT_ID)) {
		Serial.print(".");
		blink(ledPin, 100);
	}
	Serial.println("");

	if(!client.connected()){
		Serial.println("AWS IoT Timeout!");
		return;
	}

	// Subscribe to a topic
	client.subscribe(TOPIC_NAME);
	Serial.println("AWS IoT Connected!");
}

void setup() {
	delay(5000);
	Serial.begin(9600);
	pinMode(ledPin, OUTPUT);
	connectAWS();
} 
void loop() {
	client.loop();
	digitalWrite(ledPin, HIGH); // Turn the LED on
	delay(500);                 // Wait for half a second
	digitalWrite(ledPin, LOW);  // Turn the LED off
	delay(500);                 // Wait for half a second
}
