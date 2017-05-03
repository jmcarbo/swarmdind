FROM docker
#docker run --restart always  -ti --privileged -e PORT=2375 -d --name dinduser -v /dindapps:/var/lib/docker -v /nfs/home:/home --network apps --network-alias dind docker:dind --storage-driver aufs
# Add Containerpilot and set its configuration
ENV CONTAINERPILOT_VERSION 2.7.2
ENV CONTAINERPILOT file:///etc/containerpilot.json

RUN export CONTAINERPILOT_CHECKSUM=e886899467ced6d7c76027d58c7f7554c2fb2bcc \
    && export archive=containerpilot-${CONTAINERPILOT_VERSION}.tar.gz \
    && curl -Lso /tmp/${archive} \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/${archive}" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/${archive}" | sha1sum -c \
    && tar zxf /tmp/${archive} -C /usr/local/bin \
    && rm /tmp/${archive} \
    && curl -sL https://github.com/sequenceiq/docker-alpine-dig/releases/download/v9.10.2/dig.tgz|tar -xzv -C /usr/local/bin/

# Install Consul
# Releases at https://releases.hashicorp.com/consul
RUN export CONSUL_VERSION=0.8.1 \
    && export CONSUL_CHECKSUM=74cdd7ad458aa63192222ad2bd14178fc3596d4fd64d12a80520d4e6f93eaf34 \
    && curl --retry 7 --fail -vo /tmp/consul.zip "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_CHECKSUM}  /tmp/consul.zip" | sha256sum -c \
    && unzip /tmp/consul -d /usr/local/bin \
    && rm /tmp/consul.zip \
    && mkdir /config

# get consul-template
ENV CONSUL_TEMPLATE_VER 0.18.2
RUN curl -Lso /tmp/consul-template_${CONSUL_TEMPLATE_VER}_linux_amd64.zip https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VER}/consul-template_${CONSUL_TEMPLATE_VER}_linux_amd64.zip \
    && echo "6fee6ab68108298b5c10e01357ea2a8e4821302df1ff9dd70dd9896b5c37217c" /tmp/consul-template_${CONSUL_TEMPLATE_VER}_linux_amd64.zip \
    && unzip /tmp/consul-template_${CONSUL_TEMPLATE_VER}_linux_amd64.zip \
    && mv consul-template /bin \
    && rm /tmp/consul-template_${CONSUL_TEMPLATE_VER}_linux_amd64.zip

RUN apk update && apk add bash

COPY etc/* etc/
COPY bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/swarmdind-manage

CMD containerpilot -config file:///etc/containerpilot.json docker run --rm -i --privileged ${EXTRA_FLAGS} --name ${HOSTNAME}-DIND docker:dind --storage-driver aufs
