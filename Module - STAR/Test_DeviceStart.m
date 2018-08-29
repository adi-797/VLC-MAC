
%   Assigning a device ID (should be set in an ascending order uptil the total number of devices, and (strictly) should not be repeated)
DeviceID = 1;

%   Reseting/Clearing the "vlcHold.csv" file.
FileID = fopen("vlcHold.csv", 'w');
fwrite(FileID, zeros(1,1));
fclose(FileID);

%   Reseting/Clearing the "vlcProcess.csv" file.
FileID = fopen("vlcProcess" + num2str(DeviceID) + ".csv", 'w');
fwrite(FileID, ones(1,20));
fclose(FileID);

%	Reseting/Clearing the "vlcDissociation.csv" file.
FileID = fopen("vlcDissociation.csv", 'w');
fwrite(FileID, zeros(1,1));
fclose(FileID);

%	Reseting/Clearing the "vlcTerminate.csv" file.
FileID = fopen("vlcTerminate.csv", 'w');
fwrite(FileID, zeros(1,1));
fclose(FileID);

%	Reseting/Clearing the "vlcAuthority.csv" file.
FileID = fopen("vlcAuthority.csv", 'w');
fwrite(FileID, ones(1,1));
fclose(FileID);

%   Generating object for class vlcConfig.
DeviceConfiguration = vlcConfig;

%   Generating object for class vlcPrimitiveParameterConfig.
DefaultPrimitiveConfiguration = vlcPrimitiveParameterConfig;

%   Generating object for class vlcMACPIBattributes.
DefaultPIBattributes = vlcMACPIBattributes;

%   Generating data payload.
DataPayload = "9876543210";

%   Initiating the device end execution.
vlcDevicestart(DefaultPrimitiveConfiguration, DataPayload, DeviceConfiguration, DefaultPIBattributes, DeviceID)