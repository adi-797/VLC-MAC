function vlcDevicestart (cfg, payload, vlcConfig, PIBDefaults, deviceNumber)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                DEFAULTS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    primitiveDefaults = cfg;
    
    disp("The default values for the primitive paramters set");
    disp(" ");
    
    nextPrimitive = "MLMEResetRequest";
    previousPrimitive = "";
    loopVariable = true;
    macAckWaitDuration = 0;
    dataPayload = payload;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Main Loop Execution                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    while loopVariable

%   Avoids collision in the process of accessing the csv file.
        timer = clock;
        timer = round(timer(6));
        flag = mod(timer ,2);
     
        if flag == 0
            fclose("all");
            continue
         
        else
%   Timer Loop. To introduce delay in execution for avaoiding
%   conflict in accessing the csv file by both Matlabs.
            for i=1:300000000
            end
            
        	terminator = fopen("vlcTerminate.csv");
            terminatorVariable = fread(terminator);
            fclose(terminator);

            if terminatorVariable == deviceNumber
            	loopVariable = false;
                
                dissociationFile = fopen("vlcDissociation.csv");
                numberOfDissociation = fread(dissociationFile);
                fclose(dissociationFile);

                numberOfDissociation = numberOfDissociation + 1;

                dissociationFile = fopen("vlcDissociation.csv", 'w');
                fwrite(dissociationFile, numberOfDissociation);
                fclose(dissociationFile);
                
            	disp("Communication terminated abruptly.");
            
            
            else

	            authorityFile = fopen("vlcAuthority.csv");
	            authorityID = fread(authorityFile)
	            fclose(authorityFile);
	            deviceNumber
	            if authorityID == deviceNumber
	                disp("Working");
%   Check for the last primitive which indicates dissociation of device.  
	                if strcmp(previousPrimitive, "MLMEDissociationConfirm")
	                    loopVariable = false;
	                    MLMEDissociationConfirm(primitiveDefaults);
                        
%                         csvFileH = fopen("vlcHold.csv", 'w');
%                         fwrite(csvFileH, ones(1,1));
%                         fclose(csvFileH);
                        
	                    disp("Device dissociated. . .");
	                    disp("Communication terminated.");
	                
	                    dissociationFile = fopen("vlcDissociation.csv");
	                    numberOfDissociation = fread(dissociationFile);
	                    fclose(dissociationFile);
	                    
	                    numberOfDissociation = numberOfDissociation + 1;
	                    
	                    dissociationFile = fopen("vlcDissociation.csv", 'w');
	                    fwrite(dissociationFile, numberOfDissociation);
	                    fclose(dissociationFile);
	        
	                else
%   Reads the vlcHold file to assign the authority to the device or vice
%   versa.
	                    csvFileH = fopen("vlcHold.csv");
	                    holdIndicator = fread(csvFileH);
	            
	                    if isempty(holdIndicator)
	                        continue
	                    end
	            
	                    holdVariable = holdIndicator(1)
	                    fclose(csvFileH); 
	            
	                    if holdVariable == 1
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
	                        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv");
	                        Frame = fread(csvFileF);
	                        fclose(csvFileF);
	                
	                        if isempty(Frame)
	                            frameType = "";
	                            frameCommand = "";
	                            [nextPrimitive, previousPrimitive] = vlcMessageDeviceSequencer(primitiveDefaults, nextPrimitive, frameType, frameCommand, dataPayload, vlcConfig, PIBDefaults, deviceNumber);
	                
	                        else
	                            if all(Frame)
	                                frameType = "";
	                                frameCommand = "";
	                                [nextPrimitive, previousPrimitive] = vlcMessageDeviceSequencer(primitiveDefaults, nextPrimitive, frameType, frameCommand, dataPayload, vlcConfig, PIBDefaults, deviceNumber);
	                    
	                            else
	                                vlcFrame = vlcMACFrameDecoder(Frame);
                                    
                                    csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
                                    fwrite(csvFileF, ones(1,20));
                                    fclose(csvFileF);
                                    
	                                disp("Recieved frame after decoding :");
	                                disp(vlcFrame);
	                                frameType = vlcFrame.FrameType;
	                                frameCommand = vlcFrame.MACCommand;
	                                [nextPrimitive, previousPrimitive] = vlcMessageDeviceSequencer(primitiveDefaults, nextPrimitive, frameType, frameCommand, dataPayload, vlcConfig, PIBDefaults, deviceNumber);
	                            end
	                        end
	                    end
	                end
                end    
	        end
        end
    end
end

%%
function [nextPrimitive, previousPrimitive] = vlcMessageDeviceSequencer(primitiveDefauts, nextPrimitive, frameType, frameCommand, dataPayload, vlcConfig, PIBDefaults, deviceNumber)
%   Sequencer. Determines the next primitive.

    previousPrimitive = nextPrimitive;

    if strcmp(nextPrimitive, "MLMEResetRequest") &&  strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEResetRequest(primitiveDefauts, PIBDefaults);
        nextPrimitive = "MLMEResetConfirm";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
                
    elseif strcmp(nextPrimitive, "MLMEResetConfirm") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEResetConfirm(primitiveDefauts);
        nextPrimitive = "MLMEScanRequest";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
               
    elseif strcmp(nextPrimitive, "MLMEScanRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEScanRequest(primitiveDefauts);
        nextPrimitive = "MLMEBeaconNotify";
        disp("Sending MAC Command frame with command Beacon Request from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        commandConfig = vlcConfig;
        commandConfig.FrameType = 'MAC command';
        commandConfig.MACCommand = 'Beacon request';
        disp(commandConfig);
        writeFrame = vlcMACFrameGenerator(commandConfig);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEBeaconNotify") && strcmp(frameType, "Beacon") && strcmp(frameCommand, "")
        disp("Recieved Beacon frame from Coordinator MAC Layer.");
        disp(" ");
        MLMEBeaconNotify(primitiveDefauts);
        nextPrimitive = "MLMEScanConfirm";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEScanConfirm") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEScanConfirm(primitiveDefauts);
        nextPrimitive = "MLMEAssociateRequest";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEAssociateRequest(primitiveDefauts);
        disp("Sending MAC Command frame with command Association request from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        commandConfig = vlcConfig;
        commandConfig.FrameType = 'MAC command';
        commandConfig.MACCommand = 'Association request';
        disp(commandConfig);
        writeFrame = vlcMACFrameGenerator(commandConfig);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateRequest") && strcmp(frameType, "Acknowledgment") && strcmp(frameCommand, "")
        disp("Recieved Acknowledgment frame from Coordinator MAC Layer");
        disp(" ");
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateRequest") && strcmp(frameType, "MAC command") && strcmp(frameCommand, "Association response")
        disp("Recieved MAC Command frame with command Association response from Coordinator MAC Layer.");
        disp(" ");
        nextPrimitive = "MLMEAssociateConfirm";
        disp("Sending Acknowledgment frame from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        ackConfig = vlcConfig;
        ackConfig.FrameType='Acknowledgment';
        disp(ackConfig);
        writeFrame = vlcMACFrameGenerator(ackConfig);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEAssociateConfirm") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEAssociateConfirm(primitiveDefauts);
        nextPrimitive = "MLMEPollRequest";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEPollRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEPollRequest(primitiveDefauts);
        disp("Sending MAC Command frame with command Data request from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        commandConfig = vlcConfig;
        commandConfig.FrameType = 'MAC command';
        commandConfig.MACCommand = 'Data request';
        disp(commandConfig);
        writeFrame = vlcMACFrameGenerator(commandConfig);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEPollRequest") && strcmp(frameType, "Acknowledgment") && strcmp(frameCommand, "")
        disp("Recieved Acknowledgment frame from Coordinator MAC Layer.");
        disp(" ");
        nextPrimitive = "MLMEPollConfirm";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEPollConfirm") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEPollConfirm(primitiveDefauts);
        nextPrimitive = "MCPSDataRequest";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);

    elseif strcmp(nextPrimitive, "MCPSDataRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")  && ~strcmp(dataPayload, "")
        MCPSDataRequest(primitiveDefauts, dataPayload);
        disp("Sending Data frame from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        dataConfig = vlcConfig;
        dataConfig.FrameType='Data';
        disp(dataConfig);
        writeFrame = vlcMACFrameGenerator(dataConfig, dataPayload);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MCPSDataRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")  && strcmp(dataPayload, "")
        disp("Data Payload not found.");
        disp("DIssociating device. . .");
        disp(" ");
        nextPrimitive = "DissociationRequest";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MCPSDataRequest") && strcmp(frameType, "Acknowledgment") && strcmp(frameCommand, "")
        disp("Recieved Acknowledgment frame from Coordinator MAC Layer.");
        disp(" ");
        nextPrimitive = "MCPSDataConfirm";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MCPSDataConfirm") && strcmp(frameType, "") && strcmp(frameType, "")
        MCPSDataConfirm(primitiveDefauts);
        nextPrimitive = "MLMEDissociationRequest";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, zeros(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEDissociationRequest") && strcmp(frameType, "") && strcmp(frameCommand, "")
        MLMEDissociationRequest(primitiveDefauts);
        disp("Sending MAC Command frame with command Dissociation notification from device MAC layer to coordinator MAC Layer. . .");
        disp(" ");
        commandConfig = vlcConfig;
        commandConfig.FrameType = 'MAC command';
        commandConfig.MACCommand = 'Disassociation notification';
        disp(commandConfig);
        writeFrame = vlcMACFrameGenerator(commandConfig);
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, writeFrame);
        fclose(csvFileF);
        
    elseif strcmp(nextPrimitive, "MLMEDissociationRequest") && strcmp(frameType, "Acknowledgment") && strcmp(frameCommand, "")
        disp("Recieved Acknowledgment frame from Coordinator MAC Layer.");
        disp(" ");
        previousPrimitive = "MLMEDissociationConfirm";
        csvFileH = fopen("vlcHold.csv", 'w');
        fwrite(csvFileH, ones(1,1));
        fclose(csvFileH);
        csvFileF = fopen("vlcProcess" + num2str(deviceNumber) + ".csv", 'w');
        fwrite(csvFileF, ones(1,20));
        fclose(csvFileF);
        
    end
end

%%
function MLMEResetRequest (primitiveDefaults, PIBDefaults)
    disp("Sending MLMEResetRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("setDefaultPIB : " + primitiveDefaults.setDefaultPIB);
    disp(" ");
    vlcPIBattributesDefault = PIBDefaults;
    disp("The default values for PIB attributes are :");
    disp(" ");
    disp(vlcPIBattributesDefault);
end

%--------------------------------------------------------------------------
function MLMEResetConfirm (primitiveDefaults)
    disp("Sending MLMEResetConfirm primitive from device MAC Layer to device Higher Layer. . .");
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEScanRequest (primitiveDefaults)
    disp("Sending MLMEScanRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("ScanType : " + primitiveDefaults.ScanType);
    disp("By default ACTIVE scanning is performed. . .");
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEBeaconNotify (primitiveDefaults)
    disp("Sending MLMEBeaconNotify primitive from device MAC Layer to device Higher Layer. . .");
%   disp("VPANDescriptor : " + primitiveDefaults.VPANDescriptor)%(1) + primitiveDefaults.VPANDescriptor(2) + primitiveDefaults.VPANDescriptor(3));
    disp("BSN :");
    disp(primitiveDefaults.BSN);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEScanConfirm (primitiveDefaults)
    disp("Sending MLMEScanConfirm primitive from device MAC Layer to device Higher Layer. . .");
    disp("status : " + primitiveDefaults.status);
    disp("ScanType : " + primitiveDefaults.ScanType);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEAssociateRequest (primitiveDefaults)
    disp("Sending MLMEAssociateRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("CoordAddrMode : " + primitiveDefaults.CoordAddrMode);
    disp("By default Short address used.");
    disp("CoordVPANID : " + primitiveDefaults.CoordVPANID);
    disp("CoordAddress : " + primitiveDefaults.CoordAddress);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEAssociateConfirm (primitiveDefaults)
    disp("Sending MLMEAssociateConfirm primitive from device MAC Layer to device Higher Layer. . .");
    disp("AssocShortAddr : " + primitiveDefaults.AssocShortAddr);
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEPollRequest (primitiveDefaults)
    disp("Sending MLMEPollRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("CoordAddrMode : " + primitiveDefaults.CoordAddrMode);
    disp("By default Short address used.");
    disp("CoordVPANID : " + primitiveDefaults.CoordVPANID);
    disp("CoordAddress : " + primitiveDefaults.CoordAddress);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEPollConfirm (primitiveDefaults)
    disp("Sending MLMEPollConfirm primitive from device MAC to device Higher Layer. . .");
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end

%--------------------------------------------------------------------------
function MCPSDataRequest (primitiveDefaults, dataPayload)
    disp("Sending MCPSDataRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("SouceAddrMode : " + primitiveDefaults.SouceAddrMode);
    disp("MSDU : " + dataPayload);
    disp("DestinationAddrMode : " + primitiveDefaults.DestinationAddrMode);
    disp("By default Extended address used.");
    disp("DestVPANID : " + primitiveDefaults.VPANID);
    disp("DestinationAddr : " + primitiveDefaults.DestinationAddr);
    disp("MSDU Length : " + strlength(dataPayload));
    disp(" ");
end

%--------------------------------------------------------------------------
function MCPSDataConfirm (primitiveDefaults)
    disp("Sending MCPSDataConfirm primitive from device MAC Layer to device Higher Layer. . .");
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEDissociationRequest (primitiveDefaults)
    disp("Sending MLMEDissociationRequest primitive from device Higher Layer to device MAC Layer. . .");
    disp("DeviceAddrMode : " + primitiveDefaults.DeviceAddrMode);
    disp("DeviceVPANID : " + primitiveDefaults.DeviceVPANID);
    disp("DeviceAddress : " + primitiveDefaults.DeviceAddress);
    disp("Dissociation Reason : " + primitiveDefaults.DissociationReason);
    disp(" ");
end

%--------------------------------------------------------------------------
function MLMEDissociationConfirm (primitiveDefaults)
    disp("Sending MLMEDissociationConfirm primitive from MAC Layer to device Higher Layer. . .");
    disp("DeviceAddrMode : " + primitiveDefaults.DeviceAddrMode);
    disp("DeviceVPANID : " + primitiveDefaults.DeviceVPANID);
    disp("DeviceAddress : " + primitiveDefaults.DeviceAddress);
    disp("status : " + primitiveDefaults.status);
    disp(" ");
end