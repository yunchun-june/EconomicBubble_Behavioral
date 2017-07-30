clear all;
close all;
addpath('./Functions');

try
    %===== Parameters =====%
    initialCash         = 1000;
    initialStock        = 5;
    initialStockPrice   = 50;
    totalTrials         = 60;
    
    resultTime          =1;
    decideTime          =1;
    fixationTime        =1;
    
    %===== Parameters =====%
    MARKET_BASELINE = 1;
    MARKET_BUBBLE = 2;
    MARKET_BURST = 3;
    BUY = 1;  
    NO_TRADE =  2 ; 
    SELL = 3;
    TRUE = 1;
    FALSE = 0;
    
    %===== Inputs =====%
    rule = 'player2';
    myID = 'dummyID2';
    oppID = 'dummyID1';
    myIP = 'localhost';
    oppIP = 'localhost';
    myPort = 3001;
    oppPort = 3000;
    
    %===== Initialize Componets =====%
    keyboard = keyboardHandler('Mac');
    displayer = displayer(max(Screen('Screens')));
    market = market(MARKET_BASELINE,initialStockPrice);
    me = player(initialCash,initialStock);
    opp = player(initialCash,initialStock);
    data = dataHandler(myID,oppID,rule,totalTrials);
    
    %===== Establish Connection =====% 
    cnt = connector(rule,myID, oppID,myIP,myPort,oppIP,oppPort);
    cnt.establish();
        
    %display.openScreen();
    
    %===== Game Start =====%
    
    for trial = 1:totalTrials
        
        %Syncing
        cnt.syncTrial(trial);
        
        % Update condition based on last decision
        data.updateCondition(market,me,opp,trial);
        %statusData = data.getStatusData(trial,1);
                
        %Display condition
        %displayer.showStatus(statusData);
        data.logStatus(trial);
        timeZero = GetSecs();
        while GetSecs()-timeZero < resultTime
            
        end
        
        %response to get
        myRes.decision = "buy";
        myRes.RT = 0;
        myRes.events = [];
        
        %Make Decision
        fprintf('Makind decision ....\n');
        timesUp = GetSecs()+decideTime;
        decisionMade = FALSE;
        while GetSecs() < timesUp
            
        end
        
        %Get opponent's response
        %oppRes = cnt.sendOwnResAndgetOppRes(myRes);
        oppRes = myRes;
        
        %Save Data
        data.saveResponse(myRes,oppRes,trial);
        
        %Update market and player
        if(myRes.decision == "buy")   me.buyStock(market.stockPrice);end
        if(myRes.decision == "sell")  me.sellStock(market.stockPrice);end
        if(oppRes.decision == "buy")  opp.buyStock(market.stockPrice);end
        if(oppRes.decision == "sell") opp.sellStock(market.stockPrice);end
        market.trade(myRes.decision,oppRes.decision);
        
    end
    
    %displayer.closeScreen();
    
catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
end

