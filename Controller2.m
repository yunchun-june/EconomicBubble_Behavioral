clear all;
close all;
addpath('./Functions');

try
    %===== Parameters =====%
    initialCash         = 10000;
    initialStock        = 10;
    initialStockPrice   = 100;
    totalTrials         = 60;
    
    resultTime          =1;
    decideTime          =5;
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
    keyboard = keyboardHandler('Logitech');
    displayer = displayer(max(Screen('Screens')));
    parser = parser();
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
        myRes.decision = "no trade";
        myRes.events = strings(0,2);
        
        %Make Decision
        fprintf('Makind decision ....\n');
        startTime = GetSecs();
        timesUp = startTime+decideTime;
        decisionMade = FALSE;
        while GetSecs() < timesUp
            if ~decisionMade
                % Manual Mode
                %[keyName,timing] = keyboard.getResponse(timesUp);
                
                %Random Mode
                keyNameList = ["NA", "buy", "no trade", "sell", "confirm"];
                keyName = keyNameList(randi(5));
                timing = GetSecs();
                
                if keyName ~= "NA"
                    myRes.events(end+1,:) = [keyName,num2str(timing-startTime)];
                    fprintf("%s %s\n",keyName,num2str(timing-startTime));
                end

                if keyName == "buy" && me.canBuy(market.stockPrice)
                    myRes.decision = "buy";
                end
                if keyName == "no trade"
                    myRes.decision = "no trade";
                end
                if keyName == "sell" && me.canSell()
                    myRes.decision = "sell";
                end
                if keyName == "confirm"
                    decisionMade = TRUE;
                end
                % TODO %
                % show screen%
            end
            
            if decisionMade
                % TODO %
                % show screen%
            end
        end
        
        fprintf("timesUp! %s\n",num2str(GetSecs() - startTime));
        
        % TODO %
        % show screen%
        
        %Get opponent's response
        oppResRaw = cnt.sendOwnResAndgetOppRes(parser.resToStr(myRes));
        oppRes = parser.strToRes(oppResRaw);
        
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

