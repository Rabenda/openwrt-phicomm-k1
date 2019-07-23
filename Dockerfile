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
	subversion mercurial gawk wget ca-certificates curl

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

ADD upload/upload-github-release-asset.sh upload-github-release-asset.sh
RUN bash upload-github-release-asset.sh \
	github_api_token=${TOKEN} \
	owner=rabenda \
	repo=openwrt-phicomm-k1 \
	tag=v$(date +%Y.%m.%d.%H.%M) \
	filename=bin/targets/ramips/mt7620/openwrt-ramips-mt7620-phicomm_psg1208-squashfs-sysupgrade.bin

CMD ["bash"]
