
classdef connector
    properties
        rule
        myID
        oppID
        ownIP
        ownPort
        destIP
        destPort
        serverSocket
        clientSocket
    end
    
    methods
        
        function obj = connector(rule,myID, oppID,ownIP, ownPort, destIP,destPort)
            import java.net.ServerSocket
            import java.io.*
            obj.rule = rule;
            obj.myID = myID;
            obj.oppID = oppID;
            obj.ownIP = ownIP;
            obj.ownPort = ownPort;
            obj.destIP = destIP;
            obj.destPort = destPort; 
        end
        
        function establish(obj)
            if(obj.rule == 'player1')
                %// TO DO //%
                % send and check ID
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

        function syncTrial(obj,trial)
            if obj.rule == 'player1'
                obj.send(num2str(trial));
                assert(strcmp(num2str(trial), obj.fetch()));
            end
            
            if obj.rule == 'player2'
                assert(strcmp(num2str(trial), obj.fetch()));
                obj.send(num2str(trial));
            end
            
        end
        
        function send(obj,message)
            server(message,obj.ownPort,-1);
        end
        
        function data = fetch(obj)
            data = client(obj.destIP,obj.destPort,-1);
        end
        
        function oppRes = sendOwnResAndgetOppRes(obj,myRes)
            if obj.rule == 'player1'
                obj.send(num2str(myRes));
                oppRes = obj.fetch();
                oppRes = str2num(oppRes);
            end
            if obj.rule == 'player2'
                oppRes = obj.fetch();
                obj.send(num2str(myRes));
                oppRes = str2num(oppRes);
            end
            
        end

    end
end
    
