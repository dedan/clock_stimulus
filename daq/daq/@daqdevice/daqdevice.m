function obj = daqdevice
%DAQDEVICE Construct daqdevice object.
%
%    DAQDEVICE is the base class from which analoginput, analogoutput
%    and digitalio objects are derived from.  It is used to allow these
%    objects to inherit common methods.
% 
%    See also ANALOGINPUT, ANALOGOUTPUT, DIGITALIO.
%

%    CP 2-25-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:41:04 $

% Create an empty dummy object
obj.store={};
obj=class(obj,'daqdevice');