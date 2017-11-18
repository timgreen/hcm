FROM alpine

RUN apk add --no-cache \
  coreutils \
  findutils \
  grep \
  bash \
  zsh \
  ncurses \
  rsync \
  jq \
  py-pip \
  && pip install yq

USER hcm_user
ENV HOME /home/hcm_user
