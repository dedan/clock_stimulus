function daqreset
%DAQRESET Delete and unload all data acquisition objects and DLLs.
%
%    DAQRESET deletes any data acquisition objects existing in the
%    engine as well as unloads all DLLs loaded by the engine.  The
%    adaptor DLLs and daqmex.dll are also unlocked and unloaded.  As
%    a result, the data acquisition hardware is reset.
%
%    DAQRESET is the data acquisition command that returns MATLAB to 
%    the known state of having no data acquisition objects and no 
%    loaded data acquisition DLLs.
%
%    See also DAQHELP, DAQDEVICE/DELETE, DAQ/PRIVATE/CLEAR.
%

%    MP 01-05-99   
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.10.2.6 $  $Date: 2004/12/18 07:34:59 $

try
   daqmex('reset');
   builtin('clear','daqmex'); 
catch
   error('daq:daqreset:unexpected', lasterr)
end
