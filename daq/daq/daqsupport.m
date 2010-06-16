function daqsupport(varargin)
%DAQSUPPORT Debugging utility.
% 
%    DAQSUPPORT('ADAPTOR'), where ADAPTOR is the name of the data 
%    acquisition card you are using, returns diagnostic information to 
%    help troubleshoot setup problems.  Output is saved in a text file, 
%    DAQTEST.
%
%    DAQSUPPORT('ADAPTOR','FILENAME'), saves the results to the text file 
%    FILENAME.  
% 
%    DAQSUPPORT tests all installed hardware adaptors.
% 
%    Examples:
%       daqsupport('winsound')
%       daqsupport('winsound','myfile.txt')

%   SM 4-15-99
%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.8.2.5 $  $Date: 2004/07/30 01:55:07 $

OldWarningState = warning;
warning off backtrace;

filename = 'daqtest.txt';

hwInfo=daqhwinfo;

switch nargin,
case 0,
   adaptors=hwInfo.InstalledAdaptors;
case 1,
   adaptors=varargin(1);
case 2,
   adaptors=varargin(1);
   filename = varargin{2};
otherwise,
    ArgChkMsg = nargchk(0,2,nargin);
    if ~isempty(ArgChkMsg)
        error('daq:daqsupport:argcheck', ArgChkMsg);
    end
end % switch

% Check that adaptor string is contained in a cell.
if ~iscellstr(adaptors),
    error('daq:daqsupport:argcheck', 'ADAPTOR must be specified as a string.')
    warning(OldWarningState);
    return;
end

if exist(filename,'file')
   delete(filename);
end % if

try
   fid = fopen(filename,'wt');
   
   if fid==-1,
       error('') % This error message is not displayed
   end
catch
   error('daq:daqsupport:fileopen', 'Can''t open file ''%s'' for writing.', filename);
    warning(OldWarningState);
    return;
end % try

dispCapture = [];
cr = sprintf('\n');
sp = sprintf('%s','----------');

% General Info
dispCapture = [dispCapture evalc('disp([cr,sp,''General Information '',sp])')];

% Current Time and date
dispCapture = [dispCapture evalc('disp([cr,''Current Time & Date: '']);disp(datestr(now))')];

% MATLAB and Data Acquision Toolbox version

vOS=evalc('!ver');
vOS=vOS(3:end);
dispCapture = [dispCapture evalc('disp([cr,''Operating System: '']);disp(vOS)')];

[v,d] = version;  % MATLAB version information
dispCapture = [dispCapture evalc('disp([cr,''MATLAB version: '']);disp(v)')];

daqver = ver('daq'); % Data Acquistion version information
dispCapture = [dispCapture evalc('disp([cr,''Data Acquisition Toolbox version: '']); disp(daqver)')];

% MATLABROOT directory

root = matlabroot;
% Display to screen
dispCapture = [dispCapture evalc('disp([cr,sp,''MATLAB root directory: '',sp]);disp(root)')];

% MATLAB path
% Display to screen
dispCapture = [dispCapture evalc('disp([cr,sp,''MATLAB path: '',sp]);path')];

% Output daqhwinfo and expand adaptor list
dispCapture = [dispCapture evalc(['disp([cr,sp,''Available hardware: '',sp,cr]);disp(hwInfo),',...
       'disp([cr,sp,''Adaptor List'',sp,cr]);disp(hwInfo.InstalledAdaptors)'])];

for lp=1:length(adaptors),
   % Display adaptor being tested %
   dispCapture = [dispCapture evalc('disp([cr,sp,adaptors{lp} '' adaptor:'',sp])')];
   
   try 
      dispCapture = [dispCapture evalc(['disp([cr,sp,''Registering adaptor: '' adaptors{lp},sp]),',...
              'daqregister(adaptors{lp});',...
              'disp([cr,''Successfully registered '' adaptors{lp} '' adaptor''])'])];
   catch
      dispCapture = [dispCapture evalc(['disp([cr,''Error registering '' adaptors{lp} '' adaptor'']),',...
              'disp([cr,lasterr])'])];
   end % try
     
   try
      dispCapture = [dispCapture evalc(['disp([cr,sp,''Adaptor Information for adaptor '',adaptors{lp},sp,cr]),',...
                  'adaptorInfo=daqhwinfo(adaptors{lp})'])];
      if ~isempty(adaptorInfo)
         dispCapture = [dispCapture evalc(['disp([cr,sp,''Adaptor DLL Name'',sp,cr]);disp(adaptorInfo.AdaptorDllName),',...
                     'disp([cr,sp,''Adaptor Name'',sp,cr]);disp(adaptorInfo.AdaptorName)'])];
         dispCapture = [dispCapture evalc('disp([cr,sp,''Object Constructor Names '',sp,cr]);')];
         for inLp2 = 1:numel(adaptorInfo.ObjectConstructorName)
            dispCapture = [dispCapture evalc('disp(adaptorInfo.ObjectConstructorName{inLp2})')];
         end % for
      end % if
   catch
      dispCapture = [dispCapture evalc('disp([cr,''Error displaying DAQHWINFO for adaptor '',adaptors{lp}])')];
      dispCapture = [dispCapture evalc('disp(lasterr)')];
      adaptorInfo = [];
   end % try
   
   % Test all Analoginput, Analogoutput, Digital I/O objects
   if ~isempty(adaptorInfo)
      sizeObjectConstructorName = size(adaptorInfo.ObjectConstructorName);
      for inLp=1:sizeObjectConstructorName(1),
          for inLp2=1:sizeObjectConstructorName(2),
              if ~isempty(adaptorInfo.ObjectConstructorName{inLp,inLp2}),
                 try
                    dispCapture = [dispCapture evalc('disp([cr,sp,''Creating '' adaptorInfo.ObjectConstructorName{inLp,inLp2} '' object for adaptor '' adaptors{lp},sp])')];
                    b=eval(adaptorInfo.ObjectConstructorName{inLp,inLp2});
                    dispCapture = [dispCapture evalc('b') cr];
                    dispCapture = [dispCapture evalc('daqhwinfo(b)')];
                    delete(b);
                 catch
                    dispCapture = [dispCapture evalc('disp([cr,''Error creating '' adaptorInfo.ObjectConstructorName{inLp,inLp2} '' object for adaptor'' adaptors{lp}])')];
                    dispCapture = [dispCapture evalc('disp(lasterr)')];
                 end % try
              end %if ~isempty(adaptorInfo.ObjectConstructorName{inLp})
          end %for inLp2
     end %for inLp
   end % if ~isempty(adaptorInfo)
   
end % for lp

dispCapture = [dispCapture evalc(['disp([cr,sp,sp,''End test'',sp,sp]),',...
            'disp([cr,''This information has been saved in the text file:'',cr,filename]),',...
            'disp([cr,''If any errors occurred, please e-mail this information to:'',cr,''support@mathworks.com''])'])];

fprintf(fid,'%s',dispCapture);,
fclose(fid);

warning(OldWarningState);

edit(filename)
% end daqsupport