ARGS="cohort_csv='`pwd`/tutorials/tutorial3/cohort.csv';"
ARGS="$ARGS config_path='`pwd`/tutorials/tutorial3/mappers.json';"
ARGS="$ARGS output_dir='`pwd`/results/tutorial3_mappers';"
ARGS="$ARGS data_root='`pwd`/tutorials/tutorial3/';"
ARGS="$ARGS data_root='`pwd`/tutorials/tutorial3/';"

# new arguments
ARGS="${ARGS} poolsize=8;" # generate 8 parallel workers
ARGS="${ARGS} rerun_uncomputed=1;"  # Rerun Uncomputed

matlab -nodesktop -r "$ARGS run('code/analysis/run_main.m')"
