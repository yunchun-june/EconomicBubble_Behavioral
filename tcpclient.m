% Clear console and workspace
clc;
clear all;
close all;

% Configuration and connection
t = tcpip('140.112.62.160',4013);

% Open socket and wait before sending data
fopen(t);
pause(0.2);

% Send data every 500ms
for i=0:10    
    DataToSend=[i;i]
    fwrite(t,DataToSend);
    pause (0.5);
end

% Close and delete connection
fclose(t);
delete(t);