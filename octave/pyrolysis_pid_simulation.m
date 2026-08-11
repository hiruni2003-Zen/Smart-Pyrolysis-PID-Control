clear;
clc;
close all;

% ==========================================
% SMART PYROLYSIS THERMAL PID SIMULATION
% ==========================================

% Temperature settings
setPoint = 400;       % deg C
ambientTemp = 25;     % deg C
temperature = 25;     % Initial temperature

% Thermal plant parameters
K = 500;              % Process gain
tau = 60;             % Time constant (seconds)

% PID parameters
Kp = 2.0;
Ki = 0.04;
Kd = 3.0;

% Simulation settings
dt = 0.1;
simulationTime = 600;

time = 0:dt:simulationTime;

% Storage
tempData = zeros(size(time));
powerData = zeros(size(time));
errorData = zeros(size(time));

% Initial PID values
integral = 0;
previousError = setPoint - temperature;

% ==========================================
% SIMULATION LOOP
% ==========================================

for i = 1:length(time)

    % ---- PID Controller ----

    error = setPoint - temperature;

    % ----- Conditional Integration Anti-Windup -----

derivative = (error - previousError) / dt;

pidUnsat = ...
    Kp * error + ...
    Ki * integral + ...
    Kd * derivative;

% Integrate only when controller is not driving further into saturation
if (pidUnsat > 0 && pidUnsat < 255) || ...
   (pidUnsat >= 255 && error < 0) || ...
   (pidUnsat <= 0 && error > 0)

    integral = integral + error * dt;

end

% Recalculate PID output after integral update
pidOutput = ...
    Kp * error + ...
    Ki * integral + ...
    Kd * derivative;

pidOutput = max(min(pidOutput, 255), 0);

    derivative = (error - previousError) / dt;

    pidOutput = ...
        Kp * error + ...
        Ki * integral + ...
        Kd * derivative;

    % PWM saturation: 0 - 255
    pidOutput = max(min(pidOutput, 255), 0);

    % Convert PWM into heater power 0 - 1
    heaterPower = pidOutput / 255;


    % ---- Thermal Plant ----

    dTdt = ...
        ((ambientTemp + K * heaterPower) ...
        - temperature) / tau;

    temperature = temperature + dTdt * dt;


    % ---- Save Data ----

    tempData(i) = temperature;
    powerData(i) = heaterPower * 100;
    errorData(i) = error;

    previousError = error;

end


% ==========================================
% TEMPERATURE GRAPH
% ==========================================

figure;

plot(time, tempData, 'LineWidth', 2);
hold on;

plot(time, ...
     setPoint * ones(size(time)), ...
     '--', 'LineWidth', 1.5);

grid on;

xlabel('Time (s)');
ylabel('Temperature (deg C)');

title('Smart Pyrolysis PID Temperature Response');

legend('Process Temperature', ...
       '400 deg C Setpoint');


% ==========================================
% HEATER POWER GRAPH
% ==========================================

figure;

plot(time, powerData, 'LineWidth', 2);

grid on;

xlabel('Time (s)');
ylabel('Heater Power (%)');

title('PID Heater Power Response');


% ==========================================
% PERFORMANCE ANALYSIS
% ==========================================

% Final temperature
finalTemp = tempData(end);

% Steady-state error
steadyStateError = abs(setPoint - finalTemp);

% Maximum temperature
maxTemp = max(tempData);

% Overshoot
overshoot = max(0, ...
    ((maxTemp - setPoint) / setPoint) * 100);

% Rise time: 10% to 90% of total temperature change
T10 = ambientTemp + 0.10 * (setPoint - ambientTemp);
T90 = ambientTemp + 0.90 * (setPoint - ambientTemp);

index10 = find(tempData >= T10, 1);
index90 = find(tempData >= T90, 1);

riseTime = time(index90) - time(index10);

% Settling time using +/- 2% band
tolerance = 0.02 * setPoint;

settlingTime = NaN;

for i = 1:length(time)

    remainingData = tempData(i:end);

    if all(abs(remainingData - setPoint) <= tolerance)
        settlingTime = time(i);
        break;
    end

end

fprintf('\n===== PID PERFORMANCE =====\n');
fprintf('Final Temperature: %.2f deg C\n', finalTemp);
fprintf('Steady-State Error: %.2f deg C\n', steadyStateError);
fprintf('Maximum Temperature: %.2f deg C\n', maxTemp);
fprintf('Overshoot: %.2f %%\n', overshoot);
fprintf('Rise Time: %.2f s\n', riseTime);
fprintf('Settling Time (2%%): %.2f s\n', settlingTime);
fprintf('Final Heater Power: %.2f %%\n', powerData(end));
