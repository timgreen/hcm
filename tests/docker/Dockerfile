FROM alpine

RUN apk add --no-cache \
  coreutils \
  bash \
  zsh \
  ncurses \
  jq \
  py-pip \
  && pip install yq

USER hcm_user
ENV HOME /home/hcm_user
