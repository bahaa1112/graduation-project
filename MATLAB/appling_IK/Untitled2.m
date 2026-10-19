clc;
clear;
close all;

% «·≈Õœ«ÀÌ«  «·„ÿ·Ê»… »«·”‰ Ì„ — (Ê ÕÊÌ·Â«  ·ﬁ«∆Ì« ≈·Ï „ —)
x_cm = 21.4;
y_cm = 0;
z_cm = 31.9;

x = x_cm * 0.01;
y = y_cm * 0.01;
z = z_cm * 0.01;

T_des = transl(x, y, z);

%% ==========================================
% 1. DH Parameters + Adding Offsets ( ⁄—Ì› «·—Ê»Ê )
%% ==========================================

L(1) = Link([0, 0.05, 0.017, pi/2]);
L(2) = Link([0, 0,    0.12,  0]);
L(3) = Link([0, 0,    0.044, pi/2]);
L(4) = Link([0, 0.15, 0,     pi/2]);
L(5) = Link([0, 0,    0.152, 0]);

% ? ≈÷«›… «·≈“«Õ«  ·Ì ÿ«»ﬁ «·’›— «·—Ì«÷Ì „⁄ «·Ê÷⁄ «·„›—Êœ „Ìﬂ«‰ÌﬂÌ«
L(2).offset = pi/2;  % ≈“«Õ… «·„›’· «·À«‰Ì
L(4).offset = pi/2;  % ≈“«Õ… «·„›’· «·—«»⁄
L(5).offset = pi/2;  % ≈“«Õ… «·„›’· «·Œ«„”

% ÕœÊœ «·„›«’· «·¬„‰…
L(1).qlim = deg2rad([-90 90]);
L(2).qlim = deg2rad([-90 90]);
L(3).qlim = deg2rad([-90 90]);
L(4).qlim = deg2rad([-90 90]);
L(5).qlim = deg2rad([-90 90]);

MYRobot = SerialLink(L, 'name', 'DIY_ARM');
MYRobot.base = eye(4);

% «·Ê÷⁄ «·«» œ«∆Ì ··Õ”«»
q_init = [0 0 0 0 0];

%% ==========================================
% 2. Inverse Kinematics (Õ”«» «·Õ—ﬂÌ… «·⁄ﬂ”Ì…)
%% ==========================================

q0 = q_init;
[q_sol, err] = MYRobot.ikcon(T_des, q0);

%  ÕÊÌ· «·Õ· «·‰« Ã ≈·Ï œ—Ã« 
q_deg = rad2deg(q_sol);

disp('Joint Angles Calculated (deg):');
disp(q_deg);

%% ==========================================
% 4. Plot Result (—”„ «·—Ê»Ê   ›«⁄·Ì«)
%% ==========================================

figure;
MYRobot.plot(q_sol, ...
    'workspace', [-0.4 0.4 -0.4 0.4 0 0.6], ...
    'scale', 0.8, ...
    'view', [45 30]);

title('IK Result - DIY ARM');
grid on;
