## TPLink GPL compilators
This script is optimized to compile TP-Link Archer AX1500 v1, v1.2; Archex AX10 v1, v1.2 GPL sources.

It is based on ubuntu precise 12.04 and uses docker to run it on any host.

How to run:
- Build a docker image `docker build -t router_build .`
- Enter a docker container and mound sources as volume `docker run -it -v /home/vetrov/ax1500v1_GPL:/router router_build`    
- cd the router `cd /router`
- Patch the sources. `patch -p1 < ../router.patch` This step updates sources where files should be downloaded. Files keep their checksums.
- Update luci. `mkdir -p Iplatform/openwrt/dl/ && cp /luci-0.11.1.tar.gz /router/Iplatform/openwrt/dl/` I wasn't able to patch this package so I decided to simpy download it and pass to the make. Checksum is also keeped because you downloaded this file from mirror git repository with the same commit hash (check Dockerfile)
- go to the build dir `cd Iplatform/build`
- And make your sources `make SHELL=/bin/bash V=s` Shell=/bin/bash ensures make to use bash by default (needed for build), V=s enables verbose mode that produces more detail output. At the beginning of the make process it will ask you for some details. Feel free to simply press enter to choose the default option.

Errors in the build process: GPL sources are extremly legacy thing. And errors are I hate Broadcomm and any other who did it and keep without maintance from 2013 year. A lot of mirrors has been shutted down and stopped so we should prepare for everything. If any errors encountered in the build process it is likely related to the internet resources that provides package (also prepare for 30 Kbit/s download speed). To resolve these errors you have to manually find the specific version of the package and update Makefiles (see router.patch for reference).

Thanks:

JonathanNakandala for [post on openwrt forum](https://forum.openwrt.org/t/tp-link-archer-ax1500-70-802-11ax-router-support/48781/22) with starting research in this theme
