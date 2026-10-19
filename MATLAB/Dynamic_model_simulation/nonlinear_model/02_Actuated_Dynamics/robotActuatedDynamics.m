function [ddq, tauAct, tauRaw, Mq, Gq] = robotActuatedDynamics(q, dq, u, useSaturation)
% ============================================================
% Actuated forward dynamics of the 5-DOF robotic arm
%
% Core robot model:
%   M(q)*ddq + G(q) = tauAct
%
% Actuator model:
%   tauAct = Ku*u - Kv*dq - Ka*ddq
%
% Combined model without saturation:
%   (M(q) + Ka)*ddq = Ku*u - Kv*dq - G(q)
%
% Inputs:
%   q             : 5x1 joint position vector [rad]
%   dq            : 5x1 joint velocity vector [rad/s]
%   u             : 5x1 control/voltage input vector
%   useSaturation : true or false
%
% Outputs:
%   ddq    : 5x1 joint acceleration vector [rad/s^2]
%   tauAct : 5x1 actuator torque after saturation [N.m]
%   tauRaw : 5x1 actuator torque before saturation [N.m]
%   Mq     : 5x5 total inertia matrix M(q)
%   Gq     : 5x1 gravity torque vector G(q)
% ============================================================

    if nargin < 4
        useSaturation = true;
    end

    q  = q(:);
    dq = dq(:);
    u  = u(:);

    if length(q) ~= 5 || length(dq) ~= 5 || length(u) ~= 5
        error("q, dq, and u must be 5x1 vectors.");
    end

    % --------------------------------------------------------
    % Get core robot dynamics:
    %   M(q), G(q)
    %
    % M(q) already includes actuator inertia Iact.
    % --------------------------------------------------------

    [Mq, Gq] = robotCoreDynamics(q);

    % --------------------------------------------------------
    % Get actuator constants:
    %   Ku, Kv, Ka, Tmax
    % --------------------------------------------------------

    [Ku, Kv, Ka, Tmax] = robotActuatorConstants();

    % --------------------------------------------------------
    % Unsaturated integrated dynamics:
    %
    %   (M(q)+Ka)*ddq = Ku*u - Kv*dq - G(q)
    % --------------------------------------------------------

    ddqNoSat = (Mq + Ka) \ (Ku*u - Kv*dq - Gq);

    % --------------------------------------------------------
    % Raw actuator torque:
    %
    %   tauRaw = Ku*u - Kv*dq - Ka*ddq
    % --------------------------------------------------------

    tauRaw = Ku*u - Kv*dq - Ka*ddqNoSat;

    % --------------------------------------------------------
    % Apply torque saturation
    % --------------------------------------------------------

    if useSaturation

        tauAct = min(max(tauRaw, -Tmax), Tmax);

        % If saturation occurs, the actual applied torque is tauAct.
        % Therefore the robot acceleration must satisfy:
        %
        %   M(q)*ddq + G(q) = tauAct
        %
        % so:
        %
        %   ddq = M(q) \ (tauAct - G(q))

        if any(abs(tauAct - tauRaw) > 1e-12)
            ddq = Mq \ (tauAct - Gq);
        else
            ddq = ddqNoSat;
        end

    else

        tauAct = tauRaw;
        ddq = ddqNoSat;

    end

end