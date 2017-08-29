clear all;
close all;
clc;
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
    rule = 'player1';
    myID = 'dummyID1';
    oppID = 'dummyID2';
    myIP = 'localhost';
    oppIP = 'localhost';
    myPort = 3000;
    oppPort = 3001;
    
    %===== Initialize Componets =====%
    keyboard = keyboardHandler('Mac');
    displayer = displayer(max(Screen('Screens')));
    parser = parser();
    market = market(MARKET_BASELINE,initialStockPrice);
    me = player(initialCash,initialStock);
    opp = player(initialCash,initialStock);
    data = dataHandler(myID,oppID,rule,totalTrials);
    
    %===== Establish Connection =====% 
    cnt = connector(rule,myID, oppID,myIP,myPort,oppIP,oppPort);
    cnt.establish();
        
    displayer.openScreen();
    
    %===== Game Start =====%
    
    for trial = 1:totalTrials
        
        %Syncing
        cnt.syncTrial(trial);
        
        % Update condition based on last decision
        data.updateCondition(market,me,opp,trial);
        statusData = data.getStatusData(trial,1);
                
        %Display condition
        displayer.showStatus(statusData);
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
        deadline = startTime+decideTime;
        decisionMade = FALSE;
        myRes.decision = "no trade";
        showHiddenInfo = FALSE;
        for remaining = 5:-1:1
            timesUp = deadline - remaining +1;
            while GetSecs() < timesUp
                if ~decisionMade
                    % show Screen
                    displayer.showDecision(statusData,myRes.decision,showHiddenInfo,remaining,0);

                    [keyName,timing] = keyboard.getResponse(timesUp);

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
                    if keyName == "see"
                        showHiddenInfo = TRUE;
                    end
                    if keyName == "unsee"
                        showHiddenInfo = FALSE;
                    end
                end

                if decisionMade
                    displayer.showDecision(statusData,myRes.decision,showHiddenInfo,remaining,1);
                end
            end
        end
        
        
        if showHiddenInfo == TRUE
            myRes.events(end+1,:) = ["unsee",num2str(GetSecs()-startTime)];
        end
        
        fprintf("timesUp! %s\n",num2str(GetSecs() - startTime));
        displayer.showDecision(statusData,myRes.decision,FALSE,0,1);
        
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
    displayer.closeScreen();
end

