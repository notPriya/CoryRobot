//import libraries
import ketai.camera.*;
import ketai.cv.facedetector.*;

//cam variables
KetaiCamera cam;
int cameraID=1;
int maxFaces = 1;
KetaiSimpleFace[] faces = new KetaiSimpleFace[maxFaces];
float faceX;
float faceY;
float faceFactor;
float currentFaceX;
float currentFaceY;

//fonts
PFont font;

//load images
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

  /*------face tracking camera setup------*/

  //face rectangle setup
  stroke(0, 255, 0);
  strokeWeight(2);
  noFill();
  rectMode(CENTER);
  
  //start camera
  cam = new KetaiCamera(this, 320, 240, 24);
  cam.setCameraID(cameraID);
  cam.start();
  faceFactor = width/cam.width;
}

void draw() {

  /*--------track a face and get position-------*/
  
  //clear screen
  background(0);
  
  //draw camera
  image(cam, 160, 120);

  //find faces
  faces = KetaiFaceDetector.findFaces(cam, maxFaces);
  
  //draw a rectangle for every face found
  for (int face=0; face < faces.length; face++)
  {
    //We only get the distance between the eyes so we base our bounding box off of that 
    noFill();
    rect(faces[face].location.x, faces[face].location.y, 2.5*faces[face].distance, 3.0*faces[face].distance);
   
    //display face location x and y
    faceX = (faces[face].location.x-cam.width/2)*faceFactor;
    faceY = (faces[face].location.y-cam.height/2)*faceFactor;
    fill(255);
    textFont(font,24);
  }
  
  /*-------draw graphics-------*/
  
  //clear screen
  background(color(0,0,50));
  
  //draw face 
  currentFaceX = lerp(currentFaceX,faceX,0.25);
  currentFaceY = lerp(currentFaceY,faceY,0.25);
  image(eyes,width/2-currentFaceX,height/2+currentFaceY,height*.8,height*.8);
  
  /*------show information--------*/
  
  //show fps()
  if(frameCount % 100 == 0);
  {FrameRate = frameRate;}
  fill(255);
  textFont(font,24);
  text(FrameRate,width-100,30);
  text(faceX,width-100,60);
  text(faceY,width-100,90);

}

//-----NECESSARY CAM CODE:-------//

//update the camera
void onCameraPreviewEvent()
{ cam.read(); }

//if exit, then stop the camera
void exit() 
{ cam.stop(); }




