
function plot_recon(recon, clim_z, varargin)


%% ------------------------------------------------------------------------
% GOAL       : plot spatial reconstruction maps
% INPUTS
%   recon    : spatial reconstruction maps computed from do_recon_realBeta.m
%   clim_z   : min and max values for plotting
%   varargin :
%       'fitline_weighted'  : fits weighted lines and plots on recon maps
%
% OUTPUTS
  

%%
if isempty(clim_z)
   clim_z = [-1.2 1.2]; % when z-scoring each subj, for beta
end

if ismember('fitline_weighted', varargin)
    % threshold: find top 30%
    perc = 30;
    disp(['threshold: ', num2str(perc), ' %'])
end


%% parameters

nSubjs = size(recon,1);
nOris = size(recon{1},3);

roiList = {'V1V2V3' 'V3AB' 'TO1TO2' 'IPS0IPS1' 'IPS2IPS3' 'sPCSiPCS'};
  

stimr = 7.5; % radius of stim circle
ecclim = 20;
binunit = round(ecclim*2/size(recon{1},1),1);

[stimx, stimy] = plot_stim(stimr/binunit, repmat(round(size([-ecclim:binunit:ecclim],2)/2), [1 2])); 


%% plot


for roiN = 1:numel(roiList) 
    
    figure(roiN)
    suptitle(['average', '-', roiList{roiN}]);
    
    t = recon(:,roiN);
    
    for jj = 1:nOris
        
       %%
        % z-score per subj
        for sub = 1:nSubjs
            dat = t{sub}(:,:,jj);
            %recon_z{sub,roiN}(:,:,jj) = dat;
            recon_z{sub,roiN}(:,:,jj) = (dat-mean(mean(dat)))/std(reshape(dat, [numel(dat) 1]));
        end
        % average across subjects for each condition
        t2 = recon_z(:,roiN);
        r = [cellfun(@(x) {x(:,:,jj)}, t2)]';
        rcat = cat(3,r{:});
        recon_group_z{roiN,1}(:,:,jj) = sum(rcat,3)/nSubjs;
        
        if nOris > 3
            f(roiN,jj)=subplot(2,nOris/2,jj);
        else
            f(roiN,jj)=subplot(1,nOris,jj);
        end
        
        if ismember('fitline_weighted', varargin)
            imgsz = [size(recon_group_z{roiN}(:,:,jj),2), ...
                size(recon_group_z{roiN}(:,:,jj),1)];
            dat = reshape(recon_group_z{roiN}(:,:,jj), [imgsz(1)*imgsz(2) 1]);
            thres = prctile(dat, 100-perc);
            ind = find(dat>thres);
            [r, c] = ind2sub(size(recon_group_z{roiN}(:,:,jj)), ind);
            
        end
        
        
        if isempty(clim_z)
            imagesc(recon_group_z{roiN}(:,:,jj)); colormap magma; colorbar; hold on;
        else
            imagesc(recon_group_z{roiN}(:,:,jj),clim_z); colormap magma; colorbar; hold on;
        end
        plot(stimx, stimy, 'Color', [0 0 0 0.4], 'LineWidth', 0.5);
        axis square; axis off;
        
        
        if ismember('fitline_weighted', varargin)
            
            f(roiN,jj);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% using fitlm: allows both weights and constraints (to go
            %%% through center)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            cent = floor(size(recon_group_z{roiN}(:,:,jj))/2);
            if ismember('fitline_weighted', varargin)
                [~,w]=sort(dat(ind));
                tmp = fitlm(c-cent(2),r-cent(1),'linear', 'Intercept', false, 'Weights', w);
            end
            sl(roiN,jj) = tmp.Coefficients.Estimate;
            plot(([0:imgsz(2)]-cent(2))*sl(roiN,jj)+cent(1), 'Color', [0 0 0 0.4], 'LineWidth', 0.5); xlim([0 401]); ylim([0 401]); hold on; 
            
            
        end
        
    end
    
    if ismember('fitline_weighted', varargin)
        polang = cart2pol(ones(size(sl)), -sl); 
            % x is always 1 in the cartesian coords, so coords are always
            % on the right visual field (-90 <= angle <= +90)
        degang = rad2deg(polang);
        calcang = 90-degang;
        for jj = 1:nOris
            f(roiN,jj).Title.String = num2str(round(calcang(roiN,jj),2));
        end
    end
    
    % min and max clim_z
    if ismember('clim_minmax', varargin)
        minC=min(cell2mat({f.CLim}));
        maxC=max(cell2mat({f.CLim}));
        for ii = 1:numel(f)
            f(ii).CLim = [minC maxC];
        end
    end
    

    
end
 



return