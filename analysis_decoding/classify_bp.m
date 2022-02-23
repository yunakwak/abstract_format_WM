
function [acc_ind, acc] = classify_bp(traindata, traintargs, ...
    testdata, testtargs, testtargslist, nIterTrain)

%% ------------------------------------------------------------------------
% GOAL      : compute decoding accuracy
%
% INPUTS    
%   traintargs/testtargs : nConds * nSamples regressor matrix
%   testtargslist        : made from testtargs, just the index of the
%       condition labels to make things easier
%   nIterTrain           : number of iterations for classification
%   base

% OUTPUTS
%   acc_ind: decoding accuracy for each iteration
%   acc    : average decoding accuracy across all iterations



    
    % classifier parameters
    in_args.act_funct{1} = 'softmax';
    in_args.performFcn = 'crossentropy';
%     in_args.act_funct{1} = 'logsig';
%     in_args.performFcn = 'mse';
    in_args.nHidden = 0;
   
%     parfor iter = 1:nIterTrain
    for iter = 1:nIterTrain
    
        scratch = train_bp(traindata,traintargs,in_args);
        [acts, scratch] = test_bp(testdata,testtargs,scratch);

        [~,ind] = max(acts); 
        nCorr = sum(testtargslist==ind');
        acc_ind(iter,1) = nCorr/size(testtargs,2);
        
        %clear acts scratch ind
        acts = []; scratch = []; ind = []; % used to use clear but changed due to parfor
        
    end
    
    acc = mean(acc_ind);


return