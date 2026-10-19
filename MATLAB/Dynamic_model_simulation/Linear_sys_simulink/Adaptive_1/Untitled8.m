clear; clc; close all;
tspan = [0 10];
J_ref = [1;1;1;1;1];
%% ===============================
% System Matrices (Real System)
%% ===============================
A = [0 1 0 0 0 0 0 0 0 0;
     0 -457 0 192 0 -506 0 984 0 -64;
     0 0 0 1 0 0 0 0 0 0;
     0 192 0 -1287 0 2400 0 -2135 0 227;
     0 0 0 0 0 1 0 0 0 0;
     0 -506 0 2400 0 -6252 0 6992 0 -705;
     0 0 0 0 0 0 0 1 0 0;
     0 984 0 -2135 0 6992 0 -15125 0 962;
     0 0 0 0 0 0 0 0 0 1;
     0 -998 0 3521 0 -10947 0 14937 0 -1816];

B = [0 0 0 0 0;
     108 -45 120 -234 20;
     0 0 0 0 0;
     -45 306 -570 507 -73;
     0 0 0 0 0;
     120 -570 1486 -1662 229;
     0 0 0 0 0;
     -234 507 -1662 3595 -313;
     0 0 0 0 0;
     237 -837 2602 -3551 591];

d = [0;4.7;0;34;0;-45;0;26;0;-93]; % Disturbance vector

%% ===============================
% LQR Controller for Real System
%% ===============================
Q = 10*diag([1.1,1,1.5,1,1,1,1,1,0.9,1]);
R = diag([10,10,10,10,20]);
[K,~,~] = lqr(A,B,Q,R);


r = J_ref;

%% ===============================
% Simulate Real System without Uncertainty
%% ===============================
x0 = zeros(10,1);


U = @(t,x) -K*x + r;
dx = @(t,x) A*x + B*U(t,x) + d;
[t,x] = ode15s(dx,tspan,x0);

figure;
for i = 1:10
    subplot(5,2,i)
    plot(t, x(:,i),'LineWidth',1.5)
    ylabel(['q_' num2str(i)])
    grid on
end
sgtitle('Real System without Uncertainty');

%% ===============================
% Real System with Uncertainty
%% ===============================
basis_fun = @(t) 1*[0.2*sin(2*t); 0.5*cos(t); 2*sin(t); 2*cos(4*t); sin(t); ...
                  cos(3*t); 0.4*sin(t); 0.4*cos(3*t); sin(2*t); cos(t)];

weights = ones(5,10); % 5 inputs x 10 basis functions

dx_c = @(t,x) A*x + B*(U(t,x) + weights*basis_fun(t)) + d;
[t_c,x_c] = ode15s(dx_c,tspan,x0);

figure;
for i = 1:10
    subplot(5,2,i)
    plot(t_c, x_c(:,i),'LineWidth',1.5)
    ylabel(['q_' num2str(i)])
    grid on
end
sgtitle('Real System with Uncertainty');

%% ===============================
% Reference Model
%% ===============================
Am = [0 1 0 0 0 0 0 0 0 0;
     -100 -14 0 0 0 0 0 0 0 0;
      0 0 0 1 0 0 0 0 0 0;
      0 0 -100 -14 0 0 0 0 0 0;
      0 0 0 0 0 1 0 0 0 0;
      0 0 0 0 -100 -14 0 0 0 0;
      0 0 0 0 0 0 0 1 0 0;
      0 0 0 0 0 0 -100 -14 0 0;
      0 0 0 0 0 0 0 0 0 1;
      0 0 0 0 0 0 0 0 -100 -14];

Bm = zeros(10,5);
Bm(2,1) = 100;
Bm(4,2) = 100;
Bm(6,3) = 100;
Bm(8,4) = 100;
Bm(10,5)= 100;

Qm =diag([1,1,1,1,1,1,1,1,1,1]);
Rm =diag([100,100,100,100,200]);
[Km,~,~] = lqr(Am,Bm,Qm,Rm);

v = -eye(10);
p = lyap(Am,v);

%% ===============================
% Simulate Reference Model
%% ===============================
Um = @(tm,xm) -Km*xm + r;
dxm = @(tm,xm) Am*xm + Bm*Um(tm,xm);
[tm,xm] = ode15s(dxm,tspan,x0);

figure;
for i = 1:10
    subplot(5,2,i)
    plot(tm, xm(:,i),'LineWidth',1.5)
    ylabel(['q_' num2str(i)])
    grid on
end
sgtitle('Reference Model');

%% ===============================
% Adaptive MRAC Controller
%% ===============================
x0_ad = zeros(10,1);
xm0_ad = zeros(10,1);
omega_hat0 = zeros(10,5);
z0 = [x0_ad; xm0_ad; omega_hat0(:)];

[t_ad, z_ad] = ode45(@(t,z) Adiptive(t,z,A,B,K,r,Am,Bm,p,basis_fun,weights,d,Km), ...
                     tspan, z0);

x_ad  = z_ad(:,1:10);
xm_ad = z_ad(:,11:20);


xm_interp = interp1(tm, xm, t_ad);

figure;
for i=1:10
    subplot(5,2,i)
    plot(t_ad, x_ad(:,i),'b',t_ad, xm_interp(:,i),'r--','LineWidth',1.2)
    ylabel(['x_' num2str(i)])
    grid on
end
sgtitle('Adaptive MRAC vs Reference');
legend('System','Reference');




