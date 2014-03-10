// animateSerial
// By John Choi

#include <Servo.h> 
#include <SoftwareSerial.h>

/* --- animServo class --- */
class animServo
{
  public:
    animServo(int pin, int minPos, int maxPos);
    void attachPin();
    void moveUp();
    void moveDown();
    void movePos();
    
    Servo servo;
    int pin;
    int pos;
    int toPos;
    int minPos;
    int maxPos;
    boolean atPos;
  private:  
};

animServo::animServo(int _pin, int _minPos, int _maxPos)
{
  pin = _pin;
  minPos = _minPos;
  maxPos = _maxPos;
  pos = 90;
  toPos = 90;
  atPos = true;
}

void animServo::attachPin()
{
  servo.attach(pin);
}

void animServo::moveUp()
{
  if (pos < maxPos)
  {
    pos += 1;
  }
  else
  {
    pos = maxPos;
  }
  servo.write(pos);
}

void animServo::moveDown()
{
  if (pos > minPos)
  {
    pos -= 1;
  }
  else
  {
    pos = minPos;
  }
  servo.write(pos);
}

void animServo::movePos()
{
  //clamp toPos
  if (toPos < minPos)
  {
    toPos = minPos;
  }
  if (toPos > maxPos)
  {
    toPos = maxPos;
  }
  
  //now move to position
  if(pos != toPos)
  {  
    if(pos < toPos)
    {
      pos += 1;
      atPos = false;
      servo.write(pos);
    }
    else if(pos > toPos)
    {
      pos -= 1;
      atPos = false;
      servo.write(pos);
    }
  }
  else
  {
    atPos = true;
  }
}

/* ----------------- */


/* ------ Begin Robot Multisweep code: ------- */

//setup bluetooth pins
SoftwareSerial bluetooth(12,13); //RX TX

//set servos:
animServo ear1(2,10,170);
animServo ear2(3,10,170);
animServo roll(4,60,110);
animServo pitch(5,60,110);
animServo yaw(6,30,150);

int wait = 10; 

void setup() 
{   
  //attach all the servos
  ear1.attachPin();
  ear2.attachPin();
  roll.attachPin();
  pitch.attachPin();
  yaw.attachPin();
  
  //begin serial
  Serial.begin(9600);
  Serial.println("ready");

  //begin bluetooth serial
  bluetooth.begin(9600);
  
} 
 
void loop() 
{ 
  
  while (Serial.available() > 0)
  {
    //receive serial string
    ear1.toPos = Serial.parseInt();
    ear2.toPos = Serial.parseInt();
    roll.toPos = Serial.parseInt();
    pitch.toPos = Serial.parseInt();
    yaw.toPos = Serial.parseInt();
    //print serial string
    Serial.print(ear1.toPos,DEC);
    Serial.print(" ");
    Serial.print(ear2.toPos,DEC);
    Serial.print(" ");
    Serial.print(roll.toPos,DEC);
    Serial.print(" ");
    Serial.print(pitch.toPos,DEC);
    Serial.print(" ");
    Serial.println(yaw.toPos,DEC);
  }
  
  while (bluetooth.available() > 0)
  {
    //receive serial string
    ear1.toPos = bluetooth.parseInt();
    ear2.toPos = bluetooth.parseInt();
    roll.toPos = bluetooth.parseInt();
    pitch.toPos = bluetooth.parseInt();
    yaw.toPos = bluetooth.parseInt();
    //print serial string
    Serial.print(ear1.toPos,DEC);
    Serial.print(" ");
    Serial.print(ear2.toPos,DEC);
    Serial.print(" ");
    Serial.print(roll.toPos,DEC);
    Serial.print(" ");
    Serial.print(pitch.toPos,DEC);
    Serial.print(" ");
    Serial.println(yaw.toPos,DEC);
  }
  
  //now move the servos
  ear1.movePos();
  ear2.movePos();
  roll.movePos();
  pitch.movePos();
  yaw.movePos();
  
  delay(wait);
  
} 
