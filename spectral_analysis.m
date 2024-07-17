function [pvals] = spectral_analysis(EEG_struct,SD_length_hrs,LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization,SeparateSpectralIntoLPDP)
%
% USAGE: [pvals] = spectral_analysis(EEG_struct,LegendLabels)
%
% where EEG_struct has the following field structure:  EEG_struct.WT.Male.BL.Wake
% where WT could be Mut, Male could be Female, BL could be SD, and Wake could be NREM or REM 
%
% This function produces figure panels plotting normalized EEG spectral power plotted with 
% frequency on the horizontal axis and % of total power on the vertical axis.  
%


% Do you have female data?
if isempty(EEG_struct.WT.Female.BL.Wake)
	FemaleDataPresent = 0;
else 
	FemaleDataPresent = 1;
end 


dx = unique(round(EEG_bin_edges(2:end)-EEG_bin_edges(1:end-1),4));  % the EEG bin size in Hz
if length(dx)>1 error('You have uneven EEG frequency bins.  Try again.');  end  


% First unpack the data structure into matrices (it's too confusing leaving it in structures)
% Male WT
EEG_Male_WT_BL_Wake = EEG_struct.WT.Male.BL.Wake; 
EEG_Male_WT_BL_NREM = EEG_struct.WT.Male.BL.NREM; 
EEG_Male_WT_BL_REM  = EEG_struct.WT.Male.BL.REM; 
EEG_Male_WT_SD_Wake = EEG_struct.WT.Male.SD.Wake(SD_length_hrs+1:24,:,:); 		% Remove the actual SD 
EEG_Male_WT_SD_NREM = EEG_struct.WT.Male.SD.NREM(SD_length_hrs+1:24,:,:); 
EEG_Male_WT_SD_REM  = EEG_struct.WT.Male.SD.REM(SD_length_hrs+1:24,:,:); 

% Male Mutants
EEG_Male_Mut_BL_Wake = EEG_struct.Mut.Male.BL.Wake; 
EEG_Male_Mut_BL_NREM = EEG_struct.Mut.Male.BL.NREM; 
EEG_Male_Mut_BL_REM  = EEG_struct.Mut.Male.BL.REM; 
EEG_Male_Mut_SD_Wake = EEG_struct.Mut.Male.SD.Wake(SD_length_hrs+1:24,:,:); 	% Remove the actual SD
EEG_Male_Mut_SD_NREM = EEG_struct.Mut.Male.SD.NREM(SD_length_hrs+1:24,:,:); 
EEG_Male_Mut_SD_REM  = EEG_struct.Mut.Male.SD.REM(SD_length_hrs+1:24,:,:); 

if FemaleDataPresent
	% Female WT
	EEG_Female_WT_BL_Wake = EEG_struct.WT.Female.BL.Wake; 
	EEG_Female_WT_BL_NREM = EEG_struct.WT.Female.BL.NREM; 
	EEG_Female_WT_BL_REM  = EEG_struct.WT.Female.BL.REM; 
	EEG_Female_WT_SD_Wake = EEG_struct.WT.Female.SD.Wake(SD_length_hrs+1:24,:,:);	% Remove the actual SD 
	EEG_Female_WT_SD_NREM = EEG_struct.WT.Female.SD.NREM(SD_length_hrs+1:24,:,:); 
	EEG_Female_WT_SD_REM  = EEG_struct.WT.Female.SD.REM(SD_length_hrs+1:24,:,:); 

	% Female Mutants
	EEG_Female_Mut_BL_Wake = EEG_struct.Mut.Female.BL.Wake; 
	EEG_Female_Mut_BL_NREM = EEG_struct.Mut.Female.BL.NREM; 
	EEG_Female_Mut_BL_REM  = EEG_struct.Mut.Female.BL.REM; 
	EEG_Female_Mut_SD_Wake = EEG_struct.Mut.Female.SD.Wake(SD_length_hrs+1:24,:,:); % Remove the actual SD
	EEG_Female_Mut_SD_NREM = EEG_struct.Mut.Female.SD.NREM(SD_length_hrs+1:24,:,:); 
	EEG_Female_Mut_SD_REM  = EEG_struct.Mut.Female.SD.REM(SD_length_hrs+1:24,:,:); 
end 


% First normalize by the "total state specific power across 24 hours of baseline" or sleepdep per animal (quotes from Lizzy's poster)
% perhaps put this in a function.  It's messy.  EEG_Normalized = normalize_EEG(EEG_struct) or something.  
% First compute the average per animal
% UPDATE 2.24:  After talking with Peter Achermann, normalize by area under the curve so the 
% area under the normalized curve is equal to 1.  
% These all used to be squeeze(mean(mean(EEG_Male_WT_BL_Wake,'omitnan'))); 
% UPDATE 3.28:  From Frank lab meeting: make the default to normalize to the power across all states (in BL?)
% 				and the option to normalize so area under the curve is 1.  

if strcmp(Normalization,'MeanPowerAllStates')
	All_States_ByAnimal.WT.BL.M  = [EEG_Male_WT_BL_Wake; EEG_Male_WT_BL_NREM; EEG_Male_WT_BL_REM];
	All_States_ByAnimal.WT.SD.M  = [EEG_Male_WT_SD_Wake; EEG_Male_WT_SD_NREM; EEG_Male_WT_SD_REM];
	All_States_ByAnimal.Mut.BL.M = [EEG_Male_Mut_BL_Wake; EEG_Male_Mut_BL_NREM; EEG_Male_Mut_BL_REM];
	All_States_ByAnimal.Mut.SD.M = [EEG_Male_Mut_SD_Wake; EEG_Male_Mut_SD_NREM; EEG_Male_Mut_SD_REM];

	% Male WT
	norm_by_animal_M_WT_BL_Wake = squeeze(mean(mean(All_States_ByAnimal.WT.BL.M,1,'omitnan'),2,'omitnan'));
	norm_by_animal_M_WT_BL_NREM = squeeze(mean(mean(All_States_ByAnimal.WT.BL.M,1,'omitnan'),2,'omitnan'));
	norm_by_animal_M_WT_BL_REM  = squeeze(mean(mean(All_States_ByAnimal.WT.BL.M,1,'omitnan'),2,'omitnan'));
	norm_by_animal_M_WT_SD_Wake = squeeze(mean(mean(All_States_ByAnimal.WT.SD.M,1,'omitnan'),2,'omitnan'));
	norm_by_animal_M_WT_SD_NREM = squeeze(mean(mean(All_States_ByAnimal.WT.SD.M,1,'omitnan'),2,'omitnan'));
	norm_by_animal_M_WT_SD_REM  = squeeze(mean(mean(All_States_ByAnimal.WT.SD.M,1,'omitnan'),2,'omitnan'));
	
	% Male Mut
	norm_by_animal_M_Mut_BL_Wake = squeeze(mean(mean(All_States_ByAnimal.Mut.BL.M,1,'omitnan'),2,'omitnan'));
	norm_by_animal_M_Mut_BL_NREM = squeeze(mean(mean(All_States_ByAnimal.Mut.BL.M,1,'omitnan'),2,'omitnan'));
	norm_by_animal_M_Mut_BL_REM  = squeeze(mean(mean(All_States_ByAnimal.Mut.BL.M,1,'omitnan'),2,'omitnan'));
	norm_by_animal_M_Mut_SD_Wake = squeeze(mean(mean(All_States_ByAnimal.Mut.SD.M,1,'omitnan'),2,'omitnan'));
	norm_by_animal_M_Mut_SD_NREM = squeeze(mean(mean(All_States_ByAnimal.Mut.SD.M,1,'omitnan'),2,'omitnan'));
	norm_by_animal_M_Mut_SD_REM  = squeeze(mean(mean(All_States_ByAnimal.Mut.SD.M,1,'omitnan'),2,'omitnan'));

	if FemaleDataPresent
		All_States_ByAnimal.WT.BL.F  = [EEG_Female_WT_BL_Wake;  EEG_Female_WT_BL_NREM;  EEG_Female_WT_BL_REM];
		All_States_ByAnimal.WT.SD.F  = [EEG_Female_WT_SD_Wake;  EEG_Female_WT_SD_NREM;  EEG_Female_WT_SD_REM];
		All_States_ByAnimal.Mut.BL.F = [EEG_Female_Mut_BL_Wake; EEG_Female_Mut_BL_NREM; EEG_Female_Mut_BL_REM];
		All_States_ByAnimal.Mut.SD.F = [EEG_Female_Mut_SD_Wake; EEG_Female_Mut_SD_NREM; EEG_Female_Mut_SD_REM];

		% Female WT
		norm_by_animal_F_WT_BL_Wake = squeeze(mean(mean(All_States_ByAnimal.WT.BL.F,1,'omitnan'),2,'omitnan'));
		norm_by_animal_F_WT_BL_NREM = squeeze(mean(mean(All_States_ByAnimal.WT.BL.F,1,'omitnan'),2,'omitnan'));
		norm_by_animal_F_WT_BL_REM  = squeeze(mean(mean(All_States_ByAnimal.WT.BL.F,1,'omitnan'),2,'omitnan'));
		norm_by_animal_F_WT_SD_Wake = squeeze(mean(mean(All_States_ByAnimal.WT.SD.F,1,'omitnan'),2,'omitnan'));
		norm_by_animal_F_WT_SD_NREM = squeeze(mean(mean(All_States_ByAnimal.WT.SD.F,1,'omitnan'),2,'omitnan'));
		norm_by_animal_F_WT_SD_REM  = squeeze(mean(mean(All_States_ByAnimal.WT.SD.F,1,'omitnan'),2,'omitnan'));
		
	% Female Mut
		norm_by_animal_F_Mut_BL_Wake = squeeze(mean(mean(All_States_ByAnimal.Mut.BL.F,1,'omitnan'),2,'omitnan'));
		norm_by_animal_F_Mut_BL_NREM = squeeze(mean(mean(All_States_ByAnimal.Mut.BL.F,1,'omitnan'),2,'omitnan'));
		norm_by_animal_F_Mut_BL_REM  = squeeze(mean(mean(All_States_ByAnimal.Mut.BL.F,1,'omitnan'),2,'omitnan'));
		norm_by_animal_F_Mut_SD_Wake = squeeze(mean(mean(All_States_ByAnimal.Mut.SD.F,1,'omitnan'),2,'omitnan'));
		norm_by_animal_F_Mut_SD_NREM = squeeze(mean(mean(All_States_ByAnimal.Mut.SD.F,1,'omitnan'),2,'omitnan'));
		norm_by_animal_F_Mut_SD_REM  = squeeze(mean(mean(All_States_ByAnimal.Mut.SD.F,1,'omitnan'),2,'omitnan'));
	end

elseif strcmp(Normalization,'AreaUnderCurve')
	% Male WT
	norm_by_animal_M_WT_BL_Wake = calc_normalization_factor(EEG_Male_WT_BL_Wake,dx);
	norm_by_animal_M_WT_BL_NREM = calc_normalization_factor(EEG_Male_WT_BL_NREM,dx);
	norm_by_animal_M_WT_BL_REM  = calc_normalization_factor(EEG_Male_WT_BL_REM,dx);
	norm_by_animal_M_WT_SD_Wake = calc_normalization_factor(EEG_Male_WT_SD_Wake,dx);
	norm_by_animal_M_WT_SD_NREM = calc_normalization_factor(EEG_Male_WT_SD_NREM,dx);
	norm_by_animal_M_WT_SD_REM  = calc_normalization_factor(EEG_Male_WT_SD_REM,dx);

	% Male Mut
	norm_by_animal_M_Mut_BL_Wake = calc_normalization_factor(EEG_Male_Mut_BL_Wake,dx);
	norm_by_animal_M_Mut_BL_NREM = calc_normalization_factor(EEG_Male_Mut_BL_NREM,dx);
	norm_by_animal_M_Mut_BL_REM  = calc_normalization_factor(EEG_Male_Mut_BL_REM,dx);
	norm_by_animal_M_Mut_SD_Wake = calc_normalization_factor(EEG_Male_Mut_SD_Wake,dx);
	norm_by_animal_M_Mut_SD_NREM = calc_normalization_factor(EEG_Male_Mut_SD_NREM,dx);
	norm_by_animal_M_Mut_SD_REM  = calc_normalization_factor(EEG_Male_Mut_SD_REM,dx);

	if FemaleDataPresent
		% Female WT
		norm_by_animal_F_WT_BL_Wake  = calc_normalization_factor(EEG_Female_WT_BL_Wake,dx);
		norm_by_animal_F_WT_BL_NREM  = calc_normalization_factor(EEG_Female_WT_BL_NREM,dx);
		norm_by_animal_F_WT_BL_REM   = calc_normalization_factor(EEG_Female_WT_BL_REM,dx);
		norm_by_animal_F_WT_SD_Wake  = calc_normalization_factor(EEG_Female_WT_SD_Wake,dx);
		norm_by_animal_F_WT_SD_NREM  = calc_normalization_factor(EEG_Female_WT_SD_NREM,dx);
		norm_by_animal_F_WT_SD_REM   = calc_normalization_factor(EEG_Female_WT_SD_REM,dx);

		% Female Mut
		norm_by_animal_F_Mut_BL_Wake = calc_normalization_factor(EEG_Female_Mut_BL_Wake,dx);
		norm_by_animal_F_Mut_BL_NREM = calc_normalization_factor(EEG_Female_Mut_BL_NREM,dx);
		norm_by_animal_F_Mut_BL_REM  = calc_normalization_factor(EEG_Female_Mut_BL_REM,dx);
		norm_by_animal_F_Mut_SD_Wake = calc_normalization_factor(EEG_Female_Mut_SD_Wake,dx);
		norm_by_animal_F_Mut_SD_NREM = calc_normalization_factor(EEG_Female_Mut_SD_NREM,dx);
		norm_by_animal_F_Mut_SD_REM  = calc_normalization_factor(EEG_Female_Mut_SD_REM,dx);
	end 

else
	error(['Invalid choice for Normalization.  Options are MeanPowerAllStates or AreaUnderCurve. You chose ',Normalization])
end  % end of choosing normalization


% Now reshape so we can use in bsxfun(@rdivide  ...)
% Male WT 
norm_matrix_Male_WT_BL_Wake = reshape(norm_by_animal_M_WT_BL_Wake,1,1,[]);   
norm_matrix_Male_WT_BL_NREM = reshape(norm_by_animal_M_WT_BL_NREM,1,1,[]);   
norm_matrix_Male_WT_BL_REM  = reshape(norm_by_animal_M_WT_BL_REM,1,1,[]);   
norm_matrix_Male_WT_SD_Wake = reshape(norm_by_animal_M_WT_SD_Wake,1,1,[]);   
norm_matrix_Male_WT_SD_NREM = reshape(norm_by_animal_M_WT_SD_NREM,1,1,[]);   
norm_matrix_Male_WT_SD_REM  = reshape(norm_by_animal_M_WT_SD_REM,1,1,[]);   

% Male Mut 
norm_matrix_Male_Mut_BL_Wake = reshape(norm_by_animal_M_Mut_BL_Wake,1,1,[]);   
norm_matrix_Male_Mut_BL_NREM = reshape(norm_by_animal_M_Mut_BL_NREM,1,1,[]);   
norm_matrix_Male_Mut_BL_REM  = reshape(norm_by_animal_M_Mut_BL_REM,1,1,[]);   
norm_matrix_Male_Mut_SD_Wake = reshape(norm_by_animal_M_Mut_SD_Wake,1,1,[]);   
norm_matrix_Male_Mut_SD_NREM = reshape(norm_by_animal_M_Mut_SD_NREM,1,1,[]);   
norm_matrix_Male_Mut_SD_REM  = reshape(norm_by_animal_M_Mut_SD_REM,1,1,[]);  

if FemaleDataPresent
	% Female WT 
	norm_matrix_Female_WT_BL_Wake = reshape(norm_by_animal_F_WT_BL_Wake,1,1,[]);   
	norm_matrix_Female_WT_BL_NREM = reshape(norm_by_animal_F_WT_BL_NREM,1,1,[]);   
	norm_matrix_Female_WT_BL_REM  = reshape(norm_by_animal_F_WT_BL_REM,1,1,[]);   
	norm_matrix_Female_WT_SD_Wake = reshape(norm_by_animal_F_WT_SD_Wake,1,1,[]);   
	norm_matrix_Female_WT_SD_NREM = reshape(norm_by_animal_F_WT_SD_NREM,1,1,[]);   
	norm_matrix_Female_WT_SD_REM  = reshape(norm_by_animal_F_WT_SD_REM,1,1,[]);   

	% Female Mut 
	norm_matrix_Female_Mut_BL_Wake = reshape(norm_by_animal_F_Mut_BL_Wake,1,1,[]);   
	norm_matrix_Female_Mut_BL_NREM = reshape(norm_by_animal_F_Mut_BL_NREM,1,1,[]);   
	norm_matrix_Female_Mut_BL_REM  = reshape(norm_by_animal_F_Mut_BL_REM,1,1,[]);   
	norm_matrix_Female_Mut_SD_Wake = reshape(norm_by_animal_F_Mut_SD_Wake,1,1,[]);   
	norm_matrix_Female_Mut_SD_NREM = reshape(norm_by_animal_F_Mut_SD_NREM,1,1,[]);   
	norm_matrix_Female_Mut_SD_REM  = reshape(norm_by_animal_F_Mut_SD_REM,1,1,[]); 
end 

% Next normalize the EEG 
% Male WT
EEG_Normalized_Male_WT_BL_Wake = bsxfun(@rdivide,EEG_Male_WT_BL_Wake,norm_matrix_Male_WT_BL_Wake);  % this is the normalized EEG
EEG_Normalized_Male_WT_BL_NREM = bsxfun(@rdivide,EEG_Male_WT_BL_NREM,norm_matrix_Male_WT_BL_NREM);  % this is the normalized EEG
EEG_Normalized_Male_WT_BL_REM  = bsxfun(@rdivide,EEG_Male_WT_BL_REM, norm_matrix_Male_WT_BL_REM);   % this is the normalized EEG
EEG_Normalized_Male_WT_SD_Wake = bsxfun(@rdivide,EEG_Male_WT_SD_Wake,norm_matrix_Male_WT_SD_Wake);  % this is the normalized EEG
EEG_Normalized_Male_WT_SD_NREM = bsxfun(@rdivide,EEG_Male_WT_SD_NREM,norm_matrix_Male_WT_SD_NREM);  % this is the normalized EEG
EEG_Normalized_Male_WT_SD_REM  = bsxfun(@rdivide,EEG_Male_WT_SD_REM, norm_matrix_Male_WT_SD_REM);   % this is the normalized EEG

% Male Mut
EEG_Normalized_Male_Mut_BL_Wake = bsxfun(@rdivide,EEG_Male_Mut_BL_Wake,norm_matrix_Male_Mut_BL_Wake);  % this is the normalized EEG
EEG_Normalized_Male_Mut_BL_NREM = bsxfun(@rdivide,EEG_Male_Mut_BL_NREM,norm_matrix_Male_Mut_BL_NREM);  % this is the normalized EEG
EEG_Normalized_Male_Mut_BL_REM  = bsxfun(@rdivide,EEG_Male_Mut_BL_REM, norm_matrix_Male_Mut_BL_REM);   % this is the normalized EEG
EEG_Normalized_Male_Mut_SD_Wake = bsxfun(@rdivide,EEG_Male_Mut_SD_Wake,norm_matrix_Male_Mut_SD_Wake);  % this is the normalized EEG
EEG_Normalized_Male_Mut_SD_NREM = bsxfun(@rdivide,EEG_Male_Mut_SD_NREM,norm_matrix_Male_Mut_SD_NREM);  % this is the normalized EEG
EEG_Normalized_Male_Mut_SD_REM  = bsxfun(@rdivide,EEG_Male_Mut_SD_REM, norm_matrix_Male_Mut_SD_REM);   % this is the normalized EEG

if FemaleDataPresent
	% Female WT
	EEG_Normalized_Female_WT_BL_Wake = bsxfun(@rdivide,EEG_Female_WT_BL_Wake,norm_matrix_Female_WT_BL_Wake);  % this is the normalized EEG
	EEG_Normalized_Female_WT_BL_NREM = bsxfun(@rdivide,EEG_Female_WT_BL_NREM,norm_matrix_Female_WT_BL_NREM);  % this is the normalized EEG
	EEG_Normalized_Female_WT_BL_REM  = bsxfun(@rdivide,EEG_Female_WT_BL_REM, norm_matrix_Female_WT_BL_REM);   % this is the normalized EEG
	EEG_Normalized_Female_WT_SD_Wake = bsxfun(@rdivide,EEG_Female_WT_SD_Wake,norm_matrix_Female_WT_SD_Wake);  % this is the normalized EEG
	EEG_Normalized_Female_WT_SD_NREM = bsxfun(@rdivide,EEG_Female_WT_SD_NREM,norm_matrix_Female_WT_SD_NREM);  % this is the normalized EEG
	EEG_Normalized_Female_WT_SD_REM  = bsxfun(@rdivide,EEG_Female_WT_SD_REM, norm_matrix_Female_WT_SD_REM);   % this is the normalized EEG

	% Female Mut
	EEG_Normalized_Female_Mut_BL_Wake = bsxfun(@rdivide,EEG_Female_Mut_BL_Wake,norm_matrix_Female_Mut_BL_Wake);  % this is the normalized EEG
	EEG_Normalized_Female_Mut_BL_NREM = bsxfun(@rdivide,EEG_Female_Mut_BL_NREM,norm_matrix_Female_Mut_BL_NREM);  % this is the normalized EEG
	EEG_Normalized_Female_Mut_BL_REM  = bsxfun(@rdivide,EEG_Female_Mut_BL_REM, norm_matrix_Female_Mut_BL_REM);   % this is the normalized EEG
	EEG_Normalized_Female_Mut_SD_Wake = bsxfun(@rdivide,EEG_Female_Mut_SD_Wake,norm_matrix_Female_Mut_SD_Wake);  % this is the normalized EEG
	EEG_Normalized_Female_Mut_SD_NREM = bsxfun(@rdivide,EEG_Female_Mut_SD_NREM,norm_matrix_Female_Mut_SD_NREM);  % this is the normalized EEG
	EEG_Normalized_Female_Mut_SD_REM  = bsxfun(@rdivide,EEG_Female_Mut_SD_REM, norm_matrix_Female_Mut_SD_REM);   % this is the normalized EEG
end 

% Finally, compute the means (and sems) so we can make the plots
% --- Means ---
if strcmp(Normalization,'AreaUnderCurve')
	NormFactor = 1;
elseif strcmp(Normalization,'MeanPowerAllStates')
	NormFactor = 100;
else
	error('You chose an invalid normalization factor.  Please choose AreadUnderCurve or MeanPowerAllStates.')
end 

% Male WT  			was 100*mean(mean .... 
Means.Male.WT.BL.Wake = NormFactor*mean(mean(EEG_Normalized_Male_WT_BL_Wake,1,'omitnan'),3,'omitnan');
Means.Male.WT.BL.NREM = NormFactor*mean(mean(EEG_Normalized_Male_WT_BL_NREM,1,'omitnan'),3,'omitnan');
Means.Male.WT.BL.REM  = NormFactor*mean(mean(EEG_Normalized_Male_WT_BL_REM,1,'omitnan'),3,'omitnan');
Means.Male.WT.SD.Wake = NormFactor*mean(mean(EEG_Normalized_Male_WT_SD_Wake,1,'omitnan'),3,'omitnan');
Means.Male.WT.SD.NREM = NormFactor*mean(mean(EEG_Normalized_Male_WT_SD_NREM,1,'omitnan'),3,'omitnan');
Means.Male.WT.SD.REM  = NormFactor*mean(mean(EEG_Normalized_Male_WT_SD_REM,1,'omitnan'),3,'omitnan');

% Male Mut
Means.Male.Mut.BL.Wake = NormFactor*mean(mean(EEG_Normalized_Male_Mut_BL_Wake,1,'omitnan'),3,'omitnan');
Means.Male.Mut.BL.NREM = NormFactor*mean(mean(EEG_Normalized_Male_Mut_BL_NREM,1,'omitnan'),3,'omitnan');
Means.Male.Mut.BL.REM  = NormFactor*mean(mean(EEG_Normalized_Male_Mut_BL_REM,1,'omitnan'),3,'omitnan');
Means.Male.Mut.SD.Wake = NormFactor*mean(mean(EEG_Normalized_Male_Mut_SD_Wake,1,'omitnan'),3,'omitnan');
Means.Male.Mut.SD.NREM = NormFactor*mean(mean(EEG_Normalized_Male_Mut_SD_NREM,1,'omitnan'),3,'omitnan');
Means.Male.Mut.SD.REM  = NormFactor*mean(mean(EEG_Normalized_Male_Mut_SD_REM,1,'omitnan'),3,'omitnan');

if FemaleDataPresent
	% Female WT
	Means.Female.WT.BL.Wake = NormFactor*mean(mean(EEG_Normalized_Female_WT_BL_Wake,1,'omitnan'),3,'omitnan');
	Means.Female.WT.BL.NREM = NormFactor*mean(mean(EEG_Normalized_Female_WT_BL_NREM,1,'omitnan'),3,'omitnan');
	Means.Female.WT.BL.REM  = NormFactor*mean(mean(EEG_Normalized_Female_WT_BL_REM,1,'omitnan'),3,'omitnan');
	Means.Female.WT.SD.Wake = NormFactor*mean(mean(EEG_Normalized_Female_WT_SD_Wake,1,'omitnan'),3,'omitnan');
	Means.Female.WT.SD.NREM = NormFactor*mean(mean(EEG_Normalized_Female_WT_SD_NREM,1,'omitnan'),3,'omitnan');
	Means.Female.WT.SD.REM  = NormFactor*mean(mean(EEG_Normalized_Female_WT_SD_REM,1,'omitnan'),3,'omitnan');

	% Female Mut
	Means.Female.Mut.BL.Wake = NormFactor*mean(mean(EEG_Normalized_Female_Mut_BL_Wake,1,'omitnan'),3,'omitnan');
	Means.Female.Mut.BL.NREM = NormFactor*mean(mean(EEG_Normalized_Female_Mut_BL_NREM,1,'omitnan'),3,'omitnan');
	Means.Female.Mut.BL.REM  = NormFactor*mean(mean(EEG_Normalized_Female_Mut_BL_REM,1,'omitnan'),3,'omitnan');
	Means.Female.Mut.SD.Wake = NormFactor*mean(mean(EEG_Normalized_Female_Mut_SD_Wake,1,'omitnan'),3,'omitnan');
	Means.Female.Mut.SD.NREM = NormFactor*mean(mean(EEG_Normalized_Female_Mut_SD_NREM,1,'omitnan'),3,'omitnan');
	Means.Female.Mut.SD.REM  = NormFactor*mean(mean(EEG_Normalized_Female_Mut_SD_REM,1,'omitnan'),3,'omitnan');
end 

% -- split into LP+DP? --
if SeparateSpectralIntoLPDP
	Means.Male.WT.BLFirst12hr.Wake = NormFactor*mean(mean(EEG_Normalized_Male_WT_BL_Wake(1:12,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.BLLast12hr.Wake  = NormFactor*mean(mean(EEG_Normalized_Male_WT_BL_Wake(13:24,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.BLFirst12hr.NREM = NormFactor*mean(mean(EEG_Normalized_Male_WT_BL_NREM(1:12,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.BLLast12hr.NREM  = NormFactor*mean(mean(EEG_Normalized_Male_WT_BL_NREM(13:24,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.BLFirst12hr.REM  = NormFactor*mean(mean(EEG_Normalized_Male_WT_BL_REM(1:12,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.BLLast12hr.REM   = NormFactor*mean(mean(EEG_Normalized_Male_WT_BL_REM(13:24,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.SDFirst12hr.Wake = NormFactor*mean(mean(EEG_Normalized_Male_WT_SD_Wake(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.SDLast12hr.Wake  = NormFactor*mean(mean(EEG_Normalized_Male_WT_SD_Wake(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.SDFirst12hr.NREM = NormFactor*mean(mean(EEG_Normalized_Male_WT_SD_NREM(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.SDLast12hr.NREM  = NormFactor*mean(mean(EEG_Normalized_Male_WT_SD_NREM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.SDFirst12hr.REM  = NormFactor*mean(mean(EEG_Normalized_Male_WT_SD_REM(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.WT.SDLast12hr.REM   = NormFactor*mean(mean(EEG_Normalized_Male_WT_SD_REM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');

	% Male Mut
	Means.Male.Mut.BLFirst12hr.Wake = NormFactor*mean(mean(EEG_Normalized_Male_Mut_BL_Wake(1:12,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.BLLast12hr.Wake  = NormFactor*mean(mean(EEG_Normalized_Male_Mut_BL_Wake(13:24,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.BLFirst12hr.NREM = NormFactor*mean(mean(EEG_Normalized_Male_Mut_BL_NREM(1:12,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.BLLast12hr.NREM  = NormFactor*mean(mean(EEG_Normalized_Male_Mut_BL_NREM(13:24,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.BLFirst12hr.REM  = NormFactor*mean(mean(EEG_Normalized_Male_Mut_BL_REM(1:12,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.BLLast12hr.REM   = NormFactor*mean(mean(EEG_Normalized_Male_Mut_BL_REM(13:24,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.SDFirst12hr.Wake = NormFactor*mean(mean(EEG_Normalized_Male_Mut_SD_Wake(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.SDLast12hr.Wake  = NormFactor*mean(mean(EEG_Normalized_Male_Mut_SD_Wake(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.SDFirst12hr.NREM = NormFactor*mean(mean(EEG_Normalized_Male_Mut_SD_NREM(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.SDLast12hr.NREM  = NormFactor*mean(mean(EEG_Normalized_Male_Mut_SD_NREM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.SDFirst12hr.REM  = NormFactor*mean(mean(EEG_Normalized_Male_Mut_SD_REM(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	Means.Male.Mut.SDLast12hr.REM   = NormFactor*mean(mean(EEG_Normalized_Male_Mut_SD_REM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');

	if FemaleDataPresent
		% Female WT
		Means.Female.WT.BLFirst12hr.Wake = NormFactor*mean(mean(EEG_Normalized_Female_WT_BL_Wake(1:12,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.BLLast12hr.Wake  = NormFactor*mean(mean(EEG_Normalized_Female_WT_BL_Wake(13:24,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.BLFirst12hr.NREM = NormFactor*mean(mean(EEG_Normalized_Female_WT_BL_NREM(1:12,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.BLLast12hr.NREM  = NormFactor*mean(mean(EEG_Normalized_Female_WT_BL_NREM(13:24,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.BLFirst12hr.REM  = NormFactor*mean(mean(EEG_Normalized_Female_WT_BL_REM(1:12,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.BLLast12hr.REM   = NormFactor*mean(mean(EEG_Normalized_Female_WT_BL_REM(13:24,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.SDFirst12hr.Wake = NormFactor*mean(mean(EEG_Normalized_Female_WT_SD_Wake(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.SDLast12hr.Wake  = NormFactor*mean(mean(EEG_Normalized_Female_WT_SD_Wake(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.SDFirst12hr.NREM = NormFactor*mean(mean(EEG_Normalized_Female_WT_SD_NREM(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.SDLast12hr.NREM  = NormFactor*mean(mean(EEG_Normalized_Female_WT_SD_NREM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.SDFirst12hr.REM  = NormFactor*mean(mean(EEG_Normalized_Female_WT_SD_REM(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.WT.SDLast12hr.REM   = NormFactor*mean(mean(EEG_Normalized_Female_WT_SD_REM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');

		% Female Mut
		Means.Female.Mut.BLFirst12hr.Wake = NormFactor*mean(mean(EEG_Normalized_Female_Mut_BL_Wake(1:12,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.BLLast12hr.Wake  = NormFactor*mean(mean(EEG_Normalized_Female_Mut_BL_Wake(13:24,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.BLFirst12hr.NREM = NormFactor*mean(mean(EEG_Normalized_Female_Mut_BL_NREM(1:12,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.BLLast12hr.NREM  = NormFactor*mean(mean(EEG_Normalized_Female_Mut_BL_NREM(13:24,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.BLFirst12hr.REM  = NormFactor*mean(mean(EEG_Normalized_Female_Mut_BL_REM(1:12,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.BLLast12hr.REM   = NormFactor*mean(mean(EEG_Normalized_Female_Mut_BL_REM(13:24,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.SDFirst12hr.Wake = NormFactor*mean(mean(EEG_Normalized_Female_Mut_SD_Wake(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.SDLast12hr.Wake  = NormFactor*mean(mean(EEG_Normalized_Female_Mut_SD_Wake(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.SDFirst12hr.NREM = NormFactor*mean(mean(EEG_Normalized_Female_Mut_SD_NREM(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.SDLast12hr.NREM  = NormFactor*mean(mean(EEG_Normalized_Female_Mut_SD_NREM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.SDFirst12hr.REM  = NormFactor*mean(mean(EEG_Normalized_Female_Mut_SD_REM(1:12-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
		Means.Female.Mut.SDLast12hr.REM   = NormFactor*mean(mean(EEG_Normalized_Female_Mut_SD_REM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),3,'omitnan');
	end 

end % end of if SeparateSpectralIntoLPDP


% -- End of Means --

% -- SEMS --
% Male WT          was 100*std(mean ....
SEMS.Male.WT.BL.Wake = NormFactor*std(mean(EEG_Normalized_Male_WT_BL_Wake,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_BL_Wake,3));
SEMS.Male.WT.BL.NREM = NormFactor*std(mean(EEG_Normalized_Male_WT_BL_NREM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_BL_NREM,3));
SEMS.Male.WT.BL.REM  = NormFactor*std(mean(EEG_Normalized_Male_WT_BL_REM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_BL_REM,3));
SEMS.Male.WT.SD.Wake = NormFactor*std(mean(EEG_Normalized_Male_WT_SD_Wake,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_SD_Wake,3));
SEMS.Male.WT.SD.NREM = NormFactor*std(mean(EEG_Normalized_Male_WT_SD_NREM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_SD_NREM,3));
SEMS.Male.WT.SD.REM  = NormFactor*std(mean(EEG_Normalized_Male_WT_SD_REM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_SD_REM,3));

% Male Mut
SEMS.Male.Mut.BL.Wake = NormFactor*std(mean(EEG_Normalized_Male_Mut_BL_Wake,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_BL_Wake,3));
SEMS.Male.Mut.BL.NREM = NormFactor*std(mean(EEG_Normalized_Male_Mut_BL_NREM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_BL_NREM,3));
SEMS.Male.Mut.BL.REM  = NormFactor*std(mean(EEG_Normalized_Male_Mut_BL_REM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_BL_REM,3));
SEMS.Male.Mut.SD.Wake = NormFactor*std(mean(EEG_Normalized_Male_Mut_SD_Wake,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_SD_Wake,3));
SEMS.Male.Mut.SD.NREM = NormFactor*std(mean(EEG_Normalized_Male_Mut_SD_NREM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_SD_NREM,3));
SEMS.Male.Mut.SD.REM  = NormFactor*std(mean(EEG_Normalized_Male_Mut_SD_REM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_SD_REM,3));

if FemaleDataPresent
	% Female WT
	SEMS.Female.WT.BL.Wake = NormFactor*std(mean(EEG_Normalized_Female_WT_BL_Wake,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_BL_Wake,3));
	SEMS.Female.WT.BL.NREM = NormFactor*std(mean(EEG_Normalized_Female_WT_BL_NREM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_BL_NREM,3));
	SEMS.Female.WT.BL.REM  = NormFactor*std(mean(EEG_Normalized_Female_WT_BL_REM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_BL_REM,3));
	SEMS.Female.WT.SD.Wake = NormFactor*std(mean(EEG_Normalized_Female_WT_SD_Wake,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_SD_Wake,3));
	SEMS.Female.WT.SD.NREM = NormFactor*std(mean(EEG_Normalized_Female_WT_SD_NREM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_SD_NREM,3));
	SEMS.Female.WT.SD.REM  = NormFactor*std(mean(EEG_Normalized_Female_WT_SD_REM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_SD_REM,3));

	% Female Mut
	SEMS.Female.Mut.BL.Wake = NormFactor*std(mean(EEG_Normalized_Female_Mut_BL_Wake,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_BL_Wake,3));
	SEMS.Female.Mut.BL.NREM = NormFactor*std(mean(EEG_Normalized_Female_Mut_BL_NREM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_BL_NREM,3));
	SEMS.Female.Mut.BL.REM  = NormFactor*std(mean(EEG_Normalized_Female_Mut_BL_REM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_BL_REM,3));
	SEMS.Female.Mut.SD.Wake = NormFactor*std(mean(EEG_Normalized_Female_Mut_SD_Wake,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_SD_Wake,3));
	SEMS.Female.Mut.SD.NREM = NormFactor*std(mean(EEG_Normalized_Female_Mut_SD_NREM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_SD_NREM,3));
	SEMS.Female.Mut.SD.REM  = NormFactor*std(mean(EEG_Normalized_Female_Mut_SD_REM,1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_SD_REM,3));
end 

if SeparateSpectralIntoLPDP
	% Male WT          was 100*std(mean ....
	SEMS.Male.WT.BLFirst12hr.Wake = NormFactor*std(mean(EEG_Normalized_Male_WT_BL_Wake(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_BL_Wake,3));
	SEMS.Male.WT.BLLast12hr.Wake  = NormFactor*std(mean(EEG_Normalized_Male_WT_BL_Wake(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_BL_Wake,3));
	SEMS.Male.WT.BLFirst12hr.NREM = NormFactor*std(mean(EEG_Normalized_Male_WT_BL_NREM(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_BL_NREM,3));
	SEMS.Male.WT.BLLast12hr.NREM  = NormFactor*std(mean(EEG_Normalized_Male_WT_BL_NREM(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_BL_NREM,3));
	SEMS.Male.WT.BLFirst12hr.REM  = NormFactor*std(mean(EEG_Normalized_Male_WT_BL_REM(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_BL_REM,3));
	SEMS.Male.WT.BLLast12hr.REM   = NormFactor*std(mean(EEG_Normalized_Male_WT_BL_REM(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_BL_REM,3));
	SEMS.Male.WT.SDFirst12hr.Wake = NormFactor*std(mean(EEG_Normalized_Male_WT_SD_Wake(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_SD_Wake,3));
	SEMS.Male.WT.SDLast12hr.Wake  = NormFactor*std(mean(EEG_Normalized_Male_WT_SD_Wake(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_SD_Wake,3));
	SEMS.Male.WT.SDFirst12hr.NREM = NormFactor*std(mean(EEG_Normalized_Male_WT_SD_NREM(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_SD_NREM,3));
	SEMS.Male.WT.SDLast12hr.NREM  = NormFactor*std(mean(EEG_Normalized_Male_WT_SD_NREM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_SD_NREM,3));
	SEMS.Male.WT.SDFirst12hr.REM  = NormFactor*std(mean(EEG_Normalized_Male_WT_SD_REM(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_SD_REM,3));
	SEMS.Male.WT.SDLast12hr.REM   = NormFactor*std(mean(EEG_Normalized_Male_WT_SD_REM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_WT_SD_REM,3));

	% Male Mut
	SEMS.Male.Mut.BLFirst12hr.Wake = NormFactor*std(mean(EEG_Normalized_Male_Mut_BL_Wake(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_BL_Wake,3));
	SEMS.Male.Mut.BLLast12hr.Wake  = NormFactor*std(mean(EEG_Normalized_Male_Mut_BL_Wake(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_BL_Wake,3));
	SEMS.Male.Mut.BLFirst12hr.NREM = NormFactor*std(mean(EEG_Normalized_Male_Mut_BL_NREM(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_BL_NREM,3));
	SEMS.Male.Mut.BLLast12hr.NREM  = NormFactor*std(mean(EEG_Normalized_Male_Mut_BL_NREM(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_BL_NREM,3));
	SEMS.Male.Mut.BLFirst12hr.REM  = NormFactor*std(mean(EEG_Normalized_Male_Mut_BL_REM(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_BL_REM,3));
	SEMS.Male.Mut.BLLast12hr.REM   = NormFactor*std(mean(EEG_Normalized_Male_Mut_BL_REM(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_BL_REM,3));
	SEMS.Male.Mut.SDFirst12hr.Wake = NormFactor*std(mean(EEG_Normalized_Male_Mut_SD_Wake(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_SD_Wake,3));
	SEMS.Male.Mut.SDLast12hr.Wake  = NormFactor*std(mean(EEG_Normalized_Male_Mut_SD_Wake(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_SD_Wake,3));
	SEMS.Male.Mut.SDFirst12hr.NREM = NormFactor*std(mean(EEG_Normalized_Male_Mut_SD_NREM(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_SD_NREM,3));
	SEMS.Male.Mut.SDLast12hr.NREM  = NormFactor*std(mean(EEG_Normalized_Male_Mut_SD_NREM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_SD_NREM,3));
	SEMS.Male.Mut.SDFirst12hr.REM  = NormFactor*std(mean(EEG_Normalized_Male_Mut_SD_REM(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_SD_REM,3));
	SEMS.Male.Mut.SDLast12hr.REM   = NormFactor*std(mean(EEG_Normalized_Male_Mut_SD_REM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Male_Mut_SD_REM,3));

	if FemaleDataPresent
		% Female WT
		SEMS.Female.WT.BLFirst12hr.Wake = NormFactor*std(mean(EEG_Normalized_Female_WT_BL_Wake(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_BL_Wake,3));
		SEMS.Female.WT.BLLast12hr.Wake  = NormFactor*std(mean(EEG_Normalized_Female_WT_BL_Wake(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_BL_Wake,3));
		SEMS.Female.WT.BLFirst12hr.NREM = NormFactor*std(mean(EEG_Normalized_Female_WT_BL_NREM(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_BL_NREM,3));
		SEMS.Female.WT.BLLast12hr.NREM  = NormFactor*std(mean(EEG_Normalized_Female_WT_BL_NREM(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_BL_NREM,3));
		SEMS.Female.WT.BLFirst12hr.REM  = NormFactor*std(mean(EEG_Normalized_Female_WT_BL_REM(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_BL_REM,3));
		SEMS.Female.WT.BLLast12hr.REM   = NormFactor*std(mean(EEG_Normalized_Female_WT_BL_REM(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_BL_REM,3));
		SEMS.Female.WT.SDFirst12hr.Wake = NormFactor*std(mean(EEG_Normalized_Female_WT_SD_Wake(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_SD_Wake,3));
		SEMS.Female.WT.SDLast12hr.Wake  = NormFactor*std(mean(EEG_Normalized_Female_WT_SD_Wake(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_SD_Wake,3));
		SEMS.Female.WT.SDFirst12hr.NREM = NormFactor*std(mean(EEG_Normalized_Female_WT_SD_NREM(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_SD_NREM,3));
		SEMS.Female.WT.SDLast12hr.NREM  = NormFactor*std(mean(EEG_Normalized_Female_WT_SD_NREM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_SD_NREM,3));
		SEMS.Female.WT.SDFirst12hr.REM  = NormFactor*std(mean(EEG_Normalized_Female_WT_SD_REM(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_SD_REM,3));
		SEMS.Female.WT.SDLast12hr.REM   = NormFactor*std(mean(EEG_Normalized_Female_WT_SD_REM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_WT_SD_REM,3));

		% Female Mut
		SEMS.Female.Mut.BLFirst12hr.Wake = NormFactor*std(mean(EEG_Normalized_Female_Mut_BL_Wake(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_BL_Wake,3));
		SEMS.Female.Mut.BLLast12hr.Wake  = NormFactor*std(mean(EEG_Normalized_Female_Mut_BL_Wake(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_BL_Wake,3));
		SEMS.Female.Mut.BLFirst12hr.NREM = NormFactor*std(mean(EEG_Normalized_Female_Mut_BL_NREM(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_BL_NREM,3));
		SEMS.Female.Mut.BLLast12hr.NREM  = NormFactor*std(mean(EEG_Normalized_Female_Mut_BL_NREM(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_BL_NREM,3));
		SEMS.Female.Mut.BLFirst12hr.REM  = NormFactor*std(mean(EEG_Normalized_Female_Mut_BL_REM(1:12,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_BL_REM,3));
		SEMS.Female.Mut.BLLast12hr.REM   = NormFactor*std(mean(EEG_Normalized_Female_Mut_BL_REM(13:24,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_BL_REM,3));
		SEMS.Female.Mut.SDFirst12hr.Wake = NormFactor*std(mean(EEG_Normalized_Female_Mut_SD_Wake(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_SD_Wake,3));
		SEMS.Female.Mut.SDLast12hr.Wake  = NormFactor*std(mean(EEG_Normalized_Female_Mut_SD_Wake(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_SD_Wake,3));
		SEMS.Female.Mut.SDFirst12hr.NREM = NormFactor*std(mean(EEG_Normalized_Female_Mut_SD_NREM(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_SD_NREM,3));
		SEMS.Female.Mut.SDLast12hr.NREM  = NormFactor*std(mean(EEG_Normalized_Female_Mut_SD_NREM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_SD_NREM,3));
		SEMS.Female.Mut.SDFirst12hr.REM  = NormFactor*std(mean(EEG_Normalized_Female_Mut_SD_REM(1:12-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_SD_REM,3));
		SEMS.Female.Mut.SDLast12hr.REM   = NormFactor*std(mean(EEG_Normalized_Female_Mut_SD_REM(12-SD_length_hrs+1:24-SD_length_hrs,:,:),1,'omitnan'),0,3,'omitnan')./sqrt(size(EEG_Normalized_Female_Mut_SD_REM,3));
	end 
end 	% end of if SeparateSpectralIntoLPDP



% Make the individual spectral power vs frequency figures
% BL
male_w_bl_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','BL','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
male_nr_bl_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Male','BL','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
male_r_bl_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','BL','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);

if FemaleDataPresent
	female_w_bl_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','BL','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	female_nr_bl_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Female','BL','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	female_r_bl_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','BL','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
end 

% SD
male_w_sd_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','SD','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
male_nr_sd_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Male','SD','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
male_r_sd_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','SD','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);

if FemaleDataPresent
	female_w_sd_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','SD','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	female_nr_sd_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Female','SD','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	female_r_sd_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','SD','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
end 

% Combine panels into one figure each for BL and sleep dep?  
combine_spectral_power_by_state_into_one_big_figure(FemaleDataPresent,Normalization,{'Spectral Baseline Figure','Spectral SD Figure'})


% ---- If separating by LP and DP, make 4 figures: BL LP, BL DP, SD LP, SD DP ---- 
if SeparateSpectralIntoLPDP
	% -- BL LP --
	male_w_bllp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','BLFirst12hr','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	male_nr_bllp_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Male','BLFirst12hr','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	male_r_bllp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','BLFirst12hr','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);

	if FemaleDataPresent
		female_w_bllp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','BLFirst12hr','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
		female_nr_bllp_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Female','BLFirst12hr','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
		female_r_bllp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','BLFirst12hr','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	end 

	% -- SD LP --
	male_w_sdlp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','SDFirst12hr','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	male_nr_sdlp_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Male','SDFirst12hr','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	male_r_sdlp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','SDFirst12hr','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);

	if FemaleDataPresent
		female_w_sdlp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','SDFirst12hr','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
		female_nr_sdlp_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Female','SDFirst12hr','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
		female_r_sdlp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','SDFirst12hr','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	end 

	combine_spectral_power_by_state_into_one_big_figure(FemaleDataPresent,Normalization,{'Spectral Baseline LP Figure','Spectral SD LP Figure'})

	% -- BL DP --
	male_w_bldp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','BLLast12hr','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	male_nr_bldp_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Male','BLLast12hr','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	male_r_bldp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','BLLast12hr','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);

	if FemaleDataPresent
		female_w_bldp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','BLLast12hr','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
		female_nr_bldp_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Female','BLLast12hr','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
		female_r_bldp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','BLLast12hr','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	end 

	% -- SD DP --
	male_w_sddp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','SDLast12hr','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	male_nr_sddp_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Male','SDLast12hr','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	male_r_sddp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Male','SDLast12hr','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);

	if FemaleDataPresent
		female_w_sddp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','SDLast12hr','Wake',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
		female_nr_sddp_fig_handle = plot_spectral_power_vs_freq(Means,SEMS,'Female','SDLast12hr','NREM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
		female_r_sddp_fig_handle  = plot_spectral_power_vs_freq(Means,SEMS,'Female','SDLast12hr','REM',LegendLabels,EEG_bin_edges,EEGLowerLimit_Hz,Normalization);
	end 

	combine_spectral_power_by_state_into_one_big_figure(FemaleDataPresent,Normalization,{'Spectral Baseline DP Figure','Spectral SD DP Figure'})





end % end of if SeparateSpectralIntoLPDP


% Now do the stats to compare the spectral curves? 
pvals = [];