%classdef < matlab.mixin.CustomDisplay 
classdef vlcConfig
  %MACFrameConfig Create configuration for 802.15.7 MAC frames
  %   FRAMECONFIG = MACFrameConfig creates a configuration object for
  %   802.15.7 MAC frames.
  %
  %   FRAMECONFIG = MACFrameConfig(Name,Value) creates a 802.15.7 MAC frame
  %   configuration object with the specified property Name set to the
  %   specified Value. You can specify additional name-value pair arguments
  %   in any order as (Name1,Value1,...,NameN,ValueN).
  %
  %   MACFrameConfig properties:
  %
  %   FrameType                    - The type of the MAC frame
  %   SequenceNumber               - The frame sequence number
  %   AcknowledgmentRequest        - Option to request acknowledgment
  %   DestinationAddressing        - Destination addressing mode
  %   DestinationPANIdentifier     - PAN identifier of destination
  %   DestinationAddress           - Destination address
  %   SourceAddressing             - Source addressing mode
  %   SourcePANIdentifier          - PAN identifier of source
  %   SourceAddress                - Source address
  %   FramePending                 - Indication that more frames are imminent
  %   FrameVersion                 - Standard compliant frame version
  %   BeaconOrder                  - Duration of beacon interval
  %   SuperframeOrder              - Length of active superframe portion
  %   FinalCAPSlot                 - The last superframe slot of the Contention Access Period
  %   BatteryLifeExtension         - Battery life extension
  %   PANCoordinator               - Flag indicating beacon transmission by PAN coordinator
  %   PermitAssociation            - Flag indicating permissible associations
  %   PermitGTS                    - Flag indicating permissible guaranteed time slots (GTS)
  %   GTSList                      - Cell array describing guaranteed time slots
  %   PendingAddresses             - List of pending short and extended addresses.
  %   FFDDevice                    - Flag indicating full function device 
  %   BatteryPowered               - Flag indicating lack of power connection
  %   IdleReceiving                - Flag indicating receptions during idle periods 
  %   AllocateAddress              - Flag indicating address allocation during association 
  %   ShortAddress                 - Short addressed assigned during association
  %   AssociationStatus            - AssociationStatus
  %   DisassociationReason         - Reason for disassociation
  %   GTSCharacteristics           - Detailed GTS request
  %
  %   See also lrwpan.MACFrameGenerator, lrwpan.MACFrameDecoder.
  
  %   Copyright 2017 The MathWorks, Inc.
  
  properties
      
      
    %FrameVersion The version of the frame as a string denoting a
    % hexadecimal number.
    % Specifies the version of the frame as compatible with 802.15.7.
    % a value of 0b00 in hex indicates the frame is compatible.
    FrameVersion = [0 0]
    
    %FrameType The type of the MAC frame
    % Specify the type of the MAC frame as one of 'Beacon' | 'Data' |
    % 'Acknowledgment' | 'MAC command'. The default is 'Beacon'.
    FrameType = 'Beacon'
    
    %MACCommand The name of the MAC command
    % Specify the name of the MAC command as one of 'Association request' |
    % 'Association response' | 'Disassociation notification' | 'Data request' | 
    % 'PAN ID conflict notification' |
    % 'Beacon request' | 'GTS request'. The default is 'Data request'.
    MACCommand = ''
    
    %SequenceNumber The frame sequence number
    % Specify SequenceNumber of the frame.
    % It is 1 octet in length. If frame type is 'Beacon', this number is
    % interpreted as the BSN (beacon sequence number), otherwise it is
    % interpreted as the DSN (data sequence number).
    SequenceNumber = 0
    
    %AcknowledgmentRequest Option to request acknowledgment
    % Specify AcknowledgmentRequest as a logical scalar. If true, the
    % recipient shall send an acknowledgment frame upon successful
    % reception of the transmitted frame. If false, the transmitter will
    % assume that reception was successful. Only 'Data' and 'MAC command'
    % frame types can be acknowledged. The default is false.
    AcknowledgmentRequest = false
    
    %DestinationAddressing Destination addressing mode
    % Specify DesinationAddressing as one of 'Not present' | 'Short
    % address' | 'Extended address'. The 'Not present' option does not
    % generate frames containing the address and the PAN Identification of
    % the destination. 'Short address' allocates 6 bits for the destination
    % address. 'Long address' allocates 64 bits for the destination
    % address. The default is 'Not present'.
    DestinationAddressing = 'Not present'  
    
    %DestinationPANIdentifier PAN identifier of destination
    % Specify the PAN identifier of the frame's destination as a
    % four-character string denoting a hexadecimal number. A value of
    % 'FFFF' denotes the broadcast address. The default is '0000'.
    DestinationPANIdentifier = '0000'
    
    %DestinationAddress Destination address
    % Specify the destination address as a string denoting a hexadecimal
    % number. DestinationAddress must be 4 and 16 characters long if
    % DestinationAddressing is set to 'ShortAddress' and 'LongAddress',
    % respectively. A value of 'FFFF' denotes the broadcast short address.
    % The default is '0001'.
    DestinationAddress = '0000'
    
    %SourceAddressing Source addressing mode
    % Specify SourceAddressing as one of 'Not present' | 'Short address'
    % | 'Extended address'. The 'Not present' option does not generate
    % frames containing the address and the PAN Identification of the
    % source. 'Short address' allocates 6 bits for the source address.
    % 'Long address' allocates 64 bits for the source address. The default
    % is 'Not present'.
    SourceAddressing = 'Not present'
    
    %SourcePANIdentifier PAN identifier of source
    % Specify the PAN identifier of the frame's source as a four-character
    % string denoting a hexadecimal number. The default is '0000'.
    SourcePANIdentifier = [1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0]
    
    %SourceAddress Source address
    % Specify the source address as a string denoting a hexadecimal number.
    % SourceAddress must be 4 and 16 characters long if SourceAddressing is
    % set to 'Short address' and 'Long address', respectively. The default
    % is '0000'.
    SourceAddress = 'f000000000000000'
    
    %FramePending Indication that more frames are imminent
    % Specify FramePending as a logical scalar. A true value signifies that
    % the transmitting device has more data for the recipient. The default
    % is true.
    FramePending = false
    
    %Security Security enabled
    % Specify Security as a logical scalar indicating whether security is
    % enabled. The default is false.
    Security = false
    
    %SecurityLevel Security level
    % Specify SecurityLevel as an integer scalar from 0 to 7. The default is
    % 0.
    SecurityLevel = 0
    
    %FrameCounter Frame counter
    % Specify FrameCounter as an integer scalar from 0 to 2^32-1. The
    % default is 0. 
    FrameCounter = 0
    
    %BeaconOrder Duration of beacon interval
    % Specify BeaconOrder as a nonnegative scalar integer between 0 and 15.
    % Higher values indicate longer beacon intervals and more infrequent
    % transmission. If BeaconOrder is set to 15, then beacons are not
    % transmitted unless a beacon request command is received. The default
    % is 15.
    BeaconOrder = 15
    
    %SuperframeOrder Length of active superframe portion
    % Specify SuperframeOrder as a scalar integer between 0 and 15. Higher
    % values indicate longer superframe durations. However, if
    % SuperframeOrder equals 15, then the superframe does not remain active
    % after the beacon. The default is 15.
    SuperframeOrder = 15
    
    %FinalCAPSlot The last superframe slot of the Contention Access Period
    % Specify FinalCAPSlot as a scalar integer between 0 and 15. This is
    % the last slot of the Contention Access Period (CAP); next slots (if
    % any) belong to Contention Free Period (CFP). The default is 10.
    FinalCAPSlot = 10
    
    %BatteryLifeExtension Battery life extension
    % Specify BatteryLifeExtension as a logical scalar indicating whether
    % frames transmitted to the beaconing device need to be delayed. The
    % default is false.
    BatteryLifeExtension = false
    
    %PANCoordinator Flag indicating beacon transmission by PAN coordinator
    % Specify PANCoordinator as a logical scalar indicating whether the
    % beacon is transmitted by the PAN coordinator. The default is true.
    PANCoordinator = true;
    
    %PermitAssociation Flag indicating permissible associations
    % Specify PermitAssociation as a logical scalar indicating whether the
    % PAN coordinator accepts new associations. The default is true.
    PermitAssociation = true;
    
    %PermitGTS Flag indicating permissible guaranteed time slots (GTS)
    % Specify PermitGTS as a logical scalar indicating whether the PAN
    % coordinator accepts new requests for guaranteed time slots (GTS). The
    % default is true.
    PermitGTS = true;
    
    %GTSList Cell array describing guaranteed time slots
    % Specify GTSList as a four-column cell array describing the guaranteed
    % time slots (GTS). The first column contains four-character
    % hexadecimal arrays denoting the short device address. The second
    % column contains integer scalars denoting the beginning slots of the
    % GTS. The third column contains integer scalars denoting the length
    % of the GTS. The fourth column is a boolean indicating whether the
    % device is receiving instead of transmitting. The default is {'0001',
    % 11, 3, false}, which corresponds to the device address '0001'
    % transmitting during slots 11, 12 and 13.
    GTSList = {'0001', 11, 3};
    
    %PendingAddresses List of pending short and extended addresses.
    % Specify PendingAddresses as a cell array containing the pending short
    % and extended addresses. Both address types are denoted with
    % hexadecimal character arrays. Their length equals 4 for the short
    % addresses and 16 for the extended. The default is empty, i.e., {}.
    PendingAddresses = {};
    
    %FFDDevice Flag indicating full function device 
    % Specify FFDDevice as a logical scalar. If true, the device is a full
    % function device (FFD), otherwise it is a reduced function device (RFD).
    % The default is false.
    FFDDevice = false;
    
    %BatteryPowered Flag indicating lack of power connection
    % Specify BatteryPowered as a logical scalar. If true, the device is
    % battery powered, otherwise the device is connected to an electricity
    % outlet. The default is true.
    BatteryPowered = true;
    
    %IdleReceiving Flag indicating receptions during idle periods 
    % Specify IdleReceiving as a logical scalar. If true, the device does
    % not disable its receiver to conserve power during idle periods. The
    % default is false.
    IdleReceiving = false;
    
    %AllocateAddress Flag indicating address allocation during association 
    % Specify AllocateAddress as a logical scalar. If true, the coordinator
    % assigns a short address to the associated device. The default is
    % false.
    AllocateAddress = false;
    
    %ShortAddress Short addressed assigned during association
    % Specify ShortAddress as a 4-character row vector. This is the short
    % address assigned to a newly associated device. Association failures
    % should specify the short address 'FFFF'. Successful associations that
    % are unable to assign a short address should specify the short address
    % 'FFFE' The default is '0001'.
    ShortAddress = 'fff1';
    
    %AssociationStatus Association status
    % Specify AssociationStatus as one of 'Successful' | 'PAN at capacity'
    % | 'PAN access denied'. The default is 'Successful'.
    AssociationStatus = 'Successful'
    
    %DisassociationReason Reason for disassociation
    % Specify DisassociationReason as one of 'Coordinator' | 'Device'. The
    % 'Coordinator' value signifies that the coordinator wishes the device
    % to leave the PAN, while 'Device' signifies that the device itself
    % wishes to leave the PAN. The default is 'Device'.
    DisassociationReason = 'Device'
    
    %GTSCharacteristics Detailed GTS request
    % Specify GTSCharacteristics as a 3-element cell array describing the
    % request for guaranteed time slots (GTS). The first element is an
    % integer scalar, between 0 and 15, denoting the requested GTS length
    % (in slots). The second element is scalar logical which is true if and
    % only if the device receives only during the GTS. The third element is
    % a logical scalar that is true if this an request for allocating GTS
    % and false for deallocating GTS. denoting the length of the GTS.
    % The default is {3, true, true}, which corresponds to a request for
    % allocating 3 receive-only GTS slots.
    GTSLength = 0
    
    GTSCharacteristics = {'3', 1,1}
    
    GTSStartingSlot = 0
    
    callsearchEn = 0;
    
    frequency = '0'
    PacketType  = 'single'
  end
  
  properties(Constant, Hidden)
    FrameTypeValues    = {'Beacon', 'Data', 'Acknowledgment', 'MAC command','CVD'}
    SourceAddressingValues = {'Not present', 'Short address', 'Extended address','Broadcast'}
    DestinationAddressingValues = {'Not present', 'Short address', 'Extended address','Broadcast'}
    FrameVersionValues = {[0 0]};
    MACCommandValues = {'Association request', 'Association response', ...
      'Disassociation notification', 'Data request', 'VPAN ID conflict notification', ...
      'Coordinator realignment', 'Beacon request', 'GTS request','Blinking notification',...
      'Dimming notification','Fast link recovery','Mobility notification','GTS response',...
      'Clock rate change notification','Multiple channel assignment','Color stabilization timer notification',...
      'Color stabilization information','CVD disable','Information element',''}
    AssociationStatusValues = {'Successful', 'PAN at capacity', 'PAN access denied'}
    DisassociationReasonValues = {'Coordinator', 'Device'}
    PacketTypeValues = {'single','packed','burst','reserved'}
  end
  
  methods
     function obj = vlcConfig(varargin)
      % Apply constructor name value pairs:
      for i = 1:2:nargin
          obj.(varargin{i}) = varargin{i+1};
      end
      
      % register support package resources if needed:
      m = message('vlc:VPAN:InvalidAddressLength');
%       try
%           m.getString();
%       catch
%           matlab.internal.msgcat.setAdditionalResourceLocation(zigbee.internal.zigbeeResourceRoot);
%       end
    end
    
    % For autocompletion:
    function v = set(obj, prop)
      v = obj.([prop, 'Values']);
    end
    
    function obj = set.FrameType(obj, value)
      obj.FrameType = validatestring(value, obj.FrameTypeValues, '', 'FrameType');
      if any(strcmp(obj.FrameType, {'Beacon', 'Acknowledgment'}))
        
        % Not using a dependent variable if MAT file save/load is not important
        obj.AcknowledgmentRequest = false;  %#ok<*MCSUP>
      end
    end
    
    function obj = set.MACCommand(obj, value)
      obj.MACCommand = validatestring(value, obj.MACCommandValues, '', 'MACCommand');
      
      if strcmp(obj.MACCommand, 'Association request')
        obj.SourceAddressing              = 'Extended address';
        obj.FramePending                  = false;
        obj.AcknowledgmentRequest         = true;
        obj.SourcePANIdentifier           = 'FFFF'; % broadcast;

      elseif strcmp(obj.MACCommand, 'Association response')
        obj.SourceAddressing              = 'Extended address';
        obj.DestinationAddressing         = 'Extended address';
        obj.FramePending                  = false;
        obj.AcknowledgmentRequest         = true;
        
      elseif strcmp(obj.MACCommand, 'Beacon request') 
        obj.SourceAddressing              = 'Not present';
        obj.DestinationAddressing         = 'Short address';
        obj.DestinationPANIdentifier      = 'FFFF';
        obj.DestinationAddress            = 'FFFF';
        obj.FramePending                  = false;
        obj.AcknowledgmentRequest         = false;
        obj.Security                      = false;
        
      elseif strcmp(obj.MACCommand, 'Data request') 
        obj.FramePending = false;
        obj.AcknowledgmentRequest = true;
      end
    end
      
    function obj = set.SequenceNumber(obj, value)
      validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'real'}, '', 'SequenceNumber');
      obj.SequenceNumber = value;
    end
    
    function obj = set.PacketType(obj, value)
      obj.PacketType = validatestring(value, obj.PacketTypeValues, '', 'PacketType');
      obj.PacketType = value;
    end
    
    function obj = set.AcknowledgmentRequest(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'AcknowledgmentRequest');
      if value && any(strcmp(obj.FrameType, {'Beacon', 'Acknowledgment'})) 
%          error(message('vlc:VPAN:InvalidAR'));
           disp("error");
      end
      obj.AcknowledgmentRequest = value;
    end
    
    function obj = set.DestinationAddressing(obj, value)
      obj.DestinationAddressing = validatestring(value, obj.DestinationAddressingValues, '', 'DestinationAddressing');
      if strcmp(obj.DestinationAddressing, 'Short address') && ...
         length(obj.DestinationAddress) == 16 
            obj.DestinationAddress = obj.DestinationAddress(end-3:end); 
      end
      if strcmp(obj.DestinationAddressing, 'Extended address') && ...
         length(obj.DestinationAddress) == 4 
            obj.DestinationAddress = ['000000000000' obj.DestinationAddress]; 
      end
    end
    
    function obj = set.SourceAddressing(obj, value)
      obj.SourceAddressing = validatestring(value, obj.SourceAddressingValues, '', 'SourceAddressing');
      if strcmp(obj.SourceAddressing, 'Short address') && ...
         length(obj.SourceAddress) == 16 
            obj.SourceAddress = obj.SourceAddress(end-3:end); 
      end
      if strcmp(obj.SourceAddressing, 'Extended address') && ...
         length(obj.SourceAddress) == 4 
            obj.SourceAddress = ['000000000000' obj.SourceAddress]; 
      end
    end
    
    function obj = set.DestinationAddress(obj, value)
      validateattributes(value, {'char'}, {'row'}, '', 'DestinationAddress');
      if strcmp(obj.DestinationAddressing, 'Short address') && ...
         length(value) ~=4 
            error(message('vlc:VPAN:InvalidAddressLength', obj.DestinationAddressing, 4)); 
      elseif strcmp(obj.DestinationAddressing, 'Extended address') && ...
         length(value) ~=16 
            error(message('vlc:VPAN:InvalidAddressLength', obj.DestinationAddressing, 16)); 
      end
      obj.DestinationAddress = value;
    end
    
    function obj = set.SourceAddress(obj, value)
      validateattributes(value, {'char'}, {'row'}, '', 'SourceAddress');
      if strcmp(obj.SourceAddressing, 'Short address') && ...
         length(value) ~=4 
            error(message('vlc:VPAN:InvalidAddressLength', obj.SourceAddressing, 4)); 
      elseif strcmp(obj.SourceAddressing, 'Extended address') && ...
         length(value) ~=16 
            error(message('vlc:VPAN:InvalidAddressLength', obj.SourceAddressing, 16)); 
      end
      obj.SourceAddress = value;
    end
    
    function obj = set.FramePending(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'FramePending');
      obj.FramePending = value;
    end
    
%     function obj = set.FrameVersion(obj, value)
%       obj.FrameVersion = validatestring(value, obj.FrameVersionValues, '', 'FrameVersion');
%     end
    
    function obj = set.BeaconOrder(obj, value)
      validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'real', '<=', 15,}, '', 'BeaconOrder');
      obj.BeaconOrder = value;
    end
    
    function obj = set.SuperframeOrder(obj, value)
      validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'real', '<=', 15,}, '', 'SuperframeOrder');
      if value > obj.BeaconOrder 
        error(message('vlc:VPAN:InvalidSuperframeOrder'));
      end
      obj.SuperframeOrder = value;
    end
    
    function obj = set.FinalCAPSlot(obj, value)
      validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'real', '<=', 15,}, '', 'FinalCAPSlot');
      obj.FinalCAPSlot = value;
    end
    
    function obj = set.BatteryLifeExtension(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'BatteryLifeExtension');
      obj.BatteryLifeExtension = value;
    end
    
    function obj = set.PANCoordinator(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'PANCoordinator');
      obj.PANCoordinator = value;
    end
    
    function obj = set.PermitAssociation(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'PermitAssociation');
      obj.PermitAssociation = value;
    end
    
    function obj = set.PermitGTS(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'PermitGTS');
      obj.PermitGTS = value;
    end
    
    function obj = set.GTSList(obj, value)
      validateattributes(value, {'cell'}, {}, '', 'GTSList');
      if ~isempty(value)
        validateattributes({value{:, 1}}, {'char', 'cell'},    {}, '', 'GTSList{:, 1}')
        validateattributes({value{:, 2}}, {'numeric', 'cell'}, {}, '', 'GTSList{:, 2}');
        validateattributes({value{:, 3}}, {'numeric', 'cell'}, {}, '', 'GTSList{:, 3}');
        validateattributes({value{:, 4}}, {'logical', 'cell'}, {}, '', 'GTSList{:, 4}');
      end
      if size(value, 1) > 7
        %error(message('vlc:VPAN:InvalidGTSList'));
      end
      obj.GTSList = value;
    end
    
    function obj = set.PendingAddresses(obj, value)
      validateattributes(value, {'cell'}, {}, '', 'PendingAddresses');
      lengths = cellfun(@length, value);
      if ~all(lengths == 4 | lengths == 16)
       % error(message('vlc:VPAN:InvalidPendingAddresses'));
      end
      obj.PendingAddresses = value;
    end
    
    function obj = set.FFDDevice(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'FFDDevice');
      obj.FFDDevice = value;
    end
    
    function obj = set.BatteryPowered(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'BatteryPowered');
      obj.BatteryPowered = value;
    end
    
    function obj = set.IdleReceiving(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'IdleReceiving');
      obj.IdleReceiving = value;
    end
    
    function obj = set.AllocateAddress(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'AllocateAddress');
      obj.AllocateAddress = value;
    end
        
    function obj = set.ShortAddress(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'ShortAddress');
      obj.ShortAddress = value;
    end
    
    function obj = set.AssociationStatus(obj, value)
      obj.AssociationStatus = validatestring(value, obj.AssociationStatusValues, '', 'AssociationStatus');
    end
    
    function obj = set.DisassociationReason(obj, value)
      obj.DisassociationReason = validatestring(value, obj.DisassociationReasonValues, '', 'DisassociationReason');
    end
    
    function obj = set.GTSLength(obj, value)
        validateattributes(value, {'numeric'}, {'scalar', 'integer', 'real', '>=', 0, '<=', 15}, '', 'GTSLength');
        obj.GTSLength = value;
    end  
    
    function obj = set.GTSStartingSlot(obj, value)
        validateattributes(value, {'numeric'}, {'scalar', 'integer', 'real', '>=', 0, '<=', 15}, '', 'GTSLength');
        obj.GTSStartingSlot = value;
    end 
    
    function obj = set.GTSCharacteristics(obj, value)
      validateattributes(value, {'cell'}, {'numel', 3}, '', 'GTSCharacteristics');
%       validateattributes(value(1) ,{'cell'}, {'numel', 3}, '', 'GTSCharacteristics{1}');
%       validateattributes(value{2}, {'logical'}, {'scalar'}, '', 'GTSCharacteristics{2}');
%       validateattributes(value{3}, {'logical'}, {'scalar'}, '', 'GTSCharacteristics{3}');
      obj.GTSCharacteristics = value;
    end
  end
  
  methods (Access=protected)
    
    function groups = getPropertyGroups(obj)
      
      propList1  = {'FrameType'; 'MACCommand'};
      activeIdx1 = true(size(propList1));

      for n = 1:numel(propList1)
          if isInactiveProperty(obj,propList1{n})
              activeIdx1(n) = false;
          end
      end
      groups = coder.nullcopy(repmat(matlab.mixin.util.PropertyGroup(propList1(activeIdx1)), 1, 3));
      groups(1) = matlab.mixin.util.PropertyGroup(propList1(activeIdx1));
      
      propList2  = {'SequenceNumber'; 'AcknowledgmentRequest';   'DestinationAddressing'; ...        
           'DestinationPANIdentifier'; 'DestinationAddress'; 'SourceAddressing'; ...
          'SourcePANIdentifier'; 'SourceAddress'; 'PANIdentificationCompression';
          'FramePending'; 'FrameVersion'; 'Security'};
      title2 = getString(message('vlc:VPAN:GeneralPropsTitle'));
      activeIdx2 = true(size(propList2));

      for n = 1:numel(propList2)
          if isInactiveProperty(obj,propList2{n})
              activeIdx2(n) = false;
          end
      end
      
      groups(2) = matlab.mixin.util.PropertyGroup(propList2(activeIdx2), title2);
      
      propList3  = {'SecurityLevel'; 'KeyIdentifierMode'; 'FrameCounter'; 'KeySource'; 'KeyIndex'};
      title3 = getString(message('vlc:VPAN:SecurityPropsTitle'));
      activeIdx3 = true(size(propList3));

      for n = 1:numel(propList3)
          if isInactiveProperty(obj,propList3{n})
              activeIdx3(n) = false;
          end
      end
      
      groups(3) = matlab.mixin.util.PropertyGroup(propList3(activeIdx3), title3);
      
      propList4  = {'BeaconOrder'; 'SuperframeOrder'; 'FinalCAPSlot'; ...
          'BatteryLifeExtension'; 'PANCoordinator'; 'PermitAssociation'; ...
          'PermitGTS'; 'GTSList'; 'PendingAddresses'};
      title4 = getString(message('vlc:VPAN:BeaconPropsTitle'));
      activeIdx4 = true(size(propList4));

      for n = 1:numel(propList4)
          if isInactiveProperty(obj,propList4{n})
              activeIdx4(n) = false;
          end
      end
      
      groups(4) = matlab.mixin.util.PropertyGroup(propList4(activeIdx4), title4);
      
      propList5  = {'FFDDevice'; 'BatteryPowered'; 'IdleReceiving'; ...
          'AllocateAddress'; 'ShortAddress'; 'AssociationStatus'; ...
          'DisassociationReason'; 'GTSCharacteristics'};
      title5 = getString(message('vlc:VPAN:MACCommandPropsTitle'));
      activeIdx5 = true(size(propList5));
      
      for n = 1:numel(propList5)
          if isInactiveProperty(obj,propList5{n})
              activeIdx5(n) = false;
          end
      end
      groups(5) = matlab.mixin.util.PropertyGroup(propList5(activeIdx5), title5);
    end
    
    function flag = isInactiveProperty(obj, prop)
      % Controls the conditional display of properties

      flag = false;

      if strcmp(prop, 'MACCommand')
        flag = ~strcmp(obj.FrameType, 'MAC command');
      end
      
      if strcmp(prop, 'AcknowledgmentRequest')
        flag = any(strcmp(obj.FrameType, {'Beacon', 'Acknowledgment'}));
      end
      
      if any(strcmp(prop, {'DestinationPANIdentifier', 'DestinationAddress'}))
        flag = strcmp(obj.DestinationAddressing, 'Not present');
      end
      
      if any(strcmp(prop, {'SourcePANIdentifier', 'SourceAddress', 'PANIdentificationCompression'}))
        flag = strcmp(obj.SourceAddressing, 'Not present');
      end
      
      if strcmp(prop, 'SourcePANIdentifier')
        flag = strcmp(obj.SourceAddressing, 'Not present') || (obj.PANIdentificationCompression == true && ~strcmp(obj.DestinationAddressing, 'Not present'));
      end
      
      if any(strcmp(prop, {'SecurityLevel', 'KeyIdentifierMode', 'FrameCounter', 'KeySource', 'KeyIndex'}))
        flag = ~obj.Security;
      end
      
      if any(strcmp(prop, {'BeaconOrder'; 'SuperframeOrder'; 'FinalCAPSlot'; ...
          'BatteryLifeExtension'; 'PANCoordinator'; 'PermitAssociation'; ...
          'PermitGTS'; 'GTSList'; 'PendingAddresses'}))
        flag = ~strcmp(obj.FrameType, 'Beacon');
      end
      
      if any(strcmp(prop, {'FFDDevice'; 'BatteryPowered'; 'IdleReceiving'; 'AllocateAddress'}))
        flag = ~( strcmp(obj.FrameType, 'MAC command') && strcmp(obj.MACCommand, 'Association request') );
      end
        
      if any(strcmp(prop, {'ShortAddress'; 'AssociationStatus'}))
        flag = ~( strcmp(obj.FrameType, 'MAC command') && strcmp(obj.MACCommand, 'Association response') );
      end
      
      if any(strcmp(prop, {'DisassociationReason'}))
        flag = ~( strcmp(obj.FrameType, 'MAC command') && strcmp(obj.MACCommand, 'Disassociation notification') );
      end
      
      if any(strcmp(prop, {'GTSCharacteristics'}))
        flag = ~( strcmp(obj.FrameType, 'MAC command') && strcmp(obj.MACCommand, 'GTS request') );
      end
    end
  end
  
end

