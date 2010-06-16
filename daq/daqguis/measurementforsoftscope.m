function out = measurementforsoftscope(fcn, data, object);
%MEASUREMENTFORSOFTSCOPE Helper function used by Data Acquisition Toolbox oscilloscope.
%
%   MEASUREMENTFORSOFTSCOPE helper function used by Data Acquisition Toolbox 
%   oscilloscope. MEASUREMENTFORSOFTSCOPE is used by the oscilloscope to calculate
%   the measurement values.
%  
%   This function should not be called directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 10-03-01
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.5.2.4 $  $Date: 2004/07/30 01:56:57 $

% Evaluate the measurement with the given data. fcn is the Measurement Type.
% data contains the data from the Measurement Channel.
if any(strcmp(fcn, {'frequency', 'period'})) 
    out = {feval(fcn, data, object)};
elseif (any(strcmp(fcn, {'max', 'min'})))
    [val, ind] = feval(fcn, data); 
    out = {val ind};
else
    out = {feval(fcn, data)};
end

% ---------------------------------------------------------------------
% Calculate the frequency of the waveform.
function out = frequency(data, object)
if isempty(object)
    out = [];
    return;
end

%% Only evaluate data from the first mean crossing to the
%% last
[firstzero,lastzero] = localDaqCrossPt(data);

% If there isn't enough data to calculate, return NaN
if(firstzero == 0 | lastzero == 0 | firstzero == lastzero)
    out = nan;
    return
end

%%
% Calculate the fft of the data.
xfft = abs(fft(data(firstzero:lastzero)));
[ymax, idx] = max(xfft);
N=length(xfft);
Fs = get(object, 'SampleRate');
freq=[0:Fs/N:Fs-1/N];
out = freq(idx);

%% ***********************************************************************  
% Calculate the first & last crosspoints over the mean of the data.
function [firstcross, lastcross] = localDaqCrossPt(data)

firstcross = 0;
crossvalue = mean(data);
for i = 2:length(data)
    if(data(i-1) > crossvalue & data(i) < crossvalue)
        firstcross = i;
        break;
    end
end

lastcross = 0;
for i = length(data):-1:2
    if(data(i-1) > crossvalue & data(i) < crossvalue)
        lastcross = i;
        break;
    end
end

% ---------------------------------------------------------------------
% Calculate the peak to peak value of the waveform.
function out = peak2peak(data)

out =  max(data)-min(data);

% ---------------------------------------------------------------------
% Calculate the period of the waveform.
function out = period(data, object)

freq = frequency(data, object);
if isempty(freq)
    out = [];
else
    out = 1/freq;
end

% ---------------------------------------------------------------------
% Calculate the rms value of the waveform.
function out = rms(data)

out = sqrt(mean(data .* data));
