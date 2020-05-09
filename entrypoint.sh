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

echo 'Starting Grafana...'

GRAFANA_CFG_FILE=${GRAFANA_CFG_FILE:-"/etc/grafana/grafana.ini"}
GRAFANA_DATASOURCES_FILE=${GRAFANA_DATASOURCES_FILE:-"/var/lib/grafana/pulsar_provisioning/datasources/pulsar.yml"}
GRAFANA_USE_BUILTIN_DASHBOARDS=${GRAFANA_USE_BUILTIN_DASHBOARDS:-"true"}

# apply environment variables to pulsar datasource provisioning yaml file
mv ${GRAFANA_DATASOURCES_FILE} /tmp/datasources_pulsar.yml.bak
j2 /tmp/datasources_pulsar.yml.bak > ${GRAFANA_DATASOURCES_FILE}

# apply envirionment variables to grafana conf
j2 ${GRAFANA_CFG_FILE} > /var/lib/grafana/grafana.ini
chmod 0400 /var/lib/grafana/grafana.ini

# apply environment variables to pulsar provisioned dashboards
if [ "x${GRAFANA_USE_BUILTIN_DASHBOARDS}" == "xtrue" ]; then
    for item in `ls /var/lib/grafana/pulsar_provisioning/dashboard_templates`; do
      sed "s/{{ PULSAR_CLUSTER }}/${PULSAR_CLUSTER}/; s/{{ GF_LOKI_DATASOURCE_NAME }}/${GF_LOKI_DATASOURCE_NAME}/" /var/lib/grafana/pulsar_provisioning/dashboard_templates/${item} > /var/lib/grafana/pulsar_provisioning/dashboards/${item}
    done
fi

echo "Initialized the pulsar data source."

exec /run.sh --config /var/lib/grafana/grafana.ini
