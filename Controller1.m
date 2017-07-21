clear all;
close all;
addpath('./Functions');

try
    %===== Parameters =====%
    initialCash         = 1000;
    initialStock        = 5;
    initialStockPrice   = 100;
    totalTrials         = 60;
    
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
    cnt = connector('localhost',3000,'localhost',3001);
    cnt.send('Handshake');
    data = cnt.fetch();

    fprintf('Connection Established\n');
    
    %===== Initialize Componets =====%
    device = deviceHandler(max(Screen('Screens')),'Mac');
    mrk = market(MARKET_BASELINE,initialStockPrice);
    me = player(initialCash,initialStock);
    opp = player(initialCash,initialStock);
    data = dataHandler('P1','P2',totalTrials,mrk,me,opp);
    
    %===== Game Start =====%
    
    for trial = 1:totalTrials
        if(trial == 20) mrk.setCondition(MARKET_BUBBLE); end
        if(trial == 40) mrk.setCondition(MARKET_BURST); end
        
        %Syncing
        cnt.send('Sync');
        syncResult = cnt.fetch();
        
        %Fixation
        
        %See Status
        data.printStatus('player1',trial);
        
        %Make Decision
        decisionMade = FALSE;
        while decisionMade == FALSE
            %temp_decision = randi(3);
            temp_decision = device.getResponse();
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
     

        %Get opponent's response
        cnt.send(num2str(finalDecision));
        oppDecision = cnt.fetch();
        oppDecision = str2num(oppDecision);
        
        %Save Data
        data.update(mrk,me,opp,finalDecision,oppDecision,trial);
        
        %Update market and asset
        if(oppDecision == BUY)   opp.buyStock(mrk.stockPrice);end
        if(oppDecision == SELL)  opp.sellStock(mrk.stockPrice);end
        if(finalDecision == BUY)   me.buyStock(mrk.stockPrice);end
        if(finalDecision == SELL)  me.sellStock(mrk.stockPrice);end
        mrk.trade(finalDecision,oppDecision);
        
        data.preUpdate(mrk,me,opp,trial);
    end
    
    data.printStatus('player1',totalTrials+1);
    
catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
end

