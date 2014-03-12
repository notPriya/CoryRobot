//import libraries
import ketai.camera.*;
import ketai.cv.facedetector.*;

//required Android Bluetooth Libraries
import android.content.Intent;
import android.os.Bundle;
import ketai.net.bluetooth.*;
import ketai.net.*;

//cam variables
KetaiCamera cam;
int cameraID=1;
int maxFaces = 5;
KetaiSimpleFace[] faces = new KetaiSimpleFace[maxFaces];
float faceX;  // New located face x position
float faceY;  // New located face y position
float faceFactor;  // Ratio of size of camera to screen.
float currentFaceX;  // Tracked face x position
float currentFaceY;  // Tracked face y position
float threshold;  // Threshold for tracking.

//bluetooth variables
KetaiBluetooth bluetooth;
ArrayList<String> names;
String bluetoothDeviceName = "HC-06";
boolean connected = false;

//servoing variables
float servoFactor;  // Ratio of screen to robot joint angles.

//fonts
PFont font;

//load images
PImage happy_eyes;
PImage eyes;

//core variables
float FrameRate;

void setup() {
  /*-------general setup----------*/
  orientation(LANDSCAPE);
  imageMode(CENTER);
  font = createFont("Arial Bold",48);

  /*----------graphics setup---------*/

  //load images
  eyes = loadImage("Eyes.png");
  happy_eyes = loadImage("HappyEyes.png");

  /*------face tracking camera setup------*/

  //face rectangle setup
  stroke(0, 255, 0);
  strokeWeight(2);
  noFill();
  rectMode(CENTER);
  
  //start camera. Set camera id to specify which camera.
  cam = new KetaiCamera(this, 320, 240, 24);
  //cam.setCameraID(cameraID);
  println("MEOW");
  cam.start();
  
  //Constants for face positioning.
  faceFactor = width/cam.width;
  threshold = 20 * faceFactor;  // Off by 20 pixels.
  
  /*------bluetooth setup------*/
  
  //start listening for BT connections
  //bluetooth.start();
  //bluetooth.discoverDevices();
  
  /*------servo setup-----------*/
  servoFactor = 90/width;

}

void draw() {
  /*--------connecting bluetooth----------*/
  
  //if the thing has not been connected yet
  if (connected == true) // TODO FLIP
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
  
  /*--------track a face and get position-------*/
    
  //find faces
  faces = KetaiFaceDetector.findFaces(cam, maxFaces);
  
  // Flag that tells us if we found a close face.
  boolean foundFace = false;
  
  // Reset the faceX and faceY variables.
  faceX = currentFaceX;
  faceY = currentFaceY;
    
  for (int face=0; face < faces.length; face++)
  {  
    //Get the face positions.
    float newFaceX = (faces[face].location.x-cam.width/2)*faceFactor;
    float newFaceY = (faces[face].location.y-cam.height/2)*faceFactor;
    
    //If this is the face we are tracking, update the face locations.
    if ((newFaceX - currentFaceX) < threshold & (newFaceY - currentFaceY) < threshold)
    {
      //display face location x and y
      faceX = newFaceX;
      faceY = newFaceY;
      
      // Set the flag.
      foundFace = true;
    }    
  }
  
  // If we have only found one face, but it isnt close to what we
  // had before, switch to tracking the new face.
  if (faces.length == 1 & !foundFace) {
    faceX = (faces[0].location.x-cam.width/2)*faceFactor;
    faceY = (faces[0].location.y-cam.height/2)*faceFactor;
    currentFaceX = faceX;
    currentFaceY = faceY;
    foundFace = true;
  }
  
  //Update the current face as a linear interpolation between what we
  //had and where we are looking now.
  currentFaceX = lerp(currentFaceX,faceX,0.5);
  currentFaceY = lerp(currentFaceY,faceY,0.5);
  
  /*-------draw graphics-------*/
  
  //clear screen
  if (foundFace)
  {
    //draw face looking at person.
    background(color(0,90,90));
    image(happy_eyes,width/2-currentFaceX,height/2+currentFaceY,height*.8,height*.8);
  }
  else
  {
    //draw face at center 
    background(color(0,0,100));
    image(eyes,width/2,height/2,height*.8,height*.8);
  }
    
  //draw camera
  image(cam, cam.width/2, cam.height/2);
  
  //draw a rectangle for every face found
  for (int face=0; face < faces.length; face++)
  {
    noFill(); // Makes the rectangle not solid.
    //We only get the distance between the eyes so we base our bounding box off of that 
    rect(faces[face].location.x, faces[face].location.y, 2.5*faces[face].distance, 3.0*faces[face].distance);
  }
  
  /*------show information--------*/
  
  //show fps()
  if(frameCount % 100 == 0);
  {FrameRate = frameRate;}
  fill(255);
  textFont(font,24);
  text(FrameRate,width-100,30);
  text(currentFaceX,width-100,60);
  text(currentFaceY,width-100,90);
  if (connected)
  {
    text("Connected", 50, 30);
  }
  else
  {
    text("Not Connected!", 50, 30);
  }

  /*-----servo the robot head------*/
  //if the thing has been connected and we actually have a camera
  if(connected & cam.isStarted())
  {
    int yaw = round(-currentFaceX * servoFactor) + 90;  // 0 -> 180
    int pitch = round(currentFaceY * servoFactor) + 90;  // 0 -> 180
    // Left Ear, Right Ear, Roll, Pitch, Yaw.
    String servo_pos = "90,60,90," + pitch + "," + yaw;
    bluetooth.broadcast(servo_pos.getBytes());
  }  
}

// Reinitialize camera by poking screen.
void mousePressed()
{
  if (cam.isStarted())
  {
    cam.stop();
  }
  else
  {
    cam.start();
  }
}


//-----NECESSARY CAM CODE:-------//

//update the camera
void onCameraPreviewEvent()
{ cam.read(); }

//if exit, then stop the camera
void exit() 
{ cam.stop(); }

//-----NECESSARY BLUETOOTH CODE:-------//

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



