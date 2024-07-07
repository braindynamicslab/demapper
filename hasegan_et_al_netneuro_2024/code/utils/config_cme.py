import os
import pandas as pd
import numpy as np
from dotenv import load_dotenv
load_dotenv()  # take environment variables from .env.

BASE_PATH = os.path.join(os.environ['WORKSPACE'], 'results/')

def ch_ds(ch):
    locs = {
        'cme-bins1': BASE_PATH + 'cme/analysis/mappers_cme_bins1.json',
        'cme-bins2': BASE_PATH + 'cme/analysis/mappers_cme_bins2.json',
        'cme-dists2': BASE_PATH + 'cme/analysis/mappers_cme_dists2.json',
        'cme-clust1': BASE_PATH + 'cme/analysis/mappers_cme_clust1.json',
        'cme-embed1': BASE_PATH + 'cme/analysis/mappers_cme_embed1.json',
        'cme-shufPN': BASE_PATH + 'cme/analysis/mappers_cme.json',
    }
    for i in range(1, 21):
        locs[f'cme-shufP{i}'] = BASE_PATH + f'cme-shufs/P{i}/analysis/mappers_cme.json'
    return locs

ALL_DATASETS = {
    'ch7': ch_ds('ch7'),
    'ch8': ch_ds('ch8'),
    'ch10': ch_ds('ch10'),
    'ch11': ch_ds('ch11'),
}
DATASETS = ALL_DATASETS['ch10']

_FILTERS = {}
for k in DATASETS.keys():
    if k.startswith('cme-bins'):
        _FILTERS[k] = ['BDLMapper']
    elif k.startswith('cme-dists'):
        _FILTERS[k] = ['DistsGeoBDLMapper', 'DistsBDLMapper', 'DistsGeoNeuMapper']
    elif k.startswith('cme-clust'):
        _FILTERS[k] = ['ClustLinkBDLMapper', 'ClustDBSCANBDLMapper']
    elif k.startswith('cme-embed'):
        _FILTERS[k] = ['EmbedBDLMapperWtd', 'tSNEBDLMapperWtd', 'KEmbedBDLMapper']
    elif k.startswith('cme-shuf'):
        _FILTERS[k] = ['BDLMapper', 'NeuMapper']
FILTERS = _FILTERS
