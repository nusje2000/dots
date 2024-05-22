FROM ubuntu:latest

RUN useradd -m maartenn
RUN apt update
RUN apt install sudo -y
RUN echo 'maartenn ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER maartenn
WORKDIR /home/maartenn/project/dots
COPY . .

RUN bin/update.sh -y
