function vlcCoordinatorstart(cfg, vlcConfig, numberOfDevices)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                DEFAULTS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    primitiveDefaults = cfg;
    
    disp("The default values for the primitive paramters set");
    disp(" ");
    
    nextPrimitive = strings([1, numberOfDevices]);
    previousPrimitive = strings([1, numberOfDevices]);
    loopVariable = true;
    dataPayload = "";
    waitTime = 0;
    ID = 9999;
    BE = 3;
    NB = 0;
    macMaxBE = 7;
    frameType = "";
    frameCommand = "";
    deviceID = 1;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Main Loop Execution                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    while loopVariable
        
%   Avoids collision in the process of accessing the csv file.
        timer = clock;
        timer = round(timer(6));
        flag = mod(timer ,2);
        
        if flag == 1
            fclose("all");
            continue
            
        else
%   Timer Loop. To introduce delay in execution for avaoiding
%   conflict in accessing the csv file by both Matlabs.
            for i=1:300000000
            end
            
        	csvFileH = fopen("vlcHold.csv");
            holdIndicator = fread(csvFileH);
        
            if isempty(holdIndicator)
                continue
            end
            
            holdVariable = holdIndicator(1)
            fclose(csvFileH);
            
            if holdVariable == 1
                
                waitTime = 0;
                
	            dissociationFile = fopen("vlcDissociation.csv");
	            numberOfDissociation = fread(dissociationFile);
	            fclose(dissociationFile);
	            
                if numberOfDissociation == numberOfDevices
                    disp("Coordinator dissociated. . .");
                    disp("Communication terminated. . .");
                    loopVariable = false;
                    continue
                end
                
	            if strcmp(nextPrimitive(deviceID), "MLMEDissociateIndication")
	                MLMEDissociateIndication(primitiveDefaults);
                end
                    
                randomNumber = zeros(1, numberOfDevices);

                for i=1:1:numberOfDevices
                    randomNumber(i) = randi(numberOfDevices);
                end

                greatest = max(randomNumber);                            
                count = 0;

                for i=1:1:numberOfDevices
                    if greatest == randomNumber(i)
                        count = count + 1;
                        ID = vertcat(ID, i);

                        if count == 2
                            break
                        end
                    end
                end

                if count < 2 %NO COLLISION
                    deviceID = ID(2)

                    authorityFile = fopen("vlcAuthority.csv", "w");
                    fwrite(authorityFile, deviceID);
                    fclose(authorityFile);

                    csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv");
                    Frame = fread(csvFileF);
                    fclose(csvFileF);

                    if isempty(Frame)
                        frameType(deviceID) = "";
                        frameCommand(deviceID) = "";
                        [nextPrimitive(deviceID), previousPrimitive(deviceID)] = vlcMessageCoordSequencer(primitiveDefaults, nextPrimitive(deviceID), frameType(deviceID), frameCommand(deviceID), vlcConfig, dataPayload, deviceID);

                    else

                        if all(Frame)
                            frameType(deviceID) = "";
                            frameCommand(deviceID) = "";
                            [nextPrimitive(deviceID), previousPrimitive(deviceID)] = vlcMessageCoordSequencer(primitiveDefaults, nextPrimitive(deviceID), frameType(deviceID), frameCommand(deviceID), vlcConfig, dataPayload, deviceID);

                        else
                            [vlcFrame, dataPayload] = vlcMACFrameDecoder(Frame);

                            csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
                            fwrite(csvFileF, ones(1,20));
                            fclose(csvFileF);

                            disp("Recieved frame after decoding :")
                            disp(vlcFrame);
                            frameType(deviceID) = vlcFrame.FrameType;
                            frameCommand(deviceID) = vlcFrame.MACCommand;
                            [nextPrimitive(deviceID), previousPrimitive(deviceID)] = vlcMessageCoordSequencer(primitiveDefaults, nextPrimitive(deviceID), frameType(deviceID), frameCommand(deviceID), vlcConfig, dataPayload, deviceID);
                        end
                    end
                    ID = 9999;

                else
                    while true
                        timeLapse = power(2, BE) - 1;
                        first = randi(timeLapse);
                        second = randi(timeLapse);
                        NB = NB + 1;

                        disp("BackOff Number :" + num2str(NB));

                        if BE == macMaxBE
                            terminator = fopen("vlcTerminate.csv", "w");            
                            fwrite(terminator, ID(2));
                            fclose(terminator);
                            deviceID = ID(3);
                            disp("The device with device ID " + num2str(ID(2)) + " has been dissociated due to communication failure.");
                            BE = 3;
                            break

                        end

                        if first == second
                            BE = BE + 1

                        else
                            if first > second
                                deviceID = ID(2);
                            else
                                deviceID = ID(3);
                            end
                            break
                        end
                    end

                    deviceID
                    authorityFile = fopen("vlcAuthority.csv", "w");
                    fwrite(authorityFile, deviceID);
                    fclose(authorityFile);

                    csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv");
                    Frame = fread(csvFileF);
                    fclose(csvFileF);

                    if isempty(Frame)
                        frameType(deviceID) = "";
                        frameCommand(deviceID) = "";
                        [nextPrimitive(deviceID), previousPrimitive(deviceID)] = vlcMessageCoordSequencer(primitiveDefaults, nextPrimitive(deviceID), frameType(deviceID), frameCommand(deviceID), vlcConfig, dataPayload, deviceID);

                    else

                        if all(Frame)
                            frameType(deviceID) = "";
                            frameCommand(deviceID) = "";
                            [nextPrimitive(deviceID), previousPrimitive(deviceID)] = vlcMessageCoordSequencer(primitiveDefaults, nextPrimitive(deviceID), frameType(deviceID), frameCommand(deviceID), vlcConfig, dataPayload, deviceID);

                        else
                            [vlcFrame, dataPayload] = vlcMACFrameDecoder(Frame);

                            csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
                            fwrite(csvFileF, ones(1,20));
                            fclose(csvFileF);

                            disp("Recieved frame after decoding :")
                            disp(vlcFrame);
                            frameType(deviceID) = vlcFrame.FrameType;
                            frameCommand(deviceID) = vlcFrame.MACCommand;
                            nextPrimitive(deviceID)
                            [nextPrimitive(deviceID), previousPrimitive(deviceID)] = vlcMessageCoordSequencer(primitiveDefaults, nextPrimitive(deviceID), frameType(deviceID), frameCommand(deviceID), vlcConfig, dataPayload, deviceID);
                        end
                    end

                end  
            	
        	
        	else 

        		waitTime = waitTime + 1;
                disp("Waiting for " + num2str(waitTime) + " compiler clocks");
                
                if waitTime > 30
                    csvFileH = fopen("vlcHold.csv", 'w');
                    fwrite(csvFileH, ones(1,1));
                    fclose(csvFileH);
                end 
            end
        end
    end
end

%%
function [nextPrimitive, previousPrimitive] = vlcMessageCoordSequencer(primitiveDefauts, nextPrimitive, frameType, frameCommand, vlcConfig, dataPayload, deviceID)
%   Sequencer. Determines the next primitive.

    previousPrimitive = nextPrimitive;
    
    if strcmp(nextPrimitive, "") &&  strcmp(frameType, "") && strcmp(frameCommand, "")
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        disp("null");
        
    elseif strcmp(nextPrimitive, "") &&  strcmp(frameType, "MAC command") && strcmp(frameCommand, "Beacon request")
        disp("Recieved MAC command frame with command Beacon request from Device MAC Layer.");
        disp(" ");
        nextPrimitive = "MLMEAssociateIndication";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        disp("Sending Beacon frame from Coordinator MAC layer to Device MAC Layer. . .");
        disp(" ");
        beaconConfig=vlcConfig;
        beaconConfig.FrameType = "Beacon";
        writeFrame=vlcMACFrameGenerator(beaconConfig);
        disp(beaconConfig);
        csvFileH = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
        fwrite(csvFileH, writeFrame);
        fclose(csvFileH);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateIndication") &&  strcmp(frameType, "MAC command") && strcmp(frameCommand, "Association request")
        disp("Recieved MAC command frame with command Association request from Device MAC Layer.");
        disp(" ");
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        disp("Sending Acknowledgment frame from Coordinator MAC layer to Device MAC Layer. . .");
        disp(" ");
        ackConfig = vlcConfig;
        ackConfig.FrameType='Acknowledgment';
        writeFrame = vlcMACFrameGenerator(ackConfig);
        disp(ackConfig);
        csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateIndication") &&  strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEAssociateIndication(primitiveDefauts);
        nextPrimitive = "MLMEAssociateResponse";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateResponse") &&  strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEAssociateResponse(primitiveDefauts);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        disp("Sending MAC Command frame with command Association response from Coordinator MAC layer to Device MAC Layer. . .");
        disp(" ");
        commandConfig = vlcConfig;
        commandConfig.FrameType = 'MAC command';
        commandConfig.MACCommand = 'Association response';
        writeFrame= vlcMACFrameGenerator(commandConfig);
        disp(commandConfig);
        csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateResponse") &&  strcmp(frameType, "Acknowledgment") && strcmp(frameCommand, "")
        disp("Recieved Acknowledgment frame from Device MAC Layer.");
        disp(" ");
        nextPrimitive = "MLMECommStatusIndication";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMECommStatusIndication") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMECommStatusIndication(primitiveDefauts);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMECommStatusIndication") && strcmp(frameType, "MAC command") && strcmp(frameCommand, "Data request")
        disp("Recieved MAC Command frame with command Data request from Device MAC Layer.");
        disp(" ");
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        disp("Sending Acknowledgment frame from Coordinator MAC layer to Device MAC Layer. . .");
        disp(" ");
        ackConfig = vlcConfig;
        ackConfig.FrameType='Acknowledgment';
        writeFrame = vlcMACFrameGenerator(ackConfig);
        disp(ackConfig);
        csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMECommStatusIndication") && strcmp(frameType, "Data") && strcmp(frameCommand, "")
        disp("Recieved Data frame from Device MAC Layer.");
        disp(" ");
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        disp(dataPayload);
        nextPrimitive = "MCPSDataIndication";
        disp("Sending Acknowledgment frame from Coordinator MAC layer to Device MAC Layer. . .");
        disp(" ");
        ackConfig = vlcConfig;
        ackConfig.FrameType='Acknowledgment';
        writeFrame = vlcMACFrameGenerator(ackConfig);
        disp(ackConfig);
        csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MCPSDataIndication") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MCPSDataIndication(primitiveDefauts, dataPayload);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MCPSDataIndication") && strcmp(frameType, "MAC command") && strcmp(frameCommand, "Disassociation notification")
        disp("Recieved MAC Command frame with command Disassociation notification from Device MAC Layer.");
        disp(" ");
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        nextPrimitive = "MLMEDissociateIndication";
        disp("Sending Acknowledgment frame from Coordinator MAC layer to Device MAC Layer. . .");
        disp(" ");
        ackConfig = vlcConfig;
        ackConfig.FrameType='Acknowledgment';
        writeFrame = vlcMACFrameGenerator(ackConfig);
        disp(ackConfig);
        csvFileF = fopen("vlcProcess" + num2str(deviceID) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    end
end

%%
%--------------------------------------------------------------------------
function MLMEAssociateIndication (primitiveDefaults)
    disp("Sending MLMEAssociateIndication primitive from device MAC Layer to device Higher Layer. . .");
    disp("DeviceAddress : " + primitiveDefaults.DeviceAddress);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEAssociateResponse (primitiveDefaults)
    disp("Sending MLMEAssociateResponse primitive from device Higher Layer to device MAC Layer. . .");
    disp("status : " + primitiveDefaults.status);
    disp("DeviceAddress : " + primitiveDefaults.DeviceAddress);
    disp("Association Short Address : " + primitiveDefaults.AssocShortAddr);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMECommStatusIndication (primitiveDefaults)
    disp("Sending MLMECommStatusIndication primitive from device MAC Layer to device Higher Layer. . .");
    disp("VPANID : " + primitiveDefaults.VPANID);
    disp("Source Address Mode : " + primitiveDefaults.SouceAddrMode);
    disp("Source Address : " + primitiveDefaults.SourceAddr);
    disp("Destination Address Mode : " + primitiveDefaults.DestinationAddrMode);
    disp("Destination Address : " + primitiveDefaults.DestinationAddr);
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end

%--------------------------------------------------------------------------
function MCPSDataIndication (primitiveDefaults, dataPayload)
    disp("Sending MCPSDataIndication primitive from device MAC Layer to device Higher Layer. . .");
    disp("Source Address Mode : " + primitiveDefaults.SouceAddrMode);
    disp("Source VPANID : " + primitiveDefaults.VPANID);
    disp("Source Address : " + primitiveDefaults.SourceAddr);
    disp("Destination Address Mode : " + primitiveDefaults.DestinationAddrMode);
    disp("Destination VPANID : " + primitiveDefaults.VPANID);
    disp("Destination Address : " + primitiveDefaults.DestinationAddr);
    disp("MSDU : " + dataPayload);
    %disp("MSDU Length : " + num2str(strlength(dataPayload)));
    disp("DSN :");
    disp(primitiveDefaults.DSN);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEDissociateIndication (primitiveDefaults)
%     csvFileH = fopen("vlcHold.csv", 'w');
%     fwrite(csvFileH, zeros(1,1));
%     fclose(csvFileH);
    disp("Sending MLMEDissociateIndication primitive from device MAC Layer to device Higher Layer. . .");
    disp("DeviceAddress : " + primitiveDefaults.DeviceAddress);
    disp("Dissociation Reason : " + primitiveDefaults.DissociationReason);
    disp(" ");
end