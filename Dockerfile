FROM ubuntu:18.04
MAINTAINER Benjamin Borbe <bborbe@rocketnews.de>
ARG VENDOR_VERSION

ENV HOME /root
ENV LANG en_US.UTF-8

RUN set -x \
	&& DEBIAN_FRONTEND=noninteractive apt-get update --quiet \
	&& DEBIAN_FRONTEND=noninteractive apt-get upgrade --quiet --yes \
	&& DEBIAN_FRONTEND=noninteractive apt-get install --quiet --yes --no-install-recommends \
	locales \
	apt-transport-https \
	ca-certificates \
	wget \
	openjdk-11-jre \
	&& DEBIAN_FRONTEND=noninteractive apt-get autoremove --yes \
	&& DEBIAN_FRONTEND=noninteractive apt-get clean
RUN locale-gen en_US.UTF-8

RUN sed -i 's/file:\/dev\/random/file:\/dev\/urandom/' /etc/java-11-openjdk/security/java.security

RUN set -x \
	&& mkdir -p /opt \
	&& wget -qO- https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${VENDOR_VERSION}.tar.gz | tar xvz --transform "s/^atlassian-confluence-${VENDOR_VERSION}/confluence/" -C /opt

RUN set -x \
	&& echo 'confluence.home = /var/lib/confluence' > /opt/confluence/confluence/WEB-INF/classes/confluence-init.properties \
	&& sed -i 's/-Djava.awt.headless=true/-Djava.awt.headless=true -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false/' /opt/confluence/bin/setenv.sh

COPY files/server.xml /opt/confluence/conf/
COPY files/entrypoint.sh /usr/local/bin/
COPY files/service.sh /usr/local/bin/

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/service.sh"]
