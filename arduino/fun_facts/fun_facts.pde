PImage defaultImage;

String[] imageFiles = {"1.png","2.png","3.png","4.png"};
int imageCount = imageFiles.length;
PImage[] images = new PImage[imageCount];

int transparency1;

boolean fading = true;

PImage currentImage;
PImage nextImage;

void setup() {
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

void draw(){
  if (fading) {
    if (nextImage == null) {
      nextImage = images[getNextImageIndex()];
    }
    fadeInImage();
  }
}

int getNextImageIndex() {
   return int(random(4));
}

void fadeInImage() {
  if (transparency1 > 0) {
    background(255);
    transparency1-=5;
    tint(255,255,255,transparency1);
    image(currentImage,0,0);
  } else {
    background(255);
    tint(255,255,255,255);
    image(nextImage,0,0);
    currentImage = nextImage;
    nextImage = null;
    fading = false;
  }
}
