//Bluetooth Code to Communicate with Arduino
// - John Choi

//required Android Bluetooth Libraries
import android.content.Intent;
import android.os.Bundle;
import ketai.net.bluetooth.*;
import ketai.net.*;


//font variables
PFont font;
int fontSize = 20;
int spaceWidth = fontSize;
int spaceHeight = fontSize*3;

//bluetooth variables
KetaiBluetooth bluetooth;
ArrayList<String> names;
String bluetoothDeviceName = "HC-06";
boolean connected = false;

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
boolean animEnded = true;
boolean mouseReady = true;

//core variables
float FrameRate;

//required bluetooth startup code
void onCreate(Bundle savedInstanceState) 
{
  super.onCreate(savedInstanceState);
  bluetooth = new KetaiBluetooth(this);
}

void onActivityResult(int requestCode, int resultCode, Intent data) 
{
  bluetooth.onActivityResult(requestCode, resultCode, data);
}

//setup code
void setup()
{   
  //display setup
  orientation(LANDSCAPE);
  background(78, 93, 75);
  noStroke();noSmooth();
  font = createFont("Arial Bold",fontSize);
  textFont(font,fontSize);

  //start listening for BT connections
  bluetooth.start();
  bluetooth.discoverDevices();
}

//draw loop
void draw()
{

  /*--------connecting bluetooth----------*/
  
  //if the thing has not been connected yet
  if (connected == false)
  {
    
    names = bluetooth.getDiscoveredDeviceNames();
    
    //find the thing we want to connect to
    for(int i = 0; i < names.size(); i++)
    {
      //if we found it
      if (names.get(i).toString() == bluetoothDeviceName);
      {
        //connect to it
        bluetooth.connectToDeviceByName(bluetoothDeviceName);
        connected = true;
      }
    }
  }
  
  /*-----------animation processing----------*/
  
  //update timer
  timer = millis();

  //if the things has been connected
  if(connected == true)
  {
    
    //if the animation didn't complete yet..  
    if (animEnded == false)
    {  
      
      //if previous frame finished
      if (abs(timer - animTime) > anim1duration[currentFrame])
      {
        animTime = timer;
        currentFrame += 1;
        
        //send animation data to arduino
        bluetooth.broadcast(anim1[currentFrame].getBytes());
        
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
      bluetooth.broadcast(anim1[currentFrame].getBytes());  
    }
    
    if (!mousePressed)
    {
      mouseReady =true;
    }
  
  }
    
  /*---------show graphics-----------*/
  
  //draw background
  background(color(0,0,50));
   
  /*--------show information--------*/
 
  //show bluetooth data to the screen
  if (connected == true)
  {
    text("Connected!", spaceWidth,spaceHeight);
  }
  else
  {
    text("Not connected!", spaceWidth, spaceHeight);
  }
  
  //show fps() and timer
  pushMatrix();
  if(frameCount % 100 == 0);
  {FrameRate = frameRate;}
  fill(255);
  text(FrameRate,width - spaceWidth*8,spaceHeight);
  text(timer*.001, width - spaceWidth*8,spaceHeight*2);
  popMatrix();
  
}


