c = clock;
c(5)
c(6)
%   Generating object for class vlcConfig.
CoordinatorConfiguration = vlcConfig;
%   Generating object for class vlcPrimitiveParameterConfig.
DefaultPrimitiveConfiguration = vlcPrimitiveParameterConfig;

%	Number of Devices
NumberOfDevices = 2;

%   Initiating the coordinator end execution.
vlcCoordinatorstart(DefaultPrimitiveConfiguration, CoordinatorConfiguration, NumberOfDevices);

c = clock;
c(5)
c(6)