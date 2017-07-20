clear all;
close all;
addpath('./Functions');

try
    cnt = connector('1.171.154.207',3001,'1.171.154.207',3000);
    data = cnt.fetch();
    cnt.send('Handshake recieved');

    fprintf('Connection Established\n');

catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
end

    