function obj = analoginput(varargin)
%ANALOGINPUT Construct analog input object.
%
%    AI = ANALOGINPUT('ADAPTOR')
%    AI = ANALOGINPUT('ADAPTOR',ID) constructs an analog input object
%    associated with adaptor, ADAPTOR, with device identification, ID.
%
%    The supported adaptors are:
%       advantech
%       hpe1432
%		keithley
%		mcc
%       nidaq
%       winsound
% 
%    ID does not need to be specified for the winsound adaptor if the
%    ID = 0.  The analog input object is returned to AI.
%
%    In order to perform a data acquisition task with the object, AI,
%    channels must be added with ADDCHANNEL.
%
%    Examples:
%       AI = analoginput('winsound');
%       AI = analoginput('nidaq',16);
%
%    See also ADDCHANNEL, PROPINFO.
%

%    DTL 9-1-2004
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.16.2.9 $  $Date: 2004/12/01 19:46:06 $

%    Object fields
%       .uddobject  - Handle to the underlying udd object for the device.
%       .version    - Class version number.
%       .info       - Structure containing strings used to provide object
%                     methods with information regarding the object.  Its
%                     fields are:
%                       .prefix     - 'a' or 'an' prefix that would preceed the
%                                     object type name.
%                       .objtype    - object type with first characters capitalized.
%                       .addchild   - method name to add children, ie. 'addchannel'
%                                     or 'addline'.
%                       .child      - type of children associated with the object
%                                     such as 'Channel' or 'Line'.
%                       .childconst - constructor used to create children, ie. 'aichannel',
%                                     'aochannel' or 'dioline'.

% Initialize variables.
tlbxVersion = 2.0;
className = 'analoginput';

% OOPS object passed in as first parameter
if ( nargin > 0 && strcmp(class(varargin{1}), className) )
   % Just return the object as is.
   obj = varargin{1};
   return;
end

% Adaptor name passed in as first parameter - User is calling constructor.
if ( nargin > 0 && ischar(varargin{1}) )
   % Expect an adaptor name, possibly an ID and other parameters.
   % Create and return the object to the user.
   try
      if isempty(varargin{1}),
         error('daq:analoginput:invalidadaptor', 'ADAPTOR specified cannot be empty.')
      end
      
      % Convert all numeric input to strings.
      for i=2:nargin,
         if any(strcmp(class(varargin{i}),{'double' 'char'})) && ~isempty(varargin{i}),
            varargin{i} = num2str(varargin{i}); % convert numbers to string
         else
            error('daq:analoginput:invalidid', 'ID must be specified as a string or number.')
         end                  
      end
      
      % Store the adaptor name.
      adaptor = varargin{1};
    
      % Use the daq package to create the analog input object.
      obj = [];
      try
          daqmex;
          uddobj = daq.engine.createobject( className, varargin{:} );
          obj = get(uddobj,'OOPSObject');
      catch
          errmsg=lasterr;
         
          % If the adaptor wasn't registered yet, do it and try again.
          if (findstr('Failure to find requested',errmsg))
              evalc('daqregister(varargin{1}); uddobj = daq.engine.createobject( className, varargin{:} ); obj = get(uddobj,''OOPSObject'');','lasterr');
              errmsg = lasterr;
          end    
          
          % Still didn't work
          if (isempty(obj))
              error('daq:analoginput:unexpected', '%s', errmsg);
          end
      end % try/catch
   catch
      error('daq:analoginput:unexpected', '%s', deblank(lasterr))
   end
   return;
end
   
% Structure of descriptive information used to generalize object methods.
info.prefix='an';
info.objtype='Analog Input';
info.addchild='addchannel';
info.child='Channel';
info.childconst='aichannel';

% DAQMEX is calling the default constructor.
if nargin==0 
   % Create the object with an empty handle
   obj.uddobject = handle(0);

% M code is calling the constructor to create a wrapper of a AI UDD object.
elseif ( nargin == 1 && ...
         (~isempty(strfind(class(varargin{1}), 'daq.') ) || ...
           strcmp(class(varargin{1}), 'handle') ) )
   obj.uddobject = varargin{1};
% Anything else is invalid.   
else
    error('daq:analoginput:invalidadaptor', 'ADAPTOR must be passed as a single string.') 
end

obj.version = tlbxVersion;
obj.info = info;
      
dev = daqdevice;
obj = class(obj, className, dev);
