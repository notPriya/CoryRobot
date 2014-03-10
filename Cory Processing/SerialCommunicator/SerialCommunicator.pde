
//import libraries
import processing.serial.*; //for PC

//fonts
PFont font;
int fontsize = 12;
int spaceWidth = fontsize;
int spaceHeight = fontsize*3;

//serial variables
Serial serialPort;
int portNumber = 2;

//animation variables
String[] anim1 = { "90,90,90,90,90",
                   "60,60,80,110,60",
                   "120,120,100,110,120" };
int[] anim1duration = { 2000, 
                        2000,
                        2000 };
int timer = 0;
int animTime = 0;
int currentFrame = 0;
boolean animEnded = false;
boolean mouseReady = true;

//core variables
float FrameRate;

//setup code
void setup()
{
  
  //set the window to be fullsize
  size(displayWidth, displayHeight);
  size(400,400);
  orientation(LANDSCAPE);
  noStroke(); noSmooth();
  font = createFont("Arial Bold",fontsize);
  textFont(font, fontsize);

  //serial stuff
  String portName = Serial.list()[portNumber];
  serialPort = new Serial(this, portName, 9600);

  //send the first frame
  if(serialPort.available() > 0)
  {
    serialPort.write(anim1[0]);
  }
      
}


//draw to the screen 
void draw(){

  /*--------animation processing---------*/
  
  //update timer
  timer = millis();
  
  //if the animation didn't complete yet..  
  if (animEnded == false)
  {  
    
    //if previous frame finished
    if (abs(timer - animTime) > anim1duration[currentFrame])
    {
      animTime = timer;
      currentFrame += 1;
      
      //send animation data to arduino
      if(serialPort.available() > 0)
      {
        serialPort.write(anim1[currentFrame]);
      }
      
      //if we passed the last frame, then we completed the animation
      if(currentFrame == anim1.length - 1)
      {
        animEnded = true;
      }
      
    }
  
  }

  //use mouse click to replay animation
  if (mousePressed && mouseReady == true) 
  {
    mouseReady = false;
    animEnded = false;
    animTime = timer;
    currentFrame = 0;
    //send the first frame
    if(serialPort.available() > 0)
    {
      serialPort.write(anim1[0]);
    }
  }
  
  if (!mousePressed)
  {
    mouseReady =true;
  }
  
  /*---------show graphics-----------*/
  
  //draw background
  background(color(0,0,50));
 
   
  /*--------show information--------*/
  
  //print serial data to the screen 
  fill(255);
  for (int i = 0; i <Serial.list().length; i++)
  {  
    text(Serial.list()[i],spaceWidth*4, spaceHeight + i * spaceHeight);
    text(i, spaceWidth, spaceHeight + i * spaceHeight);  
  }    

  //show fps()
  pushMatrix();
  if(frameCount % 100 == 0);
  {FrameRate = frameRate;}
  fill(255);
  text(FrameRate,width - spaceWidth*8,spaceHeight);
  text(timer*.001, width - spaceWidth*8,spaceHeight*2);
  popMatrix();

}
