classdef vlcMACPIBattributes
%   vlcMACPIBattributes Create PIB attributes for 802.15.7 MAC frames
%   vlcMACPIBattributes properties
%
%   macAckWaitDuration        - The maximum number of optical clocks to wait for an acknowledgment frame to arrive following a transmitted data frame.
%   macAssociationVPANCoord   - Indication of whether the device is associated to the VPAN through the coordinator.
%   macAutoRequest            - Indication of whether a device automatically sends a data request command if its address is listed in the beacon frame.
%   macCoordExtendedAddress   - The 64-bit address of the coordinator through which the device is associated.
%   macCoordShortAddress      - The 16-bit short address assigned to the coordinator through which the device is associated.
%   macGTSPermit              - TRUE if the coordinator is to accept GTS requests. FALSE otherwise.
%   macDSN                    - The sequence number added to the transmitted data or MAC command frame.
%   macVPANId                 - The 16-bit identifier of the VPAN on which the device is operating.
%   macResponseWaitTime       - The maximum time a device shall wait for a response command frame to be available following a request command frame.
%   macSecurityEnabled        - Indication of whether the MAC sublayer has security enabled.
%   macShortAddress           - The 16-bit address that the device uses to communicate in the VPAN.
%   macSuperframeOrder        - The length of the active portion of the outgoing superframe, including the beacon frame.
%   macDimOverideRequest      - Shall be set to ‘1’ after VLC device association and shall be set to ‘0’ after the VLC device disassociation.
   
  properties  
    macAckWaitDuration = {'40', 60};
    
    macAssociationVPANCoord = {'41', false};
    
    macAutoRequest = {'43', true};
    
    macCoordExtendedAddress = {'49' , 'f0f0f0f0f0f0f0f0f0'};
    
    macCoordShortAddress = {'4a', 'ffff'};
    
    macGTSPermit = {'4c', false};
    
    macDSN = {'4b', '00'};
    
    macVPANId = {'54', 'ffff'};
    
    macResponseWaitTime = {'55', 32};
    
    macSecurityEnabled = {'57', false};
    
    macShortAddress = {'58', 'ffff'};
    
    macSuperframeOrder = {'59', 15};
    
    macDimOverideRequest = {'5f', false};
  end  
  
  methods 
    function obj = vlcMACPIBattributes(varargin)
      for i = 1:2:nargin
          obj.(varargin{i}) = varargin{i+1};
      end
    end
     
    function v = set(obj, prop)
      v = obj.([prop, 'Values']);
    end  
      
    function obj = set.macAckWaitDuration(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macAckWaitDuration');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macAckWaitDuration{1}');
        validateattributes(value{2}, {'numeric'}, {'scalar', 'integer', 'real'}, '', 'macAckWaitDuration{2}');
    end
    
    function obj = set.macAssociationVPANCoord(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macAssociationVPANCoord');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macAssociationVPANCoord{1}');
        validateattributes(value{2}, {'logical'}, {'scalar'}, '', 'macAssociationVPANCoord{2}');
    end
    
    function obj = set.macAutoRequest(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macAutoRequest');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macAutoRequest{1}');
        validateattributes(value{2}, {'logical'}, {'scalar'}, '', 'macAutoRequest{2}')
    end
    
    function obj = set.macCoordExtendedAddress(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macCoordExtendedAddress');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macCoordExtendedAddress{1}');
        validateattributes(value{2}, {'char'}, {'row', 'numel', 16}, '', 'macCoordExtendedAddress{2}');
    end
    
    function obj = set.macCoordShortAddress(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macCoordShortAddress');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macCoordShortAddress{1}');
        validateattributes(value{2}, {'char'}, {'row', 'numel', 4}, '', 'macCoordShortAddress{2}');
    end
    
    function obj = set.macGTSPermit(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macGTSPermit');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macGTSPermit{1}');
        validateattributes(value{2}, {'logical'}, {'scalar'}, '', 'macGTSPermit{2}');
    end
    
    function obj = set.macDSN(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macDSN');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macDSN{1}');
        validateattributes(value{2}, {'char'}, {'row', 'numel', 2}, '', 'macDSN{2}');
    end
    
    function obj = set.macVPANId(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macVPANId');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macVPANId{1}');
        validateattributes(value{2}, {'char'}, {'row', 'numel', 4}, '', 'macVPANId{2}');
    end
    
    function obj = set.macResponseWaitTime(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macResponseWaitTime');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macResponseWaitTime{1}');
        validateattributes(value{2}, {'numeric'}, {'scalar', 'integer', 'real'}, '', 'macResponseWaitTime{2}');
    end
    
    function obj = set.macSecurityEnabled(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macSecurityEnabled');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macSecurityEnabled{1}');
        validateattributes(value{2}, {'logical'}, {'scalar'}, '', 'macSecurityEnabled{2}');
    end
    
    function obj = set.macShortAddress(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macShortAddress');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macShortAddress{1}');
        validateattributes(value{2}, {'char'}, {'row', 'numel', 4}, '', 'macShortAddress{2}');
    end
    
    function obj = set.macSuperframeOrder(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macSuperframeOrder');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macSuperframeOrder{1}');
        validateattributes(value{2}, {'numeric'}, {'scalar', 'integer', 'real','>=', 0, '<=', 15}, '', 'macSuperframeOrder{2}');
    end
    
    function obj = set.macDimOverideRequest(obj, value)
        validateattributes(value, {'cell'}, {'numel', 2}, 'macDimOverideRequest');
        validateattributes(value{1}, {'char'}, {'row', 'numel', 2}, '', 'macDimOverideRequest{1}');
        validateattributes(value{2}, {'logical'}, {'scalar'}, '', 'macDimOverideRequest{2}');
    end
  end
end