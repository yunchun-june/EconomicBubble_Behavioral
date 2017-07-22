classdef displayer < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        wPtr
        width
        height
        screenID
    end
    
    methods
        function obj = displayer(screid)
            obj.screenID = screid;
        end
        
        function openScreen(obj)
            [obj.wPtr, screenRect]=Screen('OpenWindow',obj.screenID, 0,[],32,2);
            [obj.width, obj.height] = Screen('WindowSize', obj.wPtr);
        end
        
        function closeScreen(obj)
            Screen('CloseAll');
        end
        
    end
    
end

