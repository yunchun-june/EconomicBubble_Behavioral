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
    decideTime          =10;
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

    %===== Initialize Componets =====%
    keyboard = keyboardHandler('Mac');
    display = displayer(max(Screen('Screens')));
    market = market(MARKET_BASELINE,initialStockPrice);
    me = player(initialCash,initialStock);
    opp = player(initialCash,initialStock);
    data = dataHandler('P1','P2',totalTrials,market,opp,me);
    
    
    %===== Establish Connection =====%
    cnt = connector('player2','localhost',3001,'localhost',3000);
    cnt.establish();

    %display.openScreen();

    %===== Game Start =====%
    for trial = 1:totalTrials
        
        %Syncing
        assert(strcmp(num2str(trial), cnt.fetch()));
        cnt.send(num2str(trial));
        
        %Fixation
        
        %See Status
        statusData = data.getStatusData(trial,2);
        %display.showStatus(statusData);
        data.logStatus('player2',trial);
        timeZero = GetSecs();
        while GetSecs()-timeZero < resultTime
            
        end
        
        %Make Decision
        fprintf('Please Make Decision.\n');
        finalDecision = NO_TRADE;
        timesUp = GetSecs()+decideTime;
        decisionMade = FALSE;
        while GetSecs() < timesUp
            while GetSecs()<timesUp && ~decisionMade
                temp_decision = randi(4);
                %temp_decision = keyboard.getResponse();
                if temp_decision == 1
                    if me.canBuy(market.stockPrice)
                        finalDecision = BUY;
                    end
                end

                if temp_decision == 2
                    finalDecision = NO_TRADE;
                end

                if temp_decision == 3
                    if me.canSell()
                        finalDecision = SELL;
                    end
                end
                
                if temp_decision == 4
                    decisionMade = TRUE;
                end
                
                %display.showDecision(statusData,finalDecision,ceil(timesUp - GetSecs()),FALSE);
            end
            %display.showDecision(statusData,finalDecision,ceil(timesUp - GetSecs()),TRUE);
        end
        
        %display.showDecision(statusData,finalDecision,0,TRUE);
        
        %Get opponent's response
        oppDecision = cnt.fetch();
        cnt.send(num2str(finalDecision));
        oppDecision = str2num(oppDecision);
        
        %Save Data
        data.update(market,opp,me,oppDecision,finalDecision,trial);
        
        %Update market and asset
        if(oppDecision == BUY)   opp.buyStock(market.stockPrice);end
        if(oppDecision == SELL)  opp.sellStock(market.stockPrice);end
        if(finalDecision == BUY)   me.buyStock(market.stockPrice);end
        if(finalDecision == SELL)  me.sellStock(market.stockPrice);end
        market.trade(finalDecision,oppDecision);
        
        data.preUpdate(market,opp,me,trial);
        
    end
    
    data.printStatus('player2',totalTrials+1);
    

catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
end

    