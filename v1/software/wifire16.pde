#include <SPI.h>

// pin definitions
#define CLEARPIN 4    // master clear for 74HC595 shift registers
#define LATCHPIN 5    // latch for 74HC595 shift registers
#define OEPIN    6    // output enable for 74HC595 shift registers
#define ARMEDPIN 7    // optoisolator connected to load power
#define DATAPIN  11   // data for 74HC595 shift registers
#define CLOCKPIN 13   // clock for 74HC595 shift registers 

#define bitFlip(x,n)  bitRead(x,n) ? bitClear(x,n) : bitSet(x,n)

char c;
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
  Serial.begin(38400);

}


// main loop
void loop() {

  if(Serial.available()) {
    c = Serial.read();
    switch(c) {
      case '0' : bitFlip(r1,0); break;
      case '1' : bitFlip(r1,1); break;
      case '2' : bitFlip(r1,2); break;
      case '3' : bitFlip(r1,3); break;
      case '4' : bitFlip(r1,4); break;
      case '5' : bitFlip(r1,5); break;
      case '6' : bitFlip(r1,6); break;
      case '7' : bitFlip(r1,7); break;
      case '8' : bitFlip(r2,0); break;
      case '9' : bitFlip(r2,1); break;
      case 'a' : bitFlip(r2,2); break;
      case 'b' : bitFlip(r2,3); break;
      case 'c' : bitFlip(r2,4); break;
      case 'd' : bitFlip(r2,5); break;
      case 'e' : bitFlip(r2,6); break;
      case 'f' : bitFlip(r2,7); break;
      case '?' : 
        // load power on = low, off = high
        digitalRead(ARMEDPIN) ? Serial.print("-") : Serial.print("+");
        break;  
    }
    digitalWrite(LATCHPIN, LOW);
    digitalWrite(OEPIN, HIGH);
    c = SPI.transfer(r1);
    c = SPI.transfer(r2);
    digitalWrite(LATCHPIN, HIGH);
    digitalWrite(OEPIN, LOW);
  }
  
}


