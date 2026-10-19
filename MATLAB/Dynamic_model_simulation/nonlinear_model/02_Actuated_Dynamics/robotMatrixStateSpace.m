function [xdot, y, A, B, C, D, r] = robotMatrixStateSpace(t, x, u)
% ============================================================
% Nonlinear state-space model using matrix form:
%
%   xdot = A(q)*x + B(q)*u + r(q)
%   y    = C*x + D*u
%
% ============================================================

    %#ok<NASGU> % t is used for ode/Simulink compatibility

    x = x(:);
    u = u(:);

    if length(x) ~= 10
        error("x must be a 10x1 vector.");
    end

    if length(u) ~= 5
        error("u must be a 5x1 vector.");
    end

    % Extract joint positions
    q = x(1:5);

    % Get nonlinear state-space matrices
    [A, B, C, D, r] = robotStateMatrices(q);

    % State derivative
    xdot = A*x + B*u + r;

    % Output
    y = C*x + D*u;

end