function [xdot, y, ddq, tauAct, tauRaw] = robotNonlinearStateSpace(t, x, u, useSaturation)
% ============================================================
% Nonlinear state-space model of the actuated 5-DOF robot
%
% State vector:
%   x = [q; dq]
%
% where:
%   q  : 5x1 joint positions [rad]
%   dq : 5x1 joint velocities [rad/s]
%
% Input:
%   u  : 5x1 control/voltage input vector
%
% State equation:
%   xdot = [dq; ddq]
%
% where:
%   ddq is computed from the actuated dynamics:
%
%   (M(q)+Ka)*ddq = Ku*u - Kv*dq - G(q)
%
% Outputs:
%   xdot   : 10x1 state derivative
%   y      : 5x1 output vector, chosen as joint positions q
%   ddq    : 5x1 joint accelerations
%   tauAct : actuator torque after saturation
%   tauRaw : actuator torque before saturation
%
% Note:
%   t is included for compatibility with ode45 and Simulink.
% ============================================================

    if nargin < 4
        useSaturation = true;
    end

    % --------------------------------------------------------
    % Ensure column vectors
    % --------------------------------------------------------

    x = x(:);
    u = u(:);

    % --------------------------------------------------------
    % Check dimensions
    % --------------------------------------------------------

    if length(x) ~= 10
        error("State vector x must be 10x1.");
    end

    if length(u) ~= 5
        error("Input vector u must be 5x1.");
    end

    % --------------------------------------------------------
    % Extract states
    % --------------------------------------------------------

    q  = x(1:5);
    dq = x(6:10);

    % --------------------------------------------------------
    % Compute joint accelerations from actuated dynamics
    % --------------------------------------------------------

    [ddq, tauAct, tauRaw] = robotActuatedDynamics(q, dq, u, useSaturation);

    % --------------------------------------------------------
    % Build state derivative
    %
    % x = [q; dq]
    % xdot = [dq; ddq]
    % --------------------------------------------------------

    xdot = [
        dq;
        ddq
    ];

    % --------------------------------------------------------
    % Output
    %
    % Here we choose output y as joint positions q.
    % --------------------------------------------------------

    y = q;

end