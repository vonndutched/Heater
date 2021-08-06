//Pins
const int LM35 = A0;
const int relay = 8;

//variables
float temp = 0;
float setpoint = 45 ;

void setup() {
  //Set functions of sensor and actuator
  pinMode(LM35, INPUT);
  pinMode(relay, OUTPUT);

  //For Matlab Serial Communication
  Serial.begin(9600);

  //Turn on relay; negative logic
  digitalWrite(relay, LOW);
}

void loop() {
  //Compute for current temperature basis from datasheet
  temp = (5.0 * analogRead(LM35) * 100.0) / 1024;
  //Compare if temp reached setpoint
  if(temp >= setpoint){
    //Turn off relay; negative logic
    digitalWrite(relay, HIGH);
  }
  else{
    digitalWrite(relay, LOW);
  }
  Serial.println(temp);
  delay(1000);
}
