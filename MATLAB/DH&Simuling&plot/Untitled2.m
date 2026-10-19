clc;
clear;
close all;



x =10*0.01;
y = 0*0.01;
z = 0*0.01;
%% =========================
% DH Parameters (SI units)
%% =========================

L(1) = Link([0, 0.05, 0.017, pi/2]);
L(2) = Link([0, 0,    0.12,  0]);
L(3) = Link([0, 0,    0.044, pi/2]);
L(4) = Link([0, 0.15, 0,     pi/2]);
L(5) = Link([0, 0,    0.152, 0]);

L(1).qlim = deg2rad([-90 90]);
L(2).qlim = deg2rad([-70 70]);
L(3).qlim = deg2rad([-70 70]);
L(4).qlim = deg2rad([-90 90]);
L(5).qlim = deg2rad([-90 90]);

MYRobot = SerialLink(L, 'name', 'DIY_ARM');
MYRobot.base = eye(4);

%% =========================
% Forward configuration (initial)
%% =========================

q_init = [0  pi/2  0  pi  pi/2];

T_init = MYRobot.fkine(q_init);

disp('Initial End-Effector Pose:');
disp(T_init);

%% =========================
% Desired Position (IK target)
%% =========================



T_des = transl(x, y, z);

%% =========================
% Inverse Kinematics
%% =========================

q0 = q_init;

[q_sol, err] = MYRobot.ikcon(T_des, q0);

disp('IK Solution (rad):');
disp(q_sol);

disp('IK Solution (deg):');
disp(rad2deg(q_sol));

disp('Final Error:');
disp(err);

%% =========================
% Plot result
%% =========================

figure;
MYRobot.plot(q_sol, ...
    'workspace', [-0.4 0.4 -0.4 0.4 0 0.6], ...
    'scale', 0.8, ...
    'view', [45 30]);

title('IK Result - DIY ARM');
grid on;

