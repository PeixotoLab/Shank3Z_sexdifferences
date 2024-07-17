function fig_handle = plot_output_var_M_vs_F_WT_vs_Mut(Twelve_hour_avg_values_Male,Twelve_hour_avg_values_Female,outcome_var,p_vals_struct,BLorSD,First12hrsOrLast12hrs,SleepStage,LegendLabels)
%
% USAGE: fig_handle = plot_output_var_M_vs_F_WT_vs_Mut(Twelve_hour_avg_values_Male,Twelve_hour_avg_values_Female,outcome_var,p_vals_struct,BLorSD,First12hrsOrLast12hrs,SleepStage)
%
% This function makes a plot with dots at 4 horizontal locations: Male+WT, Male+Mutant, Female+WT, Female+Mutant, 
% vertical axis is  one of the following (based on outcome_var): 
% 							percentage of time in the particular arousal state (comparing means across Sex+Genotype combos)
% 							bout counts    
% 							bout durations 

% either for the light phase (first12hrs) or dark phase (Last12hrs) and BL or SD.
%
% INPUTS: SleepStage: 		options are 'Wake', 'NREM' or 'REM'
%					LegendLabels: 	a 2-element cell array like {'WT','Mut'} for instance


% Handle the case where no female data is present
if isempty(Twelve_hour_avg_values_Female)
	NoFemaleData = true; 
	Twelve_hour_avg_values_Female.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage) =[];
	Twelve_hour_avg_values_Female.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage) =[];
else 
	NoFemaleData = false;
end 

if strcmp(SleepStage,'WAKE')
	SleepStage_for_ylabel = upper(SleepStage);  % convert Wake to WAKE for y label boldface part
else
	SleepStage_for_ylabel = SleepStage; 
end 


% Set up labels for the vertical axis, based on the output variable and the arousal state
if strcmp(outcome_var,'Percentages')
	y_label_string = {strcat('{\bf ',SleepStage_for_ylabel,'}');['Time in ', SleepStage, ' (% TRT)']};
elseif strcmp(outcome_var,'Bout_Counts')
	y_label_string = {strcat('{\bf ',SleepStage_for_ylabel,'}');['Avg Bouts/hr']};
elseif strcmp(outcome_var,'Bout_Durations')
	y_label_string = {strcat('{\bf ',SleepStage_for_ylabel,'}');['Bout Duration (min)']};
else
	error('In plot_output_var_M_vs_F_WT_vs_Mut.m: you entered an outcome_var that is invalid.  Options are ''Percentages'', ''Bout_Counts'', or ''Bout_Durations'' ')
end 



% Extract the relevant p-values from the p-vals struct
if strcmp(First12hrsOrLast12hrs,'First12hrs')
  	LPorDP = 'LP';
  elseif strcmp(First12hrsOrLast12hrs,'Last12hrs')
  	LPorDP = 'DP';
  else
  	error('Invalid entry for First12hrsOrLast12hrs in plot_time_in_state_M_vs_F_WT_vs_Mut.')
end 


if ~strcmp(outcome_var,'Percentages')  % If not doing Percentages
	if NoFemaleData
		p_val.Male.WTvsMut.Adjusted   = p_vals_struct.Male.(BLorSD).(LPorDP).(SleepStage).ANOVA.Genotype; % plotting code needs adj or un, but if only one sex, these are the same
		p_val.Male.WTvsMut.Unadjusted = p_vals_struct.Male.(BLorSD).(LPorDP).(SleepStage).ANOVA.Genotype;
	else 
		p_val.Male.WTvsMut = p_vals_struct.Male.(BLorSD).(LPorDP).(SleepStage);   % if Female data present, we did a 2-way ANOVA first, then only post-hocs if p-vals were small
	end  

	p_val.Female.WTvsMut   = p_vals_struct.Female.(BLorSD).(LPorDP).(SleepStage).WTvsMut; 
	p_val.WT.MaleVsFemale  = p_vals_struct.BothMandF.(BLorSD).(LPorDP).(SleepStage).Posthocs.WT_MaleVsFemale;
	p_val.Mut.MaleVsFemale = p_vals_struct.BothMandF.(BLorSD).(LPorDP).(SleepStage).Posthocs.Mut_MaleVsFemale; 

else 	% for the case where Percentages is output var
 	if NoFemaleData
		%use p vals from repeated measures ANOVAs (need adjusted and un because of plotting code later. Same if no female data present)
		p_val.Male.WTvsMut.Adjusted   = p_vals_struct.Male.(BLorSD).(LPorDP).(SleepStage).Posthocs.WTvsMut;
		p_val.Male.WTvsMut.Unadjusted = p_vals_struct.Male.(BLorSD).(LPorDP).(SleepStage).Posthocs.WTvsMut;
		p_val.Female.WTvsMut   = [];
		p_val.WT.MaleVsFemale  = [];
		p_val.Mut.MaleVsFemale = [];

	else   % Percentages and both sexes present
		 p_val.WT.MaleVsFemale  = p_vals_struct.(BLorSD).(LPorDP).(SleepStage).Posthocs.WT_MvsF;
		 p_val.Mut.MaleVsFemale = p_vals_struct.(BLorSD).(LPorDP).(SleepStage).Posthocs.Mut_MvsF;
		 p_val.Female.WTvsMut   = p_vals_struct.(BLorSD).(LPorDP).(SleepStage).Posthocs.F_WTvsMut;
		 p_val.Male.WTvsMut     = p_vals_struct.(BLorSD).(LPorDP).(SleepStage).Posthocs.M_WTvsMut;
	end
end


% --- Counts per group -----
N_male_WT   = length(Twelve_hour_avg_values_Male.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage));
N_female_WT = length(Twelve_hour_avg_values_Female.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage)); 

N_male_Mut   = length(Twelve_hour_avg_values_Male.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage));
N_female_Mut = length(Twelve_hour_avg_values_Female.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage)); 

% --- Means ------------------------------
Mean_M_WT  = mean(Twelve_hour_avg_values_Male.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage));
Mean_M_Mut = mean(Twelve_hour_avg_values_Male.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage));
Mean_F_WT  = mean(Twelve_hour_avg_values_Female.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage));
Mean_F_Mut = mean(Twelve_hour_avg_values_Female.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage));


% -----------------------------------------------------------
figure

axis_linewidth = 2; 
myfontsize = 16;

f=gcf;
f.Renderer = 'painters';
p=plot(1*ones(1,N_male_WT),Twelve_hour_avg_values_Male.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage),  'ko',2*ones(1,N_male_Mut),Twelve_hour_avg_values_Male.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage),  'ro', ...
	 3*ones(1,N_female_WT),Twelve_hour_avg_values_Female.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage),'ko',4*ones(1,N_female_Mut),Twelve_hour_avg_values_Female.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage),'ro');
ax=gca();
ax.XLim = [0 5];
all_data_in_plot = [Twelve_hour_avg_values_Male.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage),  Twelve_hour_avg_values_Female.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage), ...
										Twelve_hour_avg_values_Male.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage), Twelve_hour_avg_values_Female.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage)];
ax.YLim  = [0 1.2*max(all_data_in_plot)];
ax.XTick = [];
ax.FontSize = myfontsize;
ax.Box = 'off';
ax.Color = 'none';
ax.LineWidth = axis_linewidth;
ax.TickDir = 'out';
%ax.YLabel.String = {strcat('{\bf ',SleepStage_for_ylabel,'}');['Time in ', SleepStage, ' (% TRT)']};
ax.YLabel.String = y_label_string;
ax.XTick = [1.5 3.5];
ax.XTickLabel = {'Males','Females'};
ax.XAxis.TickLength = [0 0];
if strcmp(First12hrsOrLast12hrs,'Last12hrs')
	ax.Color = [0.9 0.9 0.9];  % Use a light gray background if plotting dark phase
end  
for i=1:length(p)
	p(i).LineWidth = 3;
	p(i).MarkerSize = 12;
end 
p(1).MarkerFaceColor = 'k';
p(2).MarkerFaceColor = 'r';
hold on
line1 = line([0.85 1.15],[Mean_M_WT Mean_M_WT]);
line1.Color =[0.8 0.8 0.8];
line1.LineWidth = 6;
line2 = line([1.85 2.15],[Mean_M_Mut Mean_M_Mut]);
line2.Color =[0.8 0.8 0.8];
line2.LineWidth = 6;
line3 = line([2.85 3.15],[Mean_F_WT Mean_F_WT]);
line3.Color =[0.8 0.8 0.8];
line3.LineWidth = 6;
line4 = line([3.85 4.15],[Mean_F_Mut Mean_F_Mut]);
line4.Color =[0.8 0.8 0.8];
line4.LineWidth = 6;


% --- add * and # if significant interactions ---
vert_fudge_factor1  = 5;
vert_fudge_factor2  = 8;
asterisk_FontSize  = 24;
sig_line_thickness = 1.5;

% Male WTvsMut
if p_val.Male.WTvsMut.Adjusted < 0.05    & p_val.Male.WTvsMut.Adjusted >=0.01
	symbol.MaleWTVsMut = '*';
elseif p_val.Male.WTvsMut.Adjusted <0.01 & p_val.Male.WTvsMut.Adjusted >=0.001
	symbol.MaleWTVsMut = '**';
elseif p_val.Male.WTvsMut.Adjusted < 0.001
	symbol.MaleWTVsMut = '***';
end 

y_loc = 1.1*max(all_data_in_plot);

% add the p-value for males WT vs Mut (if you only have Male data)
if NoFemaleData
	if p_val.Male.WTvsMut.Adjusted < 0.01 p_val_displayed = '< 0.01'; else p_val_displayed = ['= ',num2str(p_val.Male.WTvsMut.Adjusted,'%.2f')]; end  
	text(ax,1.5,ax.YLim(2),['p value ',p_val_displayed],'FontSize',14,'HorizontalAlignment','center');
end

if ~NoFemaleData  % If female data are present
	
	

	% Set up the symbols

	% Female WTvsMut
	if p_val.Female.WTvsMut.Adjusted < 0.05    & p_val.Female.WTvsMut.Adjusted >=0.01
		symbol.FemaleWTVsMut = '*';
	elseif p_val.Female.WTvsMut.Adjusted <0.01 & p_val.Female.WTvsMut.Adjusted >=0.001
		symbol.FemaleWTVsMut = '**';
	elseif p_val.Female.WTvsMut.Adjusted < 0.001
		symbol.FemaleWTVsMut = '***';
	end 

	% WT Male vs Female
	if p_val.WT.MaleVsFemale.Adjusted < 0.05    & p_val.WT.MaleVsFemale.Adjusted >=0.01
		symbol.WTMaleVsFemale = '#';
	elseif p_val.WT.MaleVsFemale.Adjusted <0.01 & p_val.WT.MaleVsFemale.Adjusted >=0.001
		symbol.WTMaleVsFemale = '##';
	elseif p_val.WT.MaleVsFemale.Adjusted < 0.001
		symbol.WTMaleVsFemale = '###';
	end 

	% Mut Male vs Female
	if p_val.Mut.MaleVsFemale.Adjusted < 0.05    & p_val.Mut.MaleVsFemale.Adjusted >=0.01
		symbol.MutMaleVsFemale = '#';
	elseif p_val.Mut.MaleVsFemale.Adjusted <0.01 & p_val.Mut.MaleVsFemale.Adjusted >=0.001
		symbol.MutMaleVsFemale = '##';
	elseif p_val.Mut.MaleVsFemale.Adjusted < 0.001
		symbol.MutMaleVsFemale = '###';
	end 

	% add black asterisks for genotype differences within Sex
	% Male asterisks
	if p_val.Male.WTvsMut.Adjusted < 0.05
		y_loc = max([Twelve_hour_avg_values_Male.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage) ...
		 			 Twelve_hour_avg_values_Male.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage)])+vert_fudge_factor1;
			
		y_loc = 1.1*max(all_data_in_plot);
		if y_loc>ax.YLim(2) y_loc=ax.YLim(2); end 
		text(ax,1.5,y_loc,symbol.MaleWTVsMut,'FontSize',asterisk_FontSize,'HorizontalAlignment','center');
		plot(ax,[1,2],[y_loc,y_loc],'k','LineWidth',sig_line_thickness);
	end 

	% Female asterisks
	if p_val.Female.WTvsMut.Adjusted < 0.05
		y_loc = max([Twelve_hour_avg_values_Female.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage) ...
		 			 Twelve_hour_avg_values_Female.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage)])+vert_fudge_factor1;
		if y_loc>ax.YLim(2) y_loc=ax.YLim(2); end 
		text(ax,3.5,y_loc,symbol.FemaleWTVsMut,'FontSize',asterisk_FontSize,'HorizontalAlignment','center');
		plot(ax,[3,4],[y_loc,y_loc],'k','LineWidth',sig_line_thickness);
	end 

	% WT # M vs F
	if p_val.WT.MaleVsFemale.Adjusted < 0.05
		y_loc = max([Twelve_hour_avg_values_Male.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage) ...
		 			 Twelve_hour_avg_values_Female.WT.(BLorSD).(First12hrsOrLast12hrs).(SleepStage)])+vert_fudge_factor2;
		if y_loc>ax.YLim(2) y_loc=ax.YLim(2); end 
		text(ax,2,y_loc,symbol.WTMaleVsFemale,'FontSize',asterisk_FontSize,'Color','red','HorizontalAlignment','center','VerticalAlignment','bottom');
		plot(ax,[1,3],[y_loc,y_loc],'r','LineWidth',sig_line_thickness);
	end

	% Mut # M vs F 
	if p_val.Mut.MaleVsFemale.Adjusted < 0.05
		y_loc = max([Twelve_hour_avg_values_Male.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage) ...
		 			 Twelve_hour_avg_values_Female.Mut.(BLorSD).(First12hrsOrLast12hrs).(SleepStage)])+vert_fudge_factor2;
		if y_loc>ax.YLim(2) y_loc=ax.YLim(2); end 
		text(ax,3,y_loc,symbol.MutMaleVsFemale,'FontSize',asterisk_FontSize,'Color','red','HorizontalAlignment','center','VerticalAlignment','bottom');
		plot(ax,[2,4],[y_loc,y_loc],'r','LineWidth',sig_line_thickness);
	end
end % end of if female data are present 


hold off
if strcmp(SleepStage,'Wake')  % Only add the legend if Wake (since it's the top graph)
	l=legend([p(1) p(2)],LegendLabels{1},LegendLabels{2});
	l.Box = 'off';
	l.Location = 'northwest';
	l.FontSize = myfontsize;
end 
ax.Title.String = strcat(SleepStage,{' '},BLorSD,{' '},First12hrsOrLast12hrs); % Add an informative title (feel free to delete this line)


% Handle the case where there is no female data change the x-axis limits so we don't see the "Female" empty spot
if NoFemaleData
	ax.XLim = [0 3];
	ax.XAxis.TickValues = [1 2];  % change the label on the x-axis from "Males" to "WT" and "Mut"
	ax.XAxis.TickLabels = LegendLabels; %{'WT';'Mut'}; 
end  




fig_handle = f;  % So you return the figure handle