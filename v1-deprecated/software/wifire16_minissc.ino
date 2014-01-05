// simple program to run a wifire16 v1 board off a MiniSSC relay controller

#include <SPI.h>

// pin definitions
#define CLEARPIN 4    // master clear for 74HC595 shift registers
#define LATCHPIN 5    // latch for 74HC595 shift registers
#define OEPIN    6    // output enable for 74HC595 shift registers
#define ARMEDPIN 7    // optoisolator connected to load power
#define DATAPIN  11   // data for 74HC595 shift registers
#define CLOCKPIN 13   // clock for 74HC595 shift registers 

#define bitFlip(x,n)  bitRead(x,n) ? bitClear(x,n) : bitSet(x,n)

byte c;
byte v;
byte r1 = 0, r2 = 0;

// setup
void setup() {
  
  // set all output pins
  SPI.begin(); // handles DATAPIN and CLOCKPIN
  pinMode(LATCHPIN, OUTPUT);
  pinMode(OEPIN, OUTPUT);
  pinMode(CLEARPIN, OUTPUT);

  // make sure no lines go active until data is shifted out
  digitalWrite(CLEARPIN, HIGH);
  digitalWrite(OEPIN, LOW);

  // clear any lines that were left active
  digitalWrite(LATCHPIN, LOW);
  digitalWrite(OEPIN, HIGH);
  c = SPI.transfer(0);
  c = SPI.transfer(0);
  digitalWrite(LATCHPIN, HIGH);
  digitalWrite(OEPIN, LOW);
  
  // activate built-in pull-up resistor 
  digitalWrite(ARMEDPIN, HIGH);

  // start the serial communication with the xbee
  Serial.begin(115200);

}


// main loop
void loop() {

  if(Serial.available() >= 3) {
    c = Serial.read();
    if(c == 0xFF) {
      c = Serial.read();
      if( (c >= 0) && (c <= 0x0f) ) {
        v = Serial.read();
        if(v == 0) {
          if(c > 7) {
            bitClear(r2,c-8);
          }
          else {
            bitClear(r1,c);
          }
        }
        else if(v == 1) {
          if(c > 7) {
            bitSet(r2,c-8);
          }
          else {
            bitSet(r1,c);
          }
        }
        if((v == 0) || (v == 1)) {
          digitalWrite(LATCHPIN, LOW);
          digitalWrite(OEPIN, HIGH);
          c = SPI.transfer(r2);
          c = SPI.transfer(r1);
          digitalWrite(LATCHPIN, HIGH);
          digitalWrite(OEPIN, LOW);
        }
      }
    }
  }
}


