FROM debian:10

USER root

RUN apt-get update
RUN apt-get install -y dh-make-perl
RUN curl \
    -L http://cpanmin.us | perl - --self-upgrade

RUN apt install -y libpq-dev

WORKDIR /opt/build

ADD entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
