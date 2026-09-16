%% F1 Lap-Time and Telemetry Analysis
% Stage 4 - Simulated Circuit Telemetry

clear;
clc;
close all;

%% Create distance data

distance = 0:25:2000;

%% Create baseline speed profile - Lap A

speed_A = zeros(size(distance));

% Section 1: Acceleration along straight (0-400 m)
idx = distance <= 400;
speed_A(idx) = 180 + 0.30 * distance(idx);

% Section 2: Braking into Corner 1 (400-600 m)
idx = distance > 400 & distance <= 600;
speed_A(idx) = 300 - 0.90 * (distance(idx) - 400);

% Section 3: Acceleration out of Corner 1 (600-1000 m)
idx = distance > 600 & distance <= 1000;
speed_A(idx) = 120 + 0.45 * (distance(idx) - 600);

% Section 4: Braking into Corner 2 (1000-1200 m)
idx = distance > 1000 & distance <= 1200;
speed_A(idx) = 300 - 0.75 * (distance(idx) - 1000);

% Section 5: Acceleration out of Corner 2 (1200-1600 m)
idx = distance > 1200 & distance <= 1600;
speed_A(idx) = 150 + 0.375 * (distance(idx) - 1200);

% Section 6: Final braking zone (1600-1800 m)
idx = distance > 1600 & distance <= 1800;
speed_A(idx) = 300 - 0.65 * (distance(idx) - 1600);

% Section 7: Final acceleration zone (1800-2000 m)
idx = distance > 1800;
speed_A(idx) = 170 + 0.55 * (distance(idx) - 1800);

%% Create Lap B

speed_B = speed_A;

% Lap B brakes later into Corner 1
idx = distance >= 425 & distance <= 575;
speed_B(idx) = speed_A(idx) + 12;

% Lap B has a poorer exit from Corner 1
idx = distance > 600 & distance <= 850;
speed_B(idx) = speed_A(idx) - 8;

% Lap B carries more speed through Corner 2
idx = distance >= 1050 & distance <= 1300;
speed_B(idx) = speed_A(idx) + 10;

% Lap B has a slightly better final acceleration zone
idx = distance >= 1800;
speed_B(idx) = speed_A(idx) + 5;

%% Lap-time calculations

delta_distance = diff(distance);

avg_speed_A = (speed_A(1:end-1) + speed_A(2:end)) / 2;
avg_speed_B = (speed_B(1:end-1) + speed_B(2:end)) / 2;

avg_speed_A_ms = avg_speed_A / 3.6;
avg_speed_B_ms = avg_speed_B / 3.6;

delta_time_A = delta_distance ./ avg_speed_A_ms;
delta_time_B = delta_distance ./ avg_speed_B_ms;

cumulative_time_A = [0 cumsum(delta_time_A)];
cumulative_time_B = [0 cumsum(delta_time_B)];

total_time_A = sum(delta_time_A);
total_time_B = sum(delta_time_B);

time_delta = cumulative_time_A - cumulative_time_B;

fprintf('Lap A time: %.3f seconds\n', total_time_A);
fprintf('Lap B time: %.3f seconds\n', total_time_B);
fprintf('Lap-time difference (A - B): %.3f seconds\n', ...
    total_time_A - total_time_B);

%% Plot telemetry

figure;

tiledlayout(2,1);

% Speed comparison
nexttile;

plot(distance, speed_A, 'LineWidth', 1.5);
hold on;
plot(distance, speed_B, 'LineWidth', 1.5);
hold off;

ylabel('Speed (km/h)');
title('Simulated F1 Telemetry Comparison');
legend('Lap A','Lap B');
grid on;

% Time-delta comparison
nexttile;

plot(distance, time_delta, 'LineWidth', 1.5);
yline(0,'--');

xlabel('Distance (m)');
ylabel('Time Delta (s)');
grid on;

%% Export simulated telemetry to CSV

telemetry_table = table(distance', speed_A', speed_B', ...
    'VariableNames', {'Distance', 'Speed_A', 'Speed_B'});

writetable(telemetry_table, ...
    fullfile('data', 'simulated_telemetry.csv'));