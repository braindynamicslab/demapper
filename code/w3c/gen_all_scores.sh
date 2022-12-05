

FILE=commands_to_run_v3to6_hightr.m
FILE=commands_to_run_w3cv5lens2_hightr2.m

echo '% starting ' > $FILE

# CONF=mappers_w3cv5lens2_fast.json
# for CONF in mappers_w3cv1.json mappers_w3cv2.json
for CONF in mappers_w3cv3.json mappers_w3cv4.json mappers_w3cv5dist.json mappers_w3cv6dist.json
do

  DATAFOLDER="/scratch/groups/saggar/demapper-w3c/${CONF}/"
  COHORT_PATH="/scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_short.csv"
  OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/analysis/${CONF}/"
  ARGS="datafolder='${DATAFOLDER}'; cohort_path='${COHORT_PATH}'; output_dir='${OUTPUT_DIR}';"
  echo "clear" >> $FILE
  echo "${ARGS} run('code/w3c/circle_test_multitiming.m')" >> $FILE

  DATAFOLDER="/scratch/groups/saggar/demapper-w3c/ss2_results/${CONF}/"
  COHORT_PATH="$HOME/projects/w3c_ss2/cohort_mapper.csv"
  OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/ss2_results/analysis/${CONF}/"
  ARGS="datafolder='${DATAFOLDER}'; cohort_path='${COHORT_PATH}'; output_dir='${OUTPUT_DIR}';"
  echo "clear" >> $FILE
  echo "${ARGS} run('code/w3c/circle_test_multitiming.m')" >> $FILE


  DATAFOLDER="/scratch/groups/saggar/demapper-w3c/wnoise2_results/${CONF}/"
  FN_TIMING="/oak/stanford/groups/saggar/demapper/data/w3c/data_subsampled/task_info_99.csv"
  OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/wnoise2_results/analysis/${CONF}/"
  ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}';"
  echo "clear" >> $FILE
  echo "${ARGS} run('code/w3c/circle_test.m')" >> $FILE


  DATAFOLDER="/scratch/groups/saggar/demapper-w3c/hightr2_results/${CONF}/"
  COHORT_PATH="$HOME/projects/w3c_hightr2/cohort_mapper.csv"
  OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/hightr2_results/analysis/${CONF}/"
  ARGS="datafolder='${DATAFOLDER}'; cohort_path='${COHORT_PATH}'; output_dir='${OUTPUT_DIR}';"
  echo "clear" >> $FILE
  echo "${ARGS} run('code/w3c/circle_test_multitiming.m')" >> $FILE

done

# Then run 
# module load matlab
# matlab
# 
# run('commands_to_run.m')


# Copy scores after done:
cd $GROUP_SCRATCH/demapper-w3c
cp analysis/mappers_w3cv1.json/scores-all.csv scores/scores-ss_w3cv1-all.csv
cp wnoise_results/analysis/mappers_w3cv1.json/scores-all.csv scores/scores-wnoise_w3cv1-all.csv
cp hightr_results/analysis/mappers_w3cv1.json/scores-all.csv scores/scores-hightr_w3cv1-all.csv

cp analysis/mappers_w3cv2.json/scores-all.csv scores/scores-ss_w3cv2-all.csv
cp wnoise_results/analysis/mappers_w3cv2.json/scores-all.csv scores/scores-wnoise_w3cv2-all.csv
cp hightr_results/analysis/mappers_w3cv2.json/scores-all.csv scores/scores-hightr_w3cv2-all.csv


cp analysis/mappers_w3cv1.json/scores.csv scores/scores-ss_w3cv1.csv
cp wnoise_results/analysis/mappers_w3cv1.json/scores.csv scores/scores-wnoise_w3cv1.csv
cp hightr_results/analysis/mappers_w3cv1.json/scores.csv scores/scores-hightr_w3cv1.csv

cp analysis/mappers_w3cv2.json/scores.csv scores/scores-ss_w3cv2.csv
cp wnoise_results/analysis/mappers_w3cv2.json/scores.csv scores/scores-wnoise_w3cv2.csv
cp hightr_results/analysis/mappers_w3cv2.json/scores.csv scores/scores-hightr_w3cv2.csv

# Local download all scores


scp "hasegan@login.sherlock.stanford.edu:/scratch/groups/saggar/demapper-w3c/scores/*" scores/

cp scores/scores-ss_w3cv1-all.csv w3c_ss/analysis/mappers_w3cv1.json/scores-all.csv
cp scores/scores-wnoise_w3cv1-all.csv w3c_wnoise/analysis/mappers_w3cv1.json/scores-all.csv
cp scores/scores-hightr_w3cv1-all.csv w3c_hightr/analysis/mappers_w3cv1.json/scores-all.csv
cp scores/scores-ss_w3cv1.csv w3c_ss/analysis/mappers_w3cv1.json/scores.csv
cp scores/scores-wnoise_w3cv1.csv w3c_wnoise/analysis/mappers_w3cv1.json/scores.csv
cp scores/scores-hightr_w3cv1.csv w3c_hightr/analysis/mappers_w3cv1.json/scores.csv

cp scores/scores-ss_w3cv2-all.csv w3c_ss/analysis/mappers_w3cv2.json/scores-all.csv
cp scores/scores-wnoise_w3cv2-all.csv w3c_wnoise/analysis/mappers_w3cv2.json/scores-all.csv
cp scores/scores-hightr_w3cv2-all.csv w3c_hightr/analysis/mappers_w3cv2.json/scores-all.csv
cp scores/scores-ss_w3cv2.csv w3c_ss/analysis/mappers_w3cv2.json/scores.csv
cp scores/scores-wnoise_w3cv2.csv w3c_wnoise/analysis/mappers_w3cv2.json/scores.csv
cp scores/scores-hightr_w3cv2.csv w3c_hightr/analysis/mappers_w3cv2.json/scores.csv
