classdef player < handle
    
    properties
        cash
        stock
    end
    
    %=======================%
    
    methods
        % constructor
        function obj = player(c,s)
            obj.cash = c;
            obj.stock = s;
        end
        
        function [] = showStatus(obj)
            disp(obj.cash)
            disp(obj.stock)
        end
        
        function totalAsset = getTotalAsset(obj,currentStockPrice)
            totalAsset = obj.cash + obj.stock*currentStockPrice;
        end
        
        function buySuccess = buyStock(obj,currentStockPrice)
            if(obj.cash > currentStockPrice)
                obj.cash = obj.cash - currentStockPrice;
                obj.stock = obj.stock+1;45
                buySuccess = 1;
            else
                buySuccess = 0;
            end
        end
        
        function sellSuccess = sellStock(obj,currentStockPrice)
            if(obj.stock > 0)
                obj.cash = obj.cash + currentStockPrice;
                obj.stock = obj.stock-1;
                sellSuccess = 1;
            else
                sellSuccess = 0;
            end
        end
        
    end
end

