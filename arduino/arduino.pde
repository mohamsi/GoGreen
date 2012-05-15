const int sonarPin = 5;
const int sonarPin2 = 12;

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

long buffer[6] = {0,0,0,0,0,0};
int bufferCounter = 0;


long timerStart = millis();
//boolean letThereBeLight;

void setup() {
  pinMode(ledPin,OUTPUT);
  Serial.begin(9600); 
  Serial.print("Calibrating.\n");
  
  while (millis () < 4000){
    long d=getD(sonarPin);
    long d2 = getD(sonarPin2);
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

int getD(int sonarPin) {
  
        long duration,cm;
        pinMode(sonarPin, OUTPUT);
        digitalWrite(sonarPin, LOW);
        delayMicroseconds(2);
        digitalWrite(sonarPin, HIGH);
        delayMicroseconds(5);
        digitalWrite(sonarPin, LOW);
        pinMode(sonarPin, INPUT);
        duration = pulseIn(sonarPin, HIGH);
        cm = microsecondsToCentimeters(duration);
        return cm;
        
}

void addToBuffer() {
  int i;
  for ( i = 0; i < 6; i++ ) {
      if (buffer[i] == 0) {
              buffer[i] = millis();
              bufferCounter++;
              break;
      }
  }
}

void ledOff () {
    if (millis() - timerStart > 300) {
      digitalWrite(ledPin,HIGH);
    }
}

void letThereBeLight () {
//    letThereBeLight = true;
    timerStart = millis();
    digitalWrite(ledPin, HIGH);
}
    
    
void loop() {
  ledOff();
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
  
  
  long cm = getD(sonarPin);
  long cm2 = getD(sonarPin2);
  
  /* SPAM BLOCK
  
  Serial.print("A: ");
  Serial.println(cm);
  
  Serial.print("B: ");
  Serial.println(cm2);
  
  */ // SPAM BLOCK 
  
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

