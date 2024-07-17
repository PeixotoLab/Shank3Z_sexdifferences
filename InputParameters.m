function S = InputParamsLizzy


% -- These are the parameters that used to be set in the main script -----------------
% ------------------------------------------------------------------------------------
S.epochs = 900;               				% number of epochs for the spectra bins, 900=1h, 1800=2h if using 4-second epochs
S.numhrs = 24;
S.swa    = ([S.epochs,S.numhrs]);        	% these are the dimensions of a slow wave activity matrix  

S.SD_length_hrs  = 5;
S.epoch_duration_secs = 4;
S.firstNREM_episode_duration_epochs = 7;  	% the number of NREM epochs to count as a NREM bout for calculating sleep latency
S.NREM_char = {'N','NR','N*'};            	% the character used to label NREM sleep in sleep latency analysis  
S.EEGLowerLimit_Hz = 0.25;   				% the lower limit of frequencies read in from .mat files
S.Bout_Minimums.W = 2;        				% You need at least 2 epochs in a row to be counted as a bout.
S.Bout_Minimums.N = 2;
S.Bout_Minimums.R = 2;
S.LegendLabels = {'WildType','Shank3^{\DeltaC}'}; % Labels for figures legends

S.Normalization = 'MeanPowerAllStates'; % How to normalize the spectral curves.  Options are 'MeanPowerAllStates' or 'AreaUnderCurve'
S.PlotHourlyBaselineNREM_Delta = false;	% By default the code plots hourly NREM Delta after SD.  Do you also want to see that during baseline? 

S.Analyze_TIS_DP_6hr_segments = true; 	% true if you want to add an additional analysis of the time in state data: 
										% the first 6 hours of the dark period and the last 6 hours of the dark period.   

S.SeparateSpectralIntoLPDP = true;		% Do you want to separate the spectral analysis into light period and dark period?   	

S.Analyze_Recovery_2hr_bins = false; 	% In addition to analyzing recovery sleep in 1-hr bins, do you also want to do it using 2-hr bins?  


% Paths to data
S.path_to_WT_BL_Males_files    = '/Path/to/Male/WildType/Baseline/Data/';
S.path_to_WT_SD_Males_files    = '/Path/to/Male/WildType/SleepDep/Data/';
S.path_to_Mut_BL_Males_files   = '/Path/to/Male/Mutant/Baseline/Data/';
S.path_to_Mut_SD_Males_files   = '/Path/to/Male/Mutant/SleepDep/Data/';
S.path_to_WT_BL_Females_files  = '/Path/to/Female/WildType/Baseline/Data/';
S.path_to_WT_SD_Females_files  = '/Path/to/Female/WildType/SleepDep/Data/';
S.path_to_Mut_BL_Females_files = '/Path/to/Female/Mutant/Baseline/Data/';
S.path_to_Mut_SD_Females_files = '/Path/to/Female/Mutant/SleepDep/Data/';


% -- IMPORTANT:  Do you want to read data from a .mat file instead of the directories above? (to save time)
S.load_data_from_mat_file_instead = 0; 			% 0 for no, 1 for yes
S.MatFileContainingData = 'MySavedFile.mat'; 



% You don't need to mess with this
S.FileName = mfilename;
st = dbstack;
S.FuncName = st.name; 