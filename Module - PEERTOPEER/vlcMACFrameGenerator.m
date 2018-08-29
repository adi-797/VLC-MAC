function macFrame = vlcMACFrameGenerator(cfg, varargin)

%   MACFRAMEGENERATOR2 Generate 802.15.7 MAC frames
    cfg = preprocessConfig(cfg);

%   Get MAC Header for current configuration:
    MHR = getMACHeader(cfg);
    size(MHR);
 
%   Create MAC Payload (possibly add some headers to input payload):
    MACPayload = getMACPayload(cfg, varargin);
    MHRwMACPayload = [MHR MACPayload];


%   Get MAC Footer (16-bit CRC on MAC Header and MAC Payload):
    MFR = getMACFooter(MHRwMACPayload);

%   Combine MAC Header, MAC Payload, and MAC Footer:
    macFrame = [MHR MACPayload MFR]';
end


function cfg = preprocessConfig(cfg)

  % Changes can also throw a warning
  if strcmp(cfg.FrameType, 'MAC command')
  
    if strcmp(cfg.MACCommand, 'Association request') 
      cfg.SourceAddressing              = 'Extended address';
      cfg.DestinationAddressing         = 'Not present';      
      cfg.FramePending                  = false;
      cfg.AcknowledgmentRequest         = true;
      srcpanid                          = 'ffff';
      cfg.SourcePANIdentifier           = de2bi(hex2dec(srcpanid)); % broadcast;
      
    elseif strcmp(cfg.MACCommand, 'Association response')
      cfg.SourceAddressing              = 'Extended address';
      cfg.DestinationAddressing         = 'Extended address';
      cfg.FramePending                  = false;
      cfg.AcknowledgmentRequest         = true;
      
    elseif strcmp(cfg.MACCommand, 'Beacon request') 

      cfg.SourceAddressing              = 'Not present';
      cfg.DestinationAddressing         = 'Broadcast';
      cfg.DestinationPANIdentifier      = 'FFFF';
      cfg.DestinationAddress            = 'FFFF';
      cfg.FramePending                  = false;
      cfg.AcknowledgmentRequest         = false;
      cfg.Security                      = false;
      
        
    elseif strcmp(cfg.MACCommand, 'Disassociation notification') 

      cfg.SourceAddressing              = 'Extended address';
      cfg.FramePending                  = false;
      cfg.AcknowledgmentRequest         = true;
      
        
    elseif strcmp(cfg.MACCommand, 'VPAN ID conflict notification') 

      cfg.SourceAddressing              = 'Extended address';
      cfg.DestinationAddressing         = 'Extended address';
      cfg.FramePending                  = false;
      cfg.AcknowledgmentRequest         = true;
      %cfg.Security                      = false;
      
    elseif strcmp(cfg.MACCommand,'Coordinator realignment') 

      cfg.SourceAddressing              = 'Extended address';  
      cfg.DestinationAddressing         = 'Short address';    %check
      cfg.FramePending                  = false;
      cfg.AcknowledgmentRequest         = false;
      cfg.DestinationPANIdentifier      = 'FFFF';
      cfg.DestinationAddress            = 'FFFF';
      %cfg.Security                      = false;
    elseif strcmp(cfg.MACCommand,'GTS request') 

      cfg.SourceAddressing              = 'Short address';  
      cfg.DestinationAddressing         = 'Not present';    %check
      cfg.FramePending                  = false;
      cfg.AcknowledgmentRequest         = true;
      
    elseif strcmp(cfg.MACCommand,'GTS response') 

      cfg.SourceAddressing              = 'Short address';  
      cfg.DestinationAddressing         = 'Not present';    %check
      cfg.FramePending                  = false;
      cfg.AcknowledgmentRequest         = true;
                        
 
    end
  end
end


function MHR = getMACHeader(cfg)

  % Get common MAC header parts:
  
  % 1. Frame control:
  frameControl = zeros(1, 16);
  mhrLen = (2+1)*8; % 2 octets for frame control, 1 octet for sequence num
  FrameVersion = [0 0];
  frameControl(1:2)=FrameVersion;
  %Reserved bits are set to 0 according to the standard
  frameControl(3:6) = [0 0 0 0];
  %  Frame type:
  switch cfg.FrameType
    case 'Beacon'
      frameControl(7:9) = [0 0 0];
    case 'Data'
      frameControl(7:9) = [0 0 1];
    case 'Acknowledgment'
      frameControl(7:9) = [0 1 0];
    case 'MAC command'
      frameControl(7:9) = [0 1 1];
      %disp "frametype"
      %disp(frameControl(7:9))
    case 'CVD'
      frameControl(7:9) = [1 0 0];
   
  end
  %security enabled
  frameControl(10)=0;   % no auxiliary security header
  %disp "security"
  %disp (frameControl(10))
  % Frame pending:
  frameControl(11) = double(cfg.FramePending);
  %disp "framepending"
  %disp(frameControl(11))
  
  %  Acknowledgment request (AR):
  frameControl(12) = double(cfg.AcknowledgmentRequest);
  %disp "ackreq"
  %disp(frameControl(12))
  
  %  Destination addressing mode:
  if strcmp(cfg.DestinationAddressing, 'Not present')
    
    frameControl(13:14) = [0 0];
    %disp "DAM"
    %disp (frameControl(13:14))
    
  elseif strcmp(cfg.DestinationAddressing, 'Broadcast')
     frameControl(13:14) = [0 1];
     frameControl(15:16) = [0 1];    %in acse of broadcast both source and destination address are set to 01
  elseif strcmp(cfg.DestinationAddressing, 'Extended address')
    frameControl(13:14) = [1 1];
    %disp "DAM"
    %disp(frameControl(13:14))
    mhrLen = mhrLen + 2*8 + 8*8; % 2 octets for PAN ID, and 8 for address
  else %if strcmp(cfg.DestinationAddressing, 'Short address')
    frameControl(13:14) = [1 0];
    %disp "DAM"
    %disp (frameControl(13:14))
    mhrLen = mhrLen + 2*8 + 2*8; % 2 octets for PAN ID, and 2 for address
  end
  
 
  %  Source addressing mode:
  if strcmp(cfg.SourceAddressing, 'Not present')
   
    frameControl(15:16) = [0 0];
    %disp "SAM"
    %disp (frameControl(15:16))
    
  elseif strcmp(cfg.SourceAddressing, 'Extended address')
      frameControl(15:16) = [1 1];
      %disp "SAM"
      %disp(frameControl(15:16))      
      mhrLen = mhrLen + 8*8; % 8 octets for address
  else % 'Short address'
      frameControl(15:16) = [1 0];
      mhrLen = mhrLen + 2*8; % 2 octets for address
  end
  
 

  if  strcmp(cfg.FrameType, 'Acknowledgment')
    mhrLen = 3*8; % 2 for Frame control and 1 for Seq#. No addressing fields
  end
  MHR = zeros(1, mhrLen);
  MHR(1:2*8) = frameControl;
  
  % 2. Sequence number
  MHR(2*8+1:3*8) = de2bi(cfg.SequenceNumber, 8);
  %disp SeqNum
  %disp (MHR(2*8+1:3*8))
  cnt = 3*8;
  
  % 3.Addressing fields%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ~strcmp(cfg.DestinationAddressing, 'Not present')
    % Destination PAN ID
    MHR(cnt+1:cnt+2*8) = de2bi(hex2dec(cfg.DestinationPANIdentifier), 2*8);
    %disp "DPANID"
    %disp (MHR(cnt+1:cnt+2*8))
    cnt = cnt+2*8;
    
    % Destination Address
    if strcmp(cfg.DestinationAddressing, 'Short address')
      MHR(cnt+1:cnt+2*8) = de2bi(hex2dec(cfg.DestinationAddress),     2*8);
      %disp "DestAddrshrt"
      %disp (MHR(cnt+1:cnt+2*8))
      cnt = cnt+2*8;
    elseif strcmp(cfg.DestinationAddressing, 'Broadcast')
      MHR(cnt+1:cnt+2*8) = de2bi(hex2dec('ffff'));
      %disp "DestAddrb"
      %disp (MHR(cnt+1:cnt+2*8))      
      cnt=cnt+2*8;
      
    else % 'Extended address'
      % two steps because of 2^53 limit in dec representation
      MHR(cnt+1     : cnt+4*8) = de2bi(hex2dec(cfg.DestinationAddress(9:end)), 4*8);
      MHR(cnt+4*8+1 : cnt+8*8) = de2bi(hex2dec(cfg.DestinationAddress(1:8)),   4*8);
      %cnt = cnt+8*8;
      %disp "DestADDR"
      %disp (MHR(cnt+1:cnt+8*8))
      cnt = cnt+8*8;
      
    end

  end
  
  if ~strcmp(cfg.SourceAddressing, 'Not present')
    
    % Source PAN ID
    %if ~strcmp(cfg.DestinationAddressing, 'Not present')
    MHR(cnt+1:cnt+2*8) = cfg.SourcePANIdentifier; %CHANGE
    %disp "SPANID"
    %disp (MHR(cnt+1:cnt+2*8))
    cnt = cnt+2*8;
    %end
    
    % 3.4 Source Address
    if strcmp(cfg.SourceAddressing, 'Short address')
      MHR(cnt+1:cnt+2*8) = de2bi(hex2dec(cfg.SourceAddress),     2*8);

    else % 'Extended address'
      % two steps because of 2^53 limit in dec representation
      MHR(cnt+1     : cnt+4*8) = de2bi(hex2dec(cfg.SourceAddress(9:end)), 4*8);
      MHR(cnt+4*8+1 : cnt+8*8) = de2bi(hex2dec(cfg.SourceAddress(1:8)),   4*8);
    end
  end
  %disp "Eoaf"
  %disp (cnt)
  %%disp "EndOfAddrField"
  %%disp (Eoaf)
  % 4. Auxiliary Security Header 
  % Not supported. 0 octets.
  
end


function MACPayload = getMACPayload(cfg, args)

  if strcmp(cfg.FrameType, 'Acknowledgment')
    MACPayload = [];
    
  elseif strcmp(cfg.FrameType, 'Data')
      
     packetType = zeros(1,2);
     if strcmp(cfg.PacketType, 'single')
         packetType = [0 0];
     elseif ~strcmp(cfg.PacketType, 'packed')
         packetType  = [0 1];
     elseif ~strcmp(cfg.PacketType, 'burst')
         packetType  = [1 0];
     elseif ~strcmp(cfg.PacketType, 'reserved')
         packetType  = [1 1];
     end
     
     
     numPPDU =  zeros(1,6);
   
    
    if isempty(args)
      error(message('vlc:VPAN:MissingPaylod'));
    else
      payload = args{1};
      
      
      % convert bytes to bits
      temp = de2bi(hex2dec(payload))';%CHANGE - floating payload size
      
      payload = temp(:)';
      %payload = fliplr(payload);
      MACPayload = [packetType numPPDU payload];
    end
    
  elseif strcmp(cfg.FrameType, 'Beacon')
    
    MACPayload = getBeaconMACPayload(cfg);
    
  else% MAC command
    
    MACPayload = getCommandMACPayload(cfg);
  
  end
  
  if ~isempty(args) && ~strcmp(cfg.FrameType, 'Data')
    warning(message('vlc:LRWPAN:IgnoredPayload'));
  end
end

function MACPayload = getBeaconMACPayload(cfg)

  % 1. Superframe specification
  superframeSpec = zeros(1, 16);
  % 1.1 Beacon order 
  superframeSpec(1:4) = de2bi(cfg.BeaconOrder, 4);

  % 1.2 Superframe order 
  superframeSpec(5:8) = de2bi(cfg.SuperframeOrder, 4);

  % 1.3 Final CAP slot
  superframeSpec(9:12) = de2bi(cfg.FinalCAPSlot, 4);

  % 1.4 Battery Life Extension
  %superframeSpec(12) = double(cfg.BatteryLifeExtension);

  superframeSpec(13) = 0; % reserved

  % 1.5 PAN Coordinator
  superframeSpec(14) = double(cfg.PANCoordinator);

  % 1.6 Association Permit
  superframeSpec(15) = double(cfg.PermitAssociation);
  
  superframeSpec(16) = cfg.callsearchEn;


  % 2. GTS fields
  numGTS = size(cfg.GTSList, 1);%/3;
  if numGTS == 0 
    gtsLen = 8*1; % GTS specification only
  else
    % 1 octet for GTS specification, 1 for GTS directions and 3 for each
    % GTS entry:
    gtsLen = 8*(1+1+3*numGTS);
  end
  gtsFields = zeros(1, gtsLen);

  % 2.1 GTS Specification
  gtsSpecification = zeros(1, 8); % 1 octet
  % 2.1.1: GTS Descriptor count (num of GTS list entries)
  gtsSpecification(1:3) = de2bi(numGTS, 3);

  gtsSpecification(4:7) = [0 0 0 0]; % reserved

  % 2.1.3: GTS Permit:
  gtsSpecification(8) = double(cfg.PermitGTS);
  gtsFields(1:8) = gtsSpecification;


   if numGTS > 0
     % 2.2  GTS Directions
     gtsDirections = zeros(1, 8);
%     gtsDirections(1:numGTS) = double([cfg.GTSList{:, 4}])';
     gtsFields(9:16) = gtsDirections;
% 
%     % 2.3
     gtsList = zeros(1, 3*8*numGTS);
     for idx = 1:numGTS
       % 2.3.1 Device Short Address
       thisStart = 1+(idx-1)*3*8;
      gtsList(thisStart : thisStart+2*8-1) = ...
        de2bi(hex2dec(cfg.GTSList{idx, 1}), 16);

      % 2.3.2 GTS Starting slot
      gtsList(thisStart+2*8 : idx*3*8-4) = de2bi(cfg.GTSList{idx, 2}, 4);

      % 2.3.3 GTS Length
      gtsList(idx*3*8-3 : idx*3*8) = de2bi(cfg.GTSList{idx, 3}, 4);
    end
     gtsFields(17:end) = gtsList;
   end

  % 3. Pending Address Fields
  lens = cellfun(@length, cfg.PendingAddresses);
  shortAddresses    = {cfg.PendingAddresses{lens == 4}};
  extendedAddresses = {cfg.PendingAddresses{lens == 16}};
  numShort    = length(shortAddresses);    % 4  hex digits -> 2 octets each
  numExtended = length(extendedAddresses); % 16 hex digits -> 8 octets each
  pendingLen  = 8*(1 + 2*numShort + 8*numExtended);
  pendingAddresses = zeros(1, pendingLen);

  % 3.1 Pending address specification
  pendingAddresses(1:3) = de2bi(numShort,    3);
  pendingAddresses(4)   = 0; % reserved
  pendingAddresses(5:7) = de2bi(numExtended, 3);
  pendingAddresses(8)   = 0; % reserved
  cnt = 8;
  % 3.2 Pending address specification
  for idx = 1:numShort
    % Short address
    pendingAddresses(cnt+1:cnt+2*8) = de2bi(hex2dec(shortAddresses{idx}),    2*8);
    cnt = cnt + 2*8;
  end
  for idx = 1:numExtended
    % Extended address
    pendingAddresses(cnt+1:cnt+8*8) = de2bi(hex2dec(extendedAddresses{idx}), 8*8);
    cnt = cnt + 8*8;
  end

  % 4. Beacon payload
  beaconPayload = zeros(1, 8); % contents are NULL. Choose 1 octet

   MACPayload = [superframeSpec gtsFields pendingAddresses beaconPayload];
 end
% 
 function MACPayload = getCommandMACPayload(cfg)
  
  switch cfg.MACCommand
    case 'Association request'
      % 1. Command frame identifier
      commandID = de2bi(1, 8);
      %disp "commandID"
      %disp (commandID)
      
      % 2. Capability information
      capabilityInfo = zeros(1, 8);
      %disp "capabInfo"
      
      % capabilityInfo(1) = 0; reserved
      
      % 2.1 Device Type
      capabilityInfo(2) = double(cfg.FFDDevice);
      
      % 2.2 Power source
      capabilityInfo(3) = double(~cfg.BatteryPowered); % 1 if AC connected
      
      % 2.3 Receiver On When Idle
      capabilityInfo(4) = double(cfg.IdleReceiving);
      
      capabilityInfo(5:6) = [0 0]; % reserved
      
      % 2.4 Security
      capabilityInfo(7) = 0; % security not supported
      
      % 2.5 Allocate Address
      capabilityInfo(8) = double(cfg.AllocateAddress);
      %disp (capabilityInfo)
      MACPayload = [commandID capabilityInfo];
      %disp "macpayload"
      %disp (MACPayload)
      
    case 'Association response'
      % 1. Command frame identifier
      commandID = de2bi(2, 8);
      %disp "commandID"
      %disp (commandID)
      
      % 2. Short Address
      shortAddress = de2bi(hex2dec(cfg.ShortAddress), 2*8);
      %disp shrtaddr
      %disp(shortAddress)
      
      % 3. Association status
      switch cfg.AssociationStatus
        case 'Successful'
          status = zeros(1, 8);
          %disp(status)
        case 'PAN at capacity'
          status = [zeros(1, 7) 1];
          %disp(status)
        case 'PAN access denied'
          status = [zeros(1, 6) 1 0];
          %disp(status)
      end
      
      capabilityNegotiationResponse = zeros(1,8);
      %disp "cnr"
      %disp (capabilityNegotiationResponse)
      % capabilityNegotiationResponse(1:2)=[0 0] since no color
      % stabilization
      %capabilityNegotiationResponse(3:8) reserved
      
      MACPayload = [commandID shortAddress status capabilityNegotiationResponse];
      %disp "MACPayload"
      %disp (MACPayload)
      
    case 'Disassociation notification'
      % 1. Command frame identifier
      commandID = de2bi(3, 8);
      
      % 2. Dissasociation reason:
      switch cfg.DisassociationReason
        case 'Coordinator'
          reason = [1 zeros(1, 7)];
        case 'Device'
          reason = [0 1 zeros(1, 6)];
      end
      
      MACPayload = [commandID reason];
      
    case 'Data request'
      % 1. Command frame identifier
      commandID = de2bi(4, 8);
      
      MACPayload = commandID;
      
    case 'VPAN ID conflict notification'
      % 1. Command frame identifier
      commandID = de2bi(5, 8);
      
      MACPayload = commandID;
      
%     case 'Orphan notification'
%       % 1. Command frame identifier
%       commandID = de2bi(6, 8);
%       
%       MACPayload = commandID;
      
    case 'Beacon request'
      % 1. Command frame identifier
      commandID = de2bi(6, 8);
      %disp "commandID"
      %disp (commandID)
      
      MACPayload = commandID;
      
    case 'Coordinator realignment' 
      commandID = de2bi(7,8);
      VPANID = cfg.SourcePANIdentifier; %2 byte
      coordinatorShortAddress = zeros(1,16); %2
      logicalChannel = zeros(1,8);%1
      shortAddress = de2bi(hex2dec(cfg.ShortAddress), 2*8); %2 %CHANGE
      
      MACPayload = [commandID VPANID coordinatorShortAddress logicalChannel shortAddress];
    
    case 'GTS request'
      % 1. Command frame identifier
      commandID = de2bi(8, 8);
      
      % 2. GTS Characteristics
      %gtsCharacteristics = zeros(1, 8);
      
      gtsCharacteristics = [de2bi(cfg.GTSLength, 4) 1 1];
      
      MACPayload = [commandID gtsCharacteristics];
      
    case  'Blinking notification'    
      commandID = de2bi(9, 8);
      
      blinkingFrequency = zeros(1,8);
      blinkingFrequency(1:4) = cfg.frequency;
      % blinkingFrequency(5:8) reserved 
      MACPayload = [commandID blinkingFrequency];
    case  'Dimming notification'    
      commandID = de2bi(10, 8);
      
      dimmingLevel(1:4) = cfg.frequency;
      dimmingAdaptationTimer = zeros(1,16);
      
      MACPayload = [commandID dimmingLevel dimmingAdaptationTimer];
      
   case  'Fast link recovery'    
      commandID = de2bi(11, 8);
      
      FLRField= zeros(11,8);
      
      MACPayload = [commandID FLRField];
      
   case  'Mobility notification'    
      commandID = de2bi(12, 8);
      
      %callSearchQuality
      MACPayload = commandID;
      
   case  'GTS response'    
      commandID = de2bi(13, 8);
      
      GTSLength = de2bi(cfg.GTSLength,4);
      GTSCharacteristics = [GTSLength 1 1];
      GTSStartingSlot = de2bi(cfg.GTSStartingSlot, 4);
      
      MACPayload = [commandID GTSCharacteristics GTSStartingSlot];
      
   case  'Clock rate change notification'    
      commandID = de2bi(14, 8);
      
      newClockRate = zeros(1,8);
      
      MACPayload = [commandID newClockRate];
   case  'Multiple channel assignment'    
      commandID = de2bi(15, 8);
      
      multipleChannels = zeros(1,8);
      
      MACPayload = [commandID multipleChannels];

%   IGNORE THE CSK RELATED FRAMES %%      
%    case  'Color stabilization timer notification'    
%       commandID = de2bi(16, 8);
%       
%       shortAddress = zeros(1,16);
%       colorStabilizationTimer = zeros(1,32);
%       
%       MACPayload = [commandID shortAddress colorStabilizationTimer];
%       
%    case  'Color stabilization information'    
%       commandID = de2bi(17, 8);
%       
%    case  'CVD disable'    
%       commandID = de2bi(18, 8);
%       
%       disable = zeros(1,8);
%       
%       MACPayload = [commandID disable];
%       
%    case  'Information element'    
%       commandID = de2bi(19, 8);
   
   
  end
 end

function MFR = getMACFooter(MHRwMACPayload)

  % 16-bit  802.15.7 standard:
  crc = comm.CRCGenerator('x16 + x12 + x5 + 1');
  
  % generate bits:
  crcBits = crc(MHRwMACPayload')';

  
  % trim original message:
  MFR = crcBits(1+length(MHRwMACPayload):end);
  %disp "footer"
  %disp(MFR)
end