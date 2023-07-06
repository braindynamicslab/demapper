import os
import pandas as pd
import numpy as np


BASE_PATH = '/Users/dh/workspace/BDL/demapper/results/'

DATASETS = {
    'w3c-bins1': BASE_PATH + 'w3c/analysis/mappers_w3c_bins1.json/',
    'w3c-bins2': BASE_PATH + 'w3c/analysis/mappers_w3c_bins2.json/',
    'w3c-dists2': BASE_PATH + 'w3c/analysis/mappers_w3c_dists2.json/',
    'w3c-dists3': BASE_PATH + 'w3c-wnoise/analysis/mappers_w3c_dists3.json/',
    'w3c-dists4': BASE_PATH + 'w3c-hightr/analysis/mappers_w3c_dists4.json/',
    'w3c-clust1': BASE_PATH + 'w3c/analysis/mappers_w3c_clust1.json/',
    'ss_w3cv1': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv1.json/',
    'ss_w3cv2': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv2.json/',
    'ss_w3cv3': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv3.json/',
    'ss_w3cv4': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv4.json/',
    'ss_w3cv4euc': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv4_euc.json/',
    'ss_w3cv5': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv5fixed.json/',
    'ss_w3cv6': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv6fixed.json/',
    'ss_w3cv5lens': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv5lens.json/',
    'ss_w3cv5lens_fast': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv5lens_fast.json/',
    'ss_w3cv5lens2_fast': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv5lens2_fast.json/',
    'ss2_w3cv5lens2_fast': BASE_PATH + 'w3c_ss2/analysis/mappers_w3cv5lens2_fast.json/',
    'ss_w3cv5kval_fast': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv5kval_fast.json/',
    'ss2_w3cv5kval2_fast': BASE_PATH + 'w3c_ss2/analysis/mappers_w3cv5kval2_fast.json/',
    'ss_w3cv6lens_fast': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv6lens_fast.json/',
    'ss_w3cv6lens2_fast': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv6lens2_fast.json/',
    'ss_w3cv6kval_fast': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv6kval_fast.json/',
    'ss2_w3cv6kval2_fast': BASE_PATH + 'w3c_ss2/analysis/mappers_w3cv6kval2_fast.json/',
    'ss_w3cv8embed_fast': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv8embed_fast.json/',
    'wnoise_w3cv1': BASE_PATH + 'w3c_wnoise/analysis/mappers_w3cv1.json/',
    'wnoise_w3cv2': BASE_PATH + 'w3c_wnoise/analysis/mappers_w3cv2.json/',
    'wnoise_w3cv4': BASE_PATH + 'w3c_wnoise/analysis/mappers_w3cv4.json/',
    'wnoise_w3cv4euc': BASE_PATH + 'w3c_wnoise/analysis/mappers_w3cv4_euc.json/',
    'wnoise_w3cv5': BASE_PATH + 'w3c_wnoise/analysis/mappers_w3cv5dist.json/',
    'wnoise_w3cv6': BASE_PATH + 'w3c_wnoise/analysis/mappers_w3cv6dist.json/',
    'wnoise_w3cv5lens_fast': BASE_PATH + 'w3c_wnoise/analysis/mappers_w3cv5lens_fast.json/',
    'wnoise_w3cv6lens_fast': BASE_PATH + 'w3c_wnoise/analysis/mappers_w3cv6lens_fast.json/',
    'wnoise_w3cv5lens2_fast': BASE_PATH + 'w3c_wnoise/analysis/mappers_w3cv5lens2_fast.json/',
    'wnoise_w3cv6lens2_fast': BASE_PATH + 'w3c_wnoise/analysis/mappers_w3cv6lens2_fast.json/',
    'wnoise2_w3cv5lens2_fast': BASE_PATH + 'w3c_wnoise2/analysis/mappers_w3cv5lens2_fast.json/',
    'hightr_w3cv1': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv1.json/',
    'hightr_w3cv2': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv2.json/',
    'hightr_w3cv3': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv3.json/',
    'hightr_w3cv4': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv4.json/',
    'hightr_w3cv4euc': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv4_euc.json/',
    'hightr_w3cv5': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv5dist.json/',
    'hightr_w3cv6': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv6dist.json/',
    'hightr_w3cv5lens_fast': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv5lens_fast.json/',
    'hightr_w3cv6lens_fast': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv6lens_fast.json/',
    'hightr_w3cv5lens2_fast': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv5lens2_fast.json/',
    'hightr_w3cv6lens2_fast': BASE_PATH + 'w3c_hightr/analysis/mappers_w3cv6lens2_fast.json/',
    'hightr2_w3cv5lens2_fast': BASE_PATH + 'w3c_hightr2/analysis/mappers_w3cv5lens2_fast.json/',
    'hightr3_w3cv5lens2_fast': BASE_PATH + 'w3c_hightr3/analysis/mappers_w3cv5lens2_fast.json/',
    'hightr3_w3cv6kval_fast': BASE_PATH + 'w3c_hightr3/analysis/mappers_w3cv6kval_fast.json/',
    'hightr3_w3cv8embed_fastv2': BASE_PATH + 'w3c_hightr3/analysis/mappers_w3cv8embed_fastv2.json/',
    'hightr3_w3cv8embed_umap': BASE_PATH + 'w3c_hightr3/analysis/mappers_w3cv8embed_umap/',
    'hightr3_w3cv9clust': BASE_PATH + 'w3c_hightr3/analysis/mappers_w3cv9clust.json/',
}

_FILTERS = {}
for k in DATASETS.keys():
    if k.endswith('w3cv1') or k.endswith('w3cv3'):
        _FILTERS[k] = ['BDLMapper']
    elif k.endswith('w3cv2') or k.endswith('w3cv4'):
        _FILTERS[k] = ['NeuMapper']
    elif k.endswith('w3cv4euc'):
        _FILTERS[k] = ['EucNeuMapper']
    if k.endswith('w3cv5'):
        _FILTERS[k] = ['CustomBDLMapper', 'CMDSMapperNoKNN']
    if 'w3cv5lens' in k:
        _FILTERS[k] = ['DistsGeoBDLMapper', 'DistsBDLMapper']
    if 'w3cv5kval' in k:
        _FILTERS[k] = ['DistsGeoBDLMapper']
    if 'w3cv6lens' in k or 'w3cv6kval' in k:
        _FILTERS[k] = ['DistsGeoNeuMapper']
    if k.endswith('w3cv6'):
        _FILTERS[k] = ['CustomNeuMapper']
    if 'w3cv8embed_umap' in k:
        _FILTERS[k] = ['umapBDLMapperWtd', 'umapBDLMapperDist', 'umapBDLMapperPrep']
    elif 'w3cv8embed' in k:
        _FILTERS[k] = [
            'EmbedBDLMapperWtd', 'tSNEBDLMapperWtd', 'EmbedBDLMapperDist', 'tSNEBDLMapperDist', 'EmbedBDLMapperPrep', 'tSNEBDLMapperPrep',]
    if 'w3cv9clust' in k:
        _FILTERS[k] = ['ClustLinkBDLMapper', 'ClustDBSCANBDLMapper']
    if 'w3c-bins' in k:
        _FILTERS[k] = ['BDLMapper']
    if 'w3c-dists' in k:
        _FILTERS[k] = ['DistsGeoBDLMapper', 'DistsBDLMapper']
    if 'w3c-clust' in k:
        _FILTERS[k] = ['ClustLinkBDLMapper', 'ClustDBSCANBDLMapper']
FILTERS = _FILTERS

def get_plot_columns(mapper_name):
    if mapper_name == 'NeuMapper' or mapper_name == 'BDLMapper' or mapper_name == 'EucNeuMapper':
        fixedV, indexV, colV = 'R', 'K', 'G' # Most informative
    elif mapper_name == 'CustomBDLMapper' or mapper_name == 'CustomNeuMapper':
        fixedV, indexV, colV = 'dist', ['G', 'K'], ['preptype', 'R', 'linkbins']
    elif mapper_name == 'CMDSMapperNoKNN':
        fixedV, indexV, colV = 'dist', ['G', 'linkbins'], ['preptype', 'R']
    else:
        raise Exception('Cannot find plot vars (for columns) for Mapper {}'.format(mapper_name))
    return fixedV, indexV, colV
        
circle_loss_threshold = 10.0
