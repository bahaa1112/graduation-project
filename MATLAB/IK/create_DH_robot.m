function robot = create_DH_robot()

% =========================================================
% Create 5-DOF robot using Standard DH convention
% MATLAB R2019a compatible
%
% Important:
% The joint variables used by the IK are DH total angles:
% theta_DH = q + theta_offset
% =========================================================

robot = robotics.RigidBodyTree;
robot.DataFormat = 'column';

% -----------------------------
% Dimensions [m]
% -----------------------------
a1 = 0.017;
l1 = 0.05;
l2 = 0.12;
l3 = 0.044;
l4 = 0.15;
l5 = 0.152;

% -----------------------------
% DH table without theta offsets
% [a alpha d theta]
% The theta variable itself will be solved by IK.
% -----------------------------
DH = [
    a1,  pi/2, l1, 0;
    l2,  0,    0,  0;
    l3,  pi/2, 0,  0;
    0,   pi/2, l4, 0;
    l5,  0,    0,  0
];

% Physical joint limits for q [rad]
qmin = deg2rad([-90; -70; -70; -90; -90]);
qmax = deg2rad([ 90;  70;  70;  90;  90]);

% DH theta offsets
theta_offset = [
    0;
    pi/2;
    0;
    pi;
    pi/2
];

% Limits for DH theta variables
theta_min = qmin + theta_offset;
theta_max = qmax + theta_offset;

parent = robot.BaseName;

for i = 1:5

    body = robotics.RigidBody(['body', num2str(i)]);
    joint = robotics.Joint(['joint', num2str(i)], 'revolute');

    setFixedTransform(joint, DH(i,:), 'dh');

    joint.PositionLimits = [theta_min(i), theta_max(i)];

    body.Joint = joint;

    addBody(robot, body, parent);

    parent = body.Name;

end

end