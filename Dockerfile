FROM ubuntu:18.04

MAINTAINER Rabenda <rabenda.cn@gmail.com>

LABEL version="1.0"

ENV DEBIAN_FRONTEND noninteractive
RUN apt update -qq && \
	apt upgrade -y -qq && \
	apt install -y -qq locales

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install dependencies
RUN apt install -y -qq --no-install-recommends neofetch \
	sudo nano file \
	git-core build-essential libssl-dev libncurses5-dev unzip \
	subversion mercurial gawk wget ca-certificates 

# Set user info
RUN useradd --create-home --no-log-init --shell /bin/bash builder && \
	adduser builder sudo && \
	echo 'builder:builder' | chpasswd

USER builder
WORKDIR /home/builder

# clone code
RUN git clone https://git.openwrt.org/openwrt/openwrt.git
WORKDIR /home/builder/openwrt

RUN ./scripts/feeds update -a && ./scripts/feeds install -a
ADD config/.config .config

# compile
RUN make -j $(expr $(nproc) + 1)

CMD ["bash"]
