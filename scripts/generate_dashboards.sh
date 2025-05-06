#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

set -e

BINDIR=`dirname "$0"`
DASHBOARD_HOME=`cd ${BINDIR}/..;pwd`

help() {
    cat <<EOF

generate_dashboards.sh

Usage:

  Scripted options:

    1. Pass arguments to script:
        generate_dashboards.sh <prometheus-url> <cluster> <custom> <loki-url> <loki-datasource>

    2. Set environment variables for the following and just run generate_dashboards.sh:
        - PULSAR_PROMETHEUS_URL
        - PULSAR_CLUSTER
        - PULSAR_CUSTOM_PROMETHEUS
        - GF_LOKI_URL
        - GF_LOKI_DATASOURCE_NAME

  Interactive option:

    Missing any of the above inputs or environment variables will cause a prompt for input

EOF
}

env_var_check() {
  # Checks if either var script input or env vars are set and prompts
  # for interactive input when missing
  local VAR=${1}
  local INPUT=${2}
  if [ -z "$(echo ${VAR})" ] && [ -z "${INPUT}" ]; then
    echo "${VAR} is not set!"
    DEFAULT_INPUT=''
    read -p "Enter a value for ${VAR}: [''] " PROMPT_INPUT
    PROMPT_INPUT="${PROMPT_INPUT:-${DEFAULT_INPUT}}"
    export $(echo ${VAR})=${PROMPT_INPUT}
    echo "${VAR} set to: $(printenv ${VAR})"
  elif [ -n "${INPUT}" ]; then
    echo "Setting ${VAR} from script input."
    export $(echo ${VAR})=${INPUT}
    echo "${VAR} set to: $(printenv ${VAR})"
  elif [ -n "$(echo ${VAR})" ]; then
    echo "Using existing ${VAR} environment variable."
    echo "$(echo ${VAR}) set to: $(printenv ${VAR})"
  else
    echo "Something went wrong trying to set ${VAR}"
    help
    exit 1
  fi
}


if [ "${1}" == 'help' ] || [ "${1}" == '--help' ] || [ "${1}" == '-h' ]; then
  help
else
  # Check for env vars and promt for input if missing
  env_var_check PULSAR_PROMETHEUS_URL ${1}
  env_var_check PULSAR_CLUSTER ${2}
  env_var_check PULSAR_CUSTOM_PROMETHEUS ${3}
  env_var_check GF_LOKI_URL ${4}
  env_var_check GF_LOKI_DATASOURCE_NAME ${5}

  DASHBOARDS_OUTPUT_DIR="${DASHBOARD_HOME}/target/dashboards"
  if [ -d ${DASHBOARDS_OUTPUT_DIR} ]; then
      rm -r ${DASHBOARDS_OUTPUT_DIR}
  fi
  mkdir -p ${DASHBOARDS_OUTPUT_DIR}

  DATASOURCES_OUTPUT_DIR="${DASHBOARD_HOME}/target/datasources"
  if [ -d ${DATASOURCES_OUTPUT_DIR} ]; then
      rm -r ${DATASOURCES_OUTPUT_DIR}
  fi
  mkdir -p ${DATASOURCES_OUTPUT_DIR}

  echo 'Generating Datasources ...'

  # apply environment variables to pulsar datasource provisioning yaml file
  cp ${DASHBOARD_HOME}/conf/provisioning/datasources.yml ${DASHBOARD_HOME}/target/datasources.yml
  j2 --import-env= --undefined ${DASHBOARD_HOME}/target/datasources.yml > ${DATASOURCES_OUTPUT_DIR}/pulsar.yml

  echo "Your pulsar data source is generated as ${DATASOURCES_OUTPUT_DIR}/pulsar.yml"

  # apply environment variables to pulsar dashboards
  for item in `ls ${DASHBOARD_HOME}/dashboards.template`; do
    # Strip the '.j2' template file exstesion from output file name
    OUTPUT_FILE=$(echo ${item} | sed 's/\.j2//')

    # Only attempt to render via jinja2 if the file is a jinja2 template
    if [[ "${item}" == *".j2" ]]; then
      j2 --import-env= --undefined ${DASHBOARD_HOME}/dashboards.template/${item} > ${DASHBOARDS_OUTPUT_DIR}/${OUTPUT_FILE}
    else
      sed "s/{{ PULSAR_CLUSTER }}/${PULSAR_CLUSTER}/" ${DASHBOARD_HOME}/dashboards.template/${item} > ${DASHBOARDS_OUTPUT_DIR}/${OUTPUT_FILE}
    fi

  done

  echo "Your pulsar dashboards is generarted under ${DASHBOARDS_OUTPUT_DIR}"
fi
