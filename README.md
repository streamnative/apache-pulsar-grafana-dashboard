# Apache Pulsar Grafana Dashboard
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fstreamnative%2Fapache-pulsar-grafana-dashboard.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fstreamnative%2Fapache-pulsar-grafana-dashboard?ref=badge_shield)


The Grafana dashboard docker image is available at
[Docker Hub](https://hub.docker.com/r/streamnative/apache-pulsar-grafana-dashboard).

To use this dashboard image, provide the following environment variables: 

- *PULSAR_PROMETHEUS_URL*: The HTTP URL that points to your prometheus service. For example, `http://<prometheus-host>:9090`.
- *PULSAR_CLUSTER*: The pulsar cluster name. The cluster name is aligned with your prometheus configuration.
  See [Prometheus](#prometheus) for more details.

## Prometheus

To display the metrics correctly with this dashboard, configure your Prometheus server to collect metrics from Pulsar correctly.

1. Attach your prometheus service to an extra label - `cluster`. The cluster name is aligned with the `PULSAR_CLUSTER` name you have provided to the grafana dashboard.
   ```yaml
   global:
     ...
     external_labels:
       cluster: <your-cluster-name>
   ```

2. Make sure the job name of each component is the same with the ones in this dashboard.
   - job *proxy*: the machines that run pulsar proxies.
   - job *broker*: the machines that run pulsar brokers.
   - job *bookie*: the machines that run bookies.
   - job *zookeeper*: the machines that run zookeeper.
   - job *node_metrics*: all the machines of the pulsar cluster.

How to configure your prometheus server to collect the metrics of a Pulsar cluster, refer to [example prometheus config](prometheus/cluster.yml.template).

## Usage

Use this Grafana Dashboard on a standalone cluster.

#### Start Pulsar Standalone

Download the pulsar binary and follow the instruction to
[start a standalone cluster](http://pulsar.apache.org/docs/en/standalone/) on your computer.

#### Start Prometheus

1. Generate a Prometheus config file.

Two options are available to generate a prometheus config file.
- Copy the template file [prometheus/standalone.yml.template](prometheus/standalone.yml.template), and replace `{{ STANDALONE_HOST }}` with your IP address of the machine running pulsar standalone.
- Install [j2cli](https://github.com/kolypto/j2cli). j2cli is a command-line tool for templating [Jinja2](http://jinja.pocoo.org/docs/)
template files. You can use j2cli to generate a Prometheus config file from the standalone template.

```bash

$ STANDALONE_HOST="$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }')" j2 prometheus/standalone.yml.template > /tmp/standalone.prometheus.yml

```

In Ubuntu, set `STANDALONE_HOST` as below.
```bash

$ STANDALONE_HOST="$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }' | awk -F ':' '{ print $2 }' | awk 'NR==2')" j2 prometheus/standalone.yml.template > /tmp/standalone.prometheus.yml

```

If it doesn't work properly, you can set the IP manually.


2. Run Prometheus with the generated prometheus config file.


```bash
docker run -p 9090:9090 -v /tmp/standalone.prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
```

After running the prometheus successfully, you have access to http://localhost:9090/targets, where you can see prometheus detecting all pulsar components, shown as follows.

![](images/prometheus-targets.png?raw=true)

#### Start Grafana Dashbard

When you have a Pulsar standalone and a Prometheus server connecting to the Pulsar standalone, you can start with the Grafana Dashboard.

```bash
export PULSAR_PROMETHEUS_URL=http://$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }'):9090
export PULSAR_CLUSTER=standalone
docker run -it -p 3000:3000 -e PULSAR_PROMETHEUS_URL="${PULSAR_PROMETHEUS_URL}" -e PULSAR_CLUSTER="${PULSAR_CLUSTER}" streamnative/apache-pulsar-grafana-dashboard:latest 
```

In Ubuntu, set `PULSAR_PROMETHEUS_URL` in this way.

```bash
export PULSAR_PROMETHEUS_URL=http://$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }' | awk -F ':' '{ print $2 }' | awk 'NR==2'):9090
```

If it doesn't work properly, you can set the IP manually.  

Access the Grafana Dashboard at http://localhost:3000.
The default user name is `admin`, the default password is `happypulsaring`, and they are set in the [conf/grafana.ini](conf/grafana.ini) file.

## Import dashboard to your Grafana installation

> First of all, you need to make sure your prometheus is configured to attach `cluster`
> label as described in section [#prometheus](#prometheus).

If you already have a grafana installation and you would like to import the dashboards to your grafana installation.

You can run [scripts/generate_dashboards.sh](scripts/generate_dashboards.sh) to generate a datasource and
the dashboard files that you can use to import to your installation.

```bash
./scripts/generate_dashboards.sh <prometheus-url> <clustername>
```

- `<prometheus-url>`: The url points to your prometheus servcie. E.g. `http://localhost:9090`
- `<clustername>`: Your pulsar cluster name.

The datasource yaml file and dashboard json files will be generated under `target/datasources` and `target/dashboards`.
You can then import those files into your grafana installation.

## Details

The Grafana Docker Image contains the following built-in dashboards for different components in an Apache Pulsar cluster.
These dashboards are:

- *Overview*: This renders the overview health of a Pulsar cluster.
- *Messaging Metrics*: This renders the metrics related to Pulsar messaging (e.g. producers, consumers, msg backlog and so on).
- *Proxy Metrics*: This renders the metrics related to Pulsar proxies if you have run proxies in your Pulsar clusters. _This doesn't apply to a standalone cluster._
- *Bookie Metrics*: This renders the metrics related to Bookies. _This doesn't apply to a Standalone cluster since a Pulsar standalone doesn't expose bookie metrics._
- *ZooKeeper*: This renders the metrics related to ZooKeeper cluster.
- *JVM Metrics*: This renders the jvm related metrics of all the components in a Pulsar cluster (For example, proxies, brokers, bookies, and so on).

System metrics are rendered in the *Node Metrics* dashboard and some portions in *Overview* dashboard.<!--what's the meaning?-->
The system metrics used by these dashboards are collected by Prometheus [Node Exporter](https://github.com/prometheus/node_exporter).
So you have to configure each pulsar machine to run node exporter, and configure your Prometheus to scrape the metrics from node exporters.

## Build Your Own Image (Optional)

To customize and build your own dashboard image, issue the following command:

```bash
make
```

Checkout [Makefile](Makefile) for the details of the command used for building the docker image.


## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fstreamnative%2Fapache-pulsar-grafana-dashboard.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fstreamnative%2Fapache-pulsar-grafana-dashboard?ref=badge_large)
