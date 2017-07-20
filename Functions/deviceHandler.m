classdef deviceHandler < handle
    
    properties
       wPtr
       width
       height
       screenID
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
            obj.screenID = screid;
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
        
        function openScreen(obj)
            [obj.wPtr, screenRect]=Screen('OpenWindow',obj.screenID, 0,[],32,2);
            [obj.width, obj.height] = Screen('WindowSize', obj.wPtr);
            
        end
        
        function closeScreen(obj)
            Screen('CloseAll');
        end
        
        function setupKeyboard(obj,keyboardName)
            if keyboardName == 'Mac', keyboardName = 'Apple Internal Keyboard / Trackpad'; end
            if keyboardName == 'USB', keyboardName = 'USB Receiver'; end
            obj.dev=PsychHID('Devices');
            obj.devInd = find(strcmpi('Keyboard', {obj.dev.usageName}) & strcmpi(keyboardName, {obj.dev.product}));
            KbQueueCreate(obj.devInd);  
            KbQueueStart(obj.devInd);
            KbName('UnifyKeyNames');
        end
        
    end
    
end

