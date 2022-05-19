

FILE=commands_to_run_v3to6_hightr.m

echo '% starting ' > $FILE

# for CONF in mappers_w3cv1.json mappers_w3cv2.json
for CONF in mappers_w3cv3.json mappers_w3cv4.json mappers_w3cv5dist.json mappers_w3cv6dist.json
do

  # DATAFOLDER="/scratch/groups/saggar/demapper-w3c/${CONF}/"
  # COHORT_PATH="/scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_short.csv"
  # OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/analysis/${CONF}/"
  # ARGS="datafolder='${DATAFOLDER}'; cohort_path='${COHORT_PATH}'; output_dir='${OUTPUT_DIR}';"
  # echo "clear" >> $FILE
  # echo "${ARGS} run('code/w3c/circle_test_multitiming.m')" >> $FILE


  # DATAFOLDER="/scratch/groups/saggar/demapper-w3c/wnoise_results/${CONF}/"
  # FN_TIMING="/scratch/groups/saggar/demapper-w3c/data/task_info.csv"
  # OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/wnoise_results/analysis/${CONF}/"
  # ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}';"
  # echo "clear" >> $FILE
  # echo "${ARGS} run('code/w3c/circle_test.m')" >> $FILE


  DATAFOLDER="/scratch/groups/saggar/demapper-w3c/hightr_results/${CONF}/"
  COHORT_PATH="/scratch/groups/saggar/demapper-w3c/data_hightr/cohort.csv"
  OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/hightr_results/analysis/${CONF}/"
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
