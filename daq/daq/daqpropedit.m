function daqpropedit(varargin)
%DAQPROPEDIT Property Editor.
%
% DAQPROPEDIT has been replaced by INSPECT.  DAQPROPEDIT still works but may be
%    removed in the future.  Use INSPECT instead.
%
%    See also DAQDEVICE/INSPECT, DAQCHILD/INSPECT
%

%    DTL 10-1-2004
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.7.2.6 $  $Date: 2004/12/01 19:47:52 $

warning('daq:daqpropedit:obsoletefunction','The DAQPROPEDIT function is obsolete. Use INSPECT instead.');

if ( nargin > 1 )
    error('daq:daqpropedit:argcheck', 'Too many input arguments to DAQPROPEDIT');
end

% The following remains for backward compatibility...

% If no object was provided, use first object found. 
if ( nargin == 0 )
    obj = daqfind;

    % If an array, just use first one.
    if ( length(obj) > 1)
        obj = obj(1);   
    end
% Otherwise use the first argument passed in.    
else %if ( nargin == 1 )    
    obj = varargin{1};
end
    
if ( isempty( obj ) )
    error('daq:daqpropedit:noobjects', 'No data acquisition objects found.'); 
end

if ~(isa(obj, 'daqdevice') || isa(obj, 'daqchild')) 
    error('daq:daqpropedit:argcheck', 'Input must be a valid data acquisition object.'); 
end

% Delegate to inspect.
try
    inspect( obj );
catch
    rethrow(lasterror);
end

