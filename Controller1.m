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
    totalTrials         = 5;
    
    resultTime          =8;
    decideTime          =6;
    fixationTime        =1;
    
    %===== Constants =====%
    MARKET_BASELINE     = 1;
    MARKET_BUBBLE       = 2;
    MARKET_BURST        = 3;
    TRUE                = 1;
    FALSE               = 0;
    rule                = 'player1';
    
    NA          =0;
    BUY         =1;
    NO_TRADE    =2;
    SELL        =3;
    CONFIRM     =4;
    SEE         =5;
    UNSEE       =6;
    keyresponse = {'na','buy','no trade','sell','confirm','see','unsee'};
    
    %===== Inputs =====%
    myID                = '1234567';
    oppID               = '7654321';
    myIP                = 'localhost';
    oppIP               = 'localhost';
    myPort              = 7676;
    oppPort             = 5454;
    inputDeviceName     = 'Mac';
    displayerOn         = TRUE;
    screenID            = 0;
    
    %===== Initialize Componets =====%
    keyboard    = keyboardHandler(inputDeviceName);
    displayer   = displayer(max(Screen('Screens')),displayerOn,decideTime);
    parser      = parser();
    market      = market(MARKET_BASELINE,initialStockPrice);
    me          = player(initialCash,initialStock);
    opp         = player(initialCash,initialStock);
    data        = dataHandler(myID,oppID,rule,totalTrials);
    
    %===== Establish Connection =====% 
    cnt = connector(rule,myID, oppID,myIP,myPort,oppIP,oppPort);
    cnt.establish(myID,oppID);
    
    %===== Open Screen =====% 
    fprintf('Start after 5 secs, move cursor to script\n');
    WaitSecs(5);
    displayer.openScreen();
    
    %===== Game Start =====%
    displayer.writeMessage('Press Space To Start');
    keyboard.waitSpacePress();
    displayer.blackScreen();
    fprintf('Game Start.\n');
    
    for trial = 1:totalTrials

        %=========== Setting Up Trials ==============%
        
        %Syncing
        cnt.syncTrial(trial);
        
        % Update condition based on last decision
        data.updateCondition(market,me,opp,trial);
        statusData = data.getStatusData(trial,1);
        
        %response to get
        myRes.decision = 'no trade';
        myRes.events = zeros(0,2);
        
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
                      
                    if keyName == SEE
                        myRes.events(end+1,:) = [keyName,timing-startTime];
                        fprintf('%d %f\n',keyresponse{keyName},num2str(timing-startTime));
                        showHiddenInfo = TRUE;
                    end
                    
                    if keyName == UNSEE
                        myRes.events(end+1,:) = [keyName,timing-startTime];
                        fprintf('%d %f\n',keyresponse{keyName},num2str(timing-startTime));
                        showHiddenInfo = FALSE;
                    end
                    
                    if remaining <= decideTime
                        
                        if keyName == BUY && me.canBuy(market.stockPrice)
                            myRes.events(end+1,:) = [keyName,timing-startTime];
                            fprintf('%d %f\n',keyresponse{keyName},num2str(timing-startTime));
                            myRes.decision = 'buy';
                        end

                        if keyName == NO_TRADE
                            myRes.events(end+1,:) = [keyName,timing-startTime];
                            fprintf('%d %f\n',keyresponse{keyName},num2str(timing-startTime));
                            myRes.decision = 'no trade';
                        end

                        if keyName == SELL && me.canSell()
                            myRes.events(end+1,:) = [keyName,timing-startTime];
                            fprintf('%d %f\n',keyresponse{keyName},num2str(timing-startTime));
                            myRes.decision = 'sell';
                        end
                        
                        if keyName == CONFIRM
                            myRes.events(end+1,:) = [keyName,timing-startTime];
                            fprintf('%d %f\n',keyresponse{keyName},num2str(timing-startTime));
                            decisionMade = TRUE;
                        end
                    end
                end

                if decisionMade && GetSecs() < timesUp
                    displayer.showDecision(statusData,myRes.decision,showHiddenInfo,remaining,TRUE);
                end
            end
        end

        if showHiddenInfo == TRUE
            myRes.events{end+1,:} = [UNSEE,num2str(GetSecs()-startTime)];
        end
        
        if ~decisionMade
            myRes.decision = 'no trade';
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
    data.saveToFile();
    
catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
    displayer.closeScreen();
end

