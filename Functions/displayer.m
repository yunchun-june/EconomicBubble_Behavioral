classdef displayer < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        wPtr
        width
        height
        xCen
        yCen
        screenID
        row
        col
    end
    
    properties (Constant)
        WHITE = [255 255 255];
        YELLOW = [255 255 0];
        GREEN = [0 255 0];
        RED = [255 0 0];
    end
    
    methods
        function obj = displayer(screid)
            obj.screenID = screid;
        end
        
        function openScreen(obj)
            [obj.wPtr, screenRect]=Screen('OpenWindow',obj.screenID, 0,[],32,2);
            [obj.width, obj.height] = Screen('WindowSize', obj.wPtr);
            obj.xCen = obj.width/2;
            obj.yCen = obj.height/2;
            for i = 1:10
                obj.row(i) = -(i-6)*obj.height/10;
            end
            
            for i = 1:5
                obj.col(i) = (i-3)*obj.width/6;
            end
        end
        
        function closeScreen(obj)
            Screen('CloseAll');
        end
        
        function showStatus(obj,data)
            obj.write('Stock Price:',1,3,'white',30);
            obj.write(num2str(data.stockPrice),2,3,'white',30);
            if data.change<0
                output = '('+num2str(data.change)+')';
                obj.write(output,3,3,'red',30);
            end
            
            if data.change ==0
                obj.write('(+0)',3,3,'white',30);
            end
            
            if data.change>0
                output = '(+'+num2str(data.change)+')';
                obj.write(output,3,3,'green',30);
            end
            
            obj.write('Cash',1,4,'white',30);
            obj.write('Stock',2,4,'white',30);
            obj.write('Stock Value',3,4,'white',30);
            obj.write('Total Asset',4,4,'white',30);
            obj.write(num2str(data.cash),1,5,'white',30);
            obj.write(num2str(data.stock),2,5,'white',30);
            obj.write(num2str(data.stockValue),3,5,'white',30);
            obj.write(num2str(data.totalAsset),4,5,'white',30);
            obj.write('Your last decision:',1,6,'white',30);
            obj.write(data.d1,3,6,'white',30);
            obj.write('Opponents last decision:',1,7,'white',30);
            obj.write(data.d2,3,7,'white',30);
            
            Screen('Flip',obj.wPtr);
        end
        
        function showDecision(obj,data,temp,confirmed)
            obj.write('Stock Price:',1,3,'white',30);
            obj.write(num2str(data.stockPrice),2,3,'white',30);
            if data.change<0
                output = '('+num2str(data.change)+')';
                obj.write(output,3,3,'red',30);
            end
            
            if data.change ==0
                obj.write('(+0)',3,3,'white',30);
            end
            
            if data.change>0
                output = '(+'+num2str(data.change)+')';
                obj.write(output,3,3,'green',30);
            end
            
            obj.write('Cash',1,4,'white',30);
            obj.write('Stock',2,4,'white',30);
            obj.write('Stock Value',3,4,'white',30);
            obj.write('Total Asset',4,4,'white',30);
            obj.write(num2str(data.cash),1,5,'white',30);
            obj.write(num2str(data.stock),2,5,'white',30);
            obj.write(num2str(data.stockValue),3,5,'white',30);
            obj.write(num2str(data.totalAsset),4,5,'white',30);
            obj.write('Your last decision:',1,6,'white',30);
            obj.write(data.d1,3,6,'white',30);
            obj.write('Opponents last decision:',1,7,'white',30);
            obj.write(data.d2,3,7,'white',30);
            
            obj.write('buy',1,8,'white',30);
            obj.write('no trade',2,8,'white',30);
            obj.write('sell',3,8,'white',30);
            
            if confirmed == 0
                if temp == 1 obj.write('buy',1,8,'yellow',30); end
                if temp == 2 obj.write('no trade',2,8,'yellow',30); end
                if temp == 3 obj.write('sell',3,8,'yellow',30); end
            end
            
            if confirmed == 1
                if temp == 1 obj.write('buy',1,8,'red',30); end
                if temp == 2 obj.write('no trade',2,8,'red',30); end
                if temp == 3 obj.write('sell',3,8,'red',30); end
            end
            
            Screen('Flip',obj.wPtr);
        end
        
        function write(obj,text,x,y,c,size)
            if strcmp(c,'white') color = obj.WHITE; end
            if strcmp(c,'red') color = obj.RED; end
            if strcmp(c,'green') color = obj.GREEN; end
            if strcmp(c,'yellow') color = obj.YELLOW; end

            Screen(obj.wPtr,'TextSize', size);
            Screen('DrawText',obj.wPtr,char(text), obj.xCen+obj.col(x), obj.yCen-obj.row(y), color);
            
        end
        
    end
    
end

