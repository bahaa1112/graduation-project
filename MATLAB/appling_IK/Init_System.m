%% ÊåíÆÉ ÇáäÙÇã æİÊÍ ÇáÇÊÕÇá
clc;
clear;
close all;

disp('--- ÈÏÁ ÊåíÆÉ ÇáäÙÇã ---');

% 1. ÊÚÑíİ ÇáÑæÈæÊ (DH Parameters) ãÚ ÇáÅÒÇÍÇÊ æÇáÍÏæÏ
L(1) = Link([0, 0.05, 0.017, pi/2]);
L(2) = Link([0, 0,    0.12,  0]);
L(3) = Link([0, 0,    0.044, pi/2]);
L(4) = Link([0, 0.15, 0,     pi/2]);
L(5) = Link([0, 0,    0.152, 0]);

%L(1).offset = pi/2;
L(2).offset = pi/2;  
L(4).offset = pi/2;  
L(5).offset = pi/2;  

L(1).qlim = deg2rad([-90 90]);
L(2).qlim = deg2rad([-90 90]);
L(3).qlim = deg2rad([-90 90]);
L(4).qlim = deg2rad([-90 90]);
L(5).qlim = deg2rad([-90 90]);

MYRobot = SerialLink(L, 'name', 'DIY_ARM');
MYRobot.base = eye(4);
q_init = [0 0 0 0 0]; % ÇáæÖÚ ÇáÇÈÊÏÇÆí ááÍÓÇÈ

% 2. ÅÚÏÇÏ æİÊÍ ãäİĞ ÇáÓíÑíÇá 
instrreset; % ÊäÙíİ ÇáãäÇİĞ ÇáÚÇáŞÉ
s = serial('COM9'); 
set(s, 'BaudRate', 9600); 
set(s, 'Timeout', 5);
set(s, 'Terminator', 'LF');

try
    disp('ÌÇÑí İÊÍ ãäİĞ ÇáÓíÑíÇá...');
    fopen(s);
    disp('ÇäÊÙÇÑ ÇÓÊŞÑÇÑ ÇáÇÊÕÇá (3 ËæÇäò)...');
    pause(3); 
    disp('? ÇáäÙÇã ÌÇåÒ ÊãÇãÇğ æÇáÇÊÕÇá ãÓÊŞÑ!');
catch
    error('İÔá İÊÍ ÇáãäİĞ COM9. ÊÃßÏ ãä ÇáÅÚÏÇÏÇÊ Ãæ ÇáÇÊÕÇá ÇáÇİÊÑÇÖí.');
end