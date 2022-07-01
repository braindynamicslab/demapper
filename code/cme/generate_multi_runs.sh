#!/bin/bash

for CHNR in 7 8 10 11
do
FILE=commands_to_run_cmev3v4_ch${CHNR}.m
echo '% starting ' > $FILE
for CONF in mappers_cmev3_fast.json mappers_cmev4_fast.json \
            mappers_cmev4_euc_fast.json mappers_cmev4_euc.json \
            mappers_cmev5.json mappers_cmev5MH.json
do
  DATAFOLDER="/scratch/groups/saggar/demapper-cme/${CONF}/"
  FN_TIMING="/oak/stanford/groups/saggar/data-cme-shine375/timing.csv"
  OUTPUT_DIR="/scratch/groups/saggar/demapper-cme/analysis/ch${CHNR}_${CONF}/"
  STAT_TYPE="compute_degrees_from_TCM" # "compute_degrees_from_TCM", "compute_degrees", "degrees_TRs"
  CHANGE_POINTS=${CHNR}
  HAS_INSTRUCTIONS=1;
  ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}'; stat_type='${STAT_TYPE}';"
  ARGS="$ARGS HAS_INSTRUCTIONS=${HAS_INSTRUCTIONS}; CHANGE_POINTS=${CHANGE_POINTS};"
  echo "clear" >> $FILE
  echo "${ARGS} run('code/cme/deg_analysis_sbjs.m')" >> $FILE

done
done
