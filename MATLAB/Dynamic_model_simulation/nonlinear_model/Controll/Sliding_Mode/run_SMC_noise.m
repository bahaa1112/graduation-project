clc;
clear;
close all;

% =========================================================
% Run Sliding Mode Control with Measurement Noise
% =========================================================

% Add noise model folder
addpath('noise_model');

% -----------------------------
% Desired final joint positions
% -----------------------------
qref = deg2rad([45; 45; 45; 45; 45]);
tspan=0:0.001:20;

% -----------------------------
% Reference trajectory generator
% Second-order reference model
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
% Sliding Mode Controller gains
% -----------------------------

% Lambda matrix for sliding surface:
% s = de + Lmda*e
Lmda = diag([4; 10; 6; 6; 6]);

% Smooth correction gain
Ks = diag([1.5; 0.8; 1; 0.8; 0.4]);

% Robust sliding gain
Kr = diag([0.8; 0.08; 0.08; 0.4; 0.2]);

% Boundary layer thickness
epsilon = [0.001; 0.001; 0.08; 0.08; 0.08];



% -----------------------------
% Create measurement noise
% -----------------------------
noise = createNoiseConfig([tspan(1) tspan(end)]);

% To disable noise:
% noise.enabled = false;

% Plot generated measurement noise
plotMeasurementNoise(noise);

% -----------------------------
% Initial conditions
% -----------------------------
q0  = zeros(5,1);
dq0 = zeros(5,1);

qm0  = zeros(5,1);
dqm0 = zeros(5,1);

% Full initial state
% X = [q; dq; qm; dqm]
X0 = [
    q0;
    dq0;
    qm0;
    dqm0
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
[t, X] = ode45(@(t,X) SMC_closed_loop_noise( ...
    t, X, qref, Am, Bm, Lmda, Ks, Kr, epsilon, noise), ...
    tspan, X0, opts);

% -----------------------------
% Extract results
% -----------------------------
q   = X(:,1:5);       % real joint positions
dq  = X(:,6:10);      % real joint velocities

qm  = X(:,11:15);     % reference joint positions
dqm = X(:,16:20);     % reference joint velocities

% -----------------------------
% Tracking errors
% -----------------------------
e_q  = q  - qm;
e_dq = dq - dqm;

% -----------------------------
% Convert to degrees
% -----------------------------
q_deg    = rad2deg(q);
qm_deg   = rad2deg(qm);

dq_deg   = rad2deg(dq);
dqm_deg  = rad2deg(dqm);

e_q_deg  = rad2deg(e_q);
e_dq_deg = rad2deg(e_dq);

% -----------------------------
% Reconstruct measured signals and noise
% -----------------------------
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

q_noise_deg  = rad2deg(q_noise_all);
dq_noise_deg = rad2deg(dq_noise_all);

% -----------------------------
% Print useful values
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
sgtitle('SMC Response with Measurement Noise');

% =========================================================
% Plot position errors
% =========================================================

figure;

for i = 1:5

    subplot(5,1,i);

    plot(t, e_q_deg(:,i), 'LineWidth', 1.5);
    grid on;

    xlabel('Time (s)');
    ylabel(['e_', num2str(i), ' (deg)']);
    title(['Joint ', num2str(i), ' Position Error']);

end