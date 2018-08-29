function [cfg, varargout] = vlcMACFrameDecoder(macFrame)

%   MACFRAMEDECODER Decode 802.15.7 MAC frames
%   CFG = MACFRAMEDECODER(MACFRAME) decodes the MAC frame MACFRAME
%   and outputs all decodeded information to the MACFrameConfig object CFG.
%   [CFG, PAYLOAD] = MACFRAMEDECODER(MACFRAME) is the same as the
    
 %   Persistent crc decoder for performance optimization
    persistent crc

    varargout{1} = [];
    
%   operate horizontally, i.e., row-wise
    macFrame = macFrame'; 

%   MAC Footer (MFR) / CRC check
%   Always the last 2 octets
    MFR = macFrame(end-2*8+1:end);
    
%   crc bits calculated on MHR + payload
    MHRwPayload = macFrame(1:end-2*8);
  
%   CRC check:
    if isempty(crc)
        crc = comm.CRCGenerator('x16 + x12 + x5 + 1');
        
    else
        release(crc);
        reset(crc);
    end
    
    crcBits = crc(MHRwPayload')';
    MFR2 = crcBits(end-2*8+1:end);
    count = 0;
    
    for i=1:size(MFR,2)     
        if ~isequal(MFR(i),MFR2(i))
            count = count+1;
        end
    end

%   Discard
    if count>5
        cfg = [];
        varargout{1} = [];
        return;
    end
    
%   0. Initialize:
    cfg = vlcConfig();
  
%   1. Frame Control (first two octets)
    frameControl = macFrame(1 : 2*8);
    cfg = decodeFrameControl(cfg, frameControl);
  
%   2. Sequence Number (3rd octet)
    cfg.SequenceNumber = bi2de(macFrame(1+2*8 : 3*8));
  
%   3. Addressing fields 
    [cfg, cnt] = decodeAddressingFields(cfg, macFrame);

%   5. MAC payload
    macPayload = macFrame(cnt:end-2*8);
  
%   last 2 octets are MFR
    if ~strcmp(cfg.FrameType, 'Data')
        cfg = decodeMACPayload(cfg, macPayload);
        
    else
        [cfg, dataPayload] = decodeMACPayload(cfg, macPayload);
        dataPayload = extendec2hex(bi2de(dataPayload));
        varargout{1} = dataPayload;
    end                                                                               
end

%--------------------------------------------------------------------------
function cfg = decodeFrameControl(cfg, frameControl)
  
    cfg.FrameVersion = frameControl(1:2);
    
    switch bi2de(frameControl(7:9))
        case 0
            cfg.FrameType = 'Beacon';
            
        case 4
            cfg.FrameType = 'Data';
            
        case 2
            cfg.FrameType = 'Acknowledgment';
            
        case 6
            cfg.FrameType = 'MAC command';
            
        case 1
            cfg.FrameType = 'CVD';  
    end
  
%   2. Security enabled -> security is not supported
    cfg.Security = frameControl(10);
  
    cfg.FramePending = logical(frameControl(11));
  
    cfg.AcknowledgmentRequest = logical(frameControl(12));
 
    
    switch bi2de(frameControl(13:14))
        case 0
            cfg.DestinationAddressing = 'Not present';
            
        case 1
            cfg.DestinationAddressing = 'Broadcast';  
            
        case 2
            cfg.DestinationAddressing = 'Short address';
            
        case 3
            cfg.DestinationAddressing = 'Extended address';
    end
 
 
    switch bi2de(frameControl(15:16))
        case 0
            cfg.SourceAddressing = 'Not present';
        case 1
            cfg.SourceAddressing = 'Broadcast';
        case 2
            cfg.SourceAddressing = 'Short address';
        case 3
            cfg.SourceAddressing = 'Extended address';
    end
end

%--------------------------------------------------------------------------
function [cfg, cnt] = decodeAddressingFields(cfg, macFrame)
  
%   Beginning of addressing fields
    cnt = 1 + 3*8;

%   3.1 Destination PAN Identifier (always 2 octets)
    if ~strcmp(cfg.DestinationAddressing, 'Not present')
        cfg.DestinationPANIdentifier = dec2hex(bi2de(macFrame(1+3*8 : 5*8)), 4);
    end
  
%   3.2 Destination address
    if strcmp(cfg.DestinationAddressing, 'Short address')    % 2 octets
        cfg.DestinationAddress = dec2hex(bi2de(macFrame(1+5*8 : 7*8)), 4);
%   Skip PAN ID and short address
        cnt = cnt + (2+2)*8;
        
    elseif strcmp(cfg.DestinationAddressing, 'Extended address') % 8 octets
        cfg.DestinationAddress = dec2hex(bi2de(macFrame(1+5*8 : 13*8)), 16);
        cnt = cnt + (2+8)*8; % skip PAN ID and extended address
    end
  
%   3.3 Source PAN Identifier
    if strcmp(cfg.SourceAddressing, 'Not present')
        cfg.SourcePANIdentifier = 'Not present';
    end
  
%   3.4 Source address
    if strcmp(cfg.SourceAddressing, 'Short address')    % 2 octets
        cfg.SourceAddress = extendec2hex(bi2de(macFrame(cnt : cnt+2*8-1)), 4);
%   Skip PAN ID and short address
        cnt = cnt + (2+2)*8;
    
    elseif strcmp(cfg.SourceAddressing, 'Extended address') % 8 octets
        cfg.SourceAddress = extendec2hex(bi2de(macFrame(cnt : cnt+8*8-1)),16);
%   Skip PAN ID and extended address
        cnt = cnt + (2+8)*8;
  
    elseif strcmp(cfg.SourceAddressing, 'Not present')
        cfg.SourceAddress = 'Not present';
    end
end

%--------------------------------------------------------------------------
function [cfg, varargout] = decodeMACPayload(cfg, macPayload)

    if strcmp(cfg.FrameType, 'Acknowledgment')
%   no-op, ACKs do not contain a MAC payload, macPayload input should be empty
    
    elseif strcmp(cfg.FrameType, 'Data')
%   100% payload, no other fields
        varargout{1} = macPayload(9:end);
  
    elseif strcmp(cfg.FrameType, 'Beacon')
        cfg = decodeBeaconPayload(cfg, macPayload);
    
    elseif strcmp(cfg.FrameType, 'MAC command')
        cfg = decodeMACCommandPayload(cfg, macPayload);
    end
end

%--------------------------------------------------------------------------
function cfg = decodeBeaconPayload(cfg, macPayload)
    
%   1. Superframe specification (first 2 octets)
    superframeSpec = macPayload(1 : 2*8);

%   1.1 Beacon order
    cfg.BeaconOrder = bi2de(superframeSpec(1:4));

%   1.2 Superframe order
    cfg.SuperframeOrder = bi2de(superframeSpec(5:8));

%   1.3 Final CAP slot
    cfg.FinalCAPSlot = bi2de(superframeSpec(9:12));

%   1.4 Battery Life Extension
    cfg.BatteryLifeExtension = logical(superframeSpec(13));

%   14th bit is reserved (0).

%   1.5 PAN Coordinator
    cfg.PANCoordinator = logical(superframeSpec(15));

%   1.5 Association permit
    cfg.PermitAssociation = logical(superframeSpec(16));

  
%   2. GTS fields
%   2.1 GTS Specification (1 octet)
%   2.1.1 GTS Descriptor count:
    gtsSpec = macPayload(1 + 2*8 : 3*8);
    numGTS = bi2de(gtsSpec(1:3));
  
%   bits 4-7 are reserved
  
%   2.2.2 GTS Permit
    cfg.PermitGTS = logical(gtsSpec(8));
  
    if numGTS > 0
%   2.2 GTS directions
        gtsDirections = logical(macPayload(1+3*8: 3*8+numGTS ));
    
%   2.3 GTS List
        offset = 1 + (2+1+1)*8;
        gtsCell = {0};
        
        for idx = 1:numGTS
            gtsList = macPayload(offset + (idx-1)*3*8 : offset + idx*3*8 - 1);
      
%   2.3.1 Device short address 
            gtsCell{idx, 1} = dec2hex(bi2de(gtsList(1:16)), 4);
      
%   2.3.2 GTS starting slot
            gtsCell{idx, 2} = bi2de(gtsList(17:20));
      
%   2.3.3 GTS length
            gtsCell{idx, 3} = bi2de(gtsList(21:24));
      
%   2.3.4 GTS direction
            gtsCell{idx, 4} = gtsDirections(idx);
        end
    
        cfg.GTSList = gtsCell;
    end
  
%   3. Pending addresses
    offset = 1 + (2+1)*8 + (numGTS > 0)*8 + numGTS*3*8;
  
%   3.1 Pending address specification (1 octed)
    pendingAddressSpec = macPayload(offset : offset + 8 - 1);
  
%   3.1.1 Number of short addresses
    numShort    = bi2de(pendingAddressSpec(1:3));
    
%   3.1.2 Number of extended addresses
    numExtended = bi2de(pendingAddressSpec(5:7));
    
    offset = offset + 8;
  
%   3.2 Address list
    addresses = {0};
    
    for idx = 1:numShort
        addresses{idx} = dec2hex(bi2de(macPayload(offset : offset + 2*8 - 1)), 4);
        offset = offset + 2*8;
    end
  
    for idx = idx+1 : idx+numExtended
        addresses{idx} = dec2hex(bi2de(macPayload(offset : offset + 8*8 - 1)), 16);
        offset = offset + 8*8;
    end
     
    cfg.PendingAddresses = addresses;
end

%--------------------------------------------------------------------------
function cfg = decodeMACCommandPayload(cfg, macPayload)

%   1. Command frame identifier (1 octet)
    ID = bi2de(macPayload(1:8));
    
    switch ID
    
        case 1
            cfg.MACCommand = 'Association request';
            capabilityInfo = macPayload(9:16);
%   2.1 Device type
            cfg.FFDDevice = logical(capabilityInfo(2));
%   2.2 Power source
            cfg.BatteryPowered = ~logical(capabilityInfo(3));
%   2.3 Receive while idle
            cfg.IdleReceiving = logical(capabilityInfo(4));
%   2.4 Security not supported
%   2.5 Allocate address
            cfg.AllocateAddress = logical(capabilityInfo(8));
      
        case 2
            cfg.MACCommand = 'Association response';
%   2. Short address
            cfg.ShortAddress = dec2hex(bi2de(macPayload(1+8 : 3*8)), 4);
      
%   3. Association status
            status = bi2de(macPayload(1+3*8 : 4*8));
      
            if status == 0
                cfg.AssociationStatus = 'Successful';
            elseif status == 1
                cfg.AssociationStatus = 'PAN at capacity';
            elseif status == 2
                cfg.AssociationStatus = 'PAN access denied';
            end
      
        case 3
            cfg.MACCommand = 'Disassociation notification';
%   2. Disassociation reason
            status = bi2de(macPayload(1+8 : 2*8));
      
            if status == 1
                cfg.DisassociationReason = 'Coordinator';
            elseif status == 2
                cfg.DisassociationReason = 'Device';
            end
      
        case 4
            cfg.MACCommand = 'Data request';
      
        case 5
            cfg.MACCommand = 'VPAN ID conflict notification';
             
        case 6
            cfg.MACCommand = 'Beacon request';
      
%   case 'Coordinator realignment' % Not supported%%%%%%%%%%%%%%%%%
        case 7
            cfg.MACCommand = "Coordinator reallignment";
      
        case 8
            cfg.MACCommand = 'GTS request';
%   2. GTS characteristics (2nd octet)
            gtsCharacteristics = macPayload(9:14);
%   2.1 GTS length
            gtsLen = bi2de(gtsCharacteristics(1:4));
%   2.2 GTS direction
            gtsDirection = gtsCharacteristics(5);
%   2.3 GTS type
            gtsType  = gtsCharacteristics(6);
            cfg.GTSCharacteristics = {gtsLen, gtsDirection, gtsType};
      
        case 13
            cfg.MACCommand = 'GTS Response';
            gtsCharacteristics = macPayload(9:18);
            gtsLen = bi2de(gtsCharacteristics(1:4));
            gtsDirection = gtsCharacteristics(5);
            gtsType = gtsCharacteristics(6);
            cfg.GTSCharacteristics = {gtsLen, gtsDirection, gtsType};
            cfg.GTSStartingSlot = bi2de(gtsCharacteristics(7:10));
    end
end