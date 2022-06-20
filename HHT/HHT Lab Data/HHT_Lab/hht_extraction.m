function [arr_time, arr_inst_freq, arr_inst_ampl] = hht_extraction(SIGNAL)

% definitions
x = SIGNAL;
Fs = 50;

% get EMDs of the signal
imf = eemd(x,0,1); % newly used EEMD, built by Prof. Huang
imf = num2cell(imf(:,1:(size(imf,2)-1))',2)'; % convert array structure to cell
% imf = num2cell(imf(:,2:(size(imf,2)-1))',2)';
% definitions for plotting the EMDs
M = length(imf);

% freqMean = [];
arr_inst_freq = [];
arr_inst_ampl = [];

for k = 1:M
       
   z = hilbert(imf{k});
   instfreq = Fs/(2*pi)*diff(unwrap(angle(z))); %CORRECT, FOR OLD EMD

%        ymean = mean(instfreq);
%        freqMean = [freqMean ymean];
   arr_inst_freq = [arr_inst_freq; instfreq];
   arr_inst_ampl = [arr_inst_ampl; abs(z)];
       
end


arr_time = repmat(1:1:length(x), length(arr_inst_freq(:,1)), 1);
arr_inst_freq(:,end+1) = arr_inst_freq(:,end); %because lose 1 

end