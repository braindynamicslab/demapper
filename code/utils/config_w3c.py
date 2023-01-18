import os
import pandas as pd
import numpy as np


BASE_PATH = '/Users/dh/workspace/BDL/demapper/results/'

DATASETS = {
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
    'ss_w3cv6lens_fast': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv6lens_fast.json/',
    'ss_w3cv6lens2_fast': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv6lens2_fast.json/',
    'ss_w3cv6kval_fast': BASE_PATH + 'w3c_ss/analysis/mappers_w3cv6kval_fast.json/',
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
    if 'w3cv8embed' in k:
        _FILTERS[k] = ['EmbedBDLMapperWtd', 'tSNEBDLMapperWtd', 'EmbedBDLMapperDist', 'tSNEBDLMapperDist', 'EmbedBDLMapperPrep', 'tSNEBDLMapperPrep']
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
    elif filter_by == 'EmbedBDLMapperWtd':
        df['K'] = df.apply(lambda x: int(x['Mapper'].split('_')[1]), axis=1)
        df['embed'] = df.apply(lambda x: x['Mapper'].split('_')[2], axis=1)
        df['edim'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[5]), axis=1)
        param_cols = ['K', 'embed', 'edim', 'R', 'G']
    elif filter_by == 'tSNEBDLMapperWtd':
        df['K'] = df.apply(lambda x: int(x['Mapper'].split('_')[1]), axis=1)
        df['perplexity'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['edim'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[5]), axis=1)
        param_cols = ['K', 'perplexity', 'edim', 'R', 'G']
    elif filter_by == 'EmbedBDLMapperDist' or filter_by == 'EmbedBDLMapperPrep':
        df['embed'] = df.apply(lambda x: x['Mapper'].split('_')[1], axis=1)
        df['edim'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        param_cols = ['embed', 'edim', 'R', 'G']
    elif filter_by == 'tSNEBDLMapperDist' or filter_by == 'tSNEBDLMapperPrep':
        df['perplexity'] = df.apply(lambda x: int(x['Mapper'].split('_')[1]), axis=1)
        df['edim'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        param_cols = ['perplexity', 'edim', 'R', 'G']
    else:
        raise Exception('Mapper type not recognized')
    return df, param_cols
