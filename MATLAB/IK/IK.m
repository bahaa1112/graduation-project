clc;

robot_DH = create_DH_robot();

gik_DH = robotics.GeneralizedInverseKinematics( ...
    'RigidBodyTree', robot_DH, ...
    'ConstraintInputs', {'position'});

posTarget_DH = robotics.PositionTarget('body5');
posTarget_DH.PositionTolerance = 1e-3;

% DH theta offsets
theta_offset_DH = [
    0;
    pi/2;
    0;
    pi;
    pi/2
];

% Initial guess in physical joint coordinates q
q0_phys = deg2rad([45; 45; 45; 45; 45]);

% Initial guess for IK variables theta_DH
q_prev_IK = q0_phys + theta_offset_DH;

q_out_IK = zeros(5,1);

disp('IK initialized successfully.');