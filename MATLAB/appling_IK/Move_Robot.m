%% ÍÓÇÈ ÇáÅÍÏÇËíÇÊ æÅÑÓÇáåÇ 


x_cm = 40;
y_cm = 10;
z_cm = 25;

x = x_cm * 0.01;
y = y_cm * 0.01;
z = z_cm * 0.01;
T_des = transl(x, y, z);


[q_sol, err] = MYRobot.ikcon(T_des, q_init);
q_deg = rad2deg(q_sol);

disp('ÇáÒæÇíÇ ÇáãÍÓæÈÉ ÈÇáÏÑÌÇÊ:');
disp(q_deg);

% ÊÔİíÑ ÇáÈíÇäÇÊ æÅÑÓÇáåÇ ÚÈÑ ÇáãäİĞ s ÇáãæÌæÏ İí ÇáÜ Workspace
packet = sprintf('%.0f,%.0f,%.0f,%.0f,%.0f\n', ...
    q_deg(1)*100, ...
    q_deg(2)*100, ...
    q_deg(3)*100, ...
    q_deg(4)*100, ...
    q_deg(5)*100);

fprintf(s, packet); 
disp("? Êã ÅÑÓÇá ÇáÍÒãÉ ÇáäÕíÉ ÈäÌÇÍ:");
disp(packet);

pause(0.2);
if s.BytesAvailable > 0
    response = fscanf(s);
    disp("? ÇáÑÏ ÇáãÑÊÌÚ:");
    disp(response);
end

steps = 40; 


q_path = jtraj(q_init, q_sol, steps);

disp('? ÌÇÑí ÊÔÛíá ãÍÇßÇÉ ÇáÍÑßÉ...');
for t = 1:steps
    % ÑÓã ÇáÑæÈæÊ ÚäÏ ÇáÎØæÉ ÇáÒãäíÉ ÇáÍÇáíÉ t
    MYRobot.plot(q_path(t, :), 'workspace', [-0.4 0.4 -0.4 0.4 0 0.6], 'scale', 0.8, 'view', [45 30]);
    
    % ÊÍÏíË ÇáÚäæÇä áíÙåÑ ÊŞÏã ÇáÍÑßÉ
    title(sprintf('IK Result - DIY ARM (Moving... %d%%)', round((t/steps)*100)));
end

title('IK Result - DIY ARM (Position Reached! ?)');
disp('? ÇäÊåÊ ÇáãÍÇßÇÉ ææÕá ÇáÑæÈæÊ ááåÏİ.');

% ? ÓØÑ ÌæåÑí: ÊÍÏíË ÇáãæÖÚ ÇáÇÈÊÏÇÆí İí ÇáÜ Workspace áíÕÈÍ åæ ÇáæÖÚ ÇáÍÇáí
% åĞÇ íÖãä Ãä ÇáÍÑßÉ ÇáŞÇÏãÉ ÊÈÏÃ ãä ÍíË ÇäÊåì ÇáÑæÈæÊ ÇáÂä æáíÓ ãä ÇáÕİÑ
q_init = q_sol;