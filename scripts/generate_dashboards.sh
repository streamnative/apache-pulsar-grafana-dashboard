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
Usage: generate_dashboards.sh <prometheus-url> <cluster>
EOF
}

# if no args specified, show usage
if [ $# -lt 2 ]; then
  help;
  exit 1;
fi

export PULSAR_PROMETHEUS_URL=$1
export PULSAR_CLUSTER=$2

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
j2 ${DASHBOARD_HOME}/target/datasources.yml > ${DATASOURCES_OUTPUT_DIR}/pulsar.yml

echo "Your pulsar data source is generated as ${DATASOURCES_OUTPUT_DIR}/pulsar.yml"

# apply environment variables to pulsar dashboards
for item in `ls ${DASHBOARD_HOME}/dashboards`; do
  sed "s/{{ PULSAR_CLUSTER }}/${PULSAR_CLUSTER}/" ${DASHBOARD_HOME}/dashboards/${item} > ${DASHBOARDS_OUTPUT_DIR}/${item}
done

echo "Your pulsar dashboards is generarted under ${DASHBOARDS_OUTPUT_DIR}"
