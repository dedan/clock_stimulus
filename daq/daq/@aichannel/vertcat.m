function out = vertcat(varargin)
%VERTCAT Vertical concatenation of data acquisition objects.

%    MP 5-12-98
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.11.2.5 $  $Date: 2004/12/01 19:46:04 $

% Determine if the objects are valid and have the same parent.
valid_parent = daqgate('privatecheckparent', varargin);
if valid_parent == 1
   error('daq:vertcat:badparent', 'Only objects with the same parent are permitted to be concatenated.');
elseif valid_parent == 2
   error('daq:vertcat:invalidobject', 'Invalid object.');
end

%Concatenate the handles of each input into one object.
c=[];
for i = 1:nargin
   if ~isempty(varargin{i}),
      if isempty(c),
         c=varargin{i};
      else
         try
            c.uddobject = [c.uddobject; varargin{i}.uddobject];
         catch
            error('daq:vertcat:unexpected', lasterr);
         end
      end      
   end
end

% Determine if a matrix of channels was constructed if so error
% since only vectors are allowed.
if length(c.uddobject) ~= numel(c.uddobject)
   error('daq:vertcat:size', 'Only a row or column vector of channels can be created.')
end

% Assign the new channel vector to the output.  
out = c;
