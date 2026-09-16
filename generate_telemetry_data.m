%% Synthetic F1-Style Telemetry Data Generator
% Generates two simulated laps for the MATLAB Lap-Time and
% Telemetry Analysis project.
%
% Output channels:
% Distance, Speed, Throttle, Brake and Gear
%
% NOTE:
% This dataset is synthetic and is not real Formula 1 telemetry.

clear;
clc;

%% Distance samples

distance = (0:25:2000)';

%% Lap A - Baseline speed profile

speed_A = zeros(size(distance));

% Acceleration
idx = distance <= 400;
speed_A(idx) = 180 + 0.30 * distance(idx);

% Braking into Corner 1
idx = distance > 400 & distance <= 600;
speed_A(idx) = 300 - 0.90 * (distance(idx) - 400);

% Acceleration out of Corner 1
idx = distance > 600 & distance <= 1000;
speed_A(idx) = 120 + 0.45 * (distance(idx) - 600);

% Braking into Corner 2
idx = distance > 1000 & distance <= 1200;
speed_A(idx) = 300 - 0.75 * (distance(idx) - 1000);

% Acceleration out of Corner 2
idx = distance > 1200 & distance <= 1600;
speed_A(idx) = 150 + 0.375 * (distance(idx) - 1200);

% Final braking zone
idx = distance > 1600 & distance <= 1800;
speed_A(idx) = 300 - 0.65 * (distance(idx) - 1600);

% Final acceleration
idx = distance > 1800;
speed_A(idx) = 170 + 0.55 * (distance(idx) - 1800);

%% Lap B - Modified speed profile

speed_B = speed_A;

% Later braking into Corner 1
idx = distance >= 425 & distance <= 575;
speed_B(idx) = speed_A(idx) + 12;

% Reduced speed on Corner 1 exit
idx = distance > 600 & distance <= 850;
speed_B(idx) = speed_A(idx) - 8;

% Increased speed through Corner 2
idx = distance >= 1050 & distance <= 1300;
speed_B(idx) = speed_A(idx) + 10;

% Improved final acceleration
idx = distance >= 1800;
speed_B(idx) = speed_A(idx) + 5;

%% Throttle channels

throttle_A = zeros(size(distance));

throttle_A(distance <= 400) = 100;
throttle_A(distance > 400 & distance <= 600) = 0;
throttle_A(distance > 600 & distance <= 1000) = 100;
throttle_A(distance > 1000 & distance <= 1200) = 0;
throttle_A(distance > 1200 & distance <= 1600) = 100;
throttle_A(distance > 1600 & distance <= 1800) = 0;
throttle_A(distance > 1800) = 100;

throttle_B = throttle_A;

% Lap B remains on throttle longer before Corner 1
throttle_B(distance > 400 & distance < 450) = 100;

% Lap B reapplies throttle later after Corner 1
throttle_B(distance > 600 & distance <= 650) = 0;

% Lap B reapplies throttle earlier after Corner 2
throttle_B(distance > 1175 & distance <= 1200) = 100;

%% Brake channels

% Binary representation:
% 0 = brake inactive
% 1 = brake active

brake_A = zeros(size(distance));

brake_A(distance > 400 & distance <= 600) = 1;
brake_A(distance > 1000 & distance <= 1200) = 1;
brake_A(distance > 1600 & distance <= 1800) = 1;

brake_B = brake_A;

% Lap B begins braking later for Corner 1
brake_B(distance > 400 & distance <= 425) = 0;

%% Gear channels

% Simplified gear estimate based on vehicle speed.
% This is not intended to represent a real F1 gearbox model.

gear_A = ones(size(speed_A));
gear_B = ones(size(speed_B));

gear_A(speed_A >= 100) = 3;
gear_A(speed_A >= 150) = 4;
gear_A(speed_A >= 200) = 5;
gear_A(speed_A >= 250) = 6;
gear_A(speed_A >= 290) = 7;

gear_B(speed_B >= 100) = 3;
gear_B(speed_B >= 150) = 4;
gear_B(speed_B >= 200) = 5;
gear_B(speed_B >= 250) = 6;
gear_B(speed_B >= 290) = 7;

%% Create telemetry table

telemetry = table( ...
    distance, ...
    speed_A, speed_B, ...
    throttle_A, throttle_B, ...
    brake_A, brake_B, ...
    gear_A, gear_B);

%% Export dataset

output_file = fullfile( ...
    'data', 'simulated_multichannel_telemetry.csv');

writetable(telemetry, output_file);

%% Confirmation

fprintf('Synthetic telemetry dataset created successfully.\n');
fprintf('Number of telemetry samples: %d\n', height(telemetry));
fprintf('Saved to: %s\n', output_file);