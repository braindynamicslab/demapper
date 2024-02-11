#!/bin/bash

### [0] Set the env (generated w/ chatgpt)
current_dir=$(pwd)
while [ "$current_dir" != "/" ]; do
  if [ -f "$current_dir/.env" ]; then
    echo "Running .env file in directory: $current_dir"
    source "$current_dir/.env"
    break
  fi
  current_dir=$(dirname "$current_dir")
done


### [1] Parse the arguments
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi


POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--rerun_uncomputed)
      RERUN_UNCOMPUTED=YES
      shift # past value
      ;;
    -a|--rerun_analysis)
      RERUN_ANALYSIS="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--poolsize)
      POOLSIZE="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

### End of parsing arguments

### [2] SETUP Configuration
CONF=$1
CONFPATH="$WORKSPACE/code/configs/${CONF}"
if [ -f "$CONFPATH" ]; then
    echo "=== Using Configuration: $CONF"
else 
    echo "There is no configuration at '${CONF}'"
    exit 1
fi

DATASET=$2
case $DATASET in

  w3c)
    COHORT_CSV="$WORKSPACE/data/w3c/cohort.csv"
    DATA_ROOT="$WORKSPACE/data/w3c/"
    OUTPUT_DIR="$WORKSPACE/results/w3c/${CONF}"
    ;;

  cme)
    COHORT_CSV="$WORKSPACE/data/cme/shine/cohort.csv"
    DATA_ROOT="$WORKSPACE/data/cme/shine"
    OUTPUT_DIR="$WORKSPACE/results/cme/${CONF}"
    ;;

  w3c-wnoise)
    COHORT_CSV="$WORKSPACE/data/w3c-wnoise/cohort.csv"
    DATA_ROOT="$WORKSPACE/data/w3c-wnoise/"
    OUTPUT_DIR="$WORKSPACE/results/w3c-wnoise/${CONF}"
    ;;

  w3c-hightr)
    COHORT_CSV="$WORKSPACE/data/w3c-hightr/cohort.csv"
    DATA_ROOT="$WORKSPACE/data/w3c-hightr/"
    OUTPUT_DIR="$WORKSPACE/results/w3c-hightr/${CONF}"
    ;;

  *)
    echo "Dataset not found! '${DATASET}'"
    ;;
esac

# Load matlab # <-- not needed here
# module load matlab

DEMAPPER_MAIN="$DEMAPPER/code/analysis/run_main.m"

MATLAB_ARGS=""
MATLAB_ARGS="${MATLAB_ARGS} cohort_csv='${COHORT_CSV}';"
MATLAB_ARGS="${MATLAB_ARGS} config_path='${CONFPATH}';"
MATLAB_ARGS="${MATLAB_ARGS} data_root='${DATA_ROOT}';"
MATLAB_ARGS="${MATLAB_ARGS} output_dir='${OUTPUT_DIR}';"

if [[ -n ${POOLSIZE} ]]; then
  MATLAB_ARGS="${MATLAB_ARGS} poolsize=$POOLSIZE;"
fi
if [[ -n ${RERUN_UNCOMPUTED} ]]; then
    MATLAB_ARGS="${MATLAB_ARGS} rerun_uncomputed=1;"
fi
if [[ -n ${RERUN_ANALYSIS} ]]; then
    MATLAB_ARGS="${MATLAB_ARGS} rerun_analysis='${RERUN_ANALYSIS}';"
fi

# write command, submit, wait
CMD="matlab -nodesktop -r \"${MATLAB_ARGS} run('$DEMAPPER_MAIN')\"";
echo $CMD;
eval $CMD;
wait
