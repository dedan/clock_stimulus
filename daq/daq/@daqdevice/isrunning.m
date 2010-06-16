function out = isrunning(obj)
%ISRUNNING Determine if object is running.
%
%   OUT = ISRUNNING(OBJ) returns a logical array, OUT, that contains a 1
%   where the elements of OBJ are device objects whose Running
%   property is set to 'On' and a 0 where the elements of OBJ are device
%   objects whose Running property is set to 'Off'. 
%
%   See also DAQDEVICE/START, DAQDEVICE/STOP, DAQHELP.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/18 07:34:49 $

% Determine if an invalid handle was passed.
if ~all(isvalid(obj))
   error('daq:isrunning:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Get running state.
try
    out = isrunning( daqgetfield(obj,'uddobject') );
catch
    rethrow(lasterror);
end
