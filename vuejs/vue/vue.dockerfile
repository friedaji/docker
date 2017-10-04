FROM node:8.6

ARG NODE_USER 

RUN useradd -s /bin/false -m ${NODE_USER}

RUN mkdir -p /var/app
RUN chown -R ${NODE_USER}:${NODE_USER} /var/app

RUN npm install -g vue-cli

COPY . /var/app
USER ${NODE_USER}
WORKDIR /var/app
