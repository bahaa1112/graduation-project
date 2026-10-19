function Xdot = SMC_closed_loop_noise(t, X, qref, Am, Bm, Lmda, Ks, Kr, epsilon, noise)

% =========================================================
% Sliding Mode Control with Measurement Noise
%
% Noise is added only to measured signals:
% q_meas  = q  + noise
% dq_meas = dq + noise
%
% The real plant dynamics remain noise-free.
% =========================================================

% -----------------------------
% Extract real robot states
% -----------------------------
q  = X(1:5);
dq = X(6:10);

% -----------------------------
% Add measurement noise
% -----------------------------
[q_meas, dq_meas, ~, ~] = addMeasurementNoise(t, q, dq, noise);

% -----------------------------
% Extract reference model states
% -----------------------------
xm  = X(11:20);
qm  = xm(1:5);
dqm = xm(6:10);

% -----------------------------
% Reference model dynamics
% -----------------------------
xmdot = Am*xm + Bm*qref;

% Reference acceleration
ddqm = xmdot(6:10);

% -----------------------------
% Tracking errors using noisy measurements
% -----------------------------
e  = q_meas  - qm;
de = dq_meas - dqm;

% -----------------------------
% Sliding surface
% s = de + Lmda*e
% -----------------------------
s = de + Lmda*e;

% -----------------------------
% Modified reference acceleration
% ddq_r = ddqm - Lmda*de
% -----------------------------
ddq_r = ddqm - Lmda*de;

% -----------------------------
% Controller model using noisy measurements
% -----------------------------
[Mq_meas, Gq_meas] = robotCoreDynamics(q_meas);
[Ku, Kv, Ka, ~] = robotActuatorConstants();

Me_meas = Mq_meas + Ka;

% -----------------------------
% Saturation function for sliding term
% sat(s/epsilon)
% -----------------------------
if isscalar(epsilon)
    epsVec = epsilon * ones(5,1);
else
    epsVec = epsilon(:);
end

sat_s = s ./ epsVec;
sat_s = min(max(sat_s, -1), 1);

% -----------------------------
% Sliding Mode Control torque
% -----------------------------
tau_cmd = ...
    Me_meas*ddq_r ...
    + Kv*dq_meas ...
    + Gq_meas ...
    - Ks*s ...
    - Kr*sat_s;

% -----------------------------
% Convert torque to voltage
% -----------------------------
u_raw = Ku \ tau_cmd;

% -----------------------------
% Voltage saturation
% -----------------------------
u_sat = min(max(u_raw, -6), 6);

% -----------------------------
% Real plant dynamics without measurement noise
% -----------------------------
[Mq_real, Gq_real] = robotCoreDynamics(q);

Me_real = Mq_real + Ka;

ddq = Me_real \ (Ku*u_sat - Kv*dq - Gq_real);

% -----------------------------
% Full state derivative
% -----------------------------
Xdot = [
    dq;
    ddq;
    xmdot
];

end