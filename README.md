## Features

- boots silently with **boot splash** including progress bar
- boots directly into a **full screen web browser** (video and audio playback capable)
- optionally: boots directly into full screen video player (omxplayer).
- Node.js **webserver** included for hosting local web pages displayed in the browser
- HDMI **CEC** support
- SSH enabled
- **wpa_supplicant**, RPi Wireless drivers, Ralink drivers
- The device will also setup a TTY on the UART (ttyAMA0). You can connect with an USB serial converter.
- simple **wpe-launcher** for launching browser with custom url
- **keyboard and mouse input** support
- nano text editor
- auto-expand the persistent rootfs on the first boot
- mDNS, so you can access your RPi by calling rpi0.local or rpi3.local

By the way: Raspberry Pi 3 boots in 14 seconds - full system, wireless network, Node.js server and fullscreen browser!! Raspberry Pi Zero W takes 25 seconds.

# buildroot-webkit

For our product expansion, we were looking for a suitable buildroot system that could launch directly into a full-screen browser. The original Buildroot offers the Qt WebEngine package ready to compile, but it is much slower in performance than usual WebKit implementations.
Unfortunately, we couldn't find a solution which was suitable for our purposes.
Compiling some of them was partly faulty, not all boards were supported and the WebKit browser cannot be started conveniently easy.
After a very long time of work we now have made all desired adjustments. In this repository we now offer them all to the public.

Many thanks to https://github.com/hlev for supporting us!
Many thanks to all the people who investigated enormous time creating the source code for all this great software!

# Detailed description
Most of the adaptions are stored in the `./board/toldotechnik_rpi/rootfs-overlay` folder. After creating the `sdcard.img` it's content is placed in the root `/` folder.

Two board configurations are available right now:
- `toldotechnik_rpi0_wpe_defconfig` for RPi Zero (V1.2) and RPi Zero W (V1.1), both tested

All other RPi 1 boards should work as well.
- `toldotechnik_rpi3_wpe_defconfig` for RPi 3 B (V1.2), tested

## Custom settings
Below you will find the explanations of how the custom settings are made on the final Raspberry image installed on the SD card. If you want to apply the settings before building, you can customize the `board/toldotechnik_rpi/rootfs-overlay` folder. The link for the `url.txt` you will find in the `board/toldotechnik_rpi/post-image.sh` script.

### URL for the browser
Create a `/boot/url.txt` file and insert the desired link in the first line (e.g. http://localhost).
If the file exists, the browser will start automatically after boot and the url gets loaded in it.

### Full screen video player
Our distro is capable to boot directly into a full screen video player. We use the super fast omxplayer which supports lots of codecs.

To enable video playback follow these steps:
* Put the video file path into `/boot/video.txt` It can be a local path or any url (eg. `/var/video1.mp4`).
* Ensure to delete the `/boot/url.txt` file or its content, so the internal web browser does not get started.

Video gets played in loop mode.

### WiFi configuration
You can modify the sample `/boot/wpa_supplicant.conf.example` file on your SD card and insert your WiFi settings. After that you should rename the file into `wpa_supplicant.conf`

If the file exists at boot time it gets **moved** to /etc/wpa_supplicant.conf and network should start up immediately. Changes are retained even after restarts. If WiFi credentials are missing, boot times will be much longer.

### Boot splash screen
Our custom company boot splash (see `patches/psplash` folder) is enabled by default. *Please contact us if you want another boot splash logo in a prebuilt image.*

<img src="https://raw.githubusercontent.com/TOLDOTECHNIK/buildroot-webkit/master/_assets/splash-screen.png" width="400" />

We took some init scripts and appended the `/usr/bin/psplash-write "PROGRESS xy"`, so the progress bar increases while booting and decreases when shutdown is in progress.

### Node.js server
Node.js binaries and some node modules are preinstalled:
- express
- serve-static
- nodecec

A small Node.js webserver is also included and gets started while booting. It is running on localhost port 80.
Startup script is located here: `/etc/init.d/S30nodeserver`
Local web server content is located here: `/var/www/`

libcec and corresponding node module are both preinstalled so node apps can receive HDMI CEC messages.
See `/var/node/server.js` for an example.

**Builtin local web page supporting CEC and keyboard inputs.**

<img src="https://raw.githubusercontent.com/TOLDOTECHNIK/buildroot-webkit/master/_assets/cec-test.gif" width="400" />

### WPE WebKit browser
If the file `/boot/url.txt` exists the fullscreen browser will start automatically after boot. You will find the init script here: `/etc/init.d/S90wpe`

You can call the web inspector from an external client browser (tested with Chrome and Safari, not working with Firefox). `http://rpi0.local:9998` or `http://rpi3.local:9998`

If you want do disable it, you can comment out the `export WEBKIT_LEGACY_INSPECTOR_SERVER=0.0.0.0:9998` line in `/usr/bin/wpe`

### Keyboard and mouse input
Attach your keyboard and it's working out of the box. Try it out in the input form control on the sample web page. Please note that the keyboard layout cannot be changed for the WPE WebKit browser yet.

Mouse support in the browser window is enabled by uncommenting the `export WPE_BCMRPI_CURSOR=1` line in `/usr/bin/wpe`

### SSH, serial console
SSH (dropbear) is enabled by default. You can ssh into it with `ssh root@rpi0.local` or `ssh root@rpi3.local`

The device will setup a TTY on the UART (ttyAMA0). You can connect to it with an USB serial converter. Ensure to use 3.3V level!

**Console output on ttyAMA0 while booting**

<img src="https://raw.githubusercontent.com/TOLDOTECHNIK/buildroot-webkit/master/_assets/ttyAMA0-boot-messages.gif" width="400" />

#### Wiring
converter (RX) - green - (TX) RPi

converter (TX) - red - (RX) RPi

<img src="https://raw.githubusercontent.com/TOLDOTECHNIK/buildroot-webkit/master/_assets/USB-serial-wiring.png" width="400" />

### Root password
The root password is `root`

Please change it after first boot: `passwd root`

### Wired network interface
Due to bootup speed improvement eth0 is disabled by default. You can enable it by editing `/etc/network/interfaces`

### Auto-expand rootfs on first boot
The `S22resize_rootpart` init script expands the root filesystem to the maximum flash disk size on the first boot.
Firstly it expands the root partition, then a reboot is invoked. After second boot the root filesystem gets expanded to match the partition size. After that the system is ready to use and expand init scripts gets removed.

### CEC OSD name
You can change the CEC client name in `/boot/config.txt`. Store it in the `cec_osd_name` variable. It will be shown on your screen when selecting the HDMI source.

## Prebuilt images
Prebuilt images are freely available from our server.
- [RPi Zero / Zero W](https://dev.toldotechnik.li/wp-content/uploads/2018/11/sdcardRPi0.img_.zip) (2018-12-01)
- [RPi 3 B](https://dev.toldotechnik.li/wp-content/uploads/2018/11/sdcardRPi3.img_.zip) (2018-12-01)

Image files can be written the same way as the official Raspberry Pi images. Please see https://www.raspberrypi.org/documentation/installation/installing-images/

If you're using Etcher, you can take the zip files directly. You don't need to extract them.

## Known issues (all fixed)
### Node.js
Buildroot compiled Node.js binaries do start much slower than prebuilt ones from nodejs.org
That's why on Raspberry Pi Zero the browser gets loaded before the internal Node.js server is ready. This then results in a blank page screen.
To solve this issue we use these binaries in the prebuilt images instead https://nodejs.org/download/release/v8.12.0/node-v8.12.0-linux-armv6l.tar.xz
Create a sub folder `mkdir -p ./board/toldotechnik_rpi/rootfs-overlay/usr/bin` and copy the `node` binary into it.

### OSX terminal error when using nano
The `Error opening terminal: xterm-256color` we solved by creating the `/usr/share/terminfo/x/` folder and put in the `xterm-256color` database file.

### Raspberry Pis without onboard WiFi
If your board does not have WiFi you can attach some USB Ralink WiFi adapters. We already included those drivers. RTL8188CUS and RT5370 work for sure.

# How to build it yourself

## Prerequisites (tested on Ubuntu 16.04)
    apt-get install -y git subversion bc zip build-essential bison flex gettext libncurses5-dev texinfo autoconf automake libtool libpng12-dev libglib2.0-dev libgtk2.0-dev gperf libxt-dev ccache mtools

## Building
Clone our repo.

    git clone https://github.com/TOLDOTECHNIK/buildroot-webkit.git

Our implementation is based on the WebPlatformForEmbedded/buildroot repository. So let's clone it. We actually took the master branch commit `b67092fc5c92b3c09ad845296b3dc2734b91a66c` as of 2018-11-26.

    git clone https://github.com/WebPlatformForEmbedded/buildroot
	cd buildroot
	git reset --hard b67092fc5c92b3c09ad845296b3dc2734b91a66c

Add our custom board folder

    cp -r ../buildroot-webkit/board/toldotechnik_rpi ./board/

Add our custom board configs

    cp ../buildroot-webkit/configs/toldotechnik_rpi0_wpe_defconfig ./configs
    cp ../buildroot-webkit/configs/toldotechnik_rpi3_wpe_defconfig ./configs

Current WebPlatformForEmbedded/buildroot master branch does not provide the simple to use wpe-launcher anymore, so add it easily with our patch.

    patch -p1 < ../buildroot-webkit/0001-port-wpelauncher-from-stable.patch

Everything is ready now. You can load your board's configuration by typing

    make toldotechnik_rpi0_wpe_defconfig
or

    make toldotechnik_rpi3_wpe_defconfig

Before compiling you can make your own changes.

    make menuconfig

Finally build everything with

    make

After some hours of compiling the final image is ready. You can find it here: `./output/images/sdcard.img`
