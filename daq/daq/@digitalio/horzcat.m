function out = horzcat(varargin)
%HORZCAT Horizontal concatenation of data acquisition objects.
%

%    MP 12-22-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.5 $  $Date: 2004/12/01 19:47:32 $

% Initialize variables.
c=[];

% Concatenate field information.
for i = 1:nargin
    if ~isempty(varargin{i}),
        % Make sure we are only concatenating device objects.
        if ~isa(varargin{i},'daqdevice'),
            error('daq:horzcat:invalidobject', 'Device objects can only be concatenated with other device objects.')
        end
        
        if isempty(c),
            c=varargin{i};
        else
            try
                c.uddobject = [c.uddobject daqgetfield(varargin{i},'uddobject')];
                c.version = [c.version daqgetfield(varargin{i},'version')];
                c.info = [c.info daqgetfield(varargin{i},'info')];
            catch
                error('daq:horzcat:unexpected', lasterr);
            end
        end 
    end
end

% Determine if a matrix of device objects was constructed if so error
% since only vectors are allowed.
if length(c.uddobject) ~= numel(c.uddobject)
    error('daq:horzcat:size', 'Only a row or column vector of device objects can be created.')
end

% Assign the new device object vector to the output.  
out = c;
