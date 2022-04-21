

echo '% starting ' > commands_to_run.m

for CONF in mappers_w3cv1.json mappers_w3cv2.json
do

  DATAFOLDER="/scratch/groups/saggar/demapper-w3c/${CONF}/"
  COHORT_PATH="/scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_short.csv"
  OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/analysis/${CONF}/"
  ARGS="datafolder='${DATAFOLDER}'; cohort_path='${COHORT_PATH}'; output_dir='${OUTPUT_DIR}';"
  echo "clear" >> commands_to_run.m
  echo "${ARGS} run('code/w3c/circle_test_multitiming.m')" >> commands_to_run.m


  DATAFOLDER="/scratch/groups/saggar/demapper-w3c/wnoise_results/${CONF}/"
  FN_TIMING="/scratch/groups/saggar/demapper-w3c/data/task_info.csv"
  OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/wnoise_results/analysis/${CONF}/"
  ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}';"
  echo "clear" >> commands_to_run.m
  echo "${ARGS} run('code/w3c/circle_test.m')" >> commands_to_run.m


  DATAFOLDER="/scratch/groups/saggar/demapper-w3c/hightr_results/${CONF}/"
  COHORT_PATH="/scratch/groups/saggar/demapper-w3c/data_hightr/cohort.csv"
  OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/hightr_results/analysis/${CONF}/"
  ARGS="datafolder='${DATAFOLDER}'; cohort_path='${COHORT_PATH}'; output_dir='${OUTPUT_DIR}';"
  echo "clear" >> commands_to_run.m
  echo "${ARGS} run('code/w3c/circle_test_multitiming.m')" >> commands_to_run.m

done

# Then run 
# module load matlab
# matlab
