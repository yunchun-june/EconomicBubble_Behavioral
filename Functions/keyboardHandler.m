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
       
        function res = getResponse(obj)
            res = 0;

            KbEventFlush();
            [keyIsDown, secs, keyCode] = KbQueueCheck(obj.devInd);

            if secs(KbName(obj.buy))
                    res = 1;
                    fprintf('buy\n');
            end

            if secs(KbName(obj.noTrade))
                    res = 2;
                    fprintf('noTrade\n');
            end

            if secs(KbName(obj.sell))
                    res = 3;
                    fprintf('sell\n');
            end
            
            if secs(KbName(obj.confirm))
                res = 4;
                fprintf('confirmed\n');
            end

        end
        
    end
    
end
