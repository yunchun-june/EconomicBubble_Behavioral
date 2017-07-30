
classdef connector
    properties
        rule
        ownIP
        ownPort
        destIP
        destPort
        serverSocket
        clientSocket
    end
    
    methods
        
        function obj = connector(rule,ownIP, ownPort, destIP,destPort)
            import java.net.ServerSocket
            import java.io.*
            obj.rule = rule;
            obj.ownIP = ownIP;
            obj.ownPort = ownPort;
            obj.destIP = destIP;
            obj.destPort = destPort; 
        end
        
        function establish(obj,player)
            if(obj.rule == 'player1')
                obj.send('Handshake');
                fprintf('Recieved message from player2.\n');
                syncResult = obj.fetch();
                assert(strcmp(syncResult,'Handshake received'));
                fprintf('Message sent to player2.\n');
            end
            
            if(obj.rule == 'player2')
                syncResult = obj.fetch();
                assert(strcmp(syncResult,'Handshake'));
                fprintf('Recieved message from player1.\n');
                obj.send('Handshake received');
                fprintf('Message sent to player1.\n');
            end
            
            fprintf('Connection Established\n');
        end

        function send(obj,message)
            server(message,obj.ownPort,-1);
        end
        
        function data = fetch(obj)
            data = client(obj.destIP,obj.destPort,-1);
        end

    end
end
    
