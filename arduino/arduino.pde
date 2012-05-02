const int sonarPin = 10;
const int sensorPin = sonarPin;
  
 int emptyStair;
int threshold;
int lastValue; 

int total = 0;

int rangevalue[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0};
long pulse;
int modE;
int arraysize = 5;

void setup() {
Serial.begin(9600); 
    Serial.print("Calibrating.\n");
  
  while (millis () < 4000){
    long d=getDistance();
    emptyStair = d;
    lastValue = d;
  }
  
  threshold = emptyStair - 0;
  Serial.print("Range: ");
  Serial.print(emptyStair);
  Serial.print("\nThreshold: ");
  Serial.print(threshold);
}


long getDistance(){
    // establish variables for duration of the ping, 
  
    // and the distance result in centimeters:
  
    for (int i = 0; i < arraysize; i++) {
            
          
        long duration,cm;
      
        // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
      
        pinMode(sonarPin, OUTPUT);
      
        digitalWrite(sonarPin, LOW);
      
        delayMicroseconds(2);
      
        digitalWrite(sonarPin, HIGH);
      
        delayMicroseconds(5);
      
        digitalWrite(sonarPin, LOW);
      
        // The same pin is used to read the signal from the EZ4: a HIGH
      
        // pulse whose duration is the time (in microseconds) from the sending
      
        // of the ping to the reception of its echo off of an object.
      
        pinMode(sonarPin, INPUT);
      
        duration = pulseIn(sonarPin, HIGH);
      
        // convert the time into a distance
      
        cm = microsecondsToCentimeters(duration);
        rangevalue[i] = cm;
    }
  //Serial.print("Unsorted: ");
  //printArray(rangevalue,arraysize);
  isort(rangevalue,arraysize);
  //Serial.print("Sorted: ");
  //printArray(rangevalue,arraysize);
  modE = mode(rangevalue,arraysize);
  //Serial.print("The mode/median is: ");
  //Serial.print(modE);
  //Serial.println();

    return modE;
}

void loop()

{


  long cm = getDistance();
  //Serial.print(cm);

  //Serial.print("cm");

  //Serial.println();
    if (lastValue < threshold && cm >= threshold) {
      total++;
      Serial.println("1");
    } 
    lastValue = cm;
  delay(100);
  
}

long microsecondsToCentimeters(long microseconds)

{

  // The speed of sound is 340 m/s or 29 microseconds per centimeter.

  // The ping travels out and back, so to find the distance of the

  // object we take half of the distance travelled.

  return microseconds / 29 / 2;

}

/*-----------Functions------------*/ //Function to print the arrays.
void printArray(int *a, int n) { 


  for (int i = 0; i < n; i++)
  {
    Serial.print(a[i], DEC);
    Serial.print(' ');
  }

  Serial.println();
} 


//Sorting function
// sort function (Author: Bill Gentles, Nov. 12, 2010)
void isort(int *a, int n){
// *a is an array pointer function


  for (int i = 1; i < n; ++i)
  {
    int j = a[i];
    int k;
    for (k = i - 1; (k >= 0) && (j < a[k]); k--)
    {
      a[k + 1] = a[k];
    }
    a[k + 1] = j;
  }
} 


//Mode function, returning the mode or median.
int mode(int *x,int n){ 

  int i = 0;
  int count = 0;
  int maxCount = 0;
  int mode = 0;
  int bimodal;
  int prevCount = 0;

  while(i<(n-1)){

    prevCount=count;
    count=0;

    while(x[i]==x[i+1]){

      count++;
      i++;
    }

    if(count>prevCount&count>maxCount){
      mode=x[i];
      maxCount=count;
      bimodal=0;
    }
    if(count==0){
      i++;
    }
    if(count==maxCount){//If the dataset has 2 or more modes.
      bimodal=1;
    }
    if(mode==0||bimodal==1){//Return the median if there is no mode.
      mode=x[(n/2)];
    }
    return mode;
  }
} 




