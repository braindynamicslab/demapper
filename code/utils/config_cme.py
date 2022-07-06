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

def extract_params_f(df, filter_by):
    param_cols = None
    if filter_by == 'BDLMapper' or filter_by == 'NeuMapper' or filter_by == 'EucNeuMapper':
        df['K'] = df.apply(lambda x: int(x['Mapper'].split('_')[1]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        param_cols = ['K', 'R', 'G']
    elif filter_by == 'CustomBDLMapper' or filter_by == 'CustomNeuMapper':
        df['preptype'] = df.apply(lambda x: x['Mapper'].split('_')[1], axis=1)
        df['dist'] = df.apply(lambda x: x['Mapper'].split('_')[2], axis=1)
        df['K'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[5]), axis=1)
        df['linkbins'] = df.apply(lambda x: int(x['Mapper'].split('_')[6]), axis=1)
        param_cols = ['preptype', 'dist', 'K', 'R', 'G', 'linkbins']
    elif filter_by == 'CMDSMapperNoKNN':
        df['preptype'] = df.apply(lambda x: x['Mapper'].split('_')[1], axis=1)
        df['dist'] = df.apply(lambda x: x['Mapper'].split('_')[2], axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        df['linkbins'] = df.apply(lambda x: int(x['Mapper'].split('_')[5]), axis=1)
        param_cols = ['preptype', 'dist', 'R', 'G', 'linkbins']
    elif filter_by == 'BDLMapperNS3':
        df['prelens_type'] = df.apply(lambda x: x['Mapper'].split('_')[1], axis=1)
        df['K'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        param_cols = ['prelens_type', 'K', 'R', 'G']
    elif filter_by == 'BDLMapperMH_':
        df['prelens_type'] = df.apply(lambda x: x['Mapper'].split('_')[1], axis=1)
        df['K'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        df['NS'] = df.apply(lambda x: int(x['Mapper'].split('_')[5]), axis=1)
        param_cols = ['prelens_type', 'K', 'R', 'G', 'NS']
    elif filter_by == 'BDLMapperMHNoKnn':
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[1]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['NS'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        param_cols = ['R', 'G', 'NS']
    elif filter_by in ['DistsGeoBDLMapper', 'DistsGeoNeuMapper']:
        df['dist'] = df.apply(lambda x: x['Mapper'].split('_')[1], axis=1)
        df['K'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        param_cols = ['dist', 'K', 'R', 'G']
    elif filter_by == 'DistsBDLMapper':
        df['dist'] = df.apply(lambda x: x['Mapper'].split('_')[1], axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        param_cols = ['dist', 'R', 'G']
    else:
        raise Exception('Mapper type not recognized')
    return df, param_cols
