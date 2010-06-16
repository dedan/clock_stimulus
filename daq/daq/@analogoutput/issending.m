function out = issending(obj)
%ISSENDING Determine if object is sending.
%
%   OUT = ISSENDING(OBJ) returns a logical array, OUT, that contains a 1
%   where the elements of OBJ are analog output objects whose Sending
%   property is set to 'On' and a 0 where the elements of OBJ are analog
%   output objects whose Sending property is set to 'Off'. 
%
%   See also DAQDEVICE/START, DAQDEVICE/STOP, DAQDEVICE/TRIGGER, DAQHELP.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/18 07:34:43 $

% Determine if an invalid handle was passed.
if ~all(isvalid(obj))
   error('daq:issending:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Get sending state.
try
    % UDD method is named islogging for both AI and AO objects.
    out = islogging( daqgetfield(obj,'uddobject') );
catch
    rethrow(lasterror);
end
