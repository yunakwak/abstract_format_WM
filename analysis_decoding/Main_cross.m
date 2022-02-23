
function decAcc = Main_cross(subj, epoch, bases)


%% ------------------------------------------------------------------------
% ***IMPORTANT!***
%   This code depends heavily on Princeton MVPA toolbox
%   (http://www.csbmb.princeton.edu/mvpa). Please download the toolbox
%   and add them to the paths before running this code. You will need the 
%   toolbox for running classify_bp.m, which is in MVPA_cross.m. In our 
%   paper, we mainly used train_bp and test_bp, with certain training 
%   parameters. Feel free to play around with different training parameters.
% 
% GOAL      : runs cross-decoding for each subj, all rois
%
% INPUTS
%   subj    : subj number
%   epoch   : 'stim', 'delay'
%   bases   : which condition to do decoding on (see below)
%
% OUTPUTS
%   decAcc   : matrix (number of ROIs * number of bases tested) with final
%       decoding accuracy, averaged across iterations

%% ------------------------------- baseN info ------------------------------- %%

    %%% train and test on DELAY: bases <= 10 
        % base1: 
            %  trainCond=1, testCond=2
            % 3 conds for gabor
            % 3 conds for RDK (giving the same label to RDK conditions with 
            % same orientation but opposite direction)
        % base6:
            % trainCond=2, testcond=1
            % 3 conds for RDK (giving the same label to RDK conditions with
            % same orientation but opposite direction)
            % 3 conds for gabor
            
    %%% train and test on STIM: base > 10 & base <= 20
        % same as above
        
    %%% train on STIM and test on DELAY: base > 20
        % same as above

    %%% base1 and base6 are the main interests




%% ------------------------------- Getting Ready ------------------------------- %%

%% Parameters

    sess = 0; % both sessions combined
    
    if subj == 3 || subj == 2 || subj == 7 % glitches
        nTrialsTotal = 264-12;
    else
        nTrialsTotal = 264;
    end
    nTrialPerRun = 12;
    nRunsTotal = nTrialsTotal/nTrialPerRun;
    
    % classification
    nIterTrain = 10;
 
    % roi
    roip.roiList = {'V1V2V3' 'V3AB' 'TO1TO2' 'IPS0IPS1' 'IPS2IPS3' 'sPCSiPCS'};
    roip.roiInd = [13, 4, 15:17, 19]; % needed for indexing glmBeta files (order corresponding to roip.roiList)    
    roip.nRoi = numel(roip.roiList);
    
    
%% Load stuff

    load(['../data/params_exp/', 'subj', num2str(subj), '_sess', num2str(sess), ...
        '_cond_inds.mat']);
    load(['../data/glmBeta/', 'subj', num2str(subj), '_sess', num2str(sess), ...
        '_glmData', '_', num2str(epoch)], 'glmBeta');


    
%% ----------------- CROSS-DECODING beta values -----------------

    for ibase = 1:numel(bases)
        decAcc(:,ibase) = MVPA_cross(subj, roip, bases(ibase), ...
            nIterTrain, glmBeta, cond_inds, nTrialPerRun, nRunsTotal);
    end

