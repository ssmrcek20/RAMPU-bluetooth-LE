#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

const int ledPin = 2; 
bool trenutnaVrijednostLED = false;
bool karakteristika = false;
BLECharacteristic *pCharacteristic;

void setup() {
  pinMode(ledPin, OUTPUT);

  BLEDevice::init("RAMPU Bluetooth LE");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristic->setValue("0");
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

void loop() {
  if(pCharacteristic->getValue() == "1") karakteristika = true;
  else karakteristika = false;
  bool PromjenaLED = (karakteristika != trenutnaVrijednostLED);

  if (PromjenaLED) {
    if (karakteristika) {
      digitalWrite(ledPin, HIGH);
      trenutnaVrijednostLED = true;
    } else {
      digitalWrite(ledPin, LOW);
      trenutnaVrijednostLED = false;
    }
}}