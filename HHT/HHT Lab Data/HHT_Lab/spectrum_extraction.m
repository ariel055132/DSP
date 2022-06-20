function [plot_blocks, ax_freq, ax_time] = spectrum_extraction(arr_time, arr_inst_freq, arr_inst_ampl, do_plot)
%{
arr_inst_freq;
arr_inst_ampl;
arr_time;
%}
%{
figure;

for k1 = 1:length(arr_inst_freq(:,1))
    scatter(arr_time(k1,:), arr_inst_freq(k1,:));
    hold on;
end;
%}

arr_inst_freq = abs(arr_inst_freq);
arr_inst_ampl = abs(arr_inst_ampl);

freq_min = min(arr_inst_freq(:));
time_min = min(arr_time(:));
freq_max = max(arr_inst_freq(:));
time_max = max(arr_time(:));

% freq_length = roundn(abs(freq_max - freq_min), -1);
% ampl_length = roundn(abs(ampl_max - ampl_min) * 100, 1)/100 + 0.1;
%ampl_length = round(abs(ampl_max - ampl_min) / 1.5) * 1.5;

time_window = 125;
%freq_window = 2.5;
% freq_window = ((double(freq_max) - double(freq_min)) / 10);
freq_window = ((double(freq_max) - double(freq_min)) / 25);
%double(freq_max)+" "+double(freq_min)+" "+double(freq_window)

freq_blocks = [];
time_blocks = [];

time_counter = 0;
freq_counter = 0;



for k1 = 1:time_window:length(arr_time(1,:))
    time_blocks = [time_blocks time_counter];
    time_counter = time_counter + 1;
end

for k1 = freq_min:freq_window:freq_max
    freq_blocks = [freq_blocks freq_counter];
    freq_counter = freq_counter + 1;
end

plot_blocks = zeros(size(time_blocks,2),size(freq_blocks,2));

for k1=1:size(arr_inst_freq,1) % each component EMD
    for k2=1:size(arr_inst_freq(k1,:),2)-1 % each time
        time_block_target = ceil(k2 / time_window);
        %if(arr_inst_freq(k1, k2) >= 0)
        %    freq_block_target = ceil(arr_inst_freq(k1, k2) / freq_window);
        %else
            if(arr_inst_freq(k1, k2) == freq_min) 
                freq_block_target = 1;
            else
                freq_block_target = ceil((arr_inst_freq(k1, k2) + abs(freq_min)) / freq_window);
                if(freq_block_target > size(plot_blocks,2)) 
                    freq_block_target = size(plot_blocks,2); 
                elseif(freq_block_target < 1) 
                    freq_block_target = 1; 
                end
            end
        %end
        
        
        % summation
%         if((time_block_target == 1 )&&(  freq_block_target == 8 )&&(  k1 == 1 )&&(  k2==33))
%             flag=1;
%         end
        %"target "+time_block_target+" "+freq_block_target
        plot_blocks(time_block_target, freq_block_target) = ...
                plot_blocks(time_block_target, freq_block_target) ...
                + abs(arr_inst_ampl(k1, k2));
        
        %{
        % density
        plot_blocks(time_block_target, freq_block_target) = ...
            plot_blocks(time_block_target, freq_block_target) + 1;
        %}
    end
end

plot_blocks = smoothdata(plot_blocks,'gaussian',3); %smoothing data using gaussian method with window size = 3
plot_blocks = log(plot_blocks);
plot_blocks = replace_nan_inf(plot_blocks); %replace nan value with infinity max or min


ax_time = time_min:time_window:time_max;
ax_freq = freq_min:freq_window:freq_max;

plot_blocks = plot_blocks';

%for plotting
if(do_plot==true)
    figure;
    h = pcolor(plot_blocks);
    set(h, 'EdgeColor', 'none');
    colormap('Jet');
    %caxis([0 1300]);
    colorbar;

    ax = gca;
    %// adjust position of ticks
    set(ax,'XTick', (1:size(plot_blocks,2)) )
    set(ax,'YTick', (1:size(plot_blocks,1)) )
    %// set labels
    set(ax,'YTickLabel',ax_freq)
    set(gca,'fontsize',7)
    set(ax,'XTickLabel',ax_time')
end