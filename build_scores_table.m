function all_scores_table = build_scores_table(Scores_struct)
%
% USAGE: all_scores_table = build_scores_table(Scores_struct)
%
% This function reads in the struct Scores_struct that was created by calls to Extract_EEG_data.m
% and changes the data from a multi-level struct into a table 
% with the following columns:  scores 	Sex		WTorMut		BLorSD
%
% INPUT: 		Scores_struct 		with the following structure: Scores_struct.Male.WT.SD or Scores_struct.Female.Mut.BL  
% 
% This way it will be easy to filter for the different combinations later on. 


% Initialize  the table
all_scores_table = table('Size',[1,4],...
    'VariableNames',{'Scores','Sex','WTorMut','BLorSD'},...
    'VariableTypes',{'cell','cellstr','cellstr','cellstr'});

% Male 
% Male WT BL
for i=1:length(Scores_struct.Male.WT.BL)
	scores_cell = {Scores_struct.Male.WT.BL{i},'M','WT','BL'};
	all_scores_table = [all_scores_table; scores_cell];  
end 

% Male WT SD
for i=1:length(Scores_struct.Male.WT.SD)
	scores_cell = {Scores_struct.Male.WT.SD{i},'M','WT','SD'};
	all_scores_table = [all_scores_table; scores_cell];  
end 

% Male Mut BL
for i=1:length(Scores_struct.Male.Mut.BL)
	scores_cell = {Scores_struct.Male.Mut.BL{i},'M','Mut','BL'};
	all_scores_table = [all_scores_table; scores_cell];
end   


% Male Mut SD
for i=1:length(Scores_struct.Male.Mut.SD)
	scores_cell = {Scores_struct.Male.Mut.SD{i},'M','Mut','SD'};
	all_scores_table = [all_scores_table; scores_cell];
end   



% -- Female --  
% Female WT BL
for i=1:length(Scores_struct.Female.WT.BL)
	scores_cell = {Scores_struct.Female.WT.BL{i},'F','WT','BL'};
	all_scores_table = [all_scores_table; scores_cell];  
end 

% Female WT SD
for i=1:length(Scores_struct.Female.WT.SD)
	scores_cell = {Scores_struct.Female.WT.SD{i},'F','WT','SD'};
	all_scores_table = [all_scores_table; scores_cell];  
end 

% Female Mut BL
for i=1:length(Scores_struct.Female.Mut.BL)
	scores_cell = {Scores_struct.Female.Mut.BL{i},'F','Mut','BL'};
	all_scores_table = [all_scores_table; scores_cell];  
end 

% Female Mut SD
for i=1:length(Scores_struct.Female.Mut.SD)
	scores_cell = {Scores_struct.Female.Mut.SD{i},'F','Mut','SD'};
	all_scores_table = [all_scores_table; scores_cell];  
end 

all_scores_table(1,:) = [];  % remove first row since it is empty
all_scores_table.BLorSD  = categorical(all_scores_table.BLorSD);
all_scores_table.Sex     = categorical(all_scores_table.Sex);
all_scores_table.WTorMut = categorical(all_scores_table.WTorMut);











