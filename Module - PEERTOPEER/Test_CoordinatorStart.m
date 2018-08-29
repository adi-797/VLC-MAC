c = clock;
c(6)
c(5)
%   Generating object for class vlcConfig.
CoordinatorConfiguration = vlcConfig;

%   Generating object for class vlcPrimitiveParameterConfig.
DefaultPrimitiveConfiguration = vlcPrimitiveParameterConfig;

%   Initiating the coordinator end execution.
vlcCoordinatorstart(DefaultPrimitiveConfiguration, CoordinatorConfiguration);

c = clock;
c2 = c(6)
c(5)
f = c2-c1