FROM docker:17-dind

ARG DATA_DIR

#RUN modprobe dm-modprobe \
#  && echo dm-mod >> /etc/modules

#COPY daemon.json /etc/docker/

RUN apk add --update \
    bash \
    curl \
    python3 \
    python3-dev \
    libffi-dev \
    build-base \
    gcc \
    openssl-dev \
    readline-dev \
    ncurses-dev \
    patch \
  && rm -rf /var/cache/apk/*

#RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python3
RUN pip3 install \
  setuptools \
  readline \
  ansible \
  ansible-container[docker]

RUN mkdir -p ${DATA_DIR}
WORKDIR ${DATA_DIR}