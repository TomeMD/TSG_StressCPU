#!/bin/bash

function usage {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]
  -v, --os-virt             Technology for OS-level virtualization. [Default]
                                docker
                                apptainer
  -i, --influxdb-host       InfluxDB host to send metrics. [Default: montoxo.des.udc.es]
  -b, --influxdb-bucket     InfluxDB bucket to store metrics. [Default: glances]
  -w, --workload            Workload to stress the system with. [Default: stress-system]
                              npb                 Run NPB kenerls.
                              sysbench            Run Sysbench kernels.
                              geekbench           Run Geekbench kenerls.
                              spark               Run Spark-based DNA error correction algorithm (SMusket) using
                                                  Spark Standalone.
                                --spark-data-dir  Directory to store Spark temporary files and Spark Smusket input.
                                                  Input must be a FASTQ file named "input.fastq".

                              stress-system       Run stress tests using stress-system tool. Options:
                                --stressors              Comma-separated list of stressors to run with stress-system.
                                                         [Default: cpu]
                                --stress-load-types      Comma-separated list of types of load to stress the CPU.
                                                         Used together with CPU stressor. [Default: all]
                                --other-options          Comma-separated list of other stress-ng options specified
                                                         in key=value format.

  --add-io-noise <target>  Run fio to make random reads/writes over <target> while running the specified workload.
  -o, --output <dir>       Directory (absolute path) to store log files. [Default: ./log]
  -h, --help               Show this help and exit
EOF
exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--os-virt)
      OS_VIRT="$2"
      shift 2
      ;;
    -i|--influxdb-host)
      INFLUXDB_HOST="$2"
      shift 2
      ;;
    -b|--influxdb-bucket)
      INFLUXDB_BUCKET="$2"
      shift 2
      ;;
    -w|--workload)
      WORKLOAD="$2"
      shift 2
      ;;
    --spark-data-dir)
      SPARK_DATA_DIR="$2"
      shift 2
      ;;
    --stressors)
      STRESSORS="$2"
      shift 2
      ;;
    --stress-load-types)
      LOAD_TYPES="$2"
      shift 2
      ;;
    --other-options)
      OTHER_OPTIONS="--other ${2} "
      shift 2
      ;;
    --add-io-noise)
      RUN_FIO=1
      FIO_TARGET="$2"
      shift 2
      ;;
    -o|--output)
      LOG_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
    echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

mkdir -p "${LOG_DIR}"