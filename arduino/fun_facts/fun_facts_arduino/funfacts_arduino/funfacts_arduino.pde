
// GoGreen single sensor test
// 11.05.2012 12:08


const int sonarPin = 10;
const int sendDelay = 200;
int senseRange = 200; 

void setup() {
  
  Serial.begin(9600); 
  Serial.print("Calibrating.\n");
  
  while (millis () < 4000){
    long d=getD(sonarPin);
  }

  Serial.print("Done!\n");
  
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

void loop() {
   
  long cm = getD(sonarPin);
  
  if (cm < senseRange){
   Serial.println(1); 
  }
  else{
   Serial.println(0); 
  }

  delay(sendDelay);
  
}

long microsecondsToCentimeters(long microseconds) {
  return microseconds / 29 / 2;
}





