classdef keyboardHandler < handle
    
    properties
       dev
       devInd
    end
    
    properties (Constant)
        quitkey     = 'ESCAPE';
        confirm     = 'space';
        buy         = 'LeftArrow';
        noTrade     = 'DownArrow';
        sell        = 'RightArrow';
    end
    
    methods
        function obj = keyboardHandler(keyboardName)
            obj.setupKeyboard(keyboardName);
        end
        
        function setupKeyboard(obj,keyboardName)
            if strcmp(keyboardName,'Mac')
               keyboardName = 'Apple Internal Keyboard / Trackpad';
            end
            if strcmp(keyboardName,'Logitech')
                keyboardName = 'USB Receiver';
            end
            obj.dev=PsychHID('Devices');
            obj.devInd = find(strcmpi('Keyboard', {obj.dev.usageName}) & strcmpi(keyboardName, {obj.dev.product}));
            KbQueueCreate(obj.devInd);  
            KbQueueStart(obj.devInd);
            KbName('UnifyKeyNames');
        end
       
        function [keyName, timing] = getResponse(obj,timesUp)
            
            keyName = "NA";
            timing = -1;
            
            KbEventFlush();
            while GetSecs()<timesUp && keyName == "NA"
               [keyIsDown, secs, keyCode] = KbQueueCheck(obj.devInd); 
               if secs(KbName(obj.buy))
                    keyName = "buy";
                    timing = GetSecs();
                end

                if secs(KbName(obj.noTrade))
                    keyName = "no trade";
                    timing = GetSecs();
                end

                if secs(KbName(obj.sell))
                    keyName = "sell";
                    timing = GetSecs();
                end

                if secs(KbName(obj.confirm))
                    keyName = "confirm";
                    timing = GetSecs();
                end
            end

        end
        
    end
    
end

