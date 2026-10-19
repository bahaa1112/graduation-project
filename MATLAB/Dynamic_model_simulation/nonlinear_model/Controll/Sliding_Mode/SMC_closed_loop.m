function Xdot = SMC_closed_loop(t, X, qref, Am, Bm, Lmda, Ks, Kr, epsilon)

% =========================================================
% Sliding Mode Control for Robotic Arm
%
% System model:
% (M(q)+Ka) qdd = Ku*u - Kv*dq - G(q)
%
% State vector:
% X = [q; dq; qm; dqm]
%
% q, dq      : real robot states
% qm, dqm    : reference trajectory states
% =========================================================

% -----------------------------
% Extract real robot states
% -----------------------------
q  = X(1:5);
dq = X(6:10);

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
% Tracking errors
% -----------------------------
e  = q  - qm;
de = dq - dqm;

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
% Robot dynamics
% -----------------------------
[Mq, Gq] = robotCoreDynamics(q);
[Ku, Kv, Ka, ~] = robotActuatorConstants();

Me = Mq + Ka;

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
    Me*ddq_r ...
    + Kv*dq ...
    + Gq ...
    - Ks*s ...
    - Kr*sat_s;
% -----------------------------
% Convert torque to voltage
% -----------------------------
u_raw = Ku \ tau_cmd;

% -----------------------------
% Voltage saturation
% -----------------------------
%u_sat =u_raw;
u_sat = min(max(u_raw, -6), 6);

% -----------------------------
% Real robot acceleration
% -----------------------------
ddq = Me \ (Ku*u_sat - Kv*dq - Gq);

% -----------------------------
% Full state derivative
% -----------------------------
Xdot = [
    dq;
    ddq;
    xmdot
];

end