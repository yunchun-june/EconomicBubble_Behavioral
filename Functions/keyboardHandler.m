classdef keyboardHandler < handle
    
    properties
       dev
       devInd
    end
    
    properties (Constant)
        quitkey     = 'ESCAPE';
        confirm     = 'o';
        buy         = 't'; %'LeftArrow';
        noTrade     = '7&'; %'DownArrow';
        sell        = '8*'; %'RightArrow';
        see         = 'space'; %'UpArrow';
    end
    
    methods
        
        %---- Constructor -----%
        function obj = keyboardHandler(keyboardName)
            obj.setupKeyboard(keyboardName);
        end
        
        function setupKeyboard(obj,keyboardName)
            if strcmp(keyboardName,'Mac')
               keyboardName = 'Apple Internal Keyboard / Trackpad';
            end
            if strcmp(keyboardName,'Wireless')
                keyboardName = 'USB Receiver';
            end
            if strcmp(keyboardName,'USB')
                keyboardName = 'USB Keyboard';
            end
            
            obj.dev=PsychHID('Devices');
            obj.devInd = find(strcmpi('Keyboard', {obj.dev.usageName}) & strcmpi(keyboardName, {obj.dev.product}));
            KbQueueCreate(obj.devInd);  
            KbQueueStart(obj.devInd);
            KbName('UnifyKeyNames');
        end
       
        %----- Functions -----%
        function [keyName, timing] = getResponse(obj,timesUp)
            NA          =0;
            BUY         =1;
            NO_TRADE    =2;
            SELL        =3;
            CONFIRM     =4;
            SEE         =5;
            UNSEE       =6;
            
            keyName = NA;
            timing = -1;
            
            KbEventFlush();
            while GetSecs()<timesUp && keyName == NA
               [isDown, press, release] = KbQueueCheck(obj.devInd); 
                if press(KbName(obj.buy))
                    keyName = BUY;
                    timing = GetSecs();
                end

                if press(KbName(obj.noTrade))
                    keyName = NO_TRADE;
                    timing = GetSecs();
                end

                if press(KbName(obj.sell))
                    keyName = SELL;
                    timing = GetSecs();
                end

                if press(KbName(obj.confirm))
                    keyName = CONFIRM;
                    timing = GetSecs();
                end
                
                if press(KbName(obj.see))
                    keyName = SEE;
                    timing = GetSecs();
                end
                
                if release(KbName(obj.see))
                    keyName = UNSEE;
                    timing = GetSecs();
                end
            end

        end
        
        function waitSpacePress(obj)
            fprintf('press space to start.\n');
            KbEventFlush();
            [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd);
            while 1
                [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
                if firstKeyPressTimes(KbName('space'))
                    fprintf('space is pressed.\n');
                    break;
                end
            end
        end
    end
    
end

