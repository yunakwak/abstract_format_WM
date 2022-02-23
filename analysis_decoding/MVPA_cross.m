

function acc_all = MVPA_cross(subj, roip, base, ...
    nIterTrain, glmBeta, cond_inds, nTrialPerRun, nRunsTotal)




%% Parameters

if mod(base,10) <= 5 % train on gabor, test on RDK
    trainCond = 1; testCond = 2; 
elseif mod(base,10) > 5 % train on RDK, test on gabor
    trainCond = 2; testCond = 1;
end        
if base <= 10
    epoch = 'delay';
elseif base > 10 && base <= 20
    epoch = 'stim';
end
regs = 1; % not using this parameter (see ireg below)


%% CLASSIFICATION

acc_all = nan(numel(roip.roiList, 1);

% -------------------------------------------------------------------------

glmBeta_z = cell(size(glmBeta)); %pre-allocate

for roi = 1:numel(roip.roiList) 
    
    roin = roip.roiInd(roi);
    
    if ~isempty(glmBeta{roin})
        
        %% z-score beta values
        
        glmBeta_z{roin,1} = nan(size(glmBeta{roin}));
        for run = 1:nRunsTotal
            % z-score so that the mean(std) of each voxel for each run is
            % 0(1)
            glmBeta_z{roin,1}((run-1)*nTrialPerRun+1:run*nTrialPerRun,:) = ...
                zscore(glmBeta{roin}((run-1)*nTrialPerRun+1:run*nTrialPerRun,:));
        end
        
        %% pre-allocate
        
        acc_ind = nan(nIterTrain,regs);
        acc = nan(regs,1);
        
        trainData = cell(regs,1);
        testData = cell(regs,1);
        trainTargs = cell(regs,1);
        testTargs = cell(regs,1);
        trainTargsList = [];
        testTargsList = [];
        
        
        for ireg = 1:regs % not using this parameter (regs fixed to 1)
            
            
            %% data
            
            %%% training data
            trainPoints = find(cond_inds(:,2)==trainCond); % index of trials for training
            trainData{ireg} = glmBeta_z{roin,1}(trainPoints,:)';
            trainTargsList(:,ireg) = cond_inds(trainPoints,1);
            trainTargs{ireg} = zeros(numel(unique(trainTargsList(:,ireg))), numel(trainPoints));
            for trial = 1:numel(trainPoints)
                trainTargs{ireg}(cond_inds(trainPoints(trial),1),trial) = 1;
            end
            
            
            %%% test data
            testPoints = find(cond_inds(:,2)==testCond); % index of trials for training
            testData{ireg} = glmBeta_z{roin,1}(testPoints,:)';
            
            testTargsList(:,ireg) = cond_inds(testPoints,1);
            testTargs{ireg} = zeros(numel(unique(testTargsList(:,ireg))), numel(testPoints));
            for trial = 1:numel(testPoints)
                testTargs{ireg}(cond_inds(testPoints(trial),1),trial) = 1;
            end
            
            
            
            %% classification
            
            [acc_ind(:,ireg), acc(ireg,1)] = classify_bp(trainData{ireg}, trainTargs{ireg}, ...
                testData{ireg}, testTargs{ireg}, testTargsList(:,ireg), nIterTrain);
            
            
            %% print out results
            
            maskName = roip.roiList{roi};
            fileName = ['base', num2str(base), '_', ...
                'subj', num2str(subj), '_', epoch, '_', 'trainCond', num2str(trainCond), ...
                '_', maskName];
            fprintf(1, [fileName, ' ', 'acc=', '%.3f\n'], acc(ireg,1));
         
            
        end
        
    end
    
    acc_all(roi,1) = acc; 
    
end


return











