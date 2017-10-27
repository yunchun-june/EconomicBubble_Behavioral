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
    totalTrials         = 20;
    
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
    
    %===== Inputs =====%
    fprintf('---Starting player 1---\n');
    myID                = 'practice';
    oppID               = 'practice';
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
    
    for trial = 1:totalTrials+1

        %=========== Setting Up Trials ==============%
       
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
        
        %Get opponent's response (randomly generated)
        resultList = {'buy'; 'no trade'; 'sell'};
        oppRes.decision = resultList{randi(3)};
        oppRes.events = cell(0,2);
        
        %Save Data
        data.saveResponse(myRes,oppRes,trial);
        
        %Update market and player
        if(strcmp(myRes.decision,'buy'))   me.buyStock(market.stockPrice);end
        if(strcmp(myRes.decision,'sell'))  me.sellStock(market.stockPrice);end
        if(strcmp(oppRes.decision,'buy'))  opp.buyStock(market.stockPrice);end
        if(strcmp(oppRes.decision,'sell')) opp.sellStock(market.stockPrice);end
        market.trade(myRes.decision,oppRes.decision);
    end
    
    displayer.blackScreen();
    WaitSecs(1);
    
    displayer.writeMessage('End of Practice');
    WaitSecs(3);
    displayer.blackScreen();
    WaitSecs(1);
    
    displayer.writeMessage('Do not touch any key');
    WaitSecs(3);
    displayer.blackScreen();
    WaitSecs(1);
    
    displayer.writeMessage('Please wait the instructors');
    keyboard.waitEscPress()
    
    displayer.closeScreen();
    ListenChar();
    fprintf('----END OF EXPERIMENT----\n');
    
catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
    displayer.closeScreen();
    ListenChar();
    ShowCursor();
end

