function vlcCoordinatorstart(cfg, vlcConfig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                DEFAULTS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    primitiveDefaults = cfg;
    
    disp("The default values for the primitive paramters set");
    disp(" ");
    
    nextPrimitive = "";
    previousPrimitive = "";
    loopVariable = true;
    dataPayload = "";
    macAckWaitDuration = 0;
    
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

%   Check for the last primitive which indicates dissociation of coordinator. 
            if strcmp(previousPrimitive, "MLMEDissociateIndication")
                loopVariable = false;
                MLMEDissociateIndication(primitiveDefaults);
                disp("Coordinator dissociated. . .");
                disp("Communication terminated.")
                csvFileH = fopen("vlcHold.csv", 'w');
                fwrite(csvFileH, zeros(1,1));
                fclose(csvFileH);
            
            else
%   Reads the vlcHold file to assign the authority to the device or vice
%   versa.
                csvFileH = fopen("vlcHold.csv");
                holdIndicator = fread(csvFileH);
            
                if isempty(holdIndicator)
                    continue
                end
            
                holdVariable = holdIndicator(1);
                fclose(csvFileH);           
            
                if holdVariable == 0
                    macAckWaitDuration = macAckWaitDuration + 1;
                    disp("Wait time = ");
                    disp(macAckWaitDuration);
                    
%   If wait time exceeds the predefined threshold then retransmission of
%   frames occur.
                    if macAckWaitDuration == 20
                        csvFileH = fopen("vlcHold.csv", 'w');
                        fwrite(csvFileH, ones(1,1));
                        fclose(csvFileH);
                        nextPrimitive = previousPrimitive;
                        disp("Wait time exceeded macAckWaitDuration.");
                        disp(" ");
                        disp("RETRANSMITTING THE PREVIOUS FRAME. . .");
                        disp("Retransmitted after " + num2str(macAckWaitDuration) + " compiler clocks");
                        disp(" ");
                        macAckWaitDuration = 0;
                    else
                        continue
                    end
                    
%   Execution of main logic for determining the next frame and primitive.
                else
%   Resets the wait time.
                    macAckWaitDuration = 0;
                    csvFileF = fopen("vlcProcess.csv");
                    Frame = fread(csvFileF);
                    fclose(csvFileF);
                
                    if isempty(Frame)
                        frameType = "";
                        frameCommand = "";
                        [nextPrimitive, previousPrimitive] = vlcMessageCoordSequencer(primitiveDefaults, nextPrimitive, frameType, frameCommand, vlcConfig, dataPayload);
                
                    else
                    
                        if all(Frame)
                            frameType = "";
                            frameCommand = "";
                            [nextPrimitive, previousPrimitive] = vlcMessageCoordSequencer(primitiveDefaults, nextPrimitive, frameType, frameCommand, vlcConfig, dataPayload);
                    
                        else
                            length(Frame)
                            [vlcFrame, dataPayload] = vlcMACFrameDecoder(Frame);
                            disp("Recieved frame after decoding :")
                            disp(vlcFrame);
                            frameType = vlcFrame.FrameType;
                            frameCommand = vlcFrame.MACCommand;
                            [nextPrimitive, previousPrimitive] = vlcMessageCoordSequencer(primitiveDefaults, nextPrimitive, frameType, frameCommand, vlcConfig, dataPayload);
                        end
                    end
                end
            end
        end
    end
end

%%
function [nextPrimitive, previousPrimitive] = vlcMessageCoordSequencer(primitiveDefauts, nextPrimitive, frameType, frameCommand, vlcConfig, dataPayload)
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
        csvFileH = fopen("vlcProcess.csv", 'w');
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
        csvFileF = fopen("vlcProcess.csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateIndication") &&  strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEAssociateIndication(primitiveDefauts);
        nextPrimitive = "MLMEAssociateResponse";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess.csv", 'w');
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
        csvFileF = fopen("vlcProcess.csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateResponse") &&  strcmp(frameType, "Acknowledgment") && strcmp(frameCommand, "")
        disp("Recieved Acknowledgment frame from Device MAC Layer.");
        disp(" ");
        nextPrimitive = "MLMECommStatusIndication";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess.csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMECommStatusIndication") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMECommStatusIndication(primitiveDefauts);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess.csv", 'w');
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
        csvFileF = fopen("vlcProcess.csv", 'w');
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
        csvFileF = fopen("vlcProcess.csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MCPSDataIndication") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MCPSDataIndication(primitiveDefauts, dataPayload);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess.csv", 'w');
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
        csvFileF = fopen("vlcProcess.csv", 'w');
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
    disp("MSDU Length : " + strlength(dataPayload));
    disp("DSN :");
    disp(primitiveDefaults.DSN);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEDissociateIndication (primitiveDefaults)
    disp("Sending MLMEDissociateIndication primitive from device MAC Layer to device Higher Layer. . .");
    disp("DeviceAddress : " + primitiveDefaults.DeviceAddress);
    disp("Dissociation Reason : " + primitiveDefaults.DissociationReason);
    disp(" ");
end