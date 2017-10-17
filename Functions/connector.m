
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
        
        function establish(obj,myID,oppID)
            fprintf('-----------------------------\n');
            fprintf('Establishing Connection ....\n');
            
            if(strcmp(obj.rule,'player1'))
                sentMessage = strcat(myID,',',oppID);
                reveivedMessage = strcat(myID,',',oppID);
                obj.send(sentMessage);
                fprintf('Mesage sent to player2.\n');
                syncResult = obj.fetch();
                assert(strcmp(syncResult,reveivedMessage));
                fprintf('Recieved meeesge from player2.\n');
            end
            
            if(strcmp(obj.rule , 'player2'))
                sentMessage = strcat(oppID,',',myID);
                reveivedMessage = strcat(oppID,',',myID);
                syncResult = obj.fetch();
                assert(strcmp(syncResult,reveivedMessage));
                fprintf('Recieved message from player1.\n');
                obj.send(sentMessage);
                fprintf('Message sent to player1.\n');
            end
            
            fprintf('Connection Established\n');
            fprintf('-----------------------------\n');
        end

        function syncTrial(obj,trial)
            if strcmp(obj.rule , 'player1')
                obj.send(num2str(trial));
                assert(strcmp(num2str(trial), obj.fetch()));
            end
            
            if strcmp(obj.rule ,'player2')
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
        
        function oppRes = sendOwnResAndgetOppRes(obj,myResStr)
            fprintf('Sending data...\n');
            if strcmp(obj.rule , 'player1')
                obj.send(myResStr);
                oppRes = obj.fetch();
            end
            if strcmp(obj.rule , 'player2')
                oppRes = obj.fetch();
                obj.send(myResStr);
            end
            fprintf('Data sent and received.\n');
        end

    end
end
    
