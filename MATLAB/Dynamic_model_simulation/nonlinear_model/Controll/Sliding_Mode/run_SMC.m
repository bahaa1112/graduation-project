clc;
clear;
close all;

% =========================================================
% Run Sliding Mode Control
% =========================================================

% -----------------------------
% Desired final joint positions
% -----------------------------
tspan=0:0.001:20;
qref=deg2rad([45;45;45;45;45]);
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
% Simulation
% -----------------------------

opts = odeset( ...
    'RelTol', 1e-5, ...
    'AbsTol', 1e-7, ...
    'MaxStep', 0.005 ...
);

[t, X] = ode45(@(t,X) SMC_closed_loop( ...
    t, X, qref, Am, Bm, Lmda, Ks, Kr, epsilon), ...
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
% Print maximum velocities
% -----------------------------
disp('Maximum real joint velocities in deg/s:')
disp(max(abs(dq_deg)))

disp('Maximum reference joint velocities in deg/s:')
disp(max(abs(dqm_deg)))
% =========================================================
% Plot positions and velocities
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
        ['q_', num2str(i)], ...
        ['q_m_', num2str(i)] ...
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
        ['dq_', num2str(i)], ...
        ['dq_m_', num2str(i)] ...
    );

end
sgtitle('SMC Response: Joint Positions and Velocities');

% =========================================================
% Save SMC response data for comparison
% =========================================================

if ~exist('results', 'dir')
    mkdir('results');
end

q_ref_plot  = qm_deg;
dq_ref_plot = dqm_deg;

save('results/SMC_data.mat', ...
    't', 'q_deg', 'dq_deg', 'q_ref_plot', 'dq_ref_plot');












% =========================================================
% Compute saturated control input history (SMC)
% =========================================================
u_raw_hist = zeros(length(t),5);
u_sat_hist = zeros(length(t),5);

epsVec = epsilon(:); %  ÃÂÌ“ ‘⁄«⁄ «·”„«ÕÌ…

for i = 1:length(t)
    
    % «” Œ—«Ã «·Õ«·«  ⁄‰œ «··ÕŸ… i
    q_i   = X(i, 1:5)';
    dq_i  = X(i, 6:10)';
    qm_i  = X(i, 11:15)';
    dqm_i = X(i, 16:20)';
    xm_i  = X(i, 11:20)';
    
    % Õ”«» «· ”«—⁄ «·„—Ã⁄Ì (ddqm)
    xmdot_i = Am * xm_i + Bm * qref;
    ddqm_i  = xmdot_i(6:10);
    
    % Õ”«» «·√Œÿ«¡ Ê”ÿÕ «·«‰“·«ﬁ
    e_i  = q_i - qm_i;
    de_i = dq_i - dqm_i;
    s_i  = de_i + Lmda * e_i;
    
    % «· ”«—⁄ «·„—Ã⁄Ì «·„⁄œ·
    ddq_r_i = ddqm_i - Lmda * de_i;
    
    % «” œ⁄«¡ œÌ‰«„ÌﬂÌ… «·—Ê»Ê 
    [Mq, Gq] = robotCoreDynamics(q_i);
    [Ku, Kv, Ka, ~] = robotActuatorConstants();
    Me = Mq + Ka;
    
    % œ«·… «·≈‘»«⁄ ·”ÿÕ «·«‰“·«ﬁ
    sat_s_i = min(max(s_i ./ epsVec, -1), 1);
    
    % Õ”«» «·⁄“„ «·„ÿ·Ê»
    tau_cmd_i = Me * ddq_r_i + Kv * dq_i + Gq - Ks * s_i - Kr * sat_s_i;
    
    %  ÕÊÌ· «·⁄“„ ≈·Ï ÃÂœ ﬂÂ—»«∆Ì
    u_raw_i = Ku \ tau_cmd_i;
    
    %  ÿ»Ìﬁ «·≈‘»«⁄ (Saturation) »Ì‰ -6 Ê +6 ›Ê· 
    u_sat_i = min(max(u_raw_i, -6), 6);
    
    %  Œ“Ì‰ «·ﬁÌ„
    u_raw_hist(i,:) = u_raw_i';
    u_sat_hist(i,:) = u_sat_i';
    
end

% =========================================================
% Plot Control Input (Voltage)
% =========================================================
figure;

for i = 1:5
    subplot(5,1,i)
    
    plot(t, u_sat_hist(:,i), 'LineWidth', 1.5);
    hold on;
    plot(t, 6*ones(size(t)), 'k--', 'LineWidth', 1.0);
    plot(t, -6*ones(size(t)), 'k--', 'LineWidth', 1.0);
    grid on;
    
    ylabel(['u_', num2str(i), ' [V]']);
    legend(['u_{sat', num2str(i), '}'], '+6 V', '-6 V', 'Location', 'best');
end

xlabel('Time [s]');
sgtitle('SMC Control Input');