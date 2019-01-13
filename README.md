# Apache Pulsar Grafana Dashboard

## Usage

Use this Grafana Dashboard on ...

### ... a Standalone Cluster

#### Start Pulsar Standalone

Download the pulsar binary and follow pulsar's instruction to
[start a standalone cluster](http://pulsar.apache.org/docs/en/standalone/)
on your laptop.

#### Start Prometheus

1. Generate a Prometheus config file.

You can create a prometheus config file by copying the template file
[prometheus/standalone.yml.template](prometheus/standalone.yml.template)
and edit to replace `{{ STANDALONE_HOST }}` with your ip address of the
machine running pulsar standalone.

Alternatively, you can install [j2cli](https://github.com/kolypto/j2cli).
j2cli is a command-line tool for templating [Jinja2](http://jinja.pocoo.org/docs/)
template files. You can use j2cli to generate a Prometheus config file
from the standalone template.

```bash

$ STANDALONE_HOST="$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }')" j2 prometheus/standalone.yml.template > /tmp/standalone.prometheus.yml

```

2. Run Prometheus with the generated prometheus config file.


```bash
docker run -p 9090:9090 -v /tmp/standalone.prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
```

After successfully running the prometheus, you should be able to access http://localhost:9090/targets
to see prometheus detecting all pulsar components. A successful screenshot is shown as below:

![](images/prometheus-targets.png?raw=true)

#### Start Grafana Dashbard

Till now, you have a Pulsar standalone and a Prometheus server connecting to the Pulsar standalone.
Now, let's start the Grafana Dashboard.

```bash
export PULSAR_PROMETHEUS_URL=http://$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }'):9090
export PULSAR_CLUSTER=standalone
docker run -it -p 3000:3000 -e PULSAR_PROMETHEUS_URL="${PULSAR_PROMETHEUS_URL}" -e PULSAR_CLUSTER="${PULSAR_CLUSTER}" streamnative/apache-pulsar-grafana-dashboard:latest 
```

Now, you can access the Grafana Dashboard at http://localhost:3000.
The default password for `admin` is set as `happypulsaring` in file [conf/grafana.ini](conf/grafana.ini)

## Details

This Grafana Docker Image contains following built-in dashboards for different components in an Apache Pulsar cluster.
These dashboards are:

- *Overview*: This renders the overview health of a Pulsar cluster.
- *Messaging Metrics*: This renders the metrics related to Pulsar messaging (e.g. producers, consumers, msg backlog and such).
- *Proxy Metrics*: This renders the metrics related to Pulsar proxies if you have run proxies in your Pulsar clusters. _This doesn't apply to a Standalone cluster._
- *Bookie Metrics*: This renders the metrics related to Bookies. _This doesn't apply to a Standalone cluster since a Pulsar standalone doesn't expose bookie metrics._
- *ZooKeeper*: This renders the metrics related to ZooKeeper cluster.
- *JVM Metrics*: This renders the jvm related metrics of all the components in a Pulsar cluster (e.g. proxies, brokers, bookies, and etc).

System metrics are rendered in *Node Metrics* dashboard and some portions in *Overview* dashboard.
The system metrics used by these dashboards are collected by Prometheus [Node Exporter](https://github.com/prometheus/node_exporter).
So you have to configure each pulsar machine to run node exporter and also configure your Prometheus to scrape the metrics from node exporters.

## Build Your Own Image (Optional)

If you'd like to customize and build your own dashboard image, you can do as following:

```bash
docker build -t <your-docker-org>/<your-docker-image>[:<tag>] .
```

Example command:

```bash
docker build -t streamnative/apache-pulsar-grafana-dashboard .
```
