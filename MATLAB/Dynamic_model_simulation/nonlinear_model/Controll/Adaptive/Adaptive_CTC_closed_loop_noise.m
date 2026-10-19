function Xdot = Adaptive_CTC_closed_loop_noise(t, X, qref, Am, Bm, Lmda, Ks, gammaTheta, sigmaMod, noise)

% =========================================================
% Adaptive Computed Torque Control with Measurement Noise
%
% Noise is added only to measured signals:
% q_meas  = q  + noise
% dq_meas = dq + noise
%
% The real plant dynamics remain noise-free.
% =========================================================

% -----------------------------
% Real robot states
% -----------------------------
q  = X(1:5);
dq = X(6:10);

% -----------------------------
% Add measurement noise
% -----------------------------
[q_meas, dq_meas, ~, ~] = addMeasurementNoise(t, q, dq, noise);

% -----------------------------
% Reference model states
% -----------------------------
xm  = X(11:20);
qm  = xm(1:5);
dqm = xm(6:10);

% -----------------------------
% Adaptive parameters
% -----------------------------
theta_hat = reshape(X(21:end), 4, 5);

% -----------------------------
% Reference model dynamics
% -----------------------------
xmdot = Am*xm + Bm*qref;
ddqm  = xmdot(6:10);

% -----------------------------
% Tracking errors using measured signals
% -----------------------------
e  = q_meas  - qm;
de = dq_meas - dqm;

% Composite error
s = de + Lmda*e;

% Modified reference acceleration
ddq_r = ddqm - Lmda*de;

% -----------------------------
% Controller model using measured signals
% -----------------------------
[Mq_meas, Gq_meas] = robotCoreDynamics(q_meas);
[Ku, Kv, Ka, ~] = robotActuatorConstants();

Me_meas = Mq_meas + Ka;

% Regressor terms
Me_ddqr = Me_meas * ddq_r;
Kv_dq   = Kv * dq_meas;

% -----------------------------
% Adaptive torque calculation
% -----------------------------
tau_cmd   = zeros(5,1);
theta_dot = zeros(4,5);

theta_nom = [1; 1; 1; 0];

for i = 1:5

    Y_i = [
        Me_ddqr(i);
        Kv_dq(i);
        Gq_meas(i);
        1
    ];

    tau_cmd(i) = theta_hat(:,i)' * Y_i - Ks(i,i)*s(i);

    theta_dot(:,i) = ...
        -(gammaTheta(:) .* Y_i) * s(i) / (1 + Y_i' * Y_i) ...
        - sigmaMod * (theta_hat(:,i) - theta_nom);

end

% -----------------------------
% Convert torque to voltage
% -----------------------------
u_raw = Ku \ tau_cmd;

% Voltage saturation
u_sat = min(max(u_raw, -6), 6);

% -----------------------------
% Real plant dynamics without noise
% -----------------------------
[Mq_real, Gq_real] = robotCoreDynamics(q);
Me_real = Mq_real + Ka;

ddq = Me_real \ (Ku*u_sat - Kv*dq - Gq_real);

% -----------------------------
% Full derivative
% -----------------------------
Xdot = [
    dq;
    ddq;
    xmdot;
    theta_dot(:)
];

end