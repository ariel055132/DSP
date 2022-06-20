clc;
clear all;
 
% Load mat file (L1R1 and L1R0)
load("HHT\HHT Lab Data\HHT_Lab\driver_data_L1R0.mat");
load("HHT\HHT Lab Data\HHT_Lab\driver_data_L1R1.mat");

% declare empty variable
HHT_data_L1R1 = [];
HHT_data_L1R0 = [];

% for each sample (L1R1)
for i=1:length(driver_data_L1R1) 
        temp_column = driver_data_L1R1{i}(:,2);
 
        % EMD process
        [arr_time, arr_inst_freq, arr_inst_ampl] = hht_extraction(temp_column);

        % HHT Spectrum
        [res_ampl, res_freq, res_time] = spectrum_extraction(arr_time, arr_inst_freq, arr_inst_ampl, false);

        % concat all the data
        HHT_data_L1R1 = padconcatenation(HHT_data_L1R1, [res_time res_ampl'],1);
end 

% for each sample (L1R0)
for i=1:length(driver_data_L1R0) 
        temp_column = driver_data_L1R0{i}(:,2);
 
        % EMD process
        [arr_time, arr_inst_freq, arr_inst_ampl] = hht_extraction(temp_column);

        % HHT Spectrum
        [res_ampl, res_freq, res_time] = spectrum_extraction(arr_time, arr_inst_freq, arr_inst_ampl, false);

    % concat all the data
    HHT_data_L1R0 = padconcatenation(HHT_data_L1R0, [res_time res_ampl'],1);
end 

% Visualization data
figure
imagesc(HHT_data_L1R1(1:size(HHT_data_L1R1,1),2:25)');
set(gca,'YDir','normal'); caxis([-10 6]); 
colorbar;
colormap('jet');

figure
imagesc(HHT_data_L1R0(1:size(HHT_data_L1R0,1),2:25)');
set(gca,'YDir','normal'); caxis([-10 6]); 
colorbar;
colormap('jet');

% save result to mat file
save("HHT\HHT Lab Data\HHT_Lab\HHT_data_L1R1.mat", 'HHT_data_L1R1');
save("HHT\HHT Lab Data\HHT_Lab\HHT_data_L1R0.mat", 'HHT_data_L1R0');

