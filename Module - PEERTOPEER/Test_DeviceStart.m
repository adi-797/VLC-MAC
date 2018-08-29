%   Reseting/Clearing the "vlcHold.csv" file.
FileID = fopen("vlcHold.csv", 'w');
fwrite(FileID, zeros(1,1));
fclose(FileID);

%   Reseting/Clearing the "vlcProcess.csv" file.
FileID = fopen("vlcProcess.csv", 'w');
fwrite(FileID, ones(1,20));
fclose(FileID);

%   Generating object for class vlcConfig.
DeviceConfiguration = vlcConfig;

%   Generating object for class vlcPrimitiveParameterConfig.
DefaultPrimitiveConfiguration = vlcPrimitiveParameterConfig;

%   Generating object for class vlcMACPIBattributes.
DefaultPIBattributes = vlcMACPIBattributes;

%   Generating data payload.
DataPayload = "12213246578689879";

%   Initiating the device end execution.
vlcDevicestart(DefaultPrimitiveConfiguration, DataPayload, DeviceConfiguration, DefaultPIBattributes)