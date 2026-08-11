clear;
clc;
close all;

% ==========================================
% PID TUNING COMPARISON
% ==========================================

setPoint = 400;
ambientTemp = 25;

K = 500;
tau = 60;

dt = 0.1;
simulationTime = 600;
time = 0:dt:simulationTime;

% PID sets: [Kp Ki Kd]
PIDsets = [
    0.8  0.01  1.0;
    1.2  0.02  2.0;
    2.0  0.04  3.0
];

names = {
    'Set A: Kp=0.8 Ki=0.01 Kd=1.0',
    'Set B: Kp=1.2 Ki=0.02 Kd=2.0',
    'Set C: Kp=2.0 Ki=0.04 Kd=3.0'
};

figure;
hold on;
grid on;

for p = 1:3

    Kp = PIDsets(p,1);
    Ki = PIDsets(p,2);
    Kd = PIDsets(p,3);

    temperature = ambientTemp;
    integral = 0;
    previousError = setPoint - temperature;

    tempData = zeros(size(time));

    for i = 1:length(time)

        error = setPoint - temperature;

        derivative = (error - previousError) / dt;

        % Unsaturated controller output
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

        % Recalculate PID
        pidOutput = ...
            Kp * error + ...
            Ki * integral + ...
            Kd * derivative;

        % PWM saturation
        pidOutput = max(min(pidOutput,255),0);

        heaterPower = pidOutput / 255;

        % Thermal process
        dTdt = ...
            ((ambientTemp + K*heaterPower) ...
            - temperature) / tau;

        temperature = temperature + dTdt*dt;

        tempData(i) = temperature;

        previousError = error;

    end

    % ======================================
    % PERFORMANCE CALCULATIONS
    % ======================================

    finalTemp = tempData(end);

    steadyError = abs(setPoint-finalTemp);

    maxTemp = max(tempData);

    overshoot = ...
        max(0,((maxTemp-setPoint)/setPoint)*100);

    T10 = ambientTemp + ...
          0.10*(setPoint-ambientTemp);

    T90 = ambientTemp + ...
          0.90*(setPoint-ambientTemp);

    index10 = find(tempData >= T10,1);
    index90 = find(tempData >= T90,1);

    riseTime = time(index90)-time(index10);

    tolerance = 0.02*setPoint;

    settlingTime = NaN;

    for j = 1:length(time)

        if all(abs(tempData(j:end)-setPoint) <= tolerance)

            settlingTime = time(j);
            break;

        end
    end

    % Print results
    fprintf('\n===== PID SET %c =====\n', ...
            char(64+p));

    fprintf('Kp = %.2f, Ki = %.3f, Kd = %.2f\n', ...
            Kp,Ki,Kd);

    fprintf('Rise Time: %.2f s\n',riseTime);

    fprintf('Settling Time: %.2f s\n', ...
            settlingTime);

    fprintf('Overshoot: %.2f %%\n',overshoot);

    fprintf('Steady-State Error: %.2f deg C\n', ...
            steadyError);

    % Add response to comparison graph
    plot(time,tempData,'LineWidth',1.8);

end

% Setpoint
plot(time,...
     setPoint*ones(size(time)),...
     '--','LineWidth',1.5);

xlabel('Time (s)');
ylabel('Temperature (deg C)');

title('PID Tuning Comparison - Thermal Process');

legend(
    names{1},
    names{2},
    names{3},
    '400 deg C Setpoint',
    'Location','southeast'
);
