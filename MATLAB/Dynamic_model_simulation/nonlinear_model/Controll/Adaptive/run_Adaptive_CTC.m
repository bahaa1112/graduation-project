clc;
clear;
close all;

% =========================================================
% Run Adaptive Computed Torque Control
% =========================================================

% -----------------------------
% Desired final joint positions
% -----------------------------
tspan=0:0.001:20;

qref = deg2rad([45; 45; 45; 45; 45]);

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
Lmda = diag([4; 4; 4; 4; 4]);
%·„œ«  Õœœ ﬂ„ ‰⁄ÿÌ √Â„Ì… ·Œÿ√ «·„Ê÷⁄ œ«Œ· «·Œÿ√ «·„—ﬂ».
Ks = diag([2; 2; 2; 2; 2]);
%Â–« «·Õœ ÌÃ⁄· «·«” Ã«»… √ﬂÀ— À»« « Ê√”—⁄° Œ«’… ﬁ»· √‰   ⁄·„ „⁄«„·«  «· ﬂÌ› «·ﬁÌ„ «·„‰«”»… ÊÂÊ „ÊÃÊœ ›Ì ‘⁄«⁄ «· Õﬂ„ ··⁄“„.
% -----------------------------
% Adaptive gains
% theta = [theta_M; theta_V; theta_G; theta_0]
% -----------------------------
gammaTheta = [
    0.0005;
    0.0005;
    0.0005;
    0.0005
];%”—⁄… «· ﬂÌ›

% Sigma modification
sigmaMod = 0.02;
%ÊŸÌ› Â √‰ Ì„‰⁄ „⁄«„·«  «· ﬂÌ› „‰ «·«‰Ã—«› »⁄Ìœ« Ãœ« ⁄‰ «·ﬁÌ„ «·ÿ»Ì⁄Ì….
% -----------------------------
% Initial conditions
% -----------------------------
q0  = zeros(5,1);
dq0 = zeros(5,1);

qm0  = zeros(5,1);
dqm0 = zeros(5,1);

% Initial adaptive parameters
% theta_i = [theta_M; theta_V; theta_G; theta_0]
theta0 = repmat([1; 1; 1; 0], 1, 5);

% Full initial state
X0 = [
    q0;
    dq0;
    qm0;
    dqm0;
    theta0(:)
];

% -----------------------------
% Simulation
% -----------------------------


opts = odeset( ...
    'RelTol', 1e-5, ...%«·Œÿ√ «·‰”»Ì «·„”„ÊÕ.
    'AbsTol', 1e-7, ...%«·Œÿ√ «·„ÿ·ﬁ «·„”„ÊÕ.
    'MaxStep', 0.005 ...Â–« Ì⁄‰Ì √ﬂ»— ŒÿÊ… “„‰Ì… „”„ÊÕ…
);

[t, X] = ode45(@(t,X) Adaptive_CTC_closed_loop( ...
    t, X, qref, Am, Bm, Lmda, Ks, gammaTheta, sigmaMod), ...
    tspan, X0, opts);

% -----------------------------
% Extract results
% -----------------------------
q   = X(:,1:5);
dq  = X(:,6:10);

qm  = X(:,11:15);
dqm = X(:,16:20);

theta_all = X(:,21:end);

% Tracking errors
e_q  = q  - qm;
e_dq = dq - dqm;

% Convert to degrees
q_deg    = rad2deg(q);
qm_deg   = rad2deg(qm);

dq_deg   = rad2deg(dq);
dqm_deg  = rad2deg(dqm);

e_q_deg  = rad2deg(e_q);
e_dq_deg = rad2deg(e_dq);

% Print maximum velocities
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
sgtitle('ACTC Response: Joint Positions and Velocities');
% =========================================================
% Reconstruct control input to detect saturation
% =========================================================

N = length(t);

u_raw_all = zeros(N,5);
u_sat_all = zeros(N,5);

for k = 1:N

    % Current real states
    qk  = q(k,:)';
    dqk = dq(k,:)';

    % Current reference model states
    qmk  = qm(k,:)';
    dqmk = dqm(k,:)';

    xmk = [qmk; dqmk];

    % Current adaptive parameters
    theta_hat_k = reshape(theta_all(k,:), 4, 5);

    % Reference model acceleration
    xmdot_k = Am*xmk + Bm*qref;
    ddqm_k  = xmdot_k(6:10);

    % Tracking errors
    e_k  = qk  - qmk;
    de_k = dqk - dqmk;

    % Composite error
    s_k = de_k + Lmda*e_k;

    % Modified reference acceleration
    ddq_r_k = ddqm_k - Lmda*de_k;

    % Robot dynamics
    [Mq_k, Gq_k] = robotCoreDynamics(qk);
    [Ku, Kv, Ka, ~] = robotActuatorConstants();

    Me_k = Mq_k + Ka;

    % Regressor terms
    Me_ddqr_k = Me_k * ddq_r_k;
    Kv_dq_k   = Kv * dqk;

    % Adaptive computed torque
    tau_cmd_k = zeros(5,1);

    for i = 1:5

        Y_i = [
            Me_ddqr_k(i);
            Kv_dq_k(i);
            Gq_k(i);
            1
        ];

        tau_cmd_k(i) = theta_hat_k(:,i)' * Y_i - Ks(i,i)*s_k(i);

    end

    % Convert torque to voltage
    u_raw_k = Ku \ tau_cmd_k;

    % Apply voltage saturation
    u_sat_k = min(max(u_raw_k, -6), 6);

    % Store values
    u_raw_all(k,:) = u_raw_k';
    u_sat_all(k,:) = u_sat_k';

end

% =========================================================
% Reconstruct and plot control input voltage
% =========================================================

N = length(t);

u_raw_all = zeros(N,5);
u_sat_all = zeros(N,5);

for k = 1:N

    % Current real robot states
    qk  = q(k,:)';
    dqk = dq(k,:)';

    % Current reference model states
    qmk  = qm(k,:)';
    dqmk = dqm(k,:)';

    xmk = [qmk; dqmk];

    % Current adaptive parameters
    theta_hat_k = reshape(theta_all(k,:), 4, 5);

    % Reference model acceleration
    xmdot_k = Am*xmk + Bm*qref;
    ddqm_k  = xmdot_k(6:10);

    % Tracking errors
    e_k  = qk  - qmk;
    de_k = dqk - dqmk;

    % Composite error
    s_k = de_k + Lmda*e_k;

    % Modified reference acceleration
    ddq_r_k = ddqm_k - Lmda*de_k;

    % Robot dynamics
    [Mq_k, Gq_k] = robotCoreDynamics(qk);
    [Ku, Kv, Ka, ~] = robotActuatorConstants();

    Me_k = Mq_k + Ka;

    % Regressor terms
    Me_ddqr_k = Me_k * ddq_r_k;
    Kv_dq_k   = Kv * dqk;

    % Adaptive computed torque
    tau_cmd_k = zeros(5,1);

    for i = 1:5

        Y_i = [
            Me_ddqr_k(i);
            Kv_dq_k(i);
            Gq_k(i);
            1
        ];

        tau_cmd_k(i) = theta_hat_k(:,i)' * Y_i - Ks(i,i)*s_k(i);

    end

    % Convert torque to voltage
    u_raw_k = Ku \ tau_cmd_k;

    % Apply voltage saturation
    u_sat_k = min(max(u_raw_k, -6), 6);

    % Store values
    u_raw_all(k,:) = u_raw_k';
    u_sat_all(k,:) = u_sat_k';

end

% Print maximum required voltage before saturation
disp('Maximum required voltage before saturation:')
disp(max(abs(u_raw_all)))

% =========================================================
% Plot control input voltage
% =========================================================

figure;

for i = 1:5

    subplot(5,1,i);

    % —”„ ≈‘«—… «·ÃÂœ «·„‘»⁄… ›ﬁÿ (u_sat)
    h1 = plot(t, u_sat_all(:,i), 'LineWidth', 1.5);
    hold on;

    % —”„ ŒÿÊÿ ÕœÊœ «·≈‘»«⁄
    h2 = line([t(1) t(end)], [6 6], 'LineStyle', '--', 'Color', 'k');
    h3 = line([t(1) t(end)], [-6 -6], 'LineStyle', '--', 'Color', 'k');

    grid on;

    xlabel('Time (s)');
    ylabel(['u_', num2str(i), ' (V)']);
    title(['Joint ', num2str(i), ' Control Input']);

    %  ÕœÌÀ ﬁ«∆„… «· Ê÷ÌÕ (Legend)
    legend([h1 h2 h3], ...
        ['u_{sat', num2str(i), '}'], ...
        '+6 V', ...
        '-6 V', ...
        'Location', 'best' ...
    );

end


% =========================================================
% Save ACTC response data for comparison
% =========================================================

if ~exist('results', 'dir')
    mkdir('results');
end

q_ref_plot  = qm_deg;
dq_ref_plot = dqm_deg;

save('results/ACTC_data.mat', ...
    't', 'q_deg', 'dq_deg', 'q_ref_plot', 'dq_ref_plot');