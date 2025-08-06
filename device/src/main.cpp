#include <WiFiClientSecure.h> 
#include <MQTTClient.h>
#include <ArduinoJson.h>
#include <HTTPClient.h>
#include "secrets.h"

#define BLUE_LED 18
#define RED_LED 19
#define YELLOW_LED 22
#define GREEN_LED 23

const int ledPin = 2;
int blinkDuration = 0;

WiFiClientSecure net = WiFiClientSecure();
MQTTClient client = MQTTClient(512);

void blink(int ledPin, int duration) {
	digitalWrite(ledPin, HIGH);
	delay(duration);
	digitalWrite(ledPin, LOW);
	delay(duration);
}

void messageHandler(String &topic, String &payload) {
	// Serial.println("incoming: " + topic + " - " + payload);
	StaticJsonDocument<200> doc;
	// Test if parsing succeeds
	DeserializationError error = deserializeJson(doc, payload);
	if (error) {
		Serial.print("deserializeJson() failed: ");
		Serial.println(error.f_str());
		return;
	}
	// Serial.printf("duration: %d\n", doc["duration"].as<long>());
	blinkDuration = doc["duration"].as<long>();
}

void updateLastHash(String &cbUrl, String &hash) {

	HTTPClient client;
	client.begin("https://" + cbUrl);
	client.addHeader("Content-Type", "application/json");

	StaticJsonDocument<200> doc;
	doc["hash"] = hash;
	String jsonBody;
	serializeJson(doc, jsonBody);

	int resCode = client.POST(jsonBody);

	if(resCode > 0) {
      Serial.print("HTTP Response code: ");
    } else {
      Serial.print("Error code: ");
    }
      Serial.println(resCode);
}

void messageHandlerLeds(String &topic, String &payload) {
	StaticJsonDocument<200> doc;
	DeserializationError error = deserializeJson(doc, payload);
	if (error) {
		Serial.print("deserializeJson() failed: ");
		Serial.println(error.f_str());
		return;
	}

	Serial.println(payload);
	String led = doc["led"].as<String>();
	int state = doc["state"].as<int>();
	String hash = doc["hash"].as<String>();
	String cbUrl = doc["callbackUrl"].as<String>();
	int cLedPin;
	if(led.equals("blue")) {
		cLedPin = BLUE_LED;
	}
	else if(led.equals("red")) {
			cLedPin = RED_LED;
	}
	else if(led.equals("yellow")) {
			cLedPin = YELLOW_LED;
	}
	else if(led.equals("green")) {
			cLedPin = GREEN_LED;
	}

	digitalWrite(cLedPin, state);
	updateLastHash(cbUrl, hash);
}

void connectAWS() {
	blink(ledPin, 1000);
	WiFi.mode(WIFI_STA);
	WiFi.begin(MY_SSID, MY_PASSWORD);

	Serial.print("Connecting to Wi-Fi");

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
	client.onMessage(messageHandlerLeds);

	Serial.print("\nConnecting to AWS IOT");

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
	pinMode(BLUE_LED, OUTPUT);
	pinMode(RED_LED, OUTPUT);
	pinMode(YELLOW_LED, OUTPUT);
	pinMode(GREEN_LED, OUTPUT);
	connectAWS();
} 
void loop() {

	if(
		WiFi.status() != WL_CONNECTED ||
		!client.connected()
	) 
		connectAWS();

	client.loop();
}
