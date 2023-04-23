
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
    elif filter_by == 'umapBDLMapperWtd':
        df['K'] = df.apply(lambda x: int(x['Mapper'].split('_')[1]), axis=1)
        df['eK'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['edim'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[5]), axis=1)
        param_cols = ['K', 'eK', 'edim', 'R', 'G']
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
    elif filter_by == 'umapBDLMapperDist' or filter_by == 'umapBDLMapperPrep':
        df['eK'] = df.apply(lambda x: int(x['Mapper'].split('_')[1]), axis=1)
        df['edim'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        param_cols = ['eK', 'edim', 'R', 'G']
    elif filter_by == 'ClustLinkBDLMapper':
        df['K'] = df.apply(lambda x: int(x['Mapper'].split('_')[1]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['linkbins'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        param_cols = ['K', 'R', 'G', 'linkbins']
    elif filter_by == 'ClustDBSCANBDLMapper':
        df['K'] = df.apply(lambda x: int(x['Mapper'].split('_')[1]), axis=1)
        df['R'] = df.apply(lambda x: int(x['Mapper'].split('_')[2]), axis=1)
        df['G'] = df.apply(lambda x: int(x['Mapper'].split('_')[3]), axis=1)
        df['clustEps'] = df.apply(lambda x: int(x['Mapper'].split('_')[4]), axis=1)
        param_cols = ['K', 'R', 'G', 'clustEps']
    else:
        raise Exception('Mapper type not recognized')
    return df, param_cols
