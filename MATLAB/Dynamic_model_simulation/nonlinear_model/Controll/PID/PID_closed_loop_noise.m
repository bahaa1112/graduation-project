function Xdot = PID_closed_loop_noise(t, X, qref, dqref, Kp, Ki, Kd, noise)

% =========================================================
% PID with Gravity Compensation and Measurement Noise
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
q     = X(1:5);
dq    = X(6:10);
e_int = X(11:15);

% -----------------------------
% Add measurement noise
% -----------------------------
[q_meas, dq_meas, ~, ~] = addMeasurementNoise(t, q, dq, noise);

% -----------------------------
% PID errors using measured signals
% -----------------------------
e  = qref  - q_meas;
de = dqref - dq_meas;

% -----------------------------
% Gravity compensation using measured position
% -----------------------------
[~, Gq_meas] = robotCoreDynamics(q_meas);
[Ku, ~, ~, ~] = robotActuatorConstants();

u_g = Ku \ Gq_meas;

% -----------------------------
% PID control input
% -----------------------------
u = Kp*e + Ki*e_int + Kd*de + u_g;

% Voltage saturation
u_sat = sat(u);

% -----------------------------
% Real plant dynamics without measurement noise
% -----------------------------
x = [q; dq];

[A, B, ~, ~, r] = robotStateMatrices(q);

xdot = A*x + B*u_sat + r;

% Integral of measured error
e_int_dot = e;

% -----------------------------
% Full state derivative
% -----------------------------
Xdot = [
    xdot;
    e_int_dot
];

end


function u_sat = sat(u)

u_sat = min(max(u, -6), 6);

end