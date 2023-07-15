import pandas as pd
import numpy as np

BASE_PATH = '/Users/dh/workspace/BDL/demapper/results/'

def ch_ds(ch):
    return {
        'cme-bins1': BASE_PATH + 'cme/analysis/mappers_cme_bins1.json',
        'cme-bins2': BASE_PATH + 'cme/analysis/mappers_cme_bins2.json',
        'cme-dists2': BASE_PATH + 'cme/analysis/mappers_cme_dists2.json',
        'cme-clust1': BASE_PATH + 'cme/analysis/mappers_cme_clust1.json',
        'cme-embed1': BASE_PATH + 'cme/analysis/mappers_cme_embed1.json',
        'cmev3': BASE_PATH + 'cme/{}_mappers_cmev3.json'.format(ch),
        'cmev4': BASE_PATH + 'cme/{}_mappers_cmev4.json'.format(ch),
        'cmev4euc': BASE_PATH + 'cme/{}_mappers_cmev4_euc.json'.format(ch),
        'cmev3_fast': BASE_PATH + 'cme/{}_mappers_cmev3_fast.json'.format(ch),
        'cmev4_fast': BASE_PATH + 'cme/{}_mappers_cmev4_fast.json'.format(ch),
        'cmev4euc_fast': BASE_PATH + 'cme/{}_mappers_cmev4_euc_fast.json'.format(ch),
        'cmev5': BASE_PATH + 'cme/{}_mappers_cmev5.json'.format(ch),
        'cmev5MH': BASE_PATH + 'cme/{}_mappers_cmev5MH.json'.format(ch),
        'cmev6kval': BASE_PATH + 'cme/{}_mappers_cmev6kval_fast.json'.format(ch),
        'cmev7kval': BASE_PATH + 'cme/{}_mappers_cmev7kval_fast.json'.format(ch),
        'cmev8clust': BASE_PATH + 'cme/{}_mappers_cmev8clust.json'.format(ch),
        'cmev9embed': BASE_PATH + 'cme/{}_mappers_cmev9embed_fast.json'.format(ch),
        'cmev9umap': BASE_PATH + 'cme/{}_mappers_cmev9embed_umap.json'.format(ch),
    }

ALL_DATASETS = {
    'ch7': ch_ds('ch7'),
    'ch8': ch_ds('ch8'),
    'ch10': ch_ds('ch10'),
    'ch11': ch_ds('ch11'),
}
DATASETS = ALL_DATASETS['ch10']

_FILTERS = {}
for k in DATASETS.keys():
    if k.endswith('cmev1') or k.startswith('cmev3'):
        _FILTERS[k] = ['BDLMapper']
    elif k.startswith('cmev4euc'):
        _FILTERS[k] = ['EucNeuMapper']
    elif k.startswith('cmev2') or  k.startswith('cmev4'):
        _FILTERS[k] = ['NeuMapper']
    elif k == 'cmev5':
        _FILTERS[k] = ['BDLMapperNS3']
    elif k == 'cmev5MH':
        _FILTERS[k] = ['BDLMapperMH_', 'BDLMapperMHNoKnn']
    elif k == 'cmev6kval':
        _FILTERS[k] = ['DistsGeoBDLMapper', 'DistsBDLMapper', 'DistsGeoNeuMapper']
    elif k == 'cmev7kval':
        _FILTERS[k] = ['DistsGeoNeuMapper']
    elif k == 'cmev8clust':
        _FILTERS[k] = ['ClustLinkBDLMapper', 'ClustDBSCANBDLMapper']
    elif k == 'cmev9embed':
        _FILTERS[k] = ['EmbedBDLMapperWtd', 'tSNEBDLMapperWtd', 'tSNEBDLMapperPrep']
    elif k == 'cmev9umap':
        _FILTERS[k] = ['umapBDLMapperPrep']
    elif k.startswith('cme-bins'):
        _FILTERS[k] = ['BDLMapper']
    elif k.startswith('cme-dists'):
        _FILTERS[k] = ['DistsGeoBDLMapper', 'DistsBDLMapper', 'DistsGeoNeuMapper']
    elif k.startswith('cme-clust'):
        _FILTERS[k] = ['ClustLinkBDLMapper', 'ClustDBSCANBDLMapper']
    elif k.startswith('cme-embed'):
        _FILTERS[k] = ['EmbedBDLMapperWtd', 'tSNEBDLMapperWtd', 'KEmbedBDLMapper']
FILTERS = _FILTERS

def get_plot_columns(mapper_name):
    if mapper_name == 'NeuMapper' or mapper_name == 'BDLMapper' or mapper_name == 'EucNeuMapper':
        fixedV, indexV, colV = 'R', 'K', 'G' # Most informative
    elif mapper_name == 'CustomBDLMapper' or mapper_name == 'CustomNeuMapper':
        fixedV, indexV, colV = 'dist', ['G', 'K'], ['preptype', 'R', 'linkbins']
    elif mapper_name == 'CMDSMapperNoKNN':
        fixedV, indexV, colV = 'dist', ['G', 'linkbins'], ['preptype', 'R']
    elif mapper_name == 'BDLMapperNS3':
        fixedV, indexV, colV = 'K', ['prelens_type', 'R'], 'G'
    elif mapper_name == 'BDLMapperMH_':
        fixedV, indexV, colV = ['prelens_type', 'NS'], ['K', 'R'], 'G'
    elif mapper_name == 'BDLMapperMHNoKnn':
        fixedV, indexV, colV = 'NS', 'R', 'G'
    else:
        raise Exception('Cannot find plot vars (for columns) for Mapper {}'.format(mapper_name))
    return fixedV, indexV, colV
