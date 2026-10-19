clear;
clc;
close all;

% =========================================================
% Run PID with Gravity Compensation and Measurement Noise
% =========================================================

% Add noise model folder
addpath('noise_model');

% -----------------------------
% Initial conditions
% -----------------------------
q0  = zeros(5,1);
dq0 = zeros(5,1);

x0 = [q0; dq0];

% Integral error initial condition
e_int0 = zeros(5,1);

X0 = [x0; e_int0];   % 15 x 1

% -----------------------------
% Simulation time
% -----------------------------
tspan = 0:0.001:20;

% -----------------------------
% Reference
% -----------------------------
q_ref  = deg2rad([45; 45; 45; 45; 45]);
dq_ref = zeros(5,1);

% -----------------------------
% PID gains
% -----------------------------
Kp = diag([3 300 150 150 150]);
Kd = diag([2 150 50 50 50]);
Ki = diag([0 0 0 0 0]);

% -----------------------------
% Create measurement noise
% -----------------------------
noise = createNoiseConfig([tspan(1) tspan(end)]);

% To disable noise:
% noise.enabled = false;

% Plot generated noise
plotMeasurementNoise(noise);

% -----------------------------
% Run simulation
% -----------------------------
Xdot = @(t,X) PID_closed_loop_noise( ...
    t, X, q_ref, dq_ref, Kp, Ki, Kd, noise);

[t, X] = ode45(Xdot, tspan, X0);

% -----------------------------
% Extract simulation results
% -----------------------------
q     = X(:,1:5);
dq    = X(:,6:10);
e_int = X(:,11:15);

qref_plot  = repmat(q_ref',  length(t), 1);
dqref_plot = repmat(dq_ref', length(t), 1);

% -----------------------------
% Convert to degrees
% -----------------------------
q_deg  = rad2deg(q);
dq_deg = rad2deg(dq);

qref_plot_deg  = rad2deg(qref_plot);
dqref_plot_deg = rad2deg(dqref_plot);

% =========================================================
% Reconstruct measured signals and noise
% =========================================================

N = length(t);

q_meas_all  = zeros(N,5);
dq_meas_all = zeros(N,5);

q_noise_all  = zeros(N,5);
dq_noise_all = zeros(N,5);

for k = 1:N

    qk  = q(k,:)';
    dqk = dq(k,:)';

    [q_meas_k, dq_meas_k, q_noise_k, dq_noise_k] = ...
        addMeasurementNoise(t(k), qk, dqk, noise);

    q_meas_all(k,:)  = q_meas_k';
    dq_meas_all(k,:) = dq_meas_k';

    q_noise_all(k,:)  = q_noise_k';
    dq_noise_all(k,:) = dq_noise_k';

end

q_meas_deg  = rad2deg(q_meas_all);
dq_meas_deg = rad2deg(dq_meas_all);

q_noise_deg  = rad2deg(q_noise_all);
dq_noise_deg = rad2deg(dq_noise_all);

% -----------------------------
% Print useful values
% -----------------------------
disp('Maximum real joint velocities in deg/s:')
disp(max(abs(dq_deg)))

disp('Maximum position noise in deg:')
disp(max(abs(q_noise_deg)))

disp('Maximum velocity noise in deg/s:')
disp(max(abs(dq_noise_deg)))

% =========================================================
% Save PID noise response data
% =========================================================

if ~exist('results', 'dir')
    mkdir('results');
end

save('results/PID_noise_data.mat', ...
    't', ...
    'q_deg', ...
    'dq_deg', ...
    'qref_plot_deg', ...
    'dqref_plot_deg', ...
    'q_meas_deg', ...
    'dq_meas_deg', ...
    'q_noise_deg', ...
    'dq_noise_deg');

% =========================================================
% Plot positions and velocities with reference only
% =========================================================

figure;

for i = 1:5

    %% Column 1: Joint position
    subplot(5,2,2*i-1)

    plot(t, q_deg(:,i), 'LineWidth', 1.5);
    hold on;
    plot(t, qref_plot_deg(:,i), '--', 'LineWidth', 1.2);
    grid on;

    ydata = [q_deg(:,i); qref_plot_deg(:,i)];
    ymin = min(ydata);
    ymax = max(ydata);
    margin = 0.2 * max(abs(ymax - ymin), 1);
    ylim([ymin - margin, ymax + margin]);

    ylabel(['q_', num2str(i), ' [deg]']);

    if i == 1
        title('Joint Position');
    end

    legend(['q_', num2str(i)], ['q_{ref', num2str(i), '}'], 'Location', 'best');

    %% Column 2: Joint velocity
    subplot(5,2,2*i)

    plot(t, dq_deg(:,i), 'LineWidth', 1.5);
    hold on;
    plot(t, dqref_plot_deg(:,i), '--', 'LineWidth', 1.2);
    grid on;

    ydata = [dq_deg(:,i); dqref_plot_deg(:,i)];
    ymin = min(ydata);
    ymax = max(ydata);
    margin = 0.2 * max(abs(ymax - ymin), 1);
    ylim([ymin - margin, ymax + margin]);

    ylabel(['dq_', num2str(i), ' [deg/s]']);

    if i == 1
        title('Joint Velocity');
    end

    legend(['dq_', num2str(i)], ['dq_{ref', num2str(i), '}'], 'Location', 'best');

end

xlabel('Time [s]');
sgtitle('PID Response with Measurement Noise');

% =========================================================
% Plot noisy measured signals only if needed
% =========================================================

figure;

for i = 1:5

    subplot(5,2,2*i-1)

    plot(t, q_deg(:,i), 'LineWidth', 1.2);
    hold on;
    plot(t, q_meas_deg(:,i), ':', 'LineWidth', 1.0);
    grid on;

    ylabel(['q_', num2str(i), ' [deg]']);

    if i == 1
        title('Position: Real vs Measured');
    end

    legend('real', 'measured', 'Location', 'best');

    subplot(5,2,2*i)

    plot(t, dq_deg(:,i), 'LineWidth', 1.2);
    hold on;
    plot(t, dq_meas_deg(:,i), ':', 'LineWidth', 1.0);
    grid on;

    ylabel(['dq_', num2str(i), ' [deg/s]']);

    if i == 1
        title('Velocity: Real vs Measured');
    end

    legend('real', 'measured', 'Location', 'best');

end

xlabel('Time [s]');
sgtitle('PID Measured Signals with Noise');