classdef market < handle

    properties
        marketCondition
        stockPrice
        dramatic = 0;
    end
    
    properties (Constant)
        BASELINE = 1;
        BUBBLE = 2;
        BURST = 3;
        BUY = 1;
        NO_ACTION = 2;
        SELL = 3;
        baselineRate    = [1.1  1.06   1.00;
                           1.06 1.00   0.94;
                           1.00 0.94   0.90];
        bubbleRate      = [1.10 1.06   1.00;
                           1.06 1.00   0.97;
                           1.00 0.97   0.95];
        burstRate       = [1.05 1.03   1.00;
                           1.03 1.00   0.95;
                           1.00 0.95   0.90];
    end
    
    %=======================%
    
    methods
        %constructor
        function obj = market(condition,stockPrice)
            obj.marketCondition = condition;
            obj.stockPrice = stockPrice;
        end
        
        function [] = trade(obj,p1Act,p2Act)

            if(obj.marketCondition == obj.BASELINE)
                rate = obj.baselineRate(p1Act,p2Act);
            end
            if(obj.marketCondition == obj.BUBBLE)
                rate = obj.bubbleRate(p1Act,p2Act);
            end
            if(obj.marketCondition == obj.BURST)
                rate = obj.burstRate(p1Act,p2Act);
            end
            
            if obj.dramatic == 1
                rate = rate + (rate-1)*2;
            end
            
            obj.stockPrice = ceil(obj.stockprice * rate);
        end

        
        function [] = setCondition(obj,condition)
            obj.marketCondition = condition;
        end
        
        function [] = setDramatic(obj,dramatic)
            obj.dramatic = dramatic;
        end
    end

end