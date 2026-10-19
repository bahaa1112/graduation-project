function Xdot = Adaptive_CTC_closed_loop(t, X, qref, Am, Bm, Lmda, Ks, gammaTheta, sigmaMod)

% =========================================================
% Adaptive Computed Torque Control
%
% System model:
% (M(q)+Ka) qdd = Ku*u - Kv*dq - G(q)
%
% State vector:
% X = [q; dq; qm; dqm; theta_hat(:)]
%
% q, dq        : real robot states
% qm, dqm      : reference model states
% theta_hat    : adaptive parameters
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
% Extract adaptive parameters
% -----------------------------
theta_hat = reshape(X(21:end), 4, 5);
%«—»⁄ „⁄«„·«  ·Œ„” „œ«Œ·
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
% Composite error
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
% Regressor terms
% -----------------------------
Me_ddqr = Me * ddq_r;
Kv_dq   = Kv * dq;

% -----------------------------
% Adaptive torque calculation
% -----------------------------
tau_cmd   = zeros(5,1);
theta_dot = zeros(4,5);

theta_nom = [1; 1; 1; 0];

for i = 1:5

    % Regressor vector for joint i
    Y_i = [
        Me_ddqr(i);
        Kv_dq(i);
        Gq(i);
        1
    ];

    % Adaptive computed torque
    tau_cmd(i) = theta_hat(:,i)' * Y_i - Ks(i,i)*s(i);

    % Adaptive law
    theta_dot(:,i) = ...
        -(gammaTheta(:) .* Y_i) * s(i) / (1 + Y_i' * Y_i) ...
        - sigmaMod * (theta_hat(:,i) - theta_nom);

end
% -----------------------------
% Convert torque to voltage
% -----------------------------
u_raw = Ku \ tau_cmd;

% -----------------------------
% Voltage saturation
% -----------------------------
u_sat = min(max(u_raw, -6), 6);
%u_sat=u_raw;
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
    xmdot;
    theta_dot(:)
];

end