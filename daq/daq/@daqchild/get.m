function output = get(obj, varargin)
%GET Get data acquisition object properties.
%
%    V = GET(OBJ,'Property') returns the value, V, of the specified property
%    for data acquisition object OBJ.  If Property is replaced by a 
%    1-by-N or N-by-1 cell array of strings containing property names, 
%    then GET will return a 1-by-N cell array of values.  If OBJ is a 
%    vector of data acquisition objects, then V will be a M-by-N cell array 
%    of property values where M is equal to the length of OBJ and N is equal 
%    to the number of properties specified.
%
%    GET(OBJ) displays all property names and their current values for
%    data acquisition object OBJ.
%
%    V = GET(OBJ) returns a structure, V, where each field name is the name
%    of a property of OBJ and each field contains the value of that property.
%
%    Example:
%       ai = analoginput('winsound');
%       addchannel(ai, [1 2]);
%       chan = get(ai,'Channel')
%       get(ai,{'SampleRate','TriggerDelayUnits'})
%       get(ai)
%       get(chan, 'Units')
%       get(chan(1), {'HwChannel';'ChannelName'})
%
%    See also DAQHELP, DAQDEVICE/SET, SETVERIFY, PROPINFO.
%


%    MP 3-26-1998
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.12.2.5 $  $Date: 2004/12/01 19:46:46 $

ArgChkMsg = nargchk(1,2,nargin);
if ~isempty(ArgChkMsg)
    error('daq:get:argcheck', ArgChkMsg);
end

if nargout > 1,
   error('daq:get:argcheck', 'Too many output arguments.')
end

% Error appropriately for the call: get(1, chan);
if ~isa(obj, 'daqchild')
   try
      builtin('get', obj, varargin{:});
   catch
      error('daq:get:invalidobject', lasterr)
   end
   return;
end

% Error if an object is invalid.
if ~all(isvalid(obj))
   error('daq:get:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

switch nargin
case 1  % get(obj)
   if (~nargout) && (length(obj)>1)
      error('daq:get:invalidsize', 'Vector of objects not permitted for GET(OBJ) with no left hand side.');
   end
   % Build up the structure of property names and property values.  
   % Each column of the structure corresponds to a different object.
   x = struct(obj);
   for i = 1:length(obj)
      try
         % Do the get, and convert any UDD Objects to OOPS objects in the 
         % returned structure.
         out(i) = daqgate('privateUDDToMATLAB', get(x.uddobject(i)) );
      catch
         error('daq:get:unexpected', lasterr);
      end
   end
   % If there are no output arguments construct the GET display.
   if nargout == 0
      try
         daqgate('getdisplay', obj, out);
      catch
         error('daq:get:unexpected', lasterr);
      end
   elseif nargout == 1
      % Must sort fields of each structure
      firstfields = fieldnames(out(1));
      [sorted, ind] = sort(lower(firstfields));
      for i = 1:length(obj)
         % Test that fields are the same for each structure
         fields = fieldnames(out(i));
         if i > 1 && ~isempty(setxor(firstfields, fields))
            error('daq:get:properties', 'All objects in OBJ must have the same properties.')         
         end

         for j=1:length(sorted)
            output(i).( firstfields{ind(j)} ) = out(i).( firstfields{ind(j)} );
         end
      end
   end
case 2 % get(obj, 'Property') or get(obj, {'Property'})
   prop = varargin{1};
   if ischar(prop)     
      % Single property string passed directly.  Preallocate the output
      % cell array so that it is a row vector and assign property values.
      output = cell(length(obj),1);
      x = struct(obj);
      for i = 1:length(obj)
         try
            % Do the get, and convert any UDD Objects to OOPS objects.
            output{i} = daqgate('privateUDDToMATLAB', get(x.uddobject(i), prop) );
         catch
            temp = feval(class(obj), x.uddobject(i));
            localProduceError(temp, prop);
            error('daq:get:unexpected', lasterr)
         end
      end
      % If a string is passed and there is one object, need to 
      % output a string.
      if length(obj) == 1
         output = output{:};
      end
   elseif iscell(prop)  
      % get(obj, {'Property1';'Property2'})
      % Cell array of properties passed.  Preallocate the output
      % cell array and assign property values.  Each row contains  
      % one object.  Each column contains one property.
      output = cell(length(obj), length(prop));
      x = struct(obj);
      for j = 1:length(obj)
         for i = 1:numel(prop)
            try
               if ischar(prop{i}),
                  % Do the get, and convert any UDD Objects to OOPS
                  % objects.
                  output{j,i} = daqgate('privateUDDToMATLAB', get(x.uddobject(j), prop{i}) );
               else
                  error('daq:get:invalidargument', 'Second input argument of GET must contain a valid property\nname or a cell array containing valid property names.')
               end            
            catch
               temp = feval(class(obj), x.uddobject(j));
               localProduceError(temp, prop{i});
               error('daq:get:unexpected', lasterr)
            end
         end
      end
   else
      error('daq:get:invalidargument', 'Second input argument of GET must contain a valid property\nname or a cell array containing valid property names.')
   end
end

% *******************************************************************
% Produce an error message for ambiguous get.
function localProduceError(obj, prop)

errmsg = lasterr;
if findstr('ambiguous', errmsg)
   x = struct(obj);
   all_names = get(x.uddobject);
   all_names = fieldnames(all_names);
   all_names = sort(all_names);
   i = strmatch(lower(prop), lower(all_names));
   list = all_names(i);
   str = repmat('''%s'', ',1, length(list));
   str = str(1:end-2);
   lasterr(sprintf(['Ambiguous ' class(obj) ' property: ''' prop '''.\n',...
         'Valid properties: ' str '.'], list{:}));
   return;
end

if findstr('There is no', errmsg)
   lasterr(sprintf(['Invalid property: ''' prop '''.']));
   return;
end


   
