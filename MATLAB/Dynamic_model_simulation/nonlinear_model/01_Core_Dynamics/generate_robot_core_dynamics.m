clear; clc;

% ============================================================
% Generate robot core dynamics
%
% This script generates:
%   robotCoreDynamics.m
%   robotCoreTau.m
%
% Core model:
%   tau = M(q)*ddq + G(q)
%
% where:
%   M(q) = D(q) + Iact
%
% Coriolis and centrifugal terms are neglected.
%
% Units:
%   Internal length  : cm
%   Internal mass    : g
%   Internal inertia : g.cm^2
%   Output torque    : N.m
% ============================================================

fprintf("\nBuilding core symbolic dynamic model...\n");

% ============================================================
% Output folder
% ============================================================

coreFolder = fileparts(mfilename("fullpath"));
generatedFolder = fullfile(coreFolder, "generated_core");

if ~exist(generatedFolder, "dir")
    mkdir(generatedFolder);
end

% ============================================================
% Symbols
% ============================================================

syms th1 th2 th3 th4 th5 real
syms ddth1 ddth2 ddth3 ddth4 ddth5 real

q = [
    th1;
    th2;
    th3;
    th4;
    th5
];

ddq = [
    ddth1;
    ddth2;
    ddth3;
    ddth4;
    ddth5
];

n = 5;
p = sym(pi);

% ============================================================
% DH table
%
% A_i = RotZ(theta_i) * TransZ(d_i) * TransX(a_i) * RotX(alpha_i)
%
% Units:
% a, d : cm
% angles : rad
% ============================================================

A1 = DH(sym(1.7),  p/2,    sym(5),  th1);
A2 = DH(sym(12),   sym(0),  sym(0),  th2 + p/2);
A3 = DH(sym(4.4),  p/2,    sym(0),  th3);
A4 = DH(sym(0),    p/2,    sym(15), th4 + p);
A5 = DH(sym(15.2), sym(0),  sym(0),  th5 + p/2);

A = {A1, A2, A3, A4, A5};

% ============================================================
% Q matrix for revolute joints
% ============================================================

Q = sym([
     0  -1   0   0;
     1   0   0   0;
     0   0   0   0;
     0   0   0   0
]);

% ============================================================
% Compute U_ij
%
% U_ij = d(T_i^0)/d(q_j)
% ============================================================

fprintf("Computing U matrices...\n");

U = cell(n, n);

for i = 1:n
    for j = 1:n
        U{i, j} = computeUij(i, j, A, Q);
    end
end

% ============================================================
% Link pseudo-inertia matrices J1..J5
% ============================================================

J1 = sym([
    2211   0     0       -75;
    0      3751  0       -67;
    0      0     1940    404.5;
   -75    -67    404.5   257.7
]);

J2 = sym([
    377.88  0      0       0;
    0       5632   0       690.8;
    0       0      884.5   47.18;
    0       690.8  47.18   168.5
]);

J3 = sym([
    661.47  0     0       334;
    0       670   0       50.5;
    0       0     377.5  -19;
    334     50.5 -19      90
]);

J4 = sym([
    295   0       0        38.6;
    0     1303.2  0       -3.86;
    0     0       8235     1323.9;
    38.6 -3.86   1323.9   193
]);

J5 = sym([
    300      0        0      13.875;
    0        2751     0      425.725;
    0        0        376   -297;
    13.875   425.725 -297    92.5
]);

J = {J1, J2, J3, J4, J5};

% Check symmetry
for k = 1:n
    if ~isequal(J{k}, transpose(J{k}))
        error("J%d is not symmetric.", k);
    end
end

% ============================================================
% Masses and centers of mass
%
% m : grams
% r : cm
% ============================================================

m = sym([
    257.7;
    168.5;
    90;
    193;
    92.5
]);

r1 = sym([-0.29; -0.26;  1.57; 1]);
r2 = sym([ 0;     4.1;   0.28; 1]);
r3 = sym([ 3.71;  0.56; -0.21; 1]);
r4 = sym([ 0.2;  -0.02;  6.86; 1]);
r5 = sym([ 0.15;  4.6;  -3.21; 1]);

r = {r1, r2, r3, r4, r5};

% ============================================================
% Actuator inertia
%
% Iact = 4e-6 kg.m^2
%
% Conversion:
% 1 kg.m^2 = 1e7 g.cm^2
%
% Therefore:
% Iact = 40 g.cm^2
% ============================================================

Iact = sym(40);

% ============================================================
% Inertia matrix D(q)
%
% D_ij = sum_{p=max(i,j)}^5 Trace(U_pj * J_p * U_pi^T)
% ============================================================

fprintf("Computing inertia matrix D(q)...\n");

D = sym(zeros(n, n));

for i = 1:n
    for j = i:n

        expr = sym(0);

        for link = max(i, j):n
            expr = expr + trace( ...
                U{link, j} * J{link} * transpose(U{link, i}) ...
            );
        end

        D(i, j) = expr;
        D(j, i) = expr;
    end
end

% ============================================================
% Total inertia matrix M(q)
%
% M(q) = D(q) + Iact
% ============================================================

M = D;

for i = 1:n
    M(i, i) = M(i, i) + Iact;
end

% ============================================================
% Gravity vector
%
% Gravity is expressed in base frame:
%
% g0 = [0; 0; -981; 0] cm/s^2
% ============================================================

g0 = sym([0; 0; -981; 0]);

% ============================================================
% Gravity vector G(q)
%
% G_i = sum_{p=i}^5 -m_p * g0^T * U_pi * r_cp
% ============================================================

fprintf("Computing gravity vector G(q)...\n");

G = sym(zeros(n, 1));

for i = 1:n

    expr = sym(0);

    for link = i:n
        expr = expr - m(link) * ...
            (transpose(g0) * U{link, i} * r{link});
    end

    G(i) = expr;
end

% ============================================================
% Convert units to N.m
%
% 1 g.cm^2/s^2 = 1e-7 N.m
% ============================================================

scale = sym(1) / sym(10000000);

M_Nm = scale * M;
G_Nm = scale * G;

tau_Nm = M_Nm * ddq + G_Nm;

% ============================================================
% Static test
% ============================================================

fprintf("\nStatic torques at q=0, ddq=0:\n");

zeroSubs = [
    th1, th2, th3, th4, th5, ...
    ddth1, ddth2, ddth3, ddth4, ddth5
];

zeroValues = zeros(1, 10);

tau_static = double(subs(tau_Nm, zeroSubs, zeroValues));

for i = 1:n
    fprintf("tau%d = %.10f N.m\n", i, tau_static(i));
end

% ============================================================
% Generate MATLAB numerical functions
% ============================================================

fprintf("\nGenerating core MATLAB function files...\n");

% ------------------------------------------------------------
% robotCoreDynamics(q)
%
% Input:
%   q : 5x1 vector [rad]
%
% Outputs:
%   M : 5x5 total inertia matrix
%   G : 5x1 gravity vector
% ------------------------------------------------------------

matlabFunction(M_Nm, G_Nm, ...
    'File', fullfile(generatedFolder, 'robotCoreDynamics'), ...
    'Vars', {q}, ...
    'Outputs', {'M', 'G'}, ...
    'Optimize', true);

% ------------------------------------------------------------
% robotCoreTau(q, ddq)
%
% Inputs:
%   q   : 5x1 vector [rad]
%   ddq : 5x1 vector [rad/s^2]
%
% Output:
%   tau : 5x1 torque vector [N.m]
% ------------------------------------------------------------

matlabFunction(tau_Nm, ...
    'File', fullfile(generatedFolder, 'robotCoreTau'), ...
    'Vars', {q, ddq}, ...
    'Outputs', {'tau'}, ...
    'Optimize', true);

addpath(generatedFolder);

fprintf("\nDone.\n");
fprintf("Generated core dynamics files are saved in:\n%s\n", generatedFolder);

% ============================================================
% Test generated functions
% ============================================================

fprintf("\nTesting generated core functions...\n");

q0 = zeros(5, 1);
ddq0 = zeros(5, 1);

[M0, G0] = robotCoreDynamics(q0);
tau0 = robotCoreTau(q0, ddq0);

disp("G(q=0) =");
disp(G0);

disp("tau(q=0, ddq=0) =");
disp(tau0);

% ============================================================
% Local functions
% ============================================================

function A = DH(a, alpha, d, th)

    A = [
        cos(th), -sin(th)*cos(alpha),  sin(th)*sin(alpha), a*cos(th);
        sin(th),  cos(th)*cos(alpha), -cos(th)*sin(alpha), a*sin(th);
        0,        sin(alpha),          cos(alpha),         d;
        0,        0,                   0,                  1
    ];

    A = sym(A);
end

function Uij = computeUij(i, j, A, Q)

    if j > i
        Uij = sym(zeros(4, 4));
        return;
    end

    result = sym(eye(4));

    for k = 1:i

        if k == j
            result = result * Q;
        end

        result = result * A{k};
    end

    Uij = result;
end