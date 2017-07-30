classdef dataHandler <handle

%    column                 index
%    trials                 =1
%    marketCondition        =2
%    marketDramatic         =3
%    stockPrice             =4
%    player1Cash            =5
%    player1Stock           =6
%    player1TotalAsset      =7
%    player1Decision        =8
%    player1RT              =9
%    player1event           =10
%    player2Cash            =10
%    player2Stock           =11
%    player2TotalAsset      =12
%    player2Decision        =13
%    player2RT              =14
%    player2event           =15
   
    
    properties
        player1ID
        player2ID
        result
    end
    
    methods
        function obj = dataHandler(ID1,ID2,trials,mrk,p1,p2)
            obj.player1ID = ID1;
            obj.player2ID = ID2;
            obj.result = zeros(trials+1,14);
            obj.result(1,1) = 1;
            obj.result(1,2) = mrk.marketCondition;
            obj.result(1,3) = mrk.dramatic;
            obj.result(1,4) = mrk.stockPrice;
            obj.result(1,5) = p1.cash;
            obj.result(1,6) = p1.stock;
            obj.result(1,7) = p1.getTotalAsset(mrk.stockPrice);
            obj.result(1,8) = 0;
            obj.result(1,9) = 0;
            obj.result(1,10) = p2.cash;
            obj.result(1,11) = p2.stock;
            obj.result(1,12) = p2.getTotalAsset(mrk.stockPrice);
            obj.result(1,13) = 0;
            obj.result(1,14) = 0;
            
        end
        
        function update(obj,mrk,p1,p2,d1,d2,i)
            obj.result(i,1) = i;
            obj.result(i,2) = mrk.marketCondition;
            obj.result(i,3) = mrk.dramatic;
            obj.result(i,4) = mrk.stockPrice;
            obj.result(i,5) = p1.cash;
            obj.result(i,6) = p1.stock;
            obj.result(i,7) = p1.getTotalAsset(mrk.stockPrice);
            obj.result(i,8) = d1;
            obj.result(i,9) = 0;
            obj.result(i,10) = p2.cash;
            obj.result(i,11) = p2.stock;
            obj.result(i,12) = p2.getTotalAsset(mrk.stockPrice);
            obj.result(i,13) = d2;
            obj.result(i,14) = 0;
        end
        
        function preUpdate(obj,mrk,p1,p2,i)
            i = i+1;
            obj.result(i,1) = i;
            obj.result(i,2) = mrk.marketCondition;
            obj.result(i,3) = mrk.dramatic;
            obj.result(i,4) = mrk.stockPrice;
            obj.result(i,5) = p1.cash;
            obj.result(i,6) = p1.stock;
            obj.result(i,7) = p1.getTotalAsset(mrk.stockPrice);
            obj.result(i,10) = p2.cash;
            obj.result(i,11) = p2.stock;
            obj.result(i,12) = p2.getTotalAsset(mrk.stockPrice);
        end
        
        function data = fetchData(obj,i)
            data = obj.result(i,:);
        end
        
        function logStatus(obj,player,i,mrk,p1,p2)
            action = {'buy','no trade','sell'};
            
            fprintf('=================================================\n');
            fprintf('Trial          %d\n',obj.result(i,1));
            if( i == 1)
                fprintf('Stock Price    %d\n',obj.result(i,4));
            else
                fprintf('Stock Price    %d (%d)\n',obj.result(i,4),obj.result(i,4)-obj.result(i-1,4));
            end
            fprintf('           Cash    Stock   Asset   LastAction\n');
            
            if(strcmp(player,'player1') && i ~= 1)
                fprintf('you        %d      %d      %d      %s\n',obj.result(i,5), obj.result(i,6), obj.result(i,7),action{obj.result(i-1,8)});
                fprintf('opp        %d      %d      %d      %s\n',obj.result(i,10), obj.result(i,11), obj.result(i,12),action{obj.result(i-1,13)});
            end
            
            if(strcmp(player,'player1') && i == 1)
                fprintf('you        %d      %d      %d      NA\n',obj.result(1,5), obj.result(1,6), obj.result(1,7));
                fprintf('opp        %d      %d      %d      NA\n',obj.result(1,10), obj.result(1,11), obj.result(1,12));
            end
            
            if(strcmp(player,'player2') && i ~= 1)
                fprintf('you        %d      %d      %d      %s\n',obj.result(i,10), obj.result(i,11), obj.result(i,12),action{obj.result(i-1,13)});
                fprintf('opp        %d      %d      %d      %s\n',obj.result(i,5), obj.result(i,6), obj.result(i,7),action{obj.result(i-1,8)});
            end
            
            if(strcmp(player,'player2') && i == 1)
                fprintf('you        %d      %d      %d      NA\n',obj.result(i,10), obj.result(i,11), obj.result(i,12));
                fprintf('opp        %d      %d      %d      NA\n',obj.result(i,5), obj.result(i,6), obj.result(i,7));
            end
            
        end
        
        function data = getStatusData(obj,i,player)
            action = {'buy','no trade','sell'};
            data.stockPrice = obj.result(i,4);
            
            if player == 1
                data.cash = obj.result(i,5);
                data.stock = obj.result(i,6);
                data.stockValue = obj.result(i,6)*obj.result(i,4);
                data.totalAsset= obj.result(i,7);
            end
            if player == 2
                data.cash = obj.result(i,10);
                data.stock = obj.result(i,11);
                data.stockValue = obj.result(i,11)*obj.result(i,4);
                data.totalAsset= obj.result(i,12);
            end
            
            if i ==1
                data.change = 0;
                data.d1 = 'no trade';
                data.d2 = 'no trade';
            else
                data.change = obj.result(i,4)-obj.result(i-1,4);
                if player == 1
                    data.d1 = action{obj.result(i-1,8)};
                    data.d2 = action{obj.result(i-1,13)};
                end
                if player == 2
                    data.d1 = action{obj.result(i-1,13)};
                    data.d2 = action{obj.result(i-1,8)};
                end
                
            end
        end
    end
    
end

