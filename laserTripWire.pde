/*
  Laser gate
  
  the plug is on ports 2 and 3
 */
 
#include <RF12.h>
#include <Ports.h>


#define RED    (6)
#define GREEN  (5)

#define DOOR_CLOSED  (1)
#define DOOR_AJAR    (2)
#define DOOR_OPEN    (3)

typedef struct {
        unsigned int house;
	unsigned int device;
	unsigned int seq;
	unsigned int state;
} GarageDoorData;

GarageDoorData buf;
byte data_to_send = false;
byte door_state = 0;
byte old_door_state = 0;


void setup() {                
  // initialize the digital pin as an output.
  // Pin 13 has an LED connected on most Arduino boards:
  pinMode(5, OUTPUT);     
  pinMode(6, OUTPUT); 

  Serial.begin(9600);  
  Serial.println("here we are");
  rf12_initialize(11, RF12_868MHZ, 212); 
  
  
    buf.house = 192;
  buf.device = 6;
  buf.seq = 1;
  
  rf12_sleep(0);

}

void loop() {
  int LDRValue = analogRead(A1);
  //Serial.println(LDRValue, DEC);
  int SwitchesValue = analogRead(A2);
  Serial.println(SwitchesValue, DEC);
  

  if (SwitchesValue < 100)
  { //door closed
    door_state = DOOR_CLOSED;
    digitalWrite(RED, LOW);    // set the LED off
    digitalWrite(GREEN, LOW);   // set the LED on
  }
  else
  if (SwitchesValue < 700)
  {
    door_state = DOOR_AJAR;
    digitalWrite(RED, HIGH);    // set the LED off
    digitalWrite(GREEN, HIGH);   // set the LED on
  }
  else
  if (SwitchesValue >=700)
  {//door open enough
    door_state = DOOR_OPEN;
    if (LDRValue < 500)
    {
      digitalWrite(RED, LOW);   // set the LED on
      digitalWrite(GREEN, HIGH);    // set the LED off
    }
    else
    {
      digitalWrite(RED, HIGH);    // set the LED off
      digitalWrite(GREEN, LOW);   // set the LED on
    }
  }

  if(door_state != old_door_state)
  {
    buf.state = door_state;
    data_to_send = true;
    old_door_state = door_state;
  }

  //check if data ready to be sent and send it if so:
  if (data_to_send == true)
  {
    data_to_send = false;
    
    rf12_sleep(-1);
    buf.seq++;
      while (!rf12_canSend())	// wait until sending is allowed
       rf12_recvDone();

       rf12_sendStart(0, &buf, sizeof buf);

      while (!rf12_canSend())	// wait until sending has been completed
         rf12_recvDone();
         delay(5);
      rf12_sleep(0);
  }
}
