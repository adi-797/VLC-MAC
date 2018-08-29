classdef vlcMACsublayerconstants
%   vlcMACsublayerconstants Create sublayer constants for 802.15.7 MAC frames
%   vlcMACsublayerconstants properties
%
%   aBaseSlotDuration         - The number of optical clocks forming a superframe slot when the superframe order is equal to 0
%   aBaseSuperFrameDuration   - The number of optical clocks forming a superframe when the superframe order is equal to 0.
%   aExtendedAddress          - The 64-bit (IEEE) address assigned to the device
%   aMaxBeaconPayloadLength   - The maximum size, in octets, of a beacon payload
%   aMaxMACPayloadSize        - The maximum number of octets that can be transmitted in the MSDU field.
%   aNumSuperframeSlots       - The number of slots contained in any superframe.
    properties
       
        aBaseSlotDuration = 60;
        
        aBaseSuperFrameDuration = 60;
        
        aExtendedAddress = 'f0f0f0f0f0f0f0f0f0';
        
        aMaxBeaconPayloadLength = 8;
        
        aMaxMACPayloadSize = 8;
        
        aNumSuperframeSlots = 16;
        
    end
    
    methods
        
        function obj = vlcMACsublayerconstants(varargin)
            for i = 1:2:nargin
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        
        function v = set(obj, prop)
            v = obj.([prop, 'Values']);
        end
        
        function obj = set.aBaseSlotDuration(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'real'}, '', 'aBaseSlotDuration');
        end
        
        function obj = set.aBaseSuperFrameDuration(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'real'}, '', 'aBaseSuperFrameDuration');
        end
        
        function obj = set.aExtendedAddress(obj, value)
            validateattributes(value, {'char'}, {'row', 'numel', 16}, '', 'aExtendedAddress');
        end
        
        function obj = set.aMaxBeaconPayloadLength(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'real'}, '', 'aMaxBeaconPayloadLength');
        end
        
        function obj = set.aMaxMACPayloadSize(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'real'}, '', 'aMaxMACPayloadSize');
        end
        
        function obj = set.aNumSuperframeSlots(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'real'}, '', 'aNumSuperframeSlots');
        end
        
    end
end