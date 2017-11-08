FROM alpine

RUN apk add --no-cache \
  bash \
  zsh \
  ncurses \
  py-pip \
  && pip install yq

USER hcm_user
