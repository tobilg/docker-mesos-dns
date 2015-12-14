# Mesos DNS
This images contains the latest release of Mesos DNS (v0.5.1 as of 2015-12-14) on a minimal Alpine Linux base image. The overall size is just 27.5MB.

## Configuration options

The following options can be passed to the Docker image:

- `LOCAL_IP`: The IP address the host has which should run Mesos DNS (**mandatory, if your slave's hostname is not resolvable**)
- `MESOS_ZK`: The ZooKeeper connection string for the Mesos Master(s), e.g. `zk://192.168.0.100:2181/mesos`  (**mandatory**)
- `MESOS_DNS_EXTERNAL_SERVERS`: A comma-separated list of external DNS servers, e.g. `8.8.8.8,8.8.4.4` for the Google DNS servers. If not used, ``8.8.8.8` will be the default external DNS server.
- `MESOS_DNS_HTTP_ENABLED`: Whether the Mesos DNS web interface should be started. If not used or passed a `true` value, it will be disabled.
- `MESOS_DNS_HTTP_PORT`: The HTTP port of the Mesos DNS web interface. If not defined (and the web interface is enabled), `8123` will be used as port.
- `MESOS_DNS_REFRESH`: The frequency at which Mesos-DNS updates DNS records based on information retrieved from the Mesos master. The default value is 60 seconds.
- `MESOS_DNS_TIMEOUT`: The timeout threshold, in seconds, for connections and requests to external DNS requests. The default value is 5 seconds.
- `VERBOSITY_LEVEL`: The [level of verbosity][verbose] (can be 1 or 2). If not specified, no verbose logs will be written.

A further description of the Mesos DNS configuration parameters can be found on the [reference docs][conf].

### DNS configuration on the host
As Mesos DNS needs an nameserver entry which points to the own host (the host which Mesos DNS is running on) in the `/etc/resolv.conf` at the begining of the file (see ["Slave Setup"][docs]), it is necessary to prepare this entry before Mesos DNS can be run via Docker.
The "pinning" of the image to a host is done via `hostname` constraints when running via Marathon. 

## Running
The image can be run either via Marathon (recommended!), or via command line on the Mesos Slave's Docker host.

### Via Marathon

You should start the Mesos DNS per recommandation of the [official docs][docs] via Marathon for each slave. This can be done via `constraints` in the application's JSON definition (see below). If you're running your Mesos Master/Slave as well as Marathon on IP address `192.168.0.100`,
a sample configuration would be the following:

```
curl -XPOST 'http://192.168.0.100:8080/v2/apps' -H 'Content-Type: application/json' -d '{
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
    "cpus": 0.2,
    "mem": 128,
    "instances": 1,
	"constraints": [["hostname", "CLUSTER", "192.168.0.100"]]
}'
```

Also, if you'd want to run Mesos DNS once on every slave available in the cluster, consider the following:

* Make sure that the slave's hostnames are resolvable via `nslookup ``hostname -f```)
* Set the `instances` property to the number of current Mesos slaves in the cluster

If everything is set, run this:

```
curl -XPOST 'http://192.168.0.100:8080/v2/apps' -d '{
    "id": "mesos-dns",
    "env": {
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
    "cpus": 0.2,
    "mem": 128,
    "instances": 1,
	"constraints": [["hostname", "UNIQUE"]]
}'
```

### Via command line

```
docker run -d \
  --net=host \
  -e MESOS_ZK=zk://192.168.0.100:2181/mesos \
  -e LOCAL_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}') \
  -e MESOS_DNS_EXTERNAL_SERVERS=8.8.8.8,8.8.4.4 \
  --name dns \
  -t tobilg/mesos-dns
```

**Note:**
Use the correct network interface name, in our example it's `eth0`.

[docs]: <http://mesosphere.github.io/mesos-dns/docs/>
[conf]: <http://mesosphere.github.io/mesos-dns/docs/configuration-parameters.html>
[verbose]: <http://mesosphere.github.io/mesos-dns/docs/faq.html>