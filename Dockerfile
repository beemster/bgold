FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y pkg-config apt-utils build-essential autoconf automake libtool libboost-all-dev libgmp-dev libssl-dev libcurl4-openssl-dev git software-properties-common python-software-properties bsdmainutils sudo curl

MAINTAINER Beam <b-docker-bitcoingold@grmbl.net>

ENV DOWNLOAD_FILENAME=client.tgz
ENV DOWNLOAD_URL=https://github.com/BTCGPU/BTCGPU/releases/download/v0.15.0.2/bitcoin-gold-0.15.0-x86_64-linux-gnu.tar.gz
RUN cd /usr/src && curl -L -o $DOWNLOAD_FILENAME $DOWNLOAD_URL && tar xfz $DOWNLOAD_FILENAME -C /usr/local --strip-components 1

ENV COIN=bgold
RUN echo "$COIN	ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -m $COIN
ADD run.sh /home/$COIN/run.sh

ENTRYPOINT /bin/su - $COIN -c "/home/$COIN/run.sh" 
