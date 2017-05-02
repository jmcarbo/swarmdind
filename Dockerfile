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

RUN apk update && apk add bash

COPY etc/containerpilot.json etc/
COPY bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/swarmdind-manage

CMD containerpilot -config file:///etc/containerpilot.json docker run --rm -i --privileged ${EXTRA_FLAGS} --name ${DIND_NAME:-dind} docker:dind --storage-driver aufs
