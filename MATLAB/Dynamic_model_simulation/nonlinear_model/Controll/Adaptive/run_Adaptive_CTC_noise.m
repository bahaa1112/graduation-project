clc;
clear;
close all;

% =========================================================
% Run Adaptive Computed Torque Control with Measurement Noise
% =========================================================

% -----------------------------
% Desired final joint positions
% -----------------------------
qref = deg2rad([45; 45; 45; 45; 45]);
tspan=0:0.001:20;

% -----------------------------
% Reference model parameters
% -----------------------------
zeta = [1; 1; 1; 1; 1];

wn = [6; 6; 6; 6; 6];

Z = diag(zeta);
Omega = diag(wn);

Am = [
    zeros(5,5), eye(5);
    -Omega^2,  -2*Z*Omega
];

Bm = [
    zeros(5,5);
    Omega^2
];

% -----------------------------
% Controller gains
% -----------------------------
Lmda = diag([6; 6; 6; 6; 6]);

Ks = diag([1.8; 1.8; 1.4; 0.9; 0.4]);

% -----------------------------
% Adaptive gains
% theta = [theta_M; theta_V; theta_G; theta_0]
% -----------------------------
gammaTheta = [
    0.08;
    0.04;
    0.08;
    0.02
];

sigmaMod = 0.02;

% -----------------------------
% Simulation time
% -----------------------------

% -----------------------------
% Create measurement noise
% -----------------------------
noise = createNoiseConfig([tspan(1) tspan(end)]);

% To disable noise:
% noise.enabled = false;



% -----------------------------
% Initial conditions
% -----------------------------
q0  = zeros(5,1);
dq0 = zeros(5,1);

qm0  = zeros(5,1);
dqm0 = zeros(5,1);

theta0 = repmat([1; 1; 1; 0], 1, 5);

X0 = [
    q0;
    dq0;
    qm0;
    dqm0;
    theta0(:)
];

% -----------------------------
% Simulation options
% -----------------------------
opts = odeset( ...
    'RelTol', 1e-5, ...
    'AbsTol', 1e-7, ...
    'MaxStep', 0.005 ...
);

% -----------------------------
% Run simulation
% -----------------------------
[t, X] = ode45(@(t,X) Adaptive_CTC_closed_loop_noise( ...
    t, X, qref, Am, Bm, Lmda, Ks, gammaTheta, sigmaMod, noise), ...
    tspan, X0, opts);
% -----------------------------
% Extract results
% -----------------------------
q   = X(:,1:5);
dq  = X(:,6:10);

qm  = X(:,11:15);
dqm = X(:,16:20);

% Convert to degrees
q_deg    = rad2deg(q);
qm_deg   = rad2deg(qm);

dq_deg   = rad2deg(dq);
dqm_deg  = rad2deg(dqm);

% =========================================================
% Reconstruct measured signals with noise
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

% Convert measured signals and noise to degrees
q_meas_deg  = rad2deg(q_meas_all);
dq_meas_deg = rad2deg(dq_meas_all);

q_noise_deg  = rad2deg(q_noise_all);
dq_noise_deg = rad2deg(dq_noise_all);

% -----------------------------
% Print maximum velocities
% -----------------------------
disp('Maximum real joint velocities in deg/s:')
disp(max(abs(dq_deg)))

disp('Maximum reference joint velocities in deg/s:')
disp(max(abs(dqm_deg)))

disp('Maximum position noise in deg:')
disp(max(abs(q_noise_deg)))

disp('Maximum velocity noise in deg/s:')
disp(max(abs(dq_noise_deg)))

% =========================================================
% Plot measurement noise only
% =========================================================

figure;

for i = 1:5

    % Position noise
    subplot(5,2,2*i-1);

    plot(t, q_noise_deg(:,i), 'LineWidth', 1.2);
    grid on;

    xlabel('Time (s)');
    ylabel(['n_q_', num2str(i), ' (deg)']);
    title(['Joint ', num2str(i), ' Position Noise']);

    % Velocity noise
    subplot(5,2,2*i);

    plot(t, dq_noise_deg(:,i), 'LineWidth', 1.2);
    grid on;

    xlabel('Time (s)');
    ylabel(['n_dq_', num2str(i), ' (deg/s)']);
    title(['Joint ', num2str(i), ' Velocity Noise']);

end

% =========================================================
% Plot positions and velocities with reference only
% =========================================================

figure;

for i = 1:5

    % -----------------------------
    % Position plot
    % -----------------------------
    subplot(5,2,2*i-1);

    plot(t, q_deg(:,i), 'LineWidth', 1.5);
    hold on;
    plot(t, qm_deg(:,i), '--', 'LineWidth', 1.5);
    grid on;

    xlabel('Time (s)');
    ylabel(['q_', num2str(i), ' (deg)']);
    title(['Joint ', num2str(i), ' Position']);

    legend( ...
        ['q_', num2str(i), ' real'], ...
        ['q_m_', num2str(i), ' reference'] ...
    );

    % -----------------------------
    % Velocity plot
    % -----------------------------
    subplot(5,2,2*i);

    plot(t, dq_deg(:,i), 'LineWidth', 1.5);
    hold on;
    plot(t, dqm_deg(:,i), '--', 'LineWidth', 1.5);
    grid on;

    xlabel('Time (s)');
    ylabel(['dq_', num2str(i), ' (deg/s)']);
    title(['Joint ', num2str(i), ' Velocity']);

    legend( ...
        ['dq_', num2str(i), ' real'], ...
        ['dq_m_', num2str(i), ' reference'] ...
    );

end
sgtitle('ACTC Response with Measurement Noise');