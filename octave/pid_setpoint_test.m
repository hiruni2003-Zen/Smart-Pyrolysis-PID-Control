clear;
clc;
close all;

% ==========================================
% SETPOINT TRACKING TEST
% Compare PID Set B vs Set C
% ==========================================

ambientTemp = 25;

% Thermal plant
K = 500;
tau = 60;

% Simulation
dt = 0.1;
simulationTime = 750;
time = 0:dt:simulationTime;

% PID sets
PIDsets = [
    1.2  0.02  2.0;   % Set B
    2.0  0.04  3.0    % Set C
];

names = {
    'Set B: Kp=1.2 Ki=0.02 Kd=2.0',
    'Set C: Kp=2.0 Ki=0.04 Kd=3.0'
};

figure;
hold on;
grid on;

% Setpoint profile
setPointData = zeros(size(time));

for i = 1:length(time)

    if time(i) < 250
        setPointData(i) = 400;

    elseif time(i) < 500
        setPointData(i) = 350;

    else
        setPointData(i) = 450;
    end

end


% ==========================================
% RUN BOTH CONTROLLERS
% ==========================================

for p = 1:2

    Kp = PIDsets(p,1);
    Ki = PIDsets(p,2);
    Kd = PIDsets(p,3);

    temperature = ambientTemp;
    integral = 0;

    previousError = setPointData(1) - temperature;

    tempData = zeros(size(time));
    powerData = zeros(size(time));

    for i = 1:length(time)

        setPoint = setPointData(i);

        error = setPoint - temperature;

        derivative = ...
            (error - previousError) / dt;

        % Unsaturated PID output
        pidUnsat = ...
            Kp * error + ...
            Ki * integral + ...
            Kd * derivative;

        % Conditional integration anti-windup
        if (pidUnsat > 0 && pidUnsat < 255) || ...
           (pidUnsat >= 255 && error < 0) || ...
           (pidUnsat <= 0 && error > 0)

            integral = integral + error * dt;

        end

        % PID output
        pidOutput = ...
            Kp * error + ...
            Ki * integral + ...
            Kd * derivative;

        % PWM saturation
        pidOutput = max(min(pidOutput,255),0);

        heaterPower = pidOutput / 255;


        % Thermal plant
        dTdt = ...
            ((ambientTemp + K*heaterPower) ...
            - temperature) / tau;
5
        temperature = ...
            temperature + dTdt*dt;


        tempData(i) = temperature;
        powerData(i) = heaterPower*100;

        previousError = error;

    end

    plot(time,tempData,'LineWidth',1.8);

end


% Plot changing setpoint
plot(time,setPointData,'--','LineWidth',2);

xlabel('Time (s)');
ylabel('Temperature (deg C)');

title('PID Setpoint Tracking Comparison');

legend(
    names{1},
    names{2},
    'Setpoint',
    'Location','southeast'
);
