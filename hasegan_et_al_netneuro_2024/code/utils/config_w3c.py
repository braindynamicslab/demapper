import os
import pandas as pd
import numpy as np
from dotenv import load_dotenv
load_dotenv()  # take environment variables from .env.

BASE_PATH = os.path.join(os.environ['WORKSPACE'], 'results/')

DATASETS = {
    'w3c-bins1': BASE_PATH + 'w3c/analysis/mappers_w3c_bins1.json/',
    'w3c-bins2': BASE_PATH + 'w3c/analysis/mappers_w3c_bins2.json/',
    'w3c-dists2': BASE_PATH + 'w3c/analysis/mappers_w3c_dists2.json/',
    'w3c-dists3': BASE_PATH + 'w3c-wnoise/analysis/mappers_w3c_dists3.json/',
    'w3c-dists4': BASE_PATH + 'w3c-hightr/analysis/mappers_w3c_dists4.json/',
    'w3c-clust1': BASE_PATH + 'w3c/analysis/mappers_w3c_clust1.json/',
    'w3c-embed1': BASE_PATH + 'w3c/analysis/mappers_w3c_embed1.json/',
}

_FILTERS = {}
for k in DATASETS.keys():
    if 'w3c-bins' in k:
        _FILTERS[k] = ['BDLMapper']
    if 'w3c-dists' in k:
        _FILTERS[k] = ['DistsGeoBDLMapper', 'DistsBDLMapper']
    if 'w3c-clust' in k:
        _FILTERS[k] = ['ClustLinkBDLMapper', 'ClustDBSCANBDLMapper']
    if 'w3c-embed' in k:
        _FILTERS[k] = ['EmbedBDLMapperWtd', 'tSNEBDLMapperWtd', 'KEmbedBDLMapper']
FILTERS = _FILTERS
