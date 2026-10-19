
clear; clc; close all;


%initial condition 
q0=zeros(5,1); %initial position
dq0=zeros(5,1); % velocity

x0=[q0;dq0];


%integral error initial condition
e_int0=zeros(5,1);

X0=[x0;e_int0]; %15 x 1 

tspan=0:0.001:20;

q_ref=deg2rad([45;45;45;45;45]);
dq_ref=zeros(5,1);


Kp = diag([3 300 150 150 150]);
Kd = diag([2 150 50 50 50]);
Ki = diag([0 0 0 0 0]);
%simultion time



Xdot=@(t,X)PID_closed_loop(t, X, q_ref, dq_ref, Kp, Ki, Kd);

[t, X] = ode45( Xdot, tspan, X0);

% Extract simulation results
q = X(:,1:5);        % Joint positions
dq = X(:,6:10);      % Joint velocities
e_int = X(:,11:15);
qref_plot  = repmat(q_ref', length(t), 1);
dqref_plot = repmat(dq_ref', length(t), 1);




% =========================================================
% Save PID response data for comparison
% =========================================================

if ~exist('results', 'dir')
    mkdir('results');
end

% Convert simulation results to degrees
q_deg  = rad2deg(q);
dq_deg = rad2deg(dq);

% Convert reference signals to degrees
qref_plot_deg  = rad2deg(qref_plot);
dqref_plot_deg = rad2deg(dqref_plot);

save('results/PID_data.mat', ...
    't', ...
    'q_deg', ...
    'dq_deg', ...
    'qref_plot_deg', ...
    'dqref_plot_deg');
figure;

for i = 1:5

    %% Column 1: Joint position
    subplot(5,2,2*i-1)

    plot(t, rad2deg(q(:,i)), 'LineWidth', 1.5);
    hold on;
    plot(t, rad2deg(qref_plot(:,i)), '--', 'LineWidth', 1.2);
    grid on;

    ydata = [rad2deg(q(:,i)); rad2deg(qref_plot(:,i))];
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

    plot(t, rad2deg(dq(:,i)), 'LineWidth', 1.5);
    hold on;
    plot(t, rad2deg(dqref_plot(:,i)), '--', 'LineWidth', 1.2);
    grid on;

    ydata = [rad2deg(dq(:,i)); rad2deg(dqref_plot(:,i))];
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
sgtitle('PID Response: Joint Positions and Velocities');
%{
u_hist = zeros(length(t),5);

for i = 1:length(t)

    qi = q(i,:)';
    dqi = dq(i,:)';
    e_int_i = e_int(i,:)';

    e_i  = q_ref - qi;
    de_i = dq_ref - dqi;

    u_i = Kp*e_i + Ki*e_int_i + Kd*de_i;

    u_hist(i,:) = u_i';

end
figure;

for i = 1:5
    subplot(5,1,i)

    plot(t, u_hist(:,i), 'LineWidth', 1.5);
    grid on;

    ylabel(['u_', num2str(i)]);
    legend(['u_', num2str(i)], 'Location', 'best');
end

xlabel('Time [s]');
sgtitle('PID Control Input');
%}

%u sat
% Compute saturated control input history
u_raw_hist = zeros(length(t),5);
u_sat_hist = zeros(length(t),5);

for i = 1:length(t)

    qi = q(i,:)';
    dqi = dq(i,:)';
    e_int_i = e_int(i,:)';

    e_i  = q_ref - qi;
    de_i = dq_ref - dqi;

    u_raw_i = Kp*e_i + Ki*e_int_i + Kd*de_i;

    % Saturation between -6 V and +6 V
    u_sat_i = min(max(u_raw_i, -6), 6);

    u_raw_hist(i,:) = u_raw_i';
    u_sat_hist(i,:) = u_sat_i';

end
figure;

for i = 1:5
    subplot(5,1,i)

    plot(t, u_sat_hist(:,i), 'LineWidth', 1.5);
    hold on;
    plot(t, 6*ones(size(t)), '--', 'LineWidth', 1.0);
    plot(t, -6*ones(size(t)), '--', 'LineWidth', 1.0);
    grid on;

    ylabel(['u_', num2str(i), ' [V]']);
    legend(['u_{sat', num2str(i), '}'], '+6 V', '-6 V', 'Location', 'best');
end

xlabel('Time [s]');


