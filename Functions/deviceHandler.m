classdef deviceHandler < handle
    
    properties
       wPtr
       width
       height
       dev
       devInd
    end
    
    properties (Constant)
        quitkey     = 'ESCAPE';
        space       = 'space';
        down        = 'DownArrow';
        left        = 'LeftArrow';
        right       = 'RightArrow';
    end
    
    methods
        function obj = deviceHandler(screid,keyboardName)
            obj.setupKeyboard(keyboardName);
            obj.openScreen(screid);
        end
        
        function res = getResponse(obj)
            while true
                KbEventFlush();
                [keyIsDown, secs, keyCode] = KbQueueCheck(obj.devInd);
                if secs(KbName(obj.space))
                        res = 'space';
                        break;
                end
            end
        end
        
        function openScreen(obj,screid)
            [obj.wPtr, screenRect]=Screen('OpenWindow',screid, 0,[],32,2);
            [obj.width, obj.height] = Screen('WindowSize', obj.wPtr);
            
        end
        
        function closeScreen(obj)
            Screen('CloseAll');
        end
        
        function setupKeyboard(obj,keyboardName)
            obj.dev=PsychHID('Devices');
            obj.devInd = find(strcmpi(keyboardName, {obj.dev.usageName}) & strcmpi(keyboardName, {obj.dev.product}));
            KbQueueCreate(obj.devInd);  
            KbQueueStart(obj.devInd);
            KbName('UnifyKeyNames');
        end
        
    end
    
end

