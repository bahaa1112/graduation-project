Q = [
     0  -30 -37 -60 -90;
     5  -28 -35 -58 -88;
    10  -25 -33 -55 -85;
    15  -20 -30 -50 -80
];

s = serial('COM9',9600);
fopen(s);

pause(2)

for k = 1:size(Q,1)

    cmd = sprintf('%.2f,%.2f,%.2f,%.2f,%.2f\n', ...
        Q(k,1),Q(k,2),Q(k,3),Q(k,4),Q(k,5));

    fprintf(s, cmd);

    pause(0.05);
end

fclose(s);
delete(s);
clear s;