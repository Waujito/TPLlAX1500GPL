FROM ubuntu:12.04 as environment
WORKDIR /

# Ubuntu has moved old linux packages from archive to old-releases
COPY sources.list /etc/apt/sources.list

# Update apt
RUN apt-get update && apt-get upgrade -y

# Install needed packages
RUN apt-get install -y libtool cmake libproxy-dev uuid-dev liblzo2-dev autoconf automake bash bison bzip2 diffutils file flex m4 g++ gawk groff-base libncurses5-dev libtool libslang2 make patch perl pkg-config shtool subversion tar texinfo zlib1g zlib1g-dev git gettext libexpat1-dev libssl-dev cvs gperf unzip python libxml-parser-perl gcc-multilib gconf-editor libxml2-dev g++-multilib gitk libncurses5 mtd-utils libncurses5-dev libvorbis-dev git autopoint autogen automake sed build-essential intltool libglib2.0-dev xutils-dev lib32z1-dev lib32stdc++6 xsltproc gtk-doc-tools libelf1:i386 bc uuid-dev liblzo2-dev libtool realpath make liblzo2-2:i386 libuuid1 libuuid1:i386 rsync wget sudo curl ppp vim diff

# We need user because of GPL make requires non-root user
RUN useradd ubuntu -s /bin/bash -m

# We should add user to dip group to get access to pppd suid-based package
RUN usermod -aG dip ubuntu

# Add user to the sudoers file (We do not need any security inside the docker container)
RUN printf 'ubuntu\tALL=(ALL:ALL)\tNOPASSWD:ALL\n' >> /etc/sudoers

# Dont ask why
RUN ln -s /usr/sbin/zic /usr/bin/zic

# Patches that should be applied to the sources.
COPY router.patch /

# This archive should be copied to /Iplatform/openwrt/dl/ (prehaps a dl dir should be created)
# https://git.codelinaro.org Is the gitlab mirror after codeaurora has been turned off.
# This archibe points to the luci commit hash specified in the GPL sources (as of June 2024)
RUN wget https://git.codelinaro.org/clo/qsdk/luci/-/archive/1cdab340cd5ed15be8f25d9fe97accda9ac62ee2/luci-1cdab340cd5ed15be8f25d9fe97accda9ac62ee2.tar.gz -O luci-0.11.1.tar.gz

CMD [ "/bin/bash", "-c", "sudo -iu ubuntu" ]
