const int heaterPin = 18;

// ===============================
// TEMPERATURE SETTINGS
// ===============================
float setPoint = 400.0;
float ambientTemp = 25.0;
float temperature = 25.0;

// ===============================
// FINAL SELECTED PID VALUES
// ===============================
float Kp = 2.0;
float Ki = 0.04;
float Kd = 3.0;

// ===============================
// PID VARIABLES
// ===============================
float integral = 0.0;
float previousError = 0.0;

// ===============================
// THERMAL PROCESS MODEL
// G(s) = 500 / (60s + 1)
// ===============================
float processGain = 500.0;
float timeConstant = 60.0;

// Simulation sample time
float dt = 0.1;

void setup() {

  Serial.begin(115200);

  pinMode(heaterPin, OUTPUT);

  previousError = setPoint - temperature;
}

void loop() {

  // =====================================
  // 1. CALCULATE CONTROL ERROR
  // =====================================

  float error = setPoint - temperature;


  // =====================================
  // 2. DERIVATIVE TERM
  // =====================================

  float derivative =
      (error - previousError) / dt;


  // =====================================
  // 3. UNSATURATED PID OUTPUT
  // =====================================

  float pidUnsat =
      Kp * error +
      Ki * integral +
      Kd * derivative;


  // =====================================
  // 4. CONDITIONAL INTEGRATION
  //    ANTI-WINDUP
  // =====================================

  if (
      (pidUnsat > 0 && pidUnsat < 255) ||

      (pidUnsat >= 255 && error < 0) ||

      (pidUnsat <= 0 && error > 0)
     )
  {
      integral += error * dt;
  }


  // =====================================
  // 5. FINAL PID OUTPUT
  // =====================================

  float pidOutput =
      Kp * error +
      Ki * integral +
      Kd * derivative;


  // PWM saturation
  pidOutput = constrain(pidOutput, 0, 255);


  // =====================================
  // 6. HEATER CONTROL
  // =====================================

  analogWrite(heaterPin, (int)pidOutput);

  float heaterPower =
      pidOutput / 255.0;


  // =====================================
  // 7. THERMAL PROCESS MODEL
  // =====================================

  float dTdt =
      ((ambientTemp +
        processGain * heaterPower)
       - temperature)
      / timeConstant;

  temperature += dTdt * dt;


  // =====================================
  // 8. SERIAL OUTPUT
  // =====================================

  Serial.print("SP:");
  Serial.print(setPoint, 2);

  Serial.print(",Temp:");
  Serial.print(temperature, 2);

  Serial.print(",PWM:");
  Serial.print(pidOutput, 2);

  Serial.print(",Power:");
  Serial.println(heaterPower * 100.0, 2);


  previousError = error;

  delay(100);
}
