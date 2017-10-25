clear all;
close all;
clc;
addpath('./Functions');

try
    %===== Parameters =====%
    initialCash         = 10000;
    initialStock        = 10;
    initialStockPrice   = 100;
    totalTrials         = 100;
    
    resultTime          =8;
    decideTime          =6;
    fixationTime        =1;
    
    %===== Constants =====%
    MARKET_BASELINE     = 1;
    MARKET_BUBBLE       = 2;
    MARKET_BURST        = 3;
    TRUE                = 1;
    FALSE               = 0;
    
    %===== IP Config for 505 ===%
    setting = [12 19; 21 15 ;11 18 ;20 17; 10 16];
    [status,cmdout] = system('IPConfig');
    k = strfind(cmdout,'172.16.10');
    myIP = cmdout(k(1):k(1)+11);
    IPIndex = str2num(cmdout(k(1)+10:k(1)+11));
    for i = 1:5
        if(setting(i,1) == IPIndex)
            oppIP               = strcat('172.16.10.',num2str(setting(i,2)));
            rule                = 'player1';
            myPort              = 5454;
            oppPort             = 7676;
            break;
        end
        if(setting(i,2) == IPIndex)
            oppIP = strcat('172.16.10.',num2str(setting(i,1)));
            rule                = 'player2';
            myPort              = 7676;
            oppPort             = 5454;
            break;
        end
    end 
    
    %===== Inputs =====%

    fprintf('---Starting Experiment---\n');
    myID                = input('your ID: ','s');
    oppID               = input('Opponent ID: ','s');
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
    ListenChar(2);
    HideCursor();
    
    %===== Open Screen =====% 
    fprintf('Start after 3 seconds\n');
    WaitSecs(3);
    displayer.openScreen();
    
    %===== Game Start =====%
    displayer.writeMessage('Press Space To Start');
    keyboard.waitSpacePress();
    displayer.blackScreen();
    fprintf('Game Start.\n');
    
    for trial = 1:totalTrials+1
        
        if(trial == 21) market.setCondition(MARKET_BUBBLE); end
        if(trial == 61) market.setCondition(MARKET_BURST);end

        %=========== Setting Up Trials ==============%
        
        %Syncing
        if(trial == 1)
            displayer.writeMessage('Waiting for Opponent.');
            cnt.syncTrial(trial);
            displayer.blackScreen();
        else
            cnt.syncTrial(trial);
        end
        
        % Update condition based on last decision
        data.updateCondition(market,me,opp,trial);
        statusData = data.getStatusData(trial);
        if(trial == totalTrials+1) break; end
        
        %response to get
        myRes.decision = 'no trade';
        myRes.events = cell(0,2);
        
        %=========== Fixation ==============%
        displayer.fixation(fixationTime);
       
        %========== Show Status and Make Decision ===============%

        data.logStatus(trial);
        startTime = GetSecs();
        deadline = startTime+resultTime+decideTime;
        decisionMade = FALSE;
        showHiddenInfo = FALSE;
        
        for remaining = resultTime+decideTime:-1:1
            endOfThisSecond = deadline - remaining;
            while GetSecs() < endOfThisSecond
                if ~decisionMade
                    displayer.showDecision(statusData,myRes.decision,showHiddenInfo,remaining,FALSE);
                    
                    %Auto Mode
                    %keyNameList = ['NA', 'buy', 'no trade', 'sell', 'confirm'];
                    %keyName = keyNameList(randi(5));
                    
                    %Manual Mode
                    [keyName,timing] = keyboard.getResponse(endOfThisSecond);
                     
                    if remaining > decideTime && ~strcmp(keyName,'na')
                        myRes.events{end+1,1} = keyName;
                        myRes.events{end,2} = num2str(timing-startTime);
                        fprintf('%s %s\n',keyName,num2str(timing-startTime));  
                        
                        if strcmp(keyName,'quitkey')
                            displayer.closeScreen();
                            ListenChar();
                            fprintf('---- MANUALLY STOPPED ----\n');
                            return;
                        end
                        
                        if strcmp(keyName,'see')
                            showHiddenInfo = TRUE;
                        end
                        
                        if strcmp(keyName,'unsee')
                            showHiddenInfo = FALSE;
                        end
                    end
                    
                    
                    if remaining <= decideTime && ~strcmp(keyName,'na')
                        myRes.events{end+1,1} = keyName;
                        myRes.events{end,2} = num2str(timing-startTime);
                        fprintf('%s %s\n',keyName,num2str(timing-startTime));
                        
                        if strcmp(keyName,'quitkey')
                            displayer.closeScreen();
                            ListenChar();
                            ShowCursor();
                            fprintf('---- MANUALLY STOPPED ----\n');
                            return;
                        end
                        
                        if strcmp(keyName,'buy') && me.canBuy(market.stockPrice)
                            myRes.decision = 'buy';
                        end

                        if strcmp(keyName,'no trade')
                            myRes.decision = 'no trade';
                        end

                        if strcmp(keyName,'sell') && me.canSell()
                            myRes.decision = 'sell';
                        end

                        if strcmp(keyName,'confirm')
                            decisionMade = TRUE;
                            if showHiddenInfo == TRUE
                                myRes.events{end+1,1} = 'unsee';
                                myRes.events{end,2} = num2str(GetSecs()-startTime);
                            end
                        end

                        if strcmp(keyName,'see')
                            showHiddenInfo = TRUE;
                        end
                        
                        if strcmp(keyName,'unsee')
                            showHiddenInfo = FALSE;
                        end
                    end
                end

                if decisionMade && GetSecs() < endOfThisSecond
                    displayer.showDecision(statusData,myRes.decision,showHiddenInfo,remaining,TRUE);
                end
            end
        end

        if showHiddenInfo == TRUE
            myRes.events{end+1,1} = 'unsee';
            myRes.events{end,2} = num2str(GetSecs()-startTime);
        end
        
        if ~decisionMade
            myRes.decision = 'no trade';
        end
        
        fprintf('timesUp! decision: %s\n',myRes.decision);
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
    
    %show result on screen
    result = data.getResult();
    fprintf('Your Cash = %d\n',result.myCash);
    fprintf('Opponent Cash = %d\n',result.oppCash);
    
    if (result.myCash > result.oppCash)
        fprintf('[RESULT] you win\n');
    end
    if (result.myCash == result.oppCash)
        fprintf('[RESULT] draw\n');
    end
    if (result.myCash < result.oppCash)
        fprintf('[RESULT] you lose\n');
    end
    
    displayer.blackScreen();
    WaitSecs(1);
    displayer.writeMessage('End of Experiment');
    WaitSecs(3);
    displayer.blackScreen();
    WaitSecs(1);
    
    displayer.writeMessage('Please Inform the instructors');
    keyboard.waitEscPress()
    
    displayer.closeScreen();
    ListenChar();
    data.saveToFile();
    fprintf('----END OF EXPERIMENT----\n');
    
catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
    displayer.closeScreen();
    ListenChar();
    ShowCursor();
end
