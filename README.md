# Smart Pyrolysis Thermal PID Control System

Simulation and analysis of an ESP32-based closed-loop PID temperature control system for a first-order pyrolysis thermal process using Wokwi and GNU Octave.

## Project Overview

This project explores the design and simulation of a PID-based thermal control system for a pyrolysis process.

The objective is to regulate the process temperature at a desired setpoint using a simulated ESP32 controller, PWM-based heater control, and a first-order thermal process model.

The project includes:

- Thermal process modelling
- PID controller implementation
- PWM heater control
- Conditional-integration anti-windup
- PID gain comparison
- Setpoint tracking validation
- GNU Octave analysis
- ESP32 implementation in Wokwi

## System Architecture

The simulated closed-loop system follows this control structure:


Temperature Setpoint
        |
        v
   PID Controller
        |
        v
   PWM Heater Power
        |
        v
   Thermal Process
        |
        v
 Process Temperature
        |
        +------ Feedback ------> PID Controller


Thermal Process Model

The thermal process is represented using a first-order model:

tau(dT/dt) + T = Tambient + K*u

where:

T = process temperature
Tambient = ambient temperature
u = heater input from 0 to 1
K = process gain
tau = thermal time constant

The simulation uses:

Ambient Temperature = 25 deg C
Process Gain K       = 500
Time Constant tau    = 60 s

The corresponding transfer function is:

             500
G(s) = ----------------
          60s + 1

GNU Octave was used to examine the open-loop response of this model before implementing the closed-loop PID controller.

PID Controller

The controller follows the standard PID control law:

u(t) = Kp*e(t) + Ki*Integral(e(t)) + Kd*de(t)/dt

where:

Kp = proportional gain
Ki = integral gain
Kd = derivative gain
e(t) = setpoint error

PWM output is limited to the ESP32 control range of 0-255, corresponding to 0-100% heater power.

Anti-Windup

Conditional integration was implemented to reduce integral windup when the controller output reaches the PWM saturation limits.

This produced a smoother transient response compared with resetting the integral term when the setpoint was crossed.

PID Tuning Comparison

Three PID gain configurations were evaluated using the same thermal plant model.

PID Set	Kp	Ki	Kd	Rise Time	Settling Time	Overshoot	Steady-State Error
Set A	0.8	0.01	1.0	132.50 s	281.90 s	0.00%	0.32 deg C
Set B	1.2	0.02	2.0	93.10 s	176.30 s	0.00%	0.00 deg C
Set C	2.0	0.04	3.0	78.70 s	146.00 s	0.00%	0.00 deg C

Among the evaluated configurations, Set C produced the fastest rise and settling times while maintaining zero simulated overshoot and approximately zero steady-state error.

Selected PID Gains
Kp = 2.0
Ki = 0.04
Kd = 3.0

These gains are the selected values among the tested configurations and are not claimed to be globally optimal PID parameters.

Setpoint Tracking Validation

The selected controller was also evaluated under changing temperature references.

The test profile was:

0 - 250 s     -> 400 deg C
250 - 500 s   -> 350 deg C
500 - 750 s   -> 450 deg C

The controller tracked each setpoint change and returned to the required steady-state temperature without sustained oscillation in the simulation.

ESP32 / Wokwi Implementation

The selected PID controller was implemented in Wokwi using an ESP32.

The simulation includes:

PID control execution
PWM heater output
thermal process simulation
output saturation
conditional-integration anti-windup
serial monitoring of:
setpoint
process temperature
PWM output
heater power

For the 400 deg C operating point, the final steady-state result was approximately:

Setpoint       = 400.00 deg C
Temperature    = 400.00 deg C
PWM Output     = 191.25
Heater Power   = 75.00%

The 75% steady-state heater power is consistent with the simulated thermal model:

(400 - 25) / 500 = 0.75
Tools and Technologies
ESP32
Wokwi
GNU Octave
PID Control
PWM Control
Control-System Modelling
First-Order Transfer Functions
Embedded C/C++
Serial Monitoring
Repository Structure
Smart-Pyrolysis-PID-Control/
|
|-- README.md
|
|-- wokwi/
|   |-- sketch.ino
|   |-- diagram.json
|
|-- octave/
|   |-- pyrolysis_pid_simulation.m
|   |-- pid_comparison.m
|   |-- pid_setpoint_test.m
|
|-- results/
|   |-- simulation result images
Project Limitations

This project currently represents a simulation-based control-system study.

The values used for process gain and thermal time constant are assumed simulation parameters and were not obtained through system identification of a physical pyrolysis reactor.

Therefore, the current PID gains should not be directly transferred to a real high-temperature pyrolysis system without experimental modelling, controller tuning, appropriate power electronics, sensor validation, and hardware safety mechanisms.

Future Development

Possible future extensions include:

experimental identification of thermal process parameters
thermocouple-based temperature measurement
physical low-voltage thermal control prototype
hardware heater-driver implementation
over-temperature protection
sensor-fault detection
real-time monitoring interface
comparison between simulated and experimental responses
