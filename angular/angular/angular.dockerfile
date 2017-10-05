FROM node:8.6

ARG NODE_USER 

RUN useradd -s /bin/false -m ${NODE_USER}
RUN groupadd -g 500 nodeadm
RUN useradd -u 500 -g 500 -s /bin/false -m nodeadm

RUN mkdir -p /var/app
RUN chown -R ${NODE_USER}:${NODE_USER} /var/app

USER nodeadm
RUN npm install -g @angular/cli

COPY . /var/app

USER ${NODE_USER}
WORKDIR /var/app