import processing.serial.*;
Serial port;
PImage defaultImage;

String[] imageFiles = {"1.png","2.png","3.png","4.png"};
int imageCount = imageFiles.length;
PImage[] images = new PImage[imageCount];

int transparency1;

boolean fading = false;
boolean funfacts = false;

PImage currentImage;
PImage nextImage;

void setup() {
  //String arduinoPort = Serial.list()[1];
  port = new Serial(this, "/dev/ttyACM0", 9600); 
  port.bufferUntil('\n');
  for (int i=0; i<imageCount; i++) {
    images[i] = loadImage(imageFiles[i]);
  }
  size(1600,1200);
  transparency1 = 255;

  defaultImage = loadImage("default.png");
  background(255);
  tint(255,255,255,transparency1);
  image(defaultImage, 0, 0);
  currentImage = defaultImage; 
}

String buff = "";
long timer = millis() - 15000;

void draw() {

  if ( funfacts == false || millis() - timer > 15000 ) {
  
    while (port.available() > 0) {    
      buff = port.readStringUntil('\n');  
    }
    print(buff);
    if (buff.trim().equals("1")) {
      println(buff);
      //funfacts = true;
      if (!fading && !funfacts) {
        funfacts = true;
        fading = true;
        nextImage = images[getNextImageIndex()];
      }
    } else if (!fading && funfacts && buff.trim().equals("0")) {
      println(buff);
      funfacts = false;
      fading = true;
      nextImage = defaultImage;
    }
    buff="";
    if (fading) {
  //    if (nextImage == null) {
  //      nextImage = images[getNextImageIndex()];
   //   }
      fadeInImage();
    }
  }
}

int getNextImageIndex() {
   return int(random(4));
}


void fadeInImage() {
 // println("fading");
  if (transparency1 > 0) {
    background(255);
    transparency1-=90;
    tint(255,255,255,transparency1);
    image(currentImage,0,0);
  } else {
    background(255);
    tint(255,255,255,255);
    image(nextImage,0,0);
    currentImage = nextImage;
    nextImage = null;
    fading = false;
    if(currentImage != defaultImage) {
      timer = millis();
    }
    transparency1 = 255;
   //println("end fading");
  }
}
