function [Ku, Kv, Ka, Tmax] = robotActuatorConstants()
% ============================================================
% Actuator constants for the 5-DOF robotic arm
%
% Model form:
%   tau_act = Ku*u - Kv*dq - Ka*ddq
%
% where:
%   u    : equivalent voltage input [V]
%   dq   : joint velocity [rad/s]
%   ddq  : joint acceleration [rad/s^2]
%   tau  : actuator torque [N.m]
%
% The input voltage is assumed to be limited by:
%   -6 <= u <= 6  [V]
%
% Therefore, Ku is computed from:
%   Ku = Tmax / Vmax
%
% Kv is computed from a simplified linear torque-speed relation:
%   tau = Ku*u - Kv*dq
%
% At no-load speed:
%   tau = 0
%   u = Vmax
%   dq = omega0
%
% Therefore:
%   0 = Ku*Vmax - Kv*omega0
%   Kv = (Ku*Vmax) / omega0 = Tmax / omega0
%
% Ka is kept as an equivalent acceleration coefficient from the
% previous actuator model, because it cannot be determined from
% voltage, stall torque, and no-load speed alone.
% ============================================================


    %% --------------------------------------------------------
    % Common voltage limit
    % ---------------------------------------------------------

    Vmax = 6;   % Maximum equivalent input voltage [V]


    %% --------------------------------------------------------
    % Joints 1-4: MG995
    % ---------------------------------------------------------
    %
    % Assumed maximum torque:
    %   Tmax_MG995 = 0.9 N.m
    %
    % Assumed no-load speed at 6 V:
    %   0.16 s / 60 deg
    %
    % Therefore:
    %   omega0 = 60 deg / 0.16 s
    %
    % Convert to rad/s:
    %   omega0 = deg2rad(60/0.16)
    %
    % Input-to-torque coefficient:
    %   Ku = Tmax / Vmax
    %
    % Velocity coefficient:
    %   Kv = Tmax / omega0
    % ---------------------------------------------------------

    Tmax_MG995 = 0.9;                         % [N.m]
    omega0_MG995 = deg2rad(60 / 0.16);        % [rad/s]

    Ku_MG995 = Tmax_MG995 / Vmax;             % [N.m/V]
    Kv_MG995 = Tmax_MG995 / omega0_MG995;     % [N.m/(rad/s)]

    Ka_MG995 = 0.12;                          % Equivalent acceleration coefficient


    %% --------------------------------------------------------
    % Joint 5: MG92B
    % ---------------------------------------------------------
    %
    % Assumed maximum torque:
    %   Tmax_MG92B = 0.343 N.m
    %
    % Assumed no-load speed at 6 V:
    %   0.08 s / 60 deg
    %
    % Therefore:
    %   omega0 = 60 deg / 0.08 s
    %
    % Convert to rad/s:
    %   omega0 = deg2rad(60/0.08)
    %
    % Input-to-torque coefficient:
    %   Ku = Tmax / Vmax
    %
    % Velocity coefficient:
    %   Kv = Tmax / omega0
    % ---------------------------------------------------------

    Tmax_MG92B = 0.343;                        % [N.m]
    omega0_MG92B = deg2rad(60 / 0.08);        % [rad/s]

    Ku_MG92B = Tmax_MG92B / Vmax;             % [N.m/V]
    Kv_MG92B = Tmax_MG92B / omega0_MG92B;     % [N.m/(rad/s)]

    Ka_MG92B = 0.015;                         % Equivalent acceleration coefficient


    %% --------------------------------------------------------
    % Input-to-torque coefficients Ku
    % ---------------------------------------------------------
    %
    % Joints 1-4:
    %   Ku_MG995 = 0.9 / 6 = 0.15 N.m/V
    %
    % Joint 5:
    %   Ku_MG92B = 0.343 / 6 = 0.0572 N.m/V
    % ---------------------------------------------------------

    Ku = diag([
        Ku_MG995
        Ku_MG995
        Ku_MG995
        Ku_MG995
        Ku_MG92B
    ]);


    %% --------------------------------------------------------
    % Velocity coefficients Kv
    % ---------------------------------------------------------
    %
    % Joints 1-4:
    %   omega0_MG995 = deg2rad(60/0.16) = 6.545 rad/s
    %   Kv_MG995 = 0.9 / 6.545 = 0.1375
    %
    % Joint 5:
    %   omega0_MG92B = deg2rad(60/0.08) = 13.09 rad/s
    %   Kv_MG92B = 0.343 / 13.09 = 0.0262
    % ---------------------------------------------------------

    Kv = diag([
        Kv_MG995
        Kv_MG995
        Kv_MG995
        Kv_MG995
        Kv_MG92B
    ]);


    %% --------------------------------------------------------
    % Acceleration coefficients Ka
    % ---------------------------------------------------------
    %
    % These coefficients represent an equivalent acceleration
    % effect in the actuator model.
    %
    % They are kept from the previous model and should be treated
    % as approximate/identified parameters.
    % ---------------------------------------------------------

    Ka = diag([
        Ka_MG995
        Ka_MG995
        Ka_MG995
        Ka_MG995
        Ka_MG92B
    ]);


    %% --------------------------------------------------------
    % Torque limits Tmax
    % ---------------------------------------------------------
    %
    % These are the maximum actuator torques used for comparison
    % or possible torque saturation.
    % ---------------------------------------------------------

    Tmax = [
        Tmax_MG995
        Tmax_MG995
        Tmax_MG995
        Tmax_MG995
        Tmax_MG92B
    ];

end