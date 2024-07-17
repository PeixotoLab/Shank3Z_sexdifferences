function EEG_struct = SetUpEEGstruct(EEGWTBLWake,   EEGWTBLNREM,   EEGWTBLREM,   EEGWTSDWake,   EEGWTSDNREM,   EEGWTSDREM,...
                            		 EEGMutBLWake,  EEGMutBLNREM,  EEGMutBLREM,  EEGMutSDWake,  EEGMutSDNREM,  EEGMutSDREM, ...
                            		 EEGWTBLWake_F, EEGWTBLNREM_F, EEGWTBLREM_F, EEGWTSDWake_F, EEGWTSDNREM_F, EEGWTSDREM_F,...
                            		 EEGMutBLWake_F,EEGMutBLNREM_F,EEGMutBLREM_F,EEGMutSDWake_F,EEGMutSDNREM_F,EEGMutSDREM_F)

% This helper function sets up the struct EEG_struct. It cleans up the main script just a bit.  



% - Spectral Data -
% Males  (Spectral Data)  
EEG_struct.WT.Male.BL.Wake = EEGWTBLWake;  % WT
EEG_struct.WT.Male.BL.NREM = EEGWTBLNREM;
EEG_struct.WT.Male.BL.REM  = EEGWTBLREM;
EEG_struct.WT.Male.SD.Wake = EEGWTSDWake;
EEG_struct.WT.Male.SD.NREM = EEGWTSDNREM;
EEG_struct.WT.Male.SD.REM  = EEGWTSDREM;

EEG_struct.Mut.Male.BL.Wake = EEGMutBLWake;  % Mutant
EEG_struct.Mut.Male.BL.NREM = EEGMutBLNREM;
EEG_struct.Mut.Male.BL.REM  = EEGMutBLREM;
EEG_struct.Mut.Male.SD.Wake = EEGMutSDWake;
EEG_struct.Mut.Male.SD.NREM = EEGMutSDNREM;
EEG_struct.Mut.Male.SD.REM  = EEGMutSDREM;

% Females  (Spectral Data)  
EEG_struct.WT.Female.BL.Wake = EEGWTBLWake_F;  % WT
EEG_struct.WT.Female.BL.NREM = EEGWTBLNREM_F;
EEG_struct.WT.Female.BL.REM  = EEGWTBLREM_F;
EEG_struct.WT.Female.SD.Wake = EEGWTSDWake_F;
EEG_struct.WT.Female.SD.NREM = EEGWTSDNREM_F;
EEG_struct.WT.Female.SD.REM  = EEGWTSDREM_F;

EEG_struct.Mut.Female.BL.Wake = EEGMutBLWake_F;  % Mutant
EEG_struct.Mut.Female.BL.NREM = EEGMutBLNREM_F;
EEG_struct.Mut.Female.BL.REM  = EEGMutBLREM_F;
EEG_struct.Mut.Female.SD.Wake = EEGMutSDWake_F;
EEG_struct.Mut.Female.SD.NREM = EEGMutSDNREM_F;
EEG_struct.Mut.Female.SD.REM  = EEGMutSDREM_F;
