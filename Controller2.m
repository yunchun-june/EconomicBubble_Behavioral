clear all;
close all;
addpath('./Functions');

try
    
    %===== Parameters =====%
    initialCash         = 1000;
    initialStock        = 5;
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
    NO_TRADE = 2;
    SELL = 3;
    TRUE = 1;
    FALSE = 0;
    
    %===== Establish Connection =====%
    cnt = connector('localhost',3001,'localhost',3000);
    syncResult = cnt.fetch();
    assert(strcmp(syncResult,'Handshake'));
    fprintf('Recieved message from player1.\n');
    cnt.send('Handshake received');
    fprintf('Message sent to player1.\n');

    fprintf('Connection Established\n');
    
    %===== Initialize Componets =====%
    keyboard = keyboardHandler('Mac');
    %display = displayer(max(Screen('Screens')));
    %display.openScreen();
    mrk = market(MARKET_BASELINE,initialStockPrice);
    me = player(initialCash,initialStock);
    opp = player(initialCash,initialStock);
    data = dataHandler('P1','P2',totalTrials,mrk,opp,me);
    
    %===== Game Start =====%
    for trial = 1:totalTrials
        
        %Syncing
        assert(strcmp(num2str(trial), cnt.fetch()));
        cnt.send(num2str(trial));
        
        %Fixation
        
        %See Status
        data.printStatus('player2',trial);
        timeZero = GetSecs();
        while GetSecs()-timeZero < resultTime
            
        end
        
        %Make Decision
        fprintf('Please Make Decision.\n');
        decisionMade = FALSE;
        finalDecision = NO_TRADE;
        while GetSecs() - timeZero<decideTime
            while decisionMade == FALSE
                temp_decision = randi(3);
                %temp_decision = keyboard.getResponse();
                if temp_decision == 1
                    if me.canBuy(mrk.stockPrice)
                        finalDecision = BUY;
                        decisionMade = TRUE;
                    end
                end

                if temp_decision == 2
                    finalDecision = NO_TRADE;
                    decisionMade = TRUE;
                end

                if temp_decision == 3
                    if me.canSell()
                        finalDecision = SELL;
                        decisionMade = TRUE;
                    end
                end
            end
        end
        
        %Get opponent's response
        oppDecision = cnt.fetch();
        cnt.send(num2str(finalDecision));
        oppDecision = str2num(oppDecision);
        
        %Save Data
        data.update(mrk,opp,me,oppDecision,finalDecision,trial);
        
        %Update market and asset
        if(oppDecision == BUY)   opp.buyStock(mrk.stockPrice);end
        if(oppDecision == SELL)  opp.sellStock(mrk.stockPrice);end
        if(finalDecision == BUY)   me.buyStock(mrk.stockPrice);end
        if(finalDecision == SELL)  me.sellStock(mrk.stockPrice);end
        mrk.trade(finalDecision,oppDecision);
        
        data.preUpdate(mrk,opp,me,trial);
        
    end
    
    data.printStatus('player2',totalTrials+1);
    

catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
end

    