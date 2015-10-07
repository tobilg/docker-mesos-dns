#!/bin/bash

#set -ex

# Check for MESOS_ZK parameter
if [ -z ${MESOS_ZK+x} ]; then
  echo "Please supply at least a Zookeeper connection string!"
  exit 1
else
  ZK=$(echo ${MESOS_ZK//\//\\/})
fi

# Check for local ip address parameter
if [ -z ${LOCAL_IP+x} ]; then
  echo "Please supply at least a local IP address!"
  exit 1
fi

# Check for EXTERNAL_DNS_SERVERS parameter
if [ -z ${MESOS_DNS_EXTERNAL_SERVERS+x} ]; then
  DNS_SERVERS="8.8.8.8"
else
  IFS=',' read -a dnshosts <<< "$MESOS_DNS_EXTERNAL_SERVERS"
  for index in "${!dnshosts[@]}"
  do
    DNS_SERVER_STRINGS[(index+1)]="\"${dnshosts[index]}\""
  done
  # Produce correct env variables for DNS servers
  IFS=','
  DNS_SERVERS="[${DNS_SERVER_STRINGS[*]}]"
fi

# Check for HTTP_PORT parameter
if [ -z ${MESOS_DNS_HTTP_PORT+x} ]; then
  PORT="8123"
else
  PORT="${MESOS_DNS_HTTP_PORT}"
fi

# Check for HTTP_ENABLED parameter
if [ -z ${MESOS_DNS_HTTP_ENABLED+x} ]; then
  HTTP_ENABLED="false"
else
  HTTP_ENABLED="${MESOS_DNS_HTTP_ENABLED}"
fi

# Check for REFRESH parameter
if [ -z ${MESOS_DNS_REFRESH+x} ]; then
  REFRESH="60"
else
  REFRESH="${REFRESH}"
fi

# Check for TIMEOUT parameter
if [ -z ${MESOS_DNS_TIMEOUT+x} ]; then
  TIMEOUT="5"
else
  TIMEOUT="${MESOS_DNS_TIMEOUT}"
fi

# Replace network interface name
sed -i -e "s/%%MESOS_ZK%%/${ZK}/" \
  -e "s/%%IP%%/${LOCAL_IP}/" \
  -e "s/%%HTTP_PORT%%/${PORT}/" \
  -e "s/%%EXTERNAL_DNS_SERVERS%%/${DNS_SERVERS}/" \
  -e "s/%%HTTP_ON%%/${HTTP_ENABLED}/" \
  -e "s/%%REFRESH%%/${REFRESH}/" \
  -e "s/%%TIMEOUT%%/${TIMEOUT}/" \
  $MESOS_DNS_PATH/config.json 

exec $MESOS_DNS_PATH/mesos-dns -config=$MESOS_DNS_PATH/config.json -v=2