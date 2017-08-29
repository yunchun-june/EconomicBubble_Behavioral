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
        see         = 'UpArrow';
    end
    
    methods
        
        %----Constructor-----%
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
       
        %----------%
        function [keyName, timing] = getResponse(obj,timesUp)
            
            keyName = 'NA';
            timing = -1;
            
            KbEventFlush();
            while GetSecs()<timesUp && strcmp(keyName,'NA')
               [isDown, press, release] = KbQueueCheck(obj.devInd); 
                if press(KbName(obj.buy))
                    keyName = 'buy';
                    timing = GetSecs();
                end

                if press(KbName(obj.noTrade))
                    keyName = 'no trade';
                    timing = GetSecs();
                end

                if press(KbName(obj.sell))
                    keyName = 'sell';
                    timing = GetSecs();
                end

                if press(KbName(obj.confirm))
                    keyName = 'confirm';
                    timing = GetSecs();
                end
                
                if press(KbName(obj.see))
                    keyName = 'see';
                    timing = GetSecs();
                end
                
                if release(KbName(obj.see))
                    keyName = 'unsee';
                    timing = GetSecs();
                end
            end

        end
        
        function press(obj)
            KbEventFlush();
            [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
            while 1
                [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
                if firstKeyPressTimes(KbName('space'))
                    fprintf('Space is pressed.\n');
                    break;
                end
            end
        end
    end
    
end

