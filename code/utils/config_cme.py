import pandas as pd
import numpy as np


def ch_ds(ch):
    return {
        'cmev3': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev3.json'.format(ch),
        'cmev4': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev4.json'.format(ch),
        'cmev4euc': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev4_euc.json'.format(ch),
        'cmev3_fast': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev3_fast.json'.format(ch),
        'cmev4_fast': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev4_fast.json'.format(ch),
        'cmev4euc_fast': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev4_euc_fast.json'.format(ch),
        'cmev5': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev5.json'.format(ch),
        'cmev5MH': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev5MH.json'.format(ch),
        'cmev6kval': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev6kval_fast.json'.format(ch),
        'cmev7kval': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev7kval_fast.json'.format(ch),
        'cmev8clust': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev8clust.json'.format(ch),
        'cmev9embed': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev9embed_fast.json'.format(ch),
        'cmev9umap': '/Users/dh/workspace/BDL/demapper/results/cme/{}_mappers_cmev9embed_umap.json'.format(ch),
    }

ALL_DATASETS = {
    'ch7': ch_ds('ch7'),
    'ch8': ch_ds('ch8'),
    'ch10': ch_ds('ch10'),
    'ch11': ch_ds('ch11'),
}
DATASETS = ALL_DATASETS['ch8']

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
