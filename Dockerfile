FROM sillelien/base-alpine:0.10
MAINTAINER tobilg <fb.tools.github@gmail.com>

ENV MESOS_DNS_VERSION 0.3.0
ENV MESOS_DNS_FILENAME mesos-dns-v$MESOS_DNS_VERSION-linux-amd64
ENV MESOS_DNS_PATH /usr/local/mesos-dns

ADD /config.json $MESOS_DNS_PATH/config.json
ADD install.sh .
ADD bootstrap.sh .

RUN chmod +x install.sh
RUN chmod +x bootstrap.sh

RUN ./install.sh

ENTRYPOINT ["./bootstrap.sh"]