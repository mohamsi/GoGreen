int fancyPingA = 2; //trigger
int fancyPongA = 5; //echo
int fancyPingB = 0; //trigger
int fancyPongB = 0; //echo

const int ledPin = 10;
  
int total = 0;
int emptyStair;
int emptyStair2;
int threshold;
int threshold2;
int lastValue; 
int lastValue2;
int deadSpace = 20;
int passedFirst = 0;
long previousMillis = 0;
long interval = 1000;

long buffer[10] = {0,0,0,0,0,0,0,0,0,0};
int bufferCounter = 0;


long timerStart = millis();
//boolean letThereBeLight;

void setup() {
  pinMode(ledPin,OUTPUT);
  digitalWrite(ledPin,LOW);
        
  Serial.begin(9600); 
  Serial.print("Calibrating.\n");
  
  while (millis () < 4000){
    long d = getDistanceFancy(fancyPingA, fancyPongA);
    long d2 = getDistanceFancy(fancyPingB, fancyPongB);
    emptyStair = d;
    emptyStair2 = d2;
    lastValue = d;
    lastValue2 = d2;
  }
  
  threshold = emptyStair - deadSpace;
  threshold2 = emptyStair2 - deadSpace;
  Serial.print("Range: ");
  Serial.print(emptyStair);
  Serial.print("\nThreshold (A): ");
  Serial.println(threshold);
  Serial.print("Threshold (B): ");
  Serial.println(threshold2);
  
}

long getDistanceFancy(int ping, int pong) {
  long duration, inches, cm;
 //Serial.
  //// The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  pinMode(ping, OUTPUT);
  digitalWrite(ping, LOW);
  delayMicroseconds(2);
  digitalWrite(ping, HIGH);
  delayMicroseconds(10);
  digitalWrite(ping, LOW);
 
  // The same pin is used to read the signal from the PING))): a HIGH
  // pulse whose duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(pong, INPUT);
  duration = pulseIn(pong, HIGH);
 
  // convert the time into a distance
  cm = microsecondsToCentimeters(duration);
  return cm;
}

void addToBuffer() {
  int i;
  for ( i = 0; i < 10; i++ ) {
      if (buffer[i] == 0) {
              buffer[i] = millis();
              bufferCounter++;
              break;
      }
  }
}

boolean green = false;

void led () {
    if (millis() - timerStart > 150) {
      //timerStart = millis();
      digitalWrite(ledPin,LOW);
      green = false;
    } else {
      digitalWrite(ledPin,HIGH);
    }
}




void letThereBeLight () {
    green = true;
    timerStart = millis();
    digitalWrite(ledPin, HIGH);
}
    
    
void loop() {
  led();
  //digitalWrite(ledPin,HIGH);
 // delay(500);
  int i;
  for ( i = 0; i < 6; i++ ) {
      if (buffer[i] != 0) {
          if ( millis() - buffer[i] > 2000 ) {
             // Serial.println("removing from buffer");
              buffer[i] = 0;
              bufferCounter--;
          }
      }
  }
  
  
  //long cm = getD(sonarPin);
  long cm = getDistanceFancy(fancyPingA, fancyPongA);
  delay(5);
  long cm2 = getDistanceFancy(fancyPingB, fancyPongB);
  
  // SPAM BLOCK
  
  Serial.print("A: ");
  Serial.println(cm);
  
  Serial.print("B: ");
  Serial.println(cm2);
  
  delay(250);
  
  
    if (lastValue < threshold && cm >= threshold) {
      //passedFirst++;
      addToBuffer();
      //Serial.print("Passed first. \n");
      //Serial.println(bufferCounter);
      //Serial.println(passedFirst);
      
      
    } 
    
    if ( ((lastValue2 < threshold2) && (cm2 >= threshold)) && (bufferCounter > 0)) {
      total = total++;
      //Serial.print("Passed second. \nTotal: ");
      //Serial.println(total);
	Serial.println("1");
        letThereBeLight();
      //passedFirst = passedFirst--;
      //hasPassed = false;
      bufferCounter--;
      buffer[0] = 0;
    }
    
    lastValue2 = cm2;
    lastValue = cm;
    
    // delay(20);
  
}

//Sorting function
// sort function (Author: Bill Gentles, Nov. 12, 2010)
void isort(long *a, int n){
// *a is an array pointer function


  for (int i = 1; i < n; ++i)
  {
    long j = a[i];
    int k;
    for (k = i - 1; (k >= 0) && (j < a[k]); k--)
    {
      a[k + 1] = a[k];
    }
    a[k + 1] = j;
  }
} 



long microsecondsToCentimeters(long microseconds) {
  return microseconds / 29 / 2;
}

