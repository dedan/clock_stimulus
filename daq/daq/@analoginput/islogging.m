function out = islogging(obj)
%ISLOGGING Determine if object is logging.
%
%   OUT = ISLOGGING(OBJ) returns a logical array, OUT, that contains a 1
%   where the elements of OBJ are analog input objects whose Logging
%   property is set to 'On' and a 0 where the elements of OBJ are analog
%   input objects whose Logging property is set to 'Off'. 
%
%   See also DAQDEVICE/START, DAQDEVICE/STOP, DAQDEVICE/TRIGGER, DAQHELP.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/18 07:34:42 $

% Determine if an invalid handle was passed.
if ~all(isvalid(obj))
   error('daq:islogging:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Get logging state.
try
    out = islogging( daqgetfield(obj,'uddobject') );
catch
    rethrow(lasterror);
end
