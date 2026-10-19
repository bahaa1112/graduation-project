function Xdot=PID_closed_loop(t,X,qref,dqref,Kp,Ki,Kd)

q=X(1:5);
dq=X(6:10);
e_int=X(11:15);

e=qref-q;
de=dqref-dq;
[~, Gq] = robotCoreDynamics(q);
[Ku, ~, ~, ~] = robotActuatorConstants();

u_g = Ku \ Gq;% «·ÃÂœ «· ﬁ—Ì»Ì «··«“„ ·„ﬁ«Ê„… «·Ã«–»Ì… ”Ì „ «÷«› Â ·· PD


u=Kp*e+Ki*e_int+Kd*de+u_g;
u_sat=sat(u);
x=[q;dq];
[A,B,~,~,r]=robotStateMatrices(q);
xdot=A*x+B*u_sat+r;
e_int_dot=e;

Xdot=[xdot;e_int_dot];
end


function u_sat=sat(u)
u_sat=min(max(u,-6),6);
end
