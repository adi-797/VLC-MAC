classdef vlcPrimitiveParameterConfig
%   vlcPrimitiveParameterConfig Create default Primitive parameters values for 802.15.7.
%   vlcPrimitiveParameterConfig properties
%
%   setDefaultPIB              - Tells wheter to set default values of parameters or otherwise.
%   status                     - The status of the last MSDU transmission.
%   BSN                        - Tells the beacon sequence number.
%   CoordAddrMode              - The coordinator addressing mode for this primitive and subsequent MPDU.
%   CoordVPANID                - The VPAN identifier of the coordinator as specified in the received beacon frame.
%   CoordAddress               - The address of the coordinator with which to associate.
%   DeviceAddress              - The address of the device.
%   DeviceAddrMode             - The addressing mode of the device.
%   DeviceVPANID               - The VPAN identifier of the device.
%   DissociateReason           - The reason for the disassociation
%   AssocShortAddr             - The 16-bit short device address allocated by the coordinator on successful association.
%   DSN                        - The DSN(Data Sequence Number) of the received data frame.
%   ScanType                   - Indicates the type of scan performed.
%   ScanDuration               - The time spent scanning each channel.
%   SouceAddrMode              - The source addressing mode for this primitive corresponding to the received MPDU.
%   SourceAddr                 - The individual device address of the entity from which the MSDU was received.
%   DestinationAddrMode        - The destination addressing mode for this primitive corresponding to the received MPDU.
%   DestinationAddr            - The individual device address of the entity to which the MSDU is being transferred.
%   VPANID                     - The 16-bit VPAN identifier of the device from which the frame was received or to which the frame was being sent.
%   SuperFrameOrder            - The length of the active portion of the superframe, including the beacon frame.
%   BeaconOrder                - How often the beacon is to be transmitted.
%   VPANCoordinator            - If this value is TRUE, the device will become the coordinator of a new VPAN.
%   CoordinatorRealignment     - TRUE if a coordinator realignment command is to be transmitted prior to changing the superframe configuration or FALSE otherwise.
%   StartTime                  - The time at which to begin transmitting beacons.

    properties
        
        setDefaultPIB = true;
        status = 'SUCCESS';
        BSN = zeros(0,8);
        CoordAddrMode = '02';
        CoordVPANID = '0000';
        CoordAddress = '0000';
        DeviceAddress = '0000000000000000';
        DeviceAddrMode = '02';
        DeviceVPANID = '0000';
        AssocShortAddr = '0000';
        DSN = zeros(0,8);
        ScanType = '00';%
        ScanDuration = 15;
        SouceAddrMode = '00';
        SourceAddr = 'f0f0f0f0f0f0f0f0';
        DestinationAddrMode = '00';
        DestinationAddr = 'f0f0f0f0f0f0f0f1';
        VPANID = '0000';
        SuperFrameOrder = 7;
        BeaconOrder = 7;
        VPANCoordinator = true;
        CoordinatorRealignment = false;
        StartTime = '000000';
        DissociationReason = '02';
%       VPANDescriptor = CoordAddrMode+CoordVPANID+CoordAddress;
%       VPANDescriptorList = ;
        
    end

    methods
        
     function obj = vlcPrimitiveParameterConfig(varargin)
      for i = 1:2:nargin
          obj.(varargin{i}) = varargin{i+1};
      end
     end
    
     function obj = set.setDefaultPIB(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'AllocateAddress');
      obj.setDefaultPIB = value;
     end
     
     function obj = set.VPANCoordinator(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'VPANCoordinator');
      obj.VPANCoordinator = value;
     end
     
     function obj = set.CoordinatorRealignment(obj, value)
      validateattributes(value, {'logical'}, {'scalar'}, '', 'CoordinatorRealignment');
      obj.CoordinatorRealignment = value;
     end
     
     function obj = set.status(obj, value)
      obj.status = validatestring(value, 'SUCCESS', "NO_ACK", "NO-DATA",...
          "ASSOCIATION_SUCCESFULL","UNSUPPORTED_ATTRIBUTE","LIMIT_REACHED","NO_BEACON",...
          "SCAN_IN_PROGRESS","NO_SHORTADDRESS", '', 'status');
     end
     
     function obj = set.CoordAddrMode(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 2}, '', 'CoordAddrMode');
     end
     
     function obj = set.CoordVPANID(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'CoordVPANID');
     end
     
     function obj = set.CoordAddress(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'CoordAddress');
     end
     
     function obj = set.DeviceAddress(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 16}, '', 'DeviceAddress');
     end
     
     function obj = set.DeviceAddrMode(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'DeviceAddrMode');
     end
     
     function obj = set.DeviceVPANID(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'DeviceVPANID');
     end
     
     function obj = set.DissociationReason(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 2}, '', 'DissociationReason');
     end
     
     function obj = set.AssocShortAddr(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'AssocShortAddr');
     end
     
     function obj = set.ScanType(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 2}, '', 'ScanType');
     end
     
     function obj = set.SouceAddrMode(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 2}, '', 'SouceAddrMode');
     end
     
     function obj = set.SourceAddr(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 16}, '', 'SourceAddr');
     end
     
     function obj = set.DestinationAddrMode(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 2}, '', 'DestinationAddrMode');
     end
     
     function obj = set.DestinationAddr(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 16}, '', 'DestinationAddr');
     end
     
     function obj = set.VPANID(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 4}, '', 'VPANID');
     end
     
     function obj = set.StartTime(obj, value)
      validateattributes(value, {'char'}, {'row', 'numel', 6}, '', 'StartTime');
     end
     
     function obj = set.ScanDuration(obj, value)
      validateattributes(value, {'numeric'}, {'scalar', 'integer', 'real'}, '', 'ScanDuration');
     end
     
     function obj = set.SuperFrameOrder(obj, value)
      validateattributes(value, {'numeric'}, {'scalar', 'integer', 'real'}, '', 'SuperFrameOrder');
     end
     
     function obj = set.BeaconOrder(obj, value)
      validateattributes(value, {'numeric'}, {'scalar', 'integer', 'real'}, '', 'BeaconOrder');
     end

%      function obj = set.VPANDescriptor(obj, value)
%       obj.VPANDescriptor = validatestring(value, '', '', 'VPANDescriptor');
%      end
%      
%      function obj = set.primitiveName(obj, value)
%       obj.primitiveName = validatestring(value, obj.primitiveNameValues, '', 'primitiveName');
%      end
         
    end
end