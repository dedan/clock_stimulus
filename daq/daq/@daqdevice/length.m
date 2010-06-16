function out = length(obj)
%LENGTH Length of data acquisition object.
%
%    LENGTH(OBJ) returns the length of data acquisition object, OBJ.  
%    It is equivalent to MAX(SIZE(OBJ)).  OBJ can be a device object 
%    array or a channel/line.
%    
%    See also DAQHELP, DAQCHILD/SIZE.
%

%    MP 4-15-98
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2004/12/01 19:47:08 $

% The handle property of the object indicates the number of 
% objects that are concatenated together.
try
   h = struct(obj);
   out = builtin('length', h.uddobject);
catch
   out = 1;
end

