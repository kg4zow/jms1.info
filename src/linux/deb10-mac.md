# Notes from Installing Debian 10 on a Macbook Pro

**2021-01-09**

I've always used the RedHat-flavoured versions of Linux, usually CentOS. However, RedHat has decided to stop maintaining CentOS 8 and declare an early end-of-life for it, and instead is offering "CentOS Stream", which instead of *following* RedHat Enterprise, is essentially a beta-test distro which *feeds into* RHEL.

IBM purchased RedHat a few years back, so I can't say I'm totally surprised by this.

Anyway.

At work, the servers we deploy at client sites have been using CentOS 7 for many years, and we *were* about to start upgrading things from CentOS 7 to CentOS 8. However, with this news we've decided to move away from CentOS entirely.

At the same time, we're also in the process of re-architecting our software to run under Kubernetes, which doesn't really care *what* distro it's running on, so long as it has a Linux kernel. So moving from CentOS to Debian isn't necessarily a *huge* deal, except that it means re-writing the systems which build the underlying machines on which Docker and Kubernetes will be installed ... *which is pretty much my job.*

Long story short, we've decided to use Debian 10 instead of CentOS. (Actually, other things have taken priority and in the meantime Debian 11 was released, so we'll probably be using Debian 11 instead.)

This page contains a collection of random notes I made for myself while exploring Debian 10, using a spare 2013 MacBook Pro.

# Notes about Debian 10

Moste of these notes also apply to Debian 11 and 12 as well.

## Mac Boot Menu

On a Mac, when you hold down the Option key during the start-up chime, it shows a list of all bootable partitions or devices and lets you choose which one to boot from. Debian doesn't appear on this list, however it does boot correctly when you *don't* use the boot selector.

At some point I'll figure out why it's not showing up there, when I do I'll update this page.

## Wifi Driver

This particular machine is going to be used as a server, at least for now, so it doesn't really *need* wifi support. However, I figure I'm going to need wifi support at some point, so I took a few minutes to figure out how to enable it, so I could include it here.

Broadcomm chipsets (and some others) require that an opaque binary "blob" be uploaded into the card in order to initialize it. These blobs are not open-source, so they cannot be distributed as part of Debian itself. Instead, the debian "contrib" repo contains a package called `firmware-b43-installer` which, as part of its post-install script, downloads a package full of binary blobs from (somewhere?) to the `/lib/firmware/` directory.

* [`https://wiki.debian.org/Firmware`](https://wiki.debian.org/Firmware)

### Install firmware manually

Edit `/etc/apt/sources.list`. At the end of every `deb` and `deb-src` line which points to `deb.debian.org`, after `main`, add `contrib`.

```
deb http://deb.debian.org/debian/ buster main contrib
deb-src http://deb.debian.org/debian/ buster main contrib
```

Once this is done, install the package which downloads and installs the firmware files.

```
# apt install firmware-b43-installer
```

When the package finishes installing, you will see it download a file from an external web site, which contains a collection of firmware blobs. This file is expanded into the `/lib/firmware/` directory.

Once the file has been downloaded and installed, reboot the machine.

```
# shutdown -r now
```

When it boots again, the kernel should load the firmware file, and the wifi interface should be created.

```
# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp1s0f0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT group default qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
3: wlp2s0b1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
```

In this case, "`wlp2s0b1`" is the new wifi interface.

### During the install

The Debian installer recognizes the Wifi chipset as one that it doesn't support without a firmware "blob" file, and provides a mechanism to supply the file on a USB stick (or a floppy, if the machine has one). This seems useful if you need wifi in order to complete the install.

Every time I've seen this, the machine has had a physical ethernet port, so I've never needed to do this. I have no idea what the requirements are, i.e. what filesystem the USB stick can or should use, whether the firmware blob file should be in the root of the stick or within a certain directory, and so forth. If I ever get curious and have the time I'll play around with that and update this page with my findings.

## Interface names

Debian 10 has adopted this "Predictable Names" thing, where the network interfaces are given names which are supposed to never change, but which are very tedious for a human to remember or type.

It's not necessarily a bad *concept*, and on machines where the hardware may change from time to time (i.e. if you have network interfaces which connect via USB) it can make sense. But it doesn't really provide any value for a server, where the hardware never changes.

And I don't particularly care to un-learn almost thirty years' worth of muscle memory, and change from *knowing* that the ethernet interfaces are `eth0`, `eth1`, and so forth, to having to look up the interface names on every machine I touch.

I prefer to use the sensible "old school" names like `eth0` and `wlan0`, so I did the following:

* Edit `/etc/default/grub`, add `net.ifnames=0` to the kernel's command line.

    ```
    GRUB_CMDLINE_LINUX="net.ifnames=0"
    ```

* Run `update-grub`

* Reboot.

Once it comes back, you will probably find that none of the interfaces *have* IP addresses, because their names don't match the names in the `/etc/network/interfaces` file. To fix this...

* Run `ip link show` and note the *new* names of each interface.

* Edit `/etc/network/interfaces` and change any instance of the old interface names, to the corresponding new name.

* Restart the network.

    **TODO:** `systemctl restart network` doesn't work on Debian, need to figure out how to do this.

## Timezone

One of the first questions that the Debian installer asks is, what part of the world you're in. Later on it asks what timezone you want the machine to use, however if you selected "United States" as a location, it will only show you the American time zones.

A LOT of people have been complaining about this for years, but apparently the people who maintain the Debian installer don't want to hear that some people build *servers* and want the systems' clocks to run on UTC.

### During install

The only way to get UTC as an option during the install is to lie about your location.

* Select (UK? Europe? "Etc"?) as location.

* Then select UTC as the timezone.

Note that doing this may also configure other things on the system, like using the "`en_GB`" locale instead of "`en_US`", which may result in using an unexpected console font or keyboard mapping. (Seeing "&#x00A3;" when you're trying to type "#" is always fun.)

### After install

The other option is to let the installer do what it wants to do, and then manually configure the timezone after the system is running.

List available time zones: (the list is rather long)

```
$ timedatectl list-timezones
...
America/New_York
...
Etc/UTC
...
```

Set the system to use a different time zone:

```
$ sudo timedatectl set-timezone Etc/UTC
```

**Alternate method:** (useful on older Debian machines which don't have a `timedatectl` command)

```
$ sudo ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
```

# Changelog

**2024-06-19** jms1

- moved page to new `jms1.info` site, updated header
- minor content updates

**2022-01-22** jms1

- added possible "last updated" field for each page, used this page to test
- minor tweaks in text
- fixed Changelog dates (should be 2021, not 2011)

**2021-01-12** jms1

- updated info about how to set time zone
- better explanation of how `firmware-b43-installer` works
- added other general info
- added to `jms1.info` site

**2021-01-09** jms1

- initial version (not ready for public consumption yet)
