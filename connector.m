
classdef connector
    properties
        ownIP
        ownPort
        destIP
        destPort
        serverSocket
        clientSocket
    end
    
    methods
        
        function obj = connector(ownIP, ownPort, destIP,destPort)
            import java.net.ServerSocket
            import java.io.*
            obj.ownIP = ownIP;
            obj.ownPort = ownPort;
            obj.destIP = destIP;
            obj.destPort = destPort; 
        end

        function send(obj,message)
            server(message,obj.ownPort,-1);
        end
        
        function fetch(obj)
            data = client(obj.destIP,obj.destPort,-1);
            fprintf(1,'%s\n',data);
        end
    end
end
    
