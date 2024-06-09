ARGS="cohort_csv='`pwd`/tutorials/tutorial2/cohort.csv';"
ARGS="$ARGS config_path='`pwd`/tutorials/tutorial2/mappers.json';"
ARGS="$ARGS output_dir='`pwd`/results/tutorial2_mappers';"
ARGS="$ARGS data_root='`pwd`';"
matlab -nodesktop -r "$ARGS run('code/analysis/run_main.m')"
