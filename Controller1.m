clear all;
close all;
addpath('./Functions');

try
    %===== Parameters =====%
    initialCash       = 1000;
    initialStock        = 0;
    initialStockPrice   = 100;
    trials              = 10;
    
    %===== Parameters =====%
    MARKET_BASELINE = 1;
    MARKET_BUBBLE = 2;
    MARKET_BURST = 3;
    TRUE = 1;
    FALSE = 0;
    
    %===== Establish Connection =====%
    cnt = connector('localhost',3000,'localhost',3001);
    cnt.send('Handshake');
    data = cnt.fetch();

    fprintf('Connection Established\n');
    
    %===== Initialize Componets =====%
    device = deviceHandler(max(Screen('Screens')),'Keyboard');
    mrk = market(MARKET_BASELINE,initialSotckPrice);
    me = player(initialCash,initialStock);
    opponent = player(initialCash,initialStock);
    
    
catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
end

