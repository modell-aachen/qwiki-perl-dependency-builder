FROM debian:9

USER root

RUN apt-get update
RUN apt-get install -y dh-make-perl
RUN curl -L http://cpanmin.us | perl - --self-upgrade

WORKDIR /opt/build

ADD entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
