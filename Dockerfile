FROM ubuntu:24.04 AS downloader

RUN apt-get update 
RUN apt-get install -y curl wget git tar

# This archive should be copied to /Iplatform/openwrt/dl/ (prehaps a dl dir should be created)
# https://git.codelinaro.org Is the gitlab mirror after codeaurora has been turned off.
# This archibe points to the luci commit hash specified in the GPL sources (as of June 2024)
RUN wget https://git.codelinaro.org/clo/qsdk/luci/-/archive/1cdab340cd5ed15be8f25d9fe97accda9ac62ee2/luci-1cdab340cd5ed15be8f25d9fe97accda9ac62ee2.tar.gz -O luci-0.11.1.tar.gz

RUN git clone git://git.infradead.org/mtd-utils.git mtd-utils-1.4.5 --recursive && cd mtd-utils-1.4.5 && git remote -v && git checkout 5319b84974fcb71504aed2d1b8285e9c0a4a4bb8 


RUN rm -rf mtd-utils-1.4.5/.git &&	/bin/tar cfz mtd-utils-1.4.5.tar.gz mtd-utils-1.4.5



FROM ubuntu:12.04 AS environment
WORKDIR /

# Ubuntu has moved old linux packages from archive to old-releases
COPY sources.list /etc/apt/sources.list

# Update apt
RUN apt-get update && apt-get upgrade -y

# Install needed packages
RUN apt-get install -y libtool cmake libproxy-dev uuid-dev liblzo2-dev autoconf automake bash bison bzip2 diffutils file flex m4 g++ gawk groff-base libncurses5-dev libtool libslang2 make patch perl pkg-config shtool subversion tar texinfo zlib1g zlib1g-dev git gettext libexpat1-dev libssl-dev cvs gperf unzip python libxml-parser-perl gcc-multilib gconf-editor libxml2-dev g++-multilib gitk libncurses5 mtd-utils libncurses5-dev libvorbis-dev git autopoint autogen automake sed build-essential intltool libglib2.0-dev xutils-dev lib32z1-dev lib32stdc++6 xsltproc gtk-doc-tools libelf1:i386 bc uuid-dev liblzo2-dev libtool realpath make liblzo2-2:i386 libuuid1 libuuid1:i386 rsync wget sudo curl ppp vim diff

# We need user because of GPL make requires non-root user
RUN useradd ubuntu -s /bin/bash -m
RUN useradd github_ci -u 1001 -s /bin/bash -m

# We should add user to dip group to get access to pppd suid-based package
RUN usermod -aG dip ubuntu
RUN usermod -aG dip github_ci

# Add user to the sudoers file (We do not need any security inside the docker container)
RUN printf 'ubuntu\tALL=(ALL:ALL)\tNOPASSWD:ALL\n' >> /etc/sudoers
RUN printf 'github_ci\tALL=(ALL:ALL)\tNOPASSWD:ALL\n' >> /etc/sudoers

# Dont ask why
RUN ln -s /usr/sbin/zic /usr/bin/zic

# Patches that should be applied to the sources.
COPY router.patch /

COPY --from=downloader luci-0.11.1.tar.gz .
COPY --from=downloader mtd-utils-1.4.5.tar.gz .

CMD [ "/bin/bash", "-c", "sudo -iu ubuntu" ]
