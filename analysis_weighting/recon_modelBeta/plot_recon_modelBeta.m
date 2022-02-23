

function plot_recon_modelBeta(recon, reconLev, maxLev, res)


%% ------------------------------------------------------------------------
% GOAL        : plots reconstruction maps computed from do_recon_modelBeta
%
% INPUTS
%   recon/reconLev : output from do_recon_modelBeta
%   maxLev         : level/sub-band in model responses that gives maximum response
%       values to plug in - [15] for ext='gaborequiph'
%                           [14 15] for ext='gaborequiph', for sum of two
%                               maximal levels
%                           [9] for ext='linefix_width150';
%   res            :
%       'imsize' (uses XY loaded from file; same as image size)
%       'square' (-20:binunit:20 as with real data)
%



    %%
    addpath(genpath('../helperfunctions'));
    
    %%
    ntargs = size(recon{1,1},1);
    nLevels = size(reconLev{1,1},1);
    
    
   %% z-score
   
   for isub = 1:size(recon,1)
       recon_z{isub,1} = cellfun(@(x) {(x-mean(mean(x)))/(std(reshape(x, [1 numel(x)]))/sqrt(size(recon,1)))}, ...
           recon{isub});
       for lev = 1:nLevels
           reconLev_z{isub,1}{lev,1} = cellfun(@(x) {(x-mean(mean(x)))/(std(reshape(x, [1 numel(x)]))/sqrt(size(recon,1)))}, ...
           reconLev{isub}{lev});
       end
   end


   %% average
    
    % recon
    for ori = 1:ntargs
        recon_av{ori,1} = zeros(size(recon_z{1}{1}));
        for isub = 1:size(recon_z,1)
            recon_av{ori} = recon_av{ori}+recon_z{isub}{ori};
        end
        recon_av{ori} = recon_av{ori}/size(recon_z,1);
    end
    
    % reconLev
    for lev = 1:nLevels
        for ori = 1:ntargs
            reconLev_av{lev,1}{ori,1} = zeros(size(reconLev_z{1}{1}{1}));
            for isub = 1:size(reconLev_z,1)
                reconLev_av{lev}{ori} = reconLev_av{lev}{ori}+reconLev_z{isub}{lev}{ori};
            end
            reconLev_av{lev}{ori} = reconLev_av{lev}{ori}/size(reconLev_z,1);
        end
    end
    
    
    %% plot
    
    % parameters
    clim_z = [-8 8]; 
    clim_z_sumLevs = [-10 10]; %gaborequiph
    
    stimr = 7.5; % radius of stim circle
    binunit = 0.1; ecclim = 20;
    [stimx, stimy] = plot_stim(stimr/binunit, repmat(round(size([-ecclim:binunit:ecclim],2)/2), [1 2]));
%     if ~isempty(strfind(ext, 'doughnut'))
%         clim_z_sumLevs = [-15 15]; %gaborequiph_doughnut
%         [stimx2, stimy2] = plot_stim(6.75/2/binunit, repmat(round(size([-ecclim:binunit:ecclim],2)/2), [1 2]));
%     end
    
    % recon
    
    figure(100);
    for ori = 1:ntargs
        subplot(ntargs,1,ori)
        imagesc(recon_av{ori}, clim_z); colorbar; hold on;
        plot(stimx, stimy, 'k', 'LineWidth', 0.5); hold on;
%         if ~isempty(strfind(ext, 'doughnut'))
%             plot(stimx2, stimy2, 'k', 'LineWidth', 0.5); hold on;
%         end
        if strcmp(res, 'square')
            axis square; axis off;
        elseif strcmp(res, 'imsize')
            axis off; set(gcf, 'Position', [0 0 nrow ncol]/5); 
        end
    end
    title('sum of all levels')
    hold off;
    

    % reconLev
    

    if numel(maxLev) == 1 %%%level with maximum response
        
        lev = maxLev;
        figure(lev)
        for ori = 1:ntargs
            subplot(ntargs,1,ori)
            imagesc(reconLev_av{lev}{ori}, clim_z); colorbar; hold on;
            plot(stimx, stimy, 'k', 'LineWidth', 0.5); hold on;
%             if ~isempty(strfind(ext, 'doughnut'))
%                 plot(stimx2, stimy2, 'k', 'LineWidth', 0.5); hold on;
%             end
            if strcmp(res, 'square')
                axis square; axis off;
            elseif strcmp(res, 'imsize')
                axis off; set(gcf, 'Position', [0 0 nrow ncol]/5);
            end
        end
        suptitle(['lev',num2str(lev)]);
    
    elseif numel(maxLev) == 2 %%%sum of two levels closest to target SF
       
        figure;
        for ori = 1:ntargs
            subplot(ntargs,1,ori)
            recon_sum_lev{ori} = reconLev_av{maxLev(1)}{ori}+reconLev_av{maxLev(2)}{ori};
            imagesc(recon_sum_lev{ori}, clim_z_sumLevs); colorbar; hold on;
            plot(stimx, stimy, 'k', 'LineWidth', 0.5); hold on;
%             if ~isempty(strfind(ext, 'doughnut'))
%                 plot(stimx2, stimy2, 'k', 'LineWidth', 0.5); hold on;
%             end
            if strcmp(res, 'square')
                axis square; axis off;
            elseif strcmp(res, 'imsize')
                axis off; set(gcf, 'Position', [0 0 nrow ncol]/5);
            end
        end
       
    
    end


    
    


return