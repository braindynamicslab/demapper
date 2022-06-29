MAPPER_CONFIG=mappers_cmev3_fast.json
mkdir ch8_${MAPPER_CONFIG}
cd ch8_${MAPPER_CONFIG}
scp "hasegan@login.sherlock.stanford.edu:/scratch/groups/saggar/demapper-cme/${MAPPER_CONFIG}/compute_stats-*" .
scp -r "hasegan@login.sherlock.stanford.edu:/scratch/groups/saggar/demapper-cme/analysis/ch8_${MAPPER_CONFIG}/compute_degrees_from_TCM" .
