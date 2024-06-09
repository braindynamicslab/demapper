ARGS="cohort_csv='`pwd`/tutorials/tutorial3/cohort_wtask.csv';"
ARGS="$ARGS config_path='`pwd`/tutorials/tutorial3/mappers_wtask.json';"
ARGS="$ARGS output_dir='`pwd`/results/tutorial3_mappers_wtask';"
ARGS="$ARGS data_root='`pwd`/tutorials/tutorial3/';"
ARGS="${ARGS} poolsize=8;" # generate 8 parallel workers

matlab -nodesktop -r "$ARGS run('code/analysis/run_main.m')"
