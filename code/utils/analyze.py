import csv
import os
import numpy as np

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

from matplotlib.colors import LogNorm, Normalize


# Given a dataset stats and results path, load in the DataFrame, merge and filter
def extract_dataset(stats_path, results_path, filter_by, parseparams_f, has_sbj=True):
    if type(filter_by) == list:
        assert len(filter_by) == 1, "Can only extract 1 type of mapper"
        filter_by = filter_by[0]
    stats = []
    with open(stats_path) as f:
        for row in csv.DictReader(f):
            obj = {}
            for k,v in row.items():
                if k == 'mapper':
                    obj[k] = v
                elif k.startswith('id'):
                    pass
                elif v == '':
                    obj[k] = 0
                else:
                    obj[k] = float(v)
            if has_sbj:
                obj['SBJ'] = row['id0'] # TODO! This only works for this type of data (fix!)
            stats.append(obj)
    print('len(stats): ', len(stats))


    MAX_INT = 100000
    results = []
    with open(results_path) as f:
        for row in csv.DictReader(f):
            obj = {}
            for k,v in row.items():
                if k == 'Mapper' or k == 'subject':
                    obj[k] = v
                else:
                    if v == 'Inf' or v == 'NaN':
                        obj[k] = MAX_INT
                    else:
                        obj[k] = float(v)
            results.append(obj)
    print('len(results): ', len(results))

    assert len(stats) == len(results), 'stats {}, results {}'.format(len(stats), len(results))

    dfs = pd.DataFrame(data=stats)
    dfr = pd.DataFrame(data=results)
    
    if has_sbj:
        df = pd.merge(dfr, dfs,  how='left', left_on=['Mapper','subject'], right_on = ['mapper','SBJ'])
    else:
        df = pd.merge(dfr, dfs,  how='left', left_on=['Mapper'], right_on = ['mapper'])
    # df = dfr.join(dfs.set_index('Mapper'), on='Mapper')
    
    # Use filter_by
    df = df[df['Mapper'].str.startswith(filter_by)]

    df, param_cols = parseparams_f(df, filter_by)

    # fix CircleLoss and TransitionBetweeness
    max_values = {}
    for colname in ["CircleLoss", "TransitionBetweeness"]:
        if colname in df.columns:
            if len(df[df[colname] < MAX_INT][colname]) == 0:
                raise Exception('There are no valid values for {}'.format(colname))
            new_max_loss = max(df[df[colname] < MAX_INT][colname]) * 1.5
            max_values[colname] = new_max_loss
            df[colname] = df.apply(lambda x: x[colname] if x[colname] != MAX_INT else new_max_loss, axis=1)

    main_cols = ['Mapper'] + (['SBJ'] if has_sbj else []) + param_cols
    other_cols = [c for c in df.columns.tolist() if c not in main_cols and c.lower() != 'mapper' and c != 'subject']
    df = df[main_cols + other_cols]
        
    return df, max_values


# Extract the subjects for each datset type and the combination that we should compute.
# for example: all SBJ2* would be SBJ20 and SBJ21
# For new datasets, this has to be changed
def get_all_parameters(df, dataset_name, silent=False):
    all_sbjs = df['SBJ'].unique().tolist()
    if not silent:
        print('Total {} subjects:'.format(len(all_sbjs)))
        for sbj in all_sbjs:
            print(sbj)


    sbjs_map = {}

    if dataset_name.startswith('ss_'):
        # This is for subsampled data
        for sbj in all_sbjs:
            sbjs_map[sbj] = [sbj]

        sbjs_map['SBJ2x'] = ['SBJ20', 'SBJ21']
        sbjs_map['SBJ4x'] = ['SBJ40', 'SBJ41', 'SBJ42', 'SBJ43']
        sbjs_map['SBJxx-50'] = [sbj for sbj in all_sbjs if sbj.endswith('-50.0')]
        sbjs_map['SBJxx-75'] = [sbj for sbj in all_sbjs if sbj.endswith('-75.0')]
        sbjs_map['SBJxx-83'] = [sbj for sbj in all_sbjs if sbj.endswith('-83.0')]
        sbjs_map['SBJxx-99'] = ['SBJ20', 'SBJ40', 'SBJ99']

    elif dataset_name.startswith('wnoise_'):
        # This is for wnoise data
        for sbj in all_sbjs:
            sbjs_map[sbj] = [sbj]

    elif dataset_name.startswith('hightr_'):
        # This is for subsampled data hightr
        for sbj in all_sbjs:
            sbjs_map[sbj] = [sbj]

        for i in [2,3,4]:
            sbjs_map['SBJe{}'.format(i)] = [s for s in all_sbjs if 'e{}v'.format(i) in s]

    if not silent:
        print('Extra combinations:')
        for sbjname, sbjs_list in sbjs_map.items():
            if len(sbjs_list) > 1:
                print(sbjname, ':', sbjs_list)
            
    return all_sbjs, sbjs_map

def _handle_list_cols(df, col):
    if type(col) == list:
        newcol = '_'.join(col)
        df[newcol] = df.apply(lambda x: '_'.join([str(x[c]) for c in col]), axis=1)
        col = newcol
    return df, col
    

# For a DataFrame, compute a big figure with multiple subplots
# Each row would be a different metric (some metrics are in log scale `log_metrics`)
# Each column is a different value of the fixedV column (usually `R`)
# For each subplot, x-axis is colV column (usually `G`) and y-axis is indexV column (usually `K`)
# The `sbj_group_name` is the name of the group of subjects
def plot_results(df, sbj_group_name, sbj_group, fixedV, indexV, colV, target_metrics, log_metrics, resdir):
    df, fixedV = _handle_list_cols(df, fixedV)
    df, indexV = _handle_list_cols(df, indexV)
    df, colV = _handle_list_cols(df, colV)
    
    if len(sbj_group):
        df_filter = df['SBJ'] == sbj_group[0]
        for idx in range(1,len(sbj_group)):
            df_filter = df_filter | (df['SBJ'] == sbj_group[idx])
    else:
        df_filter = df['G'] > 0
    
    newtypes = {}
    allcols = []
    for col in [fixedV, indexV, colV]:
        col = col if type(col) == list else [col]
        allcols.extend(col)
        for c in col:
            if c in ['K', 'G', 'R', 'linkbins']:
                newtypes[c] = 'int'
                
    # Filter and group by subject/subjects
    dff = df[df_filter]
    dff = dff.groupby(['Mapper'] + allcols).mean()
    dff = dff.reset_index().astype(newtypes)
    # Deprecated below
    # Don't recompute CircleLossRev as next line, average over the CircleLossRev!
    # dff['CircleLossRev'] = dff.apply(lambda x: 1.0 / x['CircleLoss'] if x['CircleLoss'] > 0 else 100, axis=1)

    fixed_vals = sorted(list(set(df[fixedV].to_list())))
    f, axr = plt.subplots(len(target_metrics), len(fixed_vals), figsize=(4 * len(fixed_vals), 4 * len(target_metrics)))

    for axc, target in zip(axr, target_metrics):
        vmin, vmax = min(df[target]), max(df[target]) # get vmin and vmax based on all results not only for the sbj group
        for col_idx,(K,ax) in enumerate(zip(fixed_vals,axc)):
            df_p = dff[dff[fixedV] == K].pivot(index=indexV, columns=colV, values=target)
            
            last_col = col_idx == len(axc) - 1
            if target in log_metrics:
                ax = sns.heatmap(df_p, norm=LogNorm(vmin=vmin, vmax=vmax), ax=ax, cbar=not last_col)
            else:
                ax = sns.heatmap(df_p, vmin=vmin, vmax=vmax, ax=ax, cbar=not last_col)
            ax.set_title('{} == {}'.format(fixedV, K))

            if last_col:
                ax1 = ax.twinx()
                ax1.set_ylabel(target)
                ax1.set_yticks([])

    plt.tight_layout()
    plt.savefig(os.path.join(resdir,'plot_results_{}.png'.format(sbj_group_name)))
    plt.close()
    
    
# Similar to `plot_results`, this function has a map of target_metrics to an interval.
# If the picked metric inside the interval, then the value is 1, otherwise its 0
# This figure also has a row of TOTAL where all metrics are combined to yield the combination of "AND" on all metrics
def plot_limits(df, sbj_group_name, sbj_group, fixedV, indexV, colV, target_metrics, resdir):
    df, fixedV = _handle_list_cols(df, fixedV)
    df, indexV = _handle_list_cols(df, indexV)
    df, colV = _handle_list_cols(df, colV)

    newtypes = {}
    allcols = []
    for col in [fixedV, indexV, colV]:
        col = col if type(col) == list else [col]
        allcols.extend(col)
        for c in col:
            if c in ['K', 'G', 'R', 'linkbins']:
                newtypes[c] = 'int'
    
    if len(sbj_group):
        df_filter = df['SBJ'] == sbj_group[0]
        for idx in range(1,len(sbj_group)):
            df_filter = df_filter | (df['SBJ'] == sbj_group[idx])
    else:
        df_filter = df['G'] > 0
    
    dff = df[df_filter]
    dff = dff.groupby(['Mapper'] + allcols).mean()
    dff = dff.reset_index().astype(newtypes)

    fixed_vals = sorted(list(set(df[fixedV].to_list())))
    f, axr = plt.subplots(len(target_metrics)+1, len(fixed_vals), figsize=(4 * len(fixed_vals), 4 * len(target_metrics) + 4))
    
    for axc, (target, lims) in zip(axr, target_metrics.items()):
        vmin, vmax = min(df[target]), max(df[target]) # get vmin and vmax based on all results not only for the sbj group
        for col_idx,(K,ax) in enumerate(zip(fixed_vals,axc)):
            df_p = dff[dff[fixedV] == K].pivot(index=indexV, columns=colV, values=target)
            df_wl = (df_p >= lims[0]) & (df_p <= lims[1]) # within limits
            
            last_col = col_idx == len(axc)-1
            ax = sns.heatmap(df_wl, vmin=0.0, vmax=1.0, ax=ax, cbar=not last_col)
            ax.set_title('{} == {}'.format(fixedV, K))
            if last_col:
                ax1 = ax.twinx()
                ax1.set_ylabel(target)
                ax1.set_yticks([])
                
    
    # plot the combined plot
    axc = axr[len(target_metrics)]

    for col_idx,(K,ax) in enumerate(zip(fixed_vals,axc)):
        comb_isset = False
        df_comb = None
        for target, lims in target_metrics.items():
            df_p = dff[dff[fixedV] == K].pivot(index=indexV, columns=colV, values=target)
            df_wl = (df_p >= lims[0]) & (df_p <= lims[1]) # within limits
            if not comb_isset:
                df_comb = df_wl
                comb_isset = True
            else:
                df_comb = df_comb & df_wl

        last_col = col_idx == len(axc)-1
        ax = sns.heatmap(df_comb, vmin=0.0, vmax=1.0, ax=ax, cbar=not last_col)
        ax.set_title('{} == {}'.format(fixedV, K))

        if last_col:
            ax1 = ax.twinx()
            ax1.set_ylabel('TOTAL')
            ax1.set_yticks([])


    plt.tight_layout()
    plt.savefig(os.path.join(resdir,'plot_limits_{}.png'.format(sbj_group_name)))
    plt.close()
