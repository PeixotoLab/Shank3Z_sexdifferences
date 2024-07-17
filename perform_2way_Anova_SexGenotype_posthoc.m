function [p_vals,sig_difference,ANOVA_table] = perform_2way_Anova_SexGenotype_posthoc(Female_WT,Female_Mut,Male_WT,Male_Mut)
% 
% This function reads in the data in structs like Twelve_hour_avg_percentages_Female.WT.BL.First12hrs.Wake, etc
% and runs a 2-way ANOVA for sex and genotype.  If any effects are significant, it follows up with a post-hoc 
% test 
% This can be used to add asterisks or hashtags to plots 



% --- Male data ------------------------------
% --- Perform 1-way ANOVA (or a simple t-test)
if isempty(Female_WT) & isempty(Female_Mut)
	Output_variable = [Male_WT';Male_Mut'];
	Genotype = [repmat({'WT'},length(Male_WT),1); ...
	   			repmat({'Mut'},length(Male_Mut),1)];

	% I know I don't need to use anovan for this, but it was easier to copy from below
	[p,tbl,stats,terms] = anovan(Output_variable,{Genotype},'varnames','Genotype','display','off');

	[h,p_ttest_Male_WTVsMut] = ttest2(Male_WT,Male_Mut);  % 1-way ANOVA is the same as a t-test

	% Sanity check: 1-way ANOVA and ttest2 should give you the same p-value
	if abs(p-p_ttest_Male_WTVsMut)>1e-5 
		error('In perform_2way_Anova_SexGenotype_posthoc: one-way ANOVA and ttest2 gave different p-values.')
	end 


	p_vals.Male.ANOVA.Sex = zeros(0);
	p_vals.Male.ANOVA.Genotype = p(1);
	p_vals.Male.ANOVA.GenotypeXSex = zeros(0);

	p_vals.Posthoc.Male.WTvsMut     = p(1);
	p_vals.Posthoc.Female.WTvsMut   = zeros(0);
	p_vals.Posthoc.WT.MalevsFemale  = zeros(0);
	p_vals.Posthoc.Mut.MalevsFemale = zeros(0);

	sig_difference.Male.WTvsMut     = p_ttest_Male_WTVsMut     < 0.05;
	sig_difference.Female.WTvsMut   = [];
	sig_difference.WT.MalevsFemale  = [];
	sig_difference.Mut.MalevsFemale = [];

	ANOVA_table.Male.Genotype = tbl;

	p_vals.Female.ANOVA.Genotype 	= zeros(0);
	p_vals.BothMandF.ANOVA.Genotype = zeros(0); 
	ANOVA_table.Female.Genotype 	= []; 

% --- The Case Where Both Sexes are present -----------------------------------
% create a vector of all the concatenated output data
elseif ~isempty(Female_WT) & ~isempty(Female_Mut)
	Output_variable = [Female_WT';...
				   Female_Mut';...
				   Male_WT';...
				   Male_Mut'];

	sex = [repmat({'Female'},length(Female_WT),1); ...
	   repmat({'Female'},length(Female_Mut),1); ...
	   repmat({'Male'},length(Male_WT),1); ...
	   repmat({'Male'},length(Male_Mut),1)];


	% Set up Genotype vector to be 'WT','WT','WT'... 'Mut','Mut','Mut'
	Genotype = [repmat({'WT'},length(Female_WT),1); ...
		repmat({'Mut'},length(Female_Mut),1); ...
		repmat({'WT'},length(Male_WT),1); ...
		repmat({'Mut'},length(Male_Mut),1)];

	sex = categorical(sex);
	Genotype = categorical(Genotype);




	[p,tbl,stats,terms] = anovan(Output_variable,{sex Genotype},'model',2,'varnames',{'Sex','Genotype'},'display','off');

	

	% Set up the post-hoc values as empty
	p_ttest_WT_MaleVsFemale  = zeros(0);
	p_ttest_Mut_MaleVsFemale = zeros(0);
	p_ttest_Male_WTVsMut     = zeros(0);
	p_ttest_Female_WTVsMut   = zeros(0);

	if p(1) < 0.05   % if sex is a significant factor, do t-tests between sexes for each genotype
		[h,p_ttest_WT_MaleVsFemale]  = ttest2(Female_WT,Male_WT);
		[h,p_ttest_Mut_MaleVsFemale] = ttest2(Female_Mut,Male_Mut);
	end 

	

	if p(2) < 0.05 % if genotype is a significant factor, do t-tests between genotypes for each sex
		[h,p_ttest_Male_WTVsMut]   = ttest2(Male_WT,Male_Mut);
		[h,p_ttest_Female_WTVsMut] = ttest2(Female_WT,Female_Mut);
	end 

	if p(3) < 0.05 % if the interaction term is significant, do t-tests between genotypes for each sex and between sex for each genotype
		[h,p_ttest_WT_MaleVsFemale]  = ttest2(Female_WT,Male_WT);
		[h,p_ttest_Mut_MaleVsFemale] = ttest2(Female_Mut,Male_Mut);
		[h,p_ttest_Male_WTVsMut]     = ttest2(Male_WT,Male_Mut);
		[h,p_ttest_Female_WTVsMut]   = ttest2(Female_WT,Female_Mut);
	end 

	




	p_vals.BothMandF.ANOVA.Sex = p(1);
	p_vals.BothMandF.ANOVA.Genotype = p(2);
	p_vals.BothMandF.ANOVA.GenotypeXSex = p(3);


	% concatenate all p_ttest values into one vector
	T = table;
	T.pvals = cell(4,1);
	T.pvals{1} = p_ttest_WT_MaleVsFemale;
	T.pvals{2} = p_ttest_Mut_MaleVsFemale; 
	T.pvals{3} = p_ttest_Male_WTVsMut;
	T.pvals{4} = p_ttest_Female_WTVsMut;
	T.name{1}  = 'WT_MaleVsFemale';
	T.name{2}  = 'Mut_MaleVsFemale';
	T.name{3}  = 'Male_WTVsMut';
	T.name{4}  = 'Female_WTVsMut';
	T.name = categorical(T.name);
	T.isempty = cellfun('isempty',T.pvals);

	% run the vector through mafdr
	if sum(T.isempty)<4   % if at least one of the post-hocs were computed, adjust with mafdr
		adj_pvals = mafdr(cell2mat(T.pvals),'BHFDR','true');
		T.pvals(T.isempty==0) = num2cell(adj_pvals);
	end 

	% return both the unadjusted and adjusted p-values
	% Set up structures first
	% Male WT vs Mut
	M_WTvsMut_cell = cell(2);
	M_WTvsMut_cell{1,1} = 'Unadjusted';
	M_WTvsMut_cell{2,1} = p_ttest_Male_WTVsMut;  
	M_WTvsMut_cell{1,2} = 'Adjusted';
	M_WTvsMut_cell{2,2} = T.pvals{T.name=='Male_WTVsMut'};

	% Female WT vs Mut
	F_WTvsMut_cell = cell(2);
	F_WTvsMut_cell{1,1} = 'Unadjusted';
	F_WTvsMut_cell{2,1} = p_ttest_Female_WTVsMut;  
	F_WTvsMut_cell{1,2} = 'Adjusted';
	F_WTvsMut_cell{2,2} = T.pvals{T.name=='Female_WTVsMut'};

	% WT Male vs Female
	WT_MvsF_cell = cell(2);
	WT_MvsF_cell{1,1} = 'Unadjusted';
	WT_MvsF_cell{2,1} = p_ttest_WT_MaleVsFemale;
	WT_MvsF_cell{1,2} = 'Adjusted';
	WT_MvsF_cell{2,2} = T.pvals{T.name=='WT_MaleVsFemale'};

	% Mut Male vs Female
	Mut_MvsF_cell = cell(2);
	Mut_MvsF_cell{1,1} = 'Unadjusted';
	Mut_MvsF_cell{2,1} = p_ttest_Mut_MaleVsFemale;
	Mut_MvsF_cell{1,2} = 'Adjusted';
	Mut_MvsF_cell{2,2} = T.pvals{T.name=='Mut_MaleVsFemale'};

	p_vals.Posthoc.Male.WTvsMut     = cell2table(M_WTvsMut_cell(2,:),'VariableNames',M_WTvsMut_cell(1,:));
	p_vals.Posthoc.Female.WTvsMut   = cell2table(F_WTvsMut_cell(2,:),'VariableNames',F_WTvsMut_cell(1,:));
	p_vals.Posthoc.WT.MalevsFemale  = cell2table(WT_MvsF_cell(2,:),'VariableNames',WT_MvsF_cell(1,:));
	p_vals.Posthoc.Mut.MalevsFemale = cell2table(Mut_MvsF_cell(2,:),'VariableNames',Mut_MvsF_cell(1,:));

	% if either value is empty, make it NaN not a 0x0 cell because of if statements later. Matlab complains
	if iscell(p_vals.Posthoc.Male.WTvsMut.Unadjusted) 
		p_vals.Posthoc.Male.WTvsMut.Unadjusted = NaN;
	end 
	if iscell(p_vals.Posthoc.Male.WTvsMut.Adjusted) 
		p_vals.Posthoc.Male.WTvsMut.Adjusted = NaN;
	end 
	if iscell(p_vals.Posthoc.Female.WTvsMut.Unadjusted) 
		p_vals.Posthoc.Female.WTvsMut.Unadjusted = NaN;
	end 
	if iscell(p_vals.Posthoc.Female.WTvsMut.Adjusted) 
		p_vals.Posthoc.Female.WTvsMut.Adjusted = NaN;
	end 
	if iscell(p_vals.Posthoc.WT.MalevsFemale.Unadjusted)
		p_vals.Posthoc.WT.MalevsFemale.Unadjusted = NaN;
	end
	if iscell(p_vals.Posthoc.WT.MalevsFemale.Adjusted)
		p_vals.Posthoc.WT.MalevsFemale.Adjusted = NaN;
	end
	if iscell(p_vals.Posthoc.Mut.MalevsFemale.Unadjusted)
		p_vals.Posthoc.Mut.MalevsFemale.Unadjusted = NaN;
	end
	if iscell(p_vals.Posthoc.Mut.MalevsFemale.Adjusted)
		p_vals.Posthoc.Mut.MalevsFemale.Adjusted = NaN;
	end

	

	sig_difference.Male.WTvsMut     = p_ttest_Male_WTVsMut     < 0.05;
	sig_difference.Female.WTvsMut   = p_ttest_Female_WTVsMut   < 0.05;
	sig_difference.WT.MalevsFemale  = p_ttest_WT_MaleVsFemale  < 0.05;
	sig_difference.Mut.MalevsFemale = p_ttest_Mut_MaleVsFemale < 0.05;

	ANOVA_table.SexGenotype = tbl;


else 
	error('Something went wrong in perform_2way_Anova_SexGenotype_posthoc.m: You did not have Male+Female data or only Male.')
end 
