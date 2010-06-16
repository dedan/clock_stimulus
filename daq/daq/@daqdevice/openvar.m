function openvar(name, obj)
%OPENVAR Open a data acquisition object for graphical editing.
%
%    OPENVAR(NAME, OBJ) open a data acquisition object, OBJ, for graphical 
%    editing. NAME is the MATLAB variable name of OBJ.
%
%    See also DAQDEVICE/SET, DAQDEVICE/GET, DAQDEVICE/PROPINFO,
%             DAQHELP.
%

%    DTL 10-1-2004
%    Copyright 2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/12/01 19:47:11 $

if ~isa(obj, 'daqdevice')
    errordlg('OBJ must be a data acquisition object.', 'Invalid object', 'modal');
    return;
end

if ~isvalid(obj)
    errordlg('The data acquisition object is invalid.', 'Invalid object', 'modal');
    return;
end

try
    inspect(obj);
catch
    errordlg(lasterr, 'Inspection error', 'modal');
end
