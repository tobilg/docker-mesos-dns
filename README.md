# Mesos DNS
This images contains the latest release of Mesos DNS (v0.4.0-pre as of 2015-10-08) on a minimal Alpine Linux base image. The overall size is just 27.5MB.

## Configuration options

The following options can be passed to the Docker image:

- `LOCAL_IP`: The IP address the host has which should run Mesos DNS (**mandatory**)
- `MESOS_ZK`: The ZooKeeper connection string for the Mesos Master(s), e.g. `zk://192.168.0.100:2181/mesos`  (**mandatory**)
- `MESOS_DNS_EXTERNAL_SERVERS`: A comma-separated list of external DNS servers, e.g. `8.8.8.8,8.8.4.4` for the Google DNS servers. If not used, ``8.8.8.8` will be the default external DNS server.
- `MESOS_DNS_HTTP_ENABLED`: Whether the Mesos DNS web interface should be started. If not used or passed a `true` value, it will be disabled.
- `MESOS_DNS_HTTP_PORT`: The HTTP port of the Mesos DNS web interface. If not defined (and the web interface is enabled), `8123` will be used as port.
- `MESOS_DNS_REFRESH`: The frequency at which Mesos-DNS updates DNS records based on information retrieved from the Mesos master. The default value is 60 seconds.
- `MESOS_DNS_TIMEOUT`: The timeout threshold, in seconds, for connections and requests to external DNS requests. The default value is 5 seconds.

A further description of the Mesos DNS configuration parameters can be found on the [reference docs][conf].

## Running
The image can be run either via Marathon (recommended!), or via command line on the Mesos Slave's Docker host.

### Via Marathon

You should start the Mesos DNS per recommandation of the [official docs][docs] via Marathon for each slave. This can be done via `constraints` in the application's JSON definition (see below). If you're running your Mesos Master/Slave as well as Marathon on IP address `192.168.0.100`,
a sample configuration would be the following:

```
curl -XPOST 'http://192.168.0.100:8080/v2/apps' -d '{
    "id": "mesos-dns-100",
    "env": {
        "LOCAL_IP": "192.168.0.100",
        "MESOS_ZK": "zk://192.168.0.100:2181/mesos",
        "MESOS_DNS_EXTERNAL_SERVERS": "8.8.8.8,8.8.4.4"
    },
    "container": {
        "docker": {
            "image": "tobilg/mesos-dns",
            "network": "HOST"
        },
        "type": "DOCKER"
    },
    "cpus": 0.5,
    "mem": 1024,
    "instances": 1,
	"constraints": [["hostname", "CLUSTER", "192.168.0.100"]]
}'
```

### Via command line

```
docker run -d \
  --net=host \
  -e MESOS_ZK=zk://192.168.0.100:2181/mesos \
  -e LOCAL_IP=$(/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}') \
  -e MESOS_DNS_EXTERNAL_SERVERS=8.8.8.8,8.8.4.4 \
  --name dns \
  -t tobilg/mesos-dns
```

[docs]: <http://mesosphere.github.io/mesos-dns/docs/>
[conf]: <http://mesosphere.github.io/mesos-dns/docs/configuration-parameters.html>