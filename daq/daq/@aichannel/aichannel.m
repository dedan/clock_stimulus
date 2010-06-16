function obj = aichannel(varargin)
%AICHANNEL Construct analog input channel.
%
%    To create channels, ADDCHANNEL must be used.  If OBJ is an analog
%    input object, then the following command will create two channels
%    assigned to hardware channel IDs [1 2]:
%
%       addchannel(OBJ, [1 2])
%
%    See also DAQHELP, ADDCHANNEL.
%

%    DTL 9-1-2004
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.10.2.6 $  $Date: 2004/12/01 19:45:56 $

%   OBJ = AICHANNEL returns an AIchannel partially initialized 
%   object OBJ. This constructor is intendedto be used by DAQMEX only.
%
%   OBJ = AICHANNEL(UDD) returns an AIchannel object OBJ that
%   wraps the given UDD handle. This constructor is intended to be used 
%   by SUBSREF, SUBSASGN, and others.

%   Object fields
%      .uddobject  - uddobject associated with the channel.
%      .version    - class version number.

if nargin > 1,
   error('daq:aichannel:argcheck', 'To create additional channels, use ADDCHANNEL.\nFor help type ''daqhelp addchannel''.');
end

tlbx_version=2.0;


% DAQMEX is calling the constructor.
if ( nargin==0 ) 
   obj.uddobject = handle(0);
% M code is calling the constructor
elseif ( nargin==1 && ...
         (strcmp(class(varargin{1}),'handle') || ...
          ~isempty(strfind( class(varargin{1}), 'daq.'))) )
   obj.uddobject = varargin{1};
else   
   error('daq:aichannel:argcheck', 'To create additional channels, use ADDCHANNEL.\nFor help type ''daqhelp addchannel''.');
end

obj.version = tlbx_version;

daqc = daqchild;
obj = class(obj, 'aichannel', daqc);