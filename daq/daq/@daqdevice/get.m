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

%    MP 2-25-98
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.12.2.6 $  $Date: 2004/12/18 07:34:48 $

ArgChkMsg = nargchk(1,3,nargin);
if ~isempty(ArgChkMsg)
    error('daq:get:argcheck', ArgChkMsg);
end

if nargout > 1
   error('daq:get:argcheck', 'Too many output arguments.')
end

% Error appropriately if a user calls get(1,ai);
if ~isa(obj, 'daqdevice')
   try
      builtin('get', obj, varargin{:});
   catch
      error('daq:get:unexpected', lasterr);
   end
   return;
end

% Switch on the number of inputs
switch nargin
case 1   % get(obj);
    % Error if an object is invalid.
    if ~all(isvalid(obj))
       error('daq:get:invalidobject', 'Data acquisition object OBJ is an invalid object.');
    end

   if (~nargout) && (length(obj)>1)
      error('daq:get:invalidsize', 'Vector of objects not permitted for GET(OBJ) with no left hand side.');
   end
   
   % Build up the structure of property names and property values.  
   % Each column of the structure corresponds to a different object.
   x = struct(obj);
   out = cell(length(obj),1);
   for i = 1:length(obj)
      try
         % Do the get, and convert any UDD Objects to OOPS objects in the 
         % returned structure.
         out{i} = daqgate('privateUDDToMATLAB', get(x.uddobject(i)) );
      catch
         error('daq:get:unexpected', lasterr);
      end
   end

   % If there are no output arguments construct the GET display.
   if nargout == 0
      try
         daqgate('getdisplay', obj, out{:});
      catch
         error('daq:get:unexpected', lasterr);
      end
   else
      % Must sort fields of each structure
      firstfields = fieldnames(out{1});
      [sorted, ind] = sort(lower(firstfields));
      for i = 1:length(obj)
         % Test that fields are the same for each structure
         fields = fieldnames(out{i});
         if i > 1 && ~isempty(setxor(firstfields, fields))
            error('daq:get:properties', 'All objects in OBJ must have the same properties.')         
         end
         
         % Reorder the fields to the desired order.
         output(i) = orderfields( out{i}, ind );
      end
   end
case 2   % get(obj, 'Property') | get(obj, {'Property'})
   prop = varargin{1};
   
   % Special cases when called from subsref or subsasgn. GET(OBJARRAY,INDEXARRAY)
   % Indexing into the array could not be handled by subsref or subsasgn
   % since '()' would call the default subsref which did not do the correct
   % thing.
   if ( isa(prop, 'logical') )
       newprop = [];
       for i = 1:length(prop)
           if ( prop(i) )
               newprop = [newprop i];
           end
       end
       prop = newprop;
       
       % Geck 142732:  Wrong error message Wrong error msg when index into DAQ
       % objects. Check to see that the result of this is an empty (i.e.
       % didn't find anything.
       if isempty(prop)
           % yes, prop is empty -- return it.
           output = prop;
           return;
       end

   end
   
   if ( isa(prop, 'double') )
      % Create the first object.
      try
         output = localCreateParent(obj,prop(1));
         
         % Append the device objects to the output array.
         for i = 2:length(prop)
            output = [output localCreateParent(obj,prop(i))];
         end
      catch
         error('daq:get:invalidargument', 'Second input argument of GET must contain a valid property\nname or a cell array containing valid property names.');
      end
   % Normal case when prop is a string or a cell array of strings.      
   else
    % Error if an object is invalid.
    if ~all(isvalid(obj))
       error('daq:get:invalidobject', 'Data acquisition object OBJ is an invalid object.');
    end

      try
          uddobjs = daqgetfield(obj, 'uddobject');
          % Do the get, and convert any UDD Objects to OOPS objects in the 
          % returned value.
          output = daqgate('privateUDDToMATLAB', get(uddobjs, prop) );
      catch
          temp = localCreateParent(obj,1);
          localProduceError(temp);
          error('daq:get:unexpected', lasterr)
      end
   end    

case 3  
    % Error if an object is invalid.
    if ~all(isvalid(obj))
       error('daq:get:invalidobject', 'Data acquisition object OBJ is an invalid object.');
    end

   % Getting Channel/Line info:
   % get(ai, 'Channel', [1 3])  OR
   % get(ai, 'Channel', ':')
   prop = varargin{1};
   index = varargin{2};
   
   % Prop has to be 'Channel' or 'Line' otherwise too many property name
   % strings have been entered - get(ai, 'Type', 'UserData')
   % STRNCMP is used for property completion.
   if isempty(find(strncmp(lower(prop), {'channel', 'line'}, length(prop))))
      error('daq:get:argcheck', 'Too many input arguments.');
   end
      
   % Prepare empty output
   output = cell(length(obj),1);
   
   % For each parent object
   parentuddobjects = daqgetfield(obj,'uddobject');
   for i = 1:length(parentuddobjects)
       
      parentudd = parentuddobjects(i);
      
      % Handle the colon operator.  If the colon operator is entered
      % as the index, the index contains all channels.
      if strcmp(index,':')
         try
            index = 1:length(get(parentudd,prop));
         catch
            error('daq:get:unexpected', lasterr);
         end
      end
   
      % Obtain the first channel object in the children list.
      try
         resultudd = getchannel(parentudd, index(1));
         result = get(resultudd,'OOPSObject');
      catch
         localProduceError(obj);
         error('daq:get:unexpected', lasterr)
      end
   
      % Concatenate the remaining channels to the output.
      for j = 2:length(index)
         try
            resultudd = getchannel(parentudd, index(j));
            result = [result; get(resultudd,'OOPSObject')];
         catch
            localProduceError(parent);
            error('daq:get:unexpected', lasterr);
         end
      end
      output{i} = result;
   end
   
   if length(obj) == 1
	   output = output{:};
   else
	   % Create output that is a 1 x n struct with fields
	   try
		   output = [output{:}];
	   catch
		   if (findstr(lasterr, 'CAT arguments are not consistent in structure field number.'))
			   error('daq:get:properties', 'All objects in OBJ must have the same properties.');
		   end
	   end		 
   end
end
% *************************************************************************
% Create the parent object.
function parent = localCreateParent(Obj, index1)

% Recreate the device object.  Ex. obj(1)
structinfo = struct(Obj);
parent = daqgate('privateUDDToMATLAB', structinfo.uddobject(index1) );

% *******************************************************************
% Produce an error message for ambiguous get.
function localProduceError(obj)

message = lasterr;
if ~isempty(findstr('Second argument', message)) || ~isempty(findstr('Property name argument', message))
    lasterr('Second input argument of GET must contain a valid property\nname or a cell array containing valid property names.');
    return;
end    

% Find the property that caused the error
quotes = strfind( message, '''' );
if ( length(quotes) < 2 )
    prop = 'Unknown';
else
    prop = message(quotes(1)+1:quotes(2)-1);
end

if findstr('ambiguous', message)
   all_names = get(daqgetfield(obj,'uddobject'));
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

if findstr('There is no', message)
   lasterr(sprintf(['Invalid property: ''' prop '''.']));
   return;
end




