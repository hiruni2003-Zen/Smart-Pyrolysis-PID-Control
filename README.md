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

```text
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
