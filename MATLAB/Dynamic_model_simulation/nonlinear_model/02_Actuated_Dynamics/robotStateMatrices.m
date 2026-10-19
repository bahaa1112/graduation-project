function [A, B, C, D, r, H, Mq, Gq] = robotStateMatrices(q)
% ============================================================
% State-space matrices for the nonlinear 5-DOF robotic arm
%
% Model form:
%   xdot = A(q)*x + B(q)*u + r(q)
%   y    = C*x + D*u
%
% State vector:
%   x = [q; dq]
%
% Output:
%   y = q
%
% Notes:
%   The system is nonlinear because A, B, and r depend on q.
% ============================================================

    q = q(:);

    if length(q) ~= 5
        error("q must be a 5x1 vector.");
    end

    % Core dynamics
    [Mq, Gq] = robotCoreDynamics(q);

    % Actuator constants
    [Ku, Kv, Ka, ~] = robotActuatorConstants();

    % Effective inertia matrix
    Meff = Mq + Ka;

    % H(q) = inv(M(q)+Ka)
    % Numerically, this is better than using inv(Meff)
    H = Meff \ eye(5);

    % State matrix A(q)
    A = [
        zeros(5,5), eye(5);
        zeros(5,5), -H*Kv
    ];

    % Input matrix B(q)
    B = [
        zeros(5,5);
        H*Ku
    ];

    % Gravity term r(q)
    r = [
        zeros(5,1);
        -H*Gq
    ];

    % Output matrix C
    C = [
        eye(5), zeros(5,5)
    ];

    % Direct transmission matrix D
    D = zeros(5,5);

end