

function [model_recon, model_reconLev, nLevels] = do_recon_modelBeta(ext, linewidth, res)


%% ------------------------------------------------------------------------
%
% INPUTS
%   ext       : 'gaborequiph', 'linefix' ...
%   linewidth : 0 (gabor only), 150(line only), 4000(line only)
%   res       :
%       'imsize' (uses XY loaded from file; same as image size)
%       'square' (-20:binunit:20 as with real data)
%
% OUTPUTS
%   model_recon   : spatial reconstruction maps for each subj, sum of all
%       levels/sub-band
%   model_reconLev: spatial reconstruction maps for each subj, for each
%       level/sub-band

  
    %%
    disp(['-------- do_recon_rfResp(', ext, ', ', num2str(linewidth), ...
        ', ', num2str(res), ') --------']);

    
    %% 
    addpath(genpath('../helperfunctions'));
    load(fullfile('./data', ['prfModel_', ext, '_width', num2str(linewidth), '.mat']));
    if strcmp(res, 'square')
        clear X Y
        [X, Y] = meshgrid([-20:0.1:20], [-20:0.1:20]);
            % -taking into account the flipped y coordinates in mrVista
    end


    nSubj = numel(rfResp);          % rfResp: voxel response amplitudes from model output
    ntargs = 3;                     % orientation conditions
    nLevels = size(rfRespLev{min(find(cellfun(@(x) ~isempty(x), rfRespLev)))},3);
        % number of subbands from the model, determined by model params
    
    
    % z-score across ori conditions for each vox, for each subject and
    % subband 
    for isub = 1:nSubj
        tmp = [arrayfun(@(vox) {[zscore(rfResp{isub,1}(:,:,vox))]}, ...
            1:size(rfResp{isub},3))]';
        for vox = 1:size(rfResp{isub,1},3)
            rfResp_z{isub,1}(1,:,vox) = tmp{vox};
        end
        for lev = 1:nLevels
            tmp = [arrayfun(@(vox) {[zscore(rfRespLev{isub,1}(:,:,lev,vox))]}, ...
                1:size(rfRespLev{isub},4))]';
            for vox = 1:size(rfRespLev{isub,1},4)
                rfRespLev_z{isub,1}(1,:,lev,vox) = tmp{vox};
            end
        end
        
    end
    % overwrite
    rfResp = rfResp_z;
    rfRespLev = rfRespLev_z;
    
    
    
    for isub = 1:nSubj
        
        for roiN = 1:1 % only V1
            
            tmp = voxelsInc{isub,roiN}; % voxel selection: ecc<20
            
            for jj = 1:ntargs
                
                % sum of all subbands
                
                r = arrayfun(@(v) {rfResp{isub,roiN}(1,jj,tmp(v)).*...
                    gauss2d(X,Y,prfSize{isub,roiN}(tmp(v),1), [prfXY{isub,roiN}(tmp(v),:)]')}, ...
                    1:numel(tmp)); % each cell is for each voxel
                rcat = cat(3, r{:}); % cells into 3d matrices (3rd dimension is voxel)
                model_recon{isub,roiN}{jj,1} = sum(rcat, 3); % sum across all voxels
                
     
                % each subband
                
                for lev = 1:nLevels
                    r = arrayfun(@(v) {rfRespLev{isub,roiN}(1,jj,lev,tmp(v)).*...
                        gauss2d(X,Y,prfSize{isub,roiN}(tmp(v),1), [prfXY{isub,roiN}(tmp(v),:)]')}, ...
                        1:numel(tmp)); 
                    rcat = cat(3, r{:});
                    model_reconLev{isub,roiN}{lev,1}{jj,1} = sum(rcat,3);
                end
                
                disp(['---- subj', num2str(isub), ' target cond', num2str(jj), ' recon completed ----'])
            
            end
        end
    end
    
    

    
return