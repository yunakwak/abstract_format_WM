# abstract_format_WM
 
Data necessary for running these codes can be found at https://osf.io/t6b95/

<analysis_decoding>
 - Codes for cross-decoding across stimulus types (grating orientation, dot motion direction)
 - This analysis depends heavily on Princeton MVPA toolbox, which you would need to download and add to path (http://www.csbmb.princeton.edu/mvpa). 
 
 <analysis_weighting>
 - Codes for spatial reconstruction analysis and generating reconstruction map plots
 - recon_realBeta: codes for spatial reconstruction using data collected from experiments
 - recon_modelBeta: codes for spatial reconstruction using model simulation
   -> Model simulation depends heavily on codes publicy available by Roth et al (2018) at https://github.com/elifesciences-publications/stimulusVignetting.
   -> Voxel-level simulated data based on Roth et al (2018) can be found in recon_modelBeta/data for gratings and simple lines reported in paper.
   -> The inputs to the model, which are stimulus images of the exact same gratings used in the experiment and simple line images, can be found in recon_modelBeta/stim.
   
   
