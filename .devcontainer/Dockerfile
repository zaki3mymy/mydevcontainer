FROM ubuntu:latest

RUN apt -y update \
  && apt -y upgrade \
  && apt -y install curl
RUN curl https://raw.githubusercontent.com/zaki3mymy/dotfiles/refs/heads/main/setup.sh -O \
  && bash setup.sh \
  && rm setup.sh
