# apache-pulsar-grafana-dashboard
Apache Pulsar Grafana Dashboard

# Examples:

## Standalone

1. Start Standalone


2. Start Prometheus
   ```bash
   docker run -p 9090:9090 -v ${PULSAR_GRAFANA_DASHBOARD_HOME}/prometheus/standalone.yml:/etc/prometheus/prometheus.yml prom/prometheus
   ```

3. Start Grafana Dashbard
   ```bash
   docker run -it -p 3000:3000 -e PULSAR_PROMETHEUS_URL=http://172.30.1.45:9090 streamnative/apache-pulsar-grafana-dashboard:latest 
   ```
