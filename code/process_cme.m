basefolder  = split(pwd, 'demapper');
basefolder  = [basefolder{1}, 'demapper'];
codefolder  = [basefolder,'/code'];
addpath(genpath(codefolder));

s01path = [basefolder, '/data/msc/sub-MSC01/'];

c1path = [s01path, ...
  'vc38671_LR_surf_subcort_222_32k_fsLR_smooth_2.55surf_novolsmooth.dtseries.nii'];

c = cifti_read(c1path);

