clc;
clear;
close all;

% =========================================================
% Compare PID, ACTC, and SMC responses
% 1) Joint 1 only
% 2) All joints
% =========================================================

% -----------------------------
% Load saved data
% -----------------------------
pid  = load('results/PID_data.mat');
actc = load('results/ACTC_data.mat');
smc  = load('results/SMC_data.mat');

% -----------------------------
% Use ACTC time as common time vector
% -----------------------------
t = actc.t;

% -----------------------------
% Interpolate responses to common time
% -----------------------------
q_pid  = interp1(pid.t,  pid.q_deg,  t, 'linear', 'extrap');
dq_pid = interp1(pid.t,  pid.dq_deg, t, 'linear', 'extrap');

q_actc  = interp1(actc.t, actc.q_deg,  t, 'linear', 'extrap');
dq_actc = interp1(actc.t, actc.dq_deg, t, 'linear', 'extrap');

q_smc  = interp1(smc.t, smc.q_deg,  t, 'linear', 'extrap');
dq_smc = interp1(smc.t, smc.dq_deg, t, 'linear', 'extrap');

% -----------------------------
% Reference trajectory
% -----------------------------
if isfield(actc, 'q_ref_plot')
    q_ref = actc.q_ref_plot;
elseif isfield(actc, 'qref_plot_deg')
    q_ref = actc.qref_plot_deg;
else
    error('Reference position for ACTC was not found.');
end

if isfield(actc, 'dq_ref_plot')
    dq_ref = actc.dq_ref_plot;
elseif isfield(actc, 'dqref_plot_deg')
    dq_ref = actc.dqref_plot_deg;
else
    error('Reference velocity for ACTC was not found.');
end

q_ref  = interp1(actc.t, q_ref,  t, 'linear', 'extrap');
dq_ref = interp1(actc.t, dq_ref, t, 'linear', 'extrap');

% -----------------------------
% Create image folder
% -----------------------------
if ~exist('resources/images', 'dir')
    mkdir('resources/images');
end

%% =========================================================
% Figure 1: Joint 1 only
% =========================================================

figure;

i = 1;

% -----------------------------
% Joint 1 position
% -----------------------------
subplot(2,1,1);

plot(t, q_ref(:,i), 'k--', 'LineWidth', 1.6);
hold on;
plot(t, q_pid(:,i),  'LineWidth', 1.4);
plot(t, q_actc(:,i), 'LineWidth', 1.4);
plot(t, q_smc(:,i),  'LineWidth', 1.4);

grid on;

xlabel('Time (s)');
ylabel('q_1 (deg)');
title('Joint 1 Position Comparison');

legend('Reference', 'PID', 'ACTC', 'SMC', 'Location', 'best');

% -----------------------------
% Joint 1 velocity
% -----------------------------
subplot(2,1,2);

plot(t, dq_ref(:,i), 'k--', 'LineWidth', 1.6);
hold on;
plot(t, dq_pid(:,i),  'LineWidth', 1.4);
plot(t, dq_actc(:,i), 'LineWidth', 1.4);
plot(t, dq_smc(:,i),  'LineWidth', 1.4);

grid on;

xlabel('Time (s)');
ylabel('dq_1 (deg/s)');
title('Joint 1 Velocity Comparison');

legend('Reference', 'PID', 'ACTC', 'SMC', 'Location', 'best');

set(gcf, 'Position', [100 100 1100 700]);

print(gcf, 'resources/images/Controllers_comparison_joint1', '-dpng', '-r300');


%% =========================================================
% Figure 2: All joints
% =========================================================

figure;

for i = 1:5

    % -----------------------------
    % Position comparison
    % -----------------------------
    subplot(5,2,2*i-1);

    plot(t, q_ref(:,i), 'k--', 'LineWidth', 1.5);
    hold on;
    plot(t, q_pid(:,i),  'LineWidth', 1.3);
    plot(t, q_actc(:,i), 'LineWidth', 1.3);
    plot(t, q_smc(:,i),  'LineWidth', 1.3);

    grid on;

    xlabel('Time (s)');
    ylabel(['q_', num2str(i), ' (deg)']);
    title(['Joint ', num2str(i), ' Position']);

    legend('Reference', 'PID', 'ACTC', 'SMC', 'Location', 'best');

    % -----------------------------
    % Velocity comparison
    % -----------------------------
    subplot(5,2,2*i);

    plot(t, dq_ref(:,i), 'k--', 'LineWidth', 1.5);
    hold on;
    plot(t, dq_pid(:,i),  'LineWidth', 1.3);
    plot(t, dq_actc(:,i), 'LineWidth', 1.3);
    plot(t, dq_smc(:,i),  'LineWidth', 1.3);

    grid on;

    xlabel('Time (s)');
    ylabel(['dq_', num2str(i), ' (deg/s)']);
    title(['Joint ', num2str(i), ' Velocity']);

    legend('Reference', 'PID', 'ACTC', 'SMC', 'Location', 'best');

end
sgtitle('Comparison of PID, ACTC, and SMC Responses');
set(gcf, 'Position', [100 50 1300 950]);

print(gcf, 'resources/images/Controllers_comparison_all_joints', '-dpng', '-r300');