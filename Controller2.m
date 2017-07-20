clear all;
close all;
addpath('./Functions');

try
    
    %===== Parameters =====%
    initialCash         = 1000;
    initialStock        = 0;
    initialStockPrice   = 100;
    totalTrials         = 10;
    
    %===== Parameters =====%
    MARKET_BASELINE = 1;
    MARKET_BUBBLE = 2;
    MARKET_BURST = 3;
    TRUE = 1;
    FALSE = 0;
    
    %===== Establish Connection =====%
    cnt = connector('localhost',3001,'localhost',3000);
    data = cnt.fetch();
    cnt.send('Handshake recieved');

    fprintf('Connection Established\n');
    
    %===== Initialize Componets =====%
    %device = deviceHandler(max(Screen('Screens')),'USB');
    mrk = market(MARKET_BASELINE,initialStockPrice);
    me = player(initialCash,initialStock);
    opponent = player(initialCash,initialStock);
    
    %===== Game Start =====%
    for trial = 1:totalTrials
        
        %Syncing
        data = cnt.fetch();
        cnt.send('Sync');
        
        %Fixation
        
        %See Status
        
        %Make Decision
        
        %Get opponent's response
        
        fprintf('Trials: %d\n',trial);
        
    end
    

catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
end

    