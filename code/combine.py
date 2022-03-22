import fire
import os
import json
import pandas as pd

# Combine the stats from a Mapper results into a big stats file and then group by Mappers
def combine(datafolder, output_dir):
  sbjs = [fname for fname in os.listdir(datafolder) if fname.startswith('SBJ')]

  all_mappers = []
  for sbj in sorted(sbjs):
    print(sbj)
    mappers = [m for m in os.listdir(os.path.join(datafolder, sbj)) if 'Mapper' in m]
    all_mappers.extend(mappers)
    all_mappers = list(set(all_mappers))
    if len(mappers) != len(all_mappers):
      raise Error('Sbj {} has too few or too many mappers'.format(sbj))

  stats = []
  for m in sorted(mappers):
    print(m)
    for sbj in sorted(sbjs):
      stats_path = os.path.join(datafolder, sbj, m, 'stats.json')
      with open(stats_path) as f:
        j = json.load(f)
        j['SBJ'] = sbj
        j['Mapper'] = m
        stats.append(j)

  df = pd.DataFrame(data=stats)
  cols = df.columns.tolist()
  cols.reverse()
  df = df[cols]
  df.to_csv(os.path.join(output_dir, 'stats.csv'), float_format='%.6f')

  dfg1 = df.groupby('Mapper').mean()
  dfg1 = dfg1.rename(columns={c:c+'-mean' for c in dfg1.columns.tolist()})
  dfg2 = df.groupby('Mapper').std()
  dfg2 = dfg2.rename(columns={c:c+'-std' for c in dfg2.columns.tolist()})
  dfg = pd.concat([dfg1, dfg2], axis=1)
  dfg = dfg[sorted(dfg.columns.tolist())]
  dfg.to_csv(os.path.join(output_dir, 'stats-Mappers.csv'), float_format='%.6f')


if __name__ == '__main__':
  fire.Fire(combine)
