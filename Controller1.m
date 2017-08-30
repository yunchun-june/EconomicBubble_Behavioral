clear all;
close all;
clc;
addpath('./Functions');
Screen('Preference', 'SkipSyncTests', 1);

try
    %===== Parameters =====%
    initialCash         = 10000;
    initialStock        = 10;
    initialStockPrice   = 100;
    totalTrials         = 60;
    
    resultTime          =5;
    decideTime          =5;
    fixationTime        =1;
    
    %===== Parameters =====%
    MARKET_BASELINE     = 1;
    MARKET_BUBBLE       = 2;
    MARKET_BURST        = 3;
    BUY                 = 1;  
    NO_TRADE            = 2; 
    SELL                = 3;
    TRUE                = 1;
    FALSE               = 0;
    
    %===== Inputs =====%
    rule = 'player1';
    myID = 'dummyID1';
    oppID = 'dummyID2';
    myIP = '192.168.1.83';
    oppIP = '192.168.1.95';
    myPort = 7676;
    oppPort = 5454;
    inputDeviceName = 'Mac';
    displayerOn = FALSE;
    
    %===== Initialize Componets =====%
    keyboard = keyboardHandler(inputDeviceName);
    displayer = displayer(max(Screen('Screens')),displayerOn,decideTime);
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

        %=========== Setting Up Trials ==============%
        
        %Syncing
        cnt.syncTrial(trial);
        
        % Update condition based on last decision
        data.updateCondition(market,me,opp,trial);
        statusData = data.getStatusData(trial,1);
        
        %response to get
        myRes.decision = 'no trade';
        myRes.events = strings(0,2);
        
        %=========== Fixation ==============%
        displayer.fixation(fixationTime);
       
        %========== Show Status and Make Decision ===============%

        data.logStatus(trial);
        startTime = GetSecs();
        deadline = startTime+resultTime+decideTime;
        decisionMade = FALSE;
        showHiddenInfo = FALSE;
        for remaining = resultTime+decideTime:-1:1
            timesUp = deadline - remaining;
            while GetSecs() < timesUp
                if ~decisionMade
                    displayer.showDecision(statusData,myRes.decision,showHiddenInfo,remaining,FALSE);
                    
                    %Auto Mode
                    %keyNameList = ['NA', 'buy', 'no trade', 'sell', 'confirm'];
                    %keyName = keyNameList(randi(5));
                    
                    %Manual Mode
                    [keyName,timing] = keyboard.getResponse(timesUp);
                    
                    if strcmp(keyName,'see')
                        myRes.events(end+1,:) = [keyName,num2str(timing-startTime)];
                        fprintf('%s %s\n',keyName,num2str(timing-startTime));
                        showHiddenInfo = TRUE;
                    end
                    if strcmp(keyName,'unsee')
                        myRes.events(end+1,:) = [keyName,num2str(timing-startTime)];
                        fprintf('%s %s\n',keyName,num2str(timing-startTime));
                        showHiddenInfo = FALSE;
                    end
                    
                    if remaining <= decideTime
                        
                        if strcmp(keyName,'buy') && me.canBuy(market.stockPrice)
                            myRes.events(end+1,:) = [keyName,num2str(timing-startTime)];
                            fprintf('%s %s\n',keyName,num2str(timing-startTime));
                            myRes.decision = 'buy';
                        end

                        if strcmp(keyName,'no trade')
                            myRes.events(end+1,:) = [keyName,num2str(timing-startTime)];
                            fprintf('%s %s\n',keyName,num2str(timing-startTime));
                            myRes.decision = 'no trade';
                        end

                        if strcmp(keyName,'sell') && me.canSell()
                            myRes.events(end+1,:) = [keyName,num2str(timing-startTime)];
                            fprintf('%s %s\n',keyName,num2str(timing-startTime));
                            myRes.decision = 'sell';
                        end
                        if strcmp(keyName,'confirm')
                            myRes.events(end+1,:) = [keyName,num2str(timing-startTime)];
                            fprintf('%s %s\n',keyName,num2str(timing-startTime));
                            decisionMade = TRUE;
                        end
                    
                    end

                end

                if decisionMade
                    displayer.showDecision(statusData,myRes.decision,showHiddenInfo,remaining,TRUE);
                end
            end
        end

        if showHiddenInfo == TRUE
            myRes.events(end+1,:) = ['unsee',num2str(GetSecs()-startTime)];
        end
        
        fprintf('timesUp!\n');
        displayer.showDecision(statusData,myRes.decision,FALSE,0,TRUE);
        
        %========== Exchange and Save Data ===============%
        
        %Get opponent's response
        oppResRaw = cnt.sendOwnResAndgetOppRes(parser.resToStr(myRes));
        oppRes = parser.strToRes(oppResRaw);
        
        %Save Data
        data.saveResponse(myRes,oppRes,trial);
        
        %Update market and player
        if(strcmp(myRes.decision,'buy'))   me.buyStock(market.stockPrice);end
        if(strcmp(myRes.decision,'sell'))  me.sellStock(market.stockPrice);end
        if(strcmp(oppRes.decision,'buy'))  opp.buyStock(market.stockPrice);end
        if(strcmp(oppRes.decision,'sell')) opp.sellStock(market.stockPrice);end
        market.trade(myRes.decision,oppRes.decision);
        
    end
    
    displayer.closeScreen();
    
catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
    displayer.closeScreen();
end

