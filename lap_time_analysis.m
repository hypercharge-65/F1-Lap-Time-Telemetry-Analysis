%% F1-Style Lap-Time and Telemetry Analysis
% Compares two simulated laps using speed, throttle, brake and gear data.
% Reconstructs lap time from distance-based speed telemetry and performs
% a detailed analysis of Corner 1.
%
% NOTE:
% The input dataset is synthetic and is not real Formula 1 telemetry.

clear;
clc;
close all;

%% Import telemetry data

input_file = fullfile( ...
    'data', 'simulated_multichannel_telemetry.csv');

telemetry = readtable(input_file);

fprintf('Telemetry dataset loaded successfully.\n');
fprintf('Number of telemetry samples: %d\n\n', height(telemetry));

%% Extract telemetry channels

distance = telemetry.distance;

speed_A = telemetry.speed_A;
speed_B = telemetry.speed_B;

throttle_A = telemetry.throttle_A;
throttle_B = telemetry.throttle_B;

brake_A = telemetry.brake_A;
brake_B = telemetry.brake_B;

gear_A = telemetry.gear_A;
gear_B = telemetry.gear_B;

%% Reconstruct lap times

% Distance between consecutive telemetry samples
delta_distance = diff(distance);

% Approximate average speed across each distance interval
avg_speed_A = (speed_A(1:end-1) + speed_A(2:end)) / 2;
avg_speed_B = (speed_B(1:end-1) + speed_B(2:end)) / 2;

% Convert km/h to m/s
avg_speed_A_ms = avg_speed_A / 3.6;
avg_speed_B_ms = avg_speed_B / 3.6;

% Time taken through each interval:
% time = distance / speed
delta_time_A = delta_distance ./ avg_speed_A_ms;
delta_time_B = delta_distance ./ avg_speed_B_ms;

% Build cumulative lap-time traces
cumulative_time_A = [0; cumsum(delta_time_A)];
cumulative_time_B = [0; cumsum(delta_time_B)];

% Total reconstructed lap times
total_time_A = sum(delta_time_A);
total_time_B = sum(delta_time_B);

% Positive delta means Lap B is ahead
% Negative delta means Lap A is ahead
time_delta = cumulative_time_A - cumulative_time_B;

%% Overall lap results

fprintf('--- Overall Lap Comparison ---\n');
fprintf('Lap A time: %.3f s\n', total_time_A);
fprintf('Lap B time: %.3f s\n', total_time_B);
fprintf('Lap-time difference (A - B): %.3f s\n\n', ...
    total_time_A - total_time_B);

%% Corner 1 performance analysis

corner_start = 400;
corner_end = 850;

% Select samples within the Corner 1 analysis region
corner_idx = distance >= corner_start & distance <= corner_end;

corner_distance = distance(corner_idx);

corner_speed_A = speed_A(corner_idx);
corner_speed_B = speed_B(corner_idx);

corner_throttle_A = throttle_A(corner_idx);
corner_throttle_B = throttle_B(corner_idx);

corner_brake_A = brake_A(corner_idx);
corner_brake_B = brake_B(corner_idx);

%% Braking points

brake_idx_A = find(corner_brake_A > 0, 1, 'first');
brake_idx_B = find(corner_brake_B > 0, 1, 'first');

brake_point_A = corner_distance(brake_idx_A);
brake_point_B = corner_distance(brake_idx_B);

%% Minimum corner speeds

[min_speed_A, min_idx_A] = min(corner_speed_A);
[min_speed_B, min_idx_B] = min(corner_speed_B);

min_speed_distance_A = corner_distance(min_idx_A);
min_speed_distance_B = corner_distance(min_idx_B);

%% Throttle reapplication points

throttle_idx_A = find( ...
    corner_throttle_A(min_idx_A:end) > 0, 1, 'first');

throttle_idx_B = find( ...
    corner_throttle_B(min_idx_B:end) > 0, 1, 'first');

throttle_point_A = corner_distance( ...
    min_idx_A + throttle_idx_A - 1);

throttle_point_B = corner_distance( ...
    min_idx_B + throttle_idx_B - 1);

%% Corner 1 section times

start_idx = find(distance == corner_start, 1);
end_idx = find(distance == corner_end, 1);

section_time_A = ...
    cumulative_time_A(end_idx) - cumulative_time_A(start_idx);

section_time_B = ...
    cumulative_time_B(end_idx) - cumulative_time_B(start_idx);

section_delta = section_time_A - section_time_B;

%% Display Corner 1 results

fprintf('--- Corner 1 Performance Analysis ---\n');

fprintf('Lap A braking point: %.0f m\n', brake_point_A);
fprintf('Lap B braking point: %.0f m\n', brake_point_B);

fprintf('Lap A minimum speed: %.1f km/h at %.0f m\n', ...
    min_speed_A, min_speed_distance_A);

fprintf('Lap B minimum speed: %.1f km/h at %.0f m\n', ...
    min_speed_B, min_speed_distance_B);

fprintf('Lap A throttle reapplication: %.0f m\n', throttle_point_A);
fprintf('Lap B throttle reapplication: %.0f m\n', throttle_point_B);

fprintf('Lap A Corner 1 section time: %.3f s\n', section_time_A);
fprintf('Lap B Corner 1 section time: %.3f s\n', section_time_B);

fprintf('Corner 1 time difference (A - B): %.3f s\n', ...
    section_delta);

%% Multi-channel telemetry dashboard

figure('Name', 'F1-Style Telemetry Analysis');

tiledlayout(5,1, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

% Speed
nexttile;

plot(distance, speed_A, 'LineWidth', 1.5);
hold on;
plot(distance, speed_B, 'LineWidth', 1.5);
hold off;

ylabel('Speed (km/h)');
title('F1-Style Multi-Channel Telemetry Comparison');
legend('Lap A', 'Lap B', 'Location', 'best');
grid on;

% Throttle
nexttile;

plot(distance, throttle_A, 'LineWidth', 1.5);
hold on;
plot(distance, throttle_B, 'LineWidth', 1.5);
hold off;

ylabel('Throttle (%)');
ylim([-5 105]);
grid on;

% Brake
nexttile;

stairs(distance, brake_A, 'LineWidth', 1.5);
hold on;
stairs(distance, brake_B, 'LineWidth', 1.5);
hold off;

ylabel('Brake');
ylim([-0.1 1.1]);
yticks([0 1]);
grid on;

% Gear
nexttile;

stairs(distance, gear_A, 'LineWidth', 1.5);
hold on;
stairs(distance, gear_B, 'LineWidth', 1.5);
hold off;

ylabel('Gear');
yticks(1:7);
grid on;

% Time delta
nexttile;

plot(distance, time_delta, 'LineWidth', 1.5);
hold on;
yline(0, '--');
hold off;

xlabel('Distance (m)');
ylabel('\Delta t (s)');
grid on;

%% Save final figure

figure_file = fullfile( ...
    'figures', 'telemetry_comparison.png');

exportgraphics(gcf, figure_file, 'Resolution', 300);

fprintf('\nTelemetry figure saved to: %s\n', figure_file);