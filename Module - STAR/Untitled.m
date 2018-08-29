% vlcConfigg = vlcConfig;
% 
% %   Generating object for class vlcPrimitiveParameterConfig.
% DefaultPrimitiveConfiguration = vlcPrimitiveParameterConfig;
% 
% %   Generating object for class vlcMACPIBattributes.
% DefaultPIBattributes = vlcMACPIBattributes;
% dataPayload = "123";
% deviceID = 1;
% previousPrimitive ="";
% frameCommand(deviceID) = "";
% frameType(deviceID) = "";
% nextPrimitive(1) = "MLMEAssociateIndication";
% for i=1:2
%     [nextPrimitive(deviceID), previousPrimitive(deviceID)] = vlcMessageCoordSequencer(DefaultPrimitiveConfiguration, nextPrimitive(1), frameType(deviceID), frameCommand(deviceID), vlcConfigg, dataPayload);
%     deviceID = deviceID +1;
% end
% previousPrimitive
% nextPrimitive



% a = (zeros(1,2));
% b= num2str(a);
% for i=1:size(b, 2)
%     if strcmp(b(i), ' ')
%         disp("dfgrs");
%     end
% end
% 
% s = strings([1,3])
% s(4)
% 
% c = false;
% for i=1:10
%     disp("frgre");
%     i
%     if i == 9
%         c= true;
%     end
%     if c == true
%         break
%     end

FileID = fopen("vlcbbbb.csv", 'w');
fwrite(FileID, zeros(1,1));
fclose(FileID);
