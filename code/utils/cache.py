import fire
import os
import json
import csv
import pandas as pd
from tqdm import tqdm

IDS = ['id0', 'id1', 'id2']

# Combine the stats from a Mapper results into a big stats file and then group by Mappers
def combine_compute_stats(cohort_path, mapper_dir, output_dir=None, skip_uncomputed=False):
  if not os.path.isfile(cohort_path):
    raise Exception('Need to point to a correct cohort file')
  if not os.path.isdir(mapper_dir):
    raise Exception('Need to point to a correct mapper_dir')
  if not output_dir:
    output_dir = mapper_dir
  if not os.path.isdir(output_dir):
    os.makedirs(output_dir)

  cohort = []
  with open(cohort_path) as f:
    for row in csv.DictReader(f):
      cohort.append(row)

  all_mappers = []
  mappers_used = {}
  for row in tqdm(cohort, desc='Finding all mappers'):
    row_id = '/'.join([row[i] for i in IDS])
    mappers = [m for m in os.listdir(os.path.join(mapper_dir, row_id)) if 'Mapper' in m]
    all_mappers.extend(mappers)
    all_mappers = list(set(all_mappers))
    mappers_used[row_id] = mappers

  errors_message = ''
  for row_id, mappers in mappers_used.items():
    if len(mappers) != len(all_mappers):
      missing_mappers = [m for m in all_mappers if m not in mappers]
      errors_message += 'Row {} has {} missing mappers: {} {}\n'.format(
        row_id, len(missing_mappers), ','.join(missing_mappers[:5]),
        '(first 5)' if len(missing_mappers) > 5 else '')
  if errors_message and not skip_uncomputed:
    print(errors_message)
    raise Exception(errors_message)


  stats = []
  no_stats = []
  for m in tqdm(sorted(mappers), desc='Extracting Stats'):
    for row in sorted(cohort, key=lambda x:x['id0']):
      row_id = '/'.join([row[i] for i in IDS])
      stats_path = os.path.join(mapper_dir, row_id, m, 'stats.json')
      if os.path.isfile(stats_path):
        with open(stats_path) as f:
          j = json.load(f)
          for i in IDS[::-1]:
            j[i] = row[i]
          j['mapper'] = m
          stats.append(j)
      else:
        j = { 'mapper': m }
        for i in IDS[::-1]:
          j[i] = row[i]
        no_stats.append(j)

  df = pd.DataFrame(data=stats)
  cols = df.columns.tolist()
  nonid_cols = [c for c in cols if c not in IDS and c != 'mapper']
  cols = IDS + ['mapper'] + nonid_cols
  df = df[cols]
  df.to_csv(os.path.join(output_dir, 'compute_stats-combined.csv'), float_format='%.9f', index=False)

  dfg1 = df.groupby('mapper')[['mapper'] + nonid_cols].mean()
  dfg1 = dfg1.rename(columns={c:c+'-mean' for c in dfg1.columns.tolist()})
  dfg2 = df.groupby('mapper')[['mapper'] + nonid_cols].std()
  dfg2 = dfg2.rename(columns={c:c+'-std' for c in dfg2.columns.tolist()})
  dfg = pd.concat([dfg1, dfg2], axis=1)
  dfg = dfg[sorted(dfg.columns.tolist())]
  dfg.to_csv(os.path.join(output_dir, 'compute_stats-averaged.csv'), float_format='%.9f')

  if len(no_stats):
    df_err = pd.DataFrame(data=no_stats)
    df_err.to_csv(os.path.join(output_dir, 'compute_stats-errored.csv'), index=False)
    print('Found {} errors. Printing them!'.format(len(no_stats)))

  print("Saved compute_stats to:", output_dir)


if __name__ == '__main__':
  fire.Fire({
    'compute_stats': combine_compute_stats
  })
