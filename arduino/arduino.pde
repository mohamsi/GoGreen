const int fancyPingA = 2; //trigger
const int fancyPongA = 5; //echo
const int fancyPingB = 12; //trigger
const int fancyPongB = 8; //echo

const int ledPin = 10;
  
int total = 0;

long emptyStair;
long emptyStair2;
long threshold;
long threshold2;
long deadSpace = 10;

long lastValue; 
long lastValue2;

const int bufferLength = 12;
long buffer[bufferLength];
int bufferCounter = 0;

boolean calibration = true;

long timerStart = millis();

long lastBufferAddition = millis();
long lastSensorB = millis();

void setup() {
  pinMode(ledPin,OUTPUT);
  digitalWrite(ledPin,LOW);
        
  Serial.begin(9600); 
  Serial.print("Calibrating.\n");
  
  while (millis () < 5000){
    long d = getDistance(fancyPingA, fancyPongA);
    delay(50);
    long d2 = getDistance(fancyPingB, fancyPongB);
    emptyStair = d;
    emptyStair2 = d2;
    lastValue = d;
    lastValue2 = d2;
  }
  calibration = false;

  threshold = emptyStair - deadSpace;
  threshold2 = emptyStair2 - deadSpace;
  Serial.print("Range: ");
  Serial.print(emptyStair);
  Serial.print("\nThreshold (A): ");
  Serial.println(threshold);
  Serial.print("Threshold (B): ");
  Serial.println(threshold2);
  
}

long getDistance(int ping, int pong) {
  long duration, inches, cm;
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
  if (calibration) {
	return constrain(cm, 5, 230);
  }
  return cm;
}

//add to buffer the current time indicating when someone passed sensor A
void addToBuffer() {
  if ( millis() - lastBufferAddition < 1000) {
     return; 
  }
  //Serial.print("buffer plus 1 ");
  //Serial.println(millis());
  lastBufferAddition = millis();
  int i;
  for ( i = 0; i < bufferLength; i++ ) {
      if (buffer[i] == 0) {
              buffer[i] = millis();
              bufferCounter++;
              break;
      }
  }
  //Serial.println("added to buffer ");
  //Serial.print(bufferCounter);
  //Serial.print(" ");
  //printBuffer();
}

//make sure we always remove the oldest non-zero value (sort the buffer first)
void removeFromBuffer() {
  isort(buffer,bufferLength);
  for (int i = bufferLength-1; i >= 0; i--) {
    if(buffer[i] == 0) {
      continue;
    } else {
      buffer[i] = 0;
      bufferCounter--;
      break;
    }
  }
  //Serial.print("removed from buffer ");
  //Serial.print(bufferCounter);
  //Serial.print(" ");  
  //printBuffer();
}

void printBuffer() {
	Serial.print("Buffer: ");	
	for (int i = 0; i<bufferLength; i++) {
		Serial.print(buffer[i]);
                Serial.print(" ");
	}
	Serial.println();
}

void cleanBuffer() {
  //remove from the buffer any values that are older than 2000ms
  int i;
  for ( i = 0; i < bufferLength; i++ ) {
      if (buffer[i] != 0) {
          if ( millis() - buffer[i] > 4000 ) {
             // Serial.println("removing from buffer");
              buffer[i] = 0;
              bufferCounter--;
          }
      }
  }
}

boolean green = false;

//check if we need to turn off the LED
void led () {
    if (millis() - timerStart > 150) {
      digitalWrite(ledPin,LOW);
      green = false;
    } else {
      digitalWrite(ledPin,HIGH);
    }
}

//turn on the LED
void letThereBeLight () {
    green = true;
    timerStart = millis();
    digitalWrite(ledPin, HIGH);
}
    
    
void loop() {
  //check if we need to turn off the led
  led();

  //remove from the buffer any values that are older than 2000ms
  cleanBuffer();
  
  //get the distance for each sensor
  //ignore values higher than threshold by setting them equal to threshold
  long cm = getDistance(fancyPingA, fancyPongA);
  if (cm > threshold)
    cm = threshold;
  delay(5);
  long cm2 = getDistance(fancyPingB, fancyPongB);
  if (cm2 > threshold2)
    cm2 = threshold2;

  // SPAM BLOCK
  /*
  Serial.print("A: ");
  Serial.print(millis());
  Serial.print(" ");
  Serial.println(cm);
   
  Serial.print("B: ");
  Serial.print(millis());
  Serial.print(" ");
   
  Serial.println(cm2);
 */
  //delay(25);
  
    //check if someone passed sensor A
	//		we ignore values higher than 300
    if (lastValue < threshold && cm >= threshold && cm < 300) {
      addToBuffer();
      
    } 
    
	//check if someone passed sensor B after passing sensor A
	//		we ignore values higher than 300
   if ( ((lastValue2 < threshold2) && (cm2 >= threshold2)) && (bufferCounter > 0) && cm2 < 300 && (millis() - lastSensorB > 1000)) {
      	total = total++;
	Serial.println("1");
        lastSensorB = millis();
        letThereBeLight();
        removeFromBuffer();
      	//bufferCounter--;
      	//buffer[0] = 0;
    } else if (((lastValue2 < threshold2) && (cm2 >= threshold2))) {
      //Serial.print("whats wrong with you? ");
      //Serial.print(bufferCounter);
      
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

