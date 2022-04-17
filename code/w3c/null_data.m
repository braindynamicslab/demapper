

origpath  = split(pwd, 'demapper');
basefolder  = [origpath{1}, 'demapper'];
codefolder  = [basefolder,'/code/3rdparty'];
addpath(genpath(codefolder));
toolboxfolder  = [origpath{1},'mappertoolbox-matlab/code/'];
addpath(genpath(toolboxfolder));
toolboxfolder  = [origpath{1},'mappertoolbox-matlab/tests/tools/'];
addpath(genpath(toolboxfolder));


datapath = [basefolder, '/data/w3c/w3c_simulated_bold.npy'];

bold = readNPY(datapath);

surrblk = phaseran(bold, 3);

outdir = [basefolder, '/data/w3c_wnull/'];
writeNPY(bold, [outdir, 'SBJ100.npy']);

N = size(bold, 2);
bold150 = [bold, surrblk(:,1:ceil(N/2),1)];
bold200 = [bold, surrblk(:,:,1)];
bold300 = [bold, surrblk(:,:,1), surrblk(:,:,2)];
bold400 = [bold, surrblk(:,:,1), surrblk(:,:,2), surrblk(:,:,3)];
writeNPY(bold150, [outdir, 'SBJ150.npy']);
writeNPY(bold200, [outdir, 'SBJ200.npy']);
writeNPY(bold300, [outdir, 'SBJ300.npy']);
writeNPY(bold400, [outdir, 'SBJ400.npy']);
