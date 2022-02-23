

function [recon] = do_recon_realBeta(epoch, sigmaOpt, mod)


%% ------------------------------------------------------------------------
% GOAL      : do spatial reconstruction with beta values
% INPUTS
%   epoch   : 'stim', 'delay'
%   sigmaOpt: 
%       'lim' (uses each voxel's fitted sigma value but max limit exists)
%       'fix' (fixed to certain value)
%   mod     : 0 (gabor&rdk combined), 1 (gabor), 2 (rdk), 3 (rdk-6labels)
%
% OUTPUTS
%   recon   : spatial reconstruction maps for each subj, roi



%% params

subjs = [1 2 3 4 5 6 7 8 10 11 12];
nTrialPerRun = 12;
if mod == 3
    load(fullfile(pwd, 'rdklabels_mask.mat')); % load RDK labels
end


% roi parameters
roiList = {'V1V2V3' 'V3AB' 'TO1TO2' 'IPS0IPS1' 'IPS2IPS3' 'sPCSiPCS'};
roiInd = [13 4 15 16 17 19]; % for indexing glmBeta
prf_roiInd = 1:numel(roiList); % for indexing prfdat


% some default parameters for voxel selection
ecclim = 20; 
sigmalim = 100; % sigmalim=100: no selection
velim = 0; % ve=0: no selection based on variance explained

% reconstruction map parameters
binunit = 0.1; % downsampling
[xgauss,ygauss] = meshgrid([-ecclim:binunit:ecclim],[-ecclim:binunit:ecclim]);
    % mrVista flips y positions in that - is up, + is down
    
% sigma parameters
if ismember('fix', sigmaOpt)
    sigmafix = 5;  % 2.5, 5, 7.5
end


% load pRF data
load(fullfile('../../data/params_pRF', 'prfdat_final.mat'));
    % index of pRF params
    ve = find(ismember(labels, {'ve'}));
    ecc = find(ismember(labels, {'ecc'}));
    sigma = find(ismember(labels, {'sigma'}));
    x0 = find(ismember(labels, {'x0'}));
    y0 = find(ismember(labels, {'y0'}));

% path for loading data
dataPath = '../../data/glmBeta';
paramPath = '../../data/params_exp';
addpath(genpath('../helperfunctions'));

%% -------------------- start reconstruction --------------------

% initialize
recon = cell(numel(subjs), numel(roiList)); 


for sub = 1:numel(subjs)
      
    subjN = subjs(sub);
    
    % glitches
    if subjN == 3 || subjN == 2 || subjN == 7
        nTrialsTotal = 264-12;
    else
        nTrialsTotal = 264;
    end
    
    
    % load condition index matrices
    pFileName = fullfile(paramPath, ['subj', num2str(subjN), '_sess0', '_cond_inds.mat']);
    load(pFileName, 'cond_inds');
        % cond_inds: 
        %   1st col is index of ori condition, 2nd cols is
        %   gabor(1)/rdk(2)
        
    % load glmBeta
    load(fullfile(dataPath, ['subj', num2str(subjN), '_sess0', '_glmData', ...
        '_', epoch, '.mat']));
    
    
    if mod == 3
        cond_inds(:,1) = mask{sub}(:,1);
        if sum(cond_inds(:,2)==1&cond_inds(:,1)~=0) ~= 0, error('check'); end
            % find gabor conds and turn them into 0 (interested in only the
            % RDK here)
    end
   
    nOris = numel(unique(cond_inds(:,1)));
    if mod == 3
        nOris = nOris-1; %get rid of 0
    end
   
    
    for roi = 1:numel(roiList)
        
        prf_roi = prf_roiInd(roi); 
        
        %% voxel info
        
        % voxel selection
        voxind{sub,roi} = prfdat{sub,prf_roi}(:,ecc)<=ecclim & ...
            (prfdat{sub,prf_roi}(:,sigma)<=sigmalim) & ...
            (prfdat{sub,prf_roi}(:,ve)>=velim);
        
        % sigma 
        if ismember('lim', sigmaOpt)
            sigmadat = prfdat{sub,prf_roi}(voxind{sub,roi},sigma);
        end
        
         % real beta values
         glmBeta_z{sub}{roi,1} = nan(size(glmBeta{roiInd(roi)}));
         for run = 1:nTrialsTotal/nTrialPerRun
             % z-score so that the mean(std) of each voxel for each run is
             % 0(1)
             glmBeta_z{sub}{roi,1}((run-1)*nTrialPerRun+1:run*nTrialPerRun,:) = ...
                 zscore(glmBeta{roiInd(roi)}((run-1)*nTrialPerRun+1:run*nTrialPerRun,:));
         end

        for jj = 1:nOris
            % beta values of voxels averaged across trials for each condition
            if mod == 0 || mod == 3
                real_avg{sub,roi}(jj,:) = mean(glmBeta_z{sub}{roi}...
                    (cond_inds(:,1)==jj,voxind{sub,roi}));
            elseif mod == 1 || mod == 2
                real_avg{sub,roi}(jj,:) = mean(glmBeta_z{sub}{roi}...
                    (cond_inds(:,1)==jj&cond_inds(:,2)==mod,voxind{sub,roi}));
            end
        end
        

        %% stimulus reconstruction 
        
        tmp = find(voxind{sub,roi}); % index of selected vox
        for jj = 1:nOris
            % each cell of r is for each voxel
            if ismember('lim', sigmaOpt)
                r = arrayfun(@(v) {real_avg{sub,roi}(jj,v).*...
                    gauss2d(xgauss,ygauss,sigmadat(v,1),[prfdat{sub,prf_roi}(tmp(v),x0:y0)]')}, ...
                    1:numel(tmp));
            elseif ismember('fix', sigmaOpt)
                 r = arrayfun(@(v) {real_avg{sub,roi}(jj,v).*...
                    gauss2d(xgauss,ygauss,sigmafix,[prfdat{sub,prf_roi}(tmp(v),x0:y0)]')}, ...
                    1:numel(tmp));
            end
            % turn cell into a matrix, where 3rd dimension is voxel
            rcat = cat(3, r{:}); 
            % sum across voxel dimension
            recon{sub,roi}(:,:,jj) = sum(rcat, 3);
        end
        

    end
    
    disp(['---- completed subj ', num2str(sub), ' ----']);

end





return
