# Using colima to run x86 Containers on ARM

**2024-07-06**

I started off using [Docker Desktop](https://www.docker.com/products/docker-desktop/) to run containers on my macOS workstation, both at work and for personal projects. For a while it was actually pretty cool.

However, Docker (the company) changed. They started collecting detailed usage information from the software, they wouldn't let you *use* the software without logging into a "Docker account" (which lets them correlate the usage information with a specific person), and then they changed their licensing and started demanding that commercial users to pay for it - with a *ridiculously* high pricetag at the time ($25/mo per user? really?)

So I started looking for alternatives, and found [colima](https://github.com/abiosoft/colima). This is an open source program which combines [Lima](https://github.com/lima-vm/lima) (LInux MAchines, which runs Linux VMs on macOS) and a container runtime (Docker, [Podman](https://podman.io/), or [containerd](https://containerd.io/)). I've been using this at work, and for personal projects, for a few years now.

### Rosetta 2

One of my home machines is a MacBook Air with an Apple M2 processor, and now that Apple no longer sells Intel machines, it looks like any future Apple machines I buy will also use "Apple Silicon" (aka "ARM") processors as well. Being a different processor architecture, it has a totally different instruction set, and therefore cannot run x86 code by itself.

When Apple switched from PowerPC to Intel processors, they also released a thing called Rosetta, which allowed PowerPC executables to run on Intel-based machines. When they released the first M1 machine, they also released [Rosetta 2](https://support.apple.com/guide/security/rosetta-2-on-a-mac-with-apple-silicon-secebb113be1/web), which translates x86_64 code into ARM code, either "on the fly" while a process is running, or "ahead of time" the first time you run a program.

### Colima

Colima works by creating a Linux VM, using one of two methods:

* [QEMU](https://www.qemu.org/) is an open-source software-based virtualization framework which has been around for 20+ years. This is the default technology used by [KVM](https://www.linux-kvm.org/page/Main_Page), which I've been using for many years to run Linux VMs on Linux hosts.

    QEMU has the ability to create VMs running a wide [range of architectures](https://www.qemu.org/docs/master/about/emulation.html), on a range of host operating systems and architectures.

    Colima uses QEMU by default.

* Apple's native virtualization framework, called VZ. The framework itself is built into macOS, but Apple only provides an [API](https://developer.apple.com/documentation/virtualization) for other programs to call it - they don't offer any kind of user interface to manage VMs. (If you're interested, programs like [UTM](https://mac.getutm.app/) and [VirtualBuddy](https://github.com/insidegui/VirtualBuddy) exist for this, but you won't need them for what this page covers.)

## Creating Colima VMs

The `colima start` command will create a new VM, if one doesn't already exist.

Each Linux VM is identified using a "profile" name. If you create a Linux VM without giving it a profile name, it will use the name `default`. There are options to specify the properties of the VM, such as CPU count, RAM, and disk space. These options are only needed when *creating* a new Linux VM, and are ignored if the VM already exists.

The commands listed below only cover the options needed to set the VM's architecture and virtualization runtime. Other options, such as CPU count, RAM, and disk size, are not shown, but should be added to these commands if needed.

### On an Intel Mac

* Intel (`x86_64`) VM using QEMU

    ```
    colima start --arch x86_64 --profile qemu_x86_64
    ```

    * The `--arch x86_64` option isn't strictly necessary, since it will be the default on an ARM-based Mac, but it doesn't hurt anything to include it.


* Intel (`x86_64`) VM using VZ (&#x2753; not tested yet)

    ```
    colima start --arch x86_64 --vm-type=vz --profile vz_x86_64
    ```

    * The `--arch x86_64` option isn't strictly necessary, since it will be the default on an ARM-based Mac, but it doesn't hurt anything to include it.

* ARM (`aarch64`) VM using QEMU (&#x2753; not tested yet)

    ```
    colima start --arch aarch64 --profile qemu_aarch64
    ```

### On an ARM (Apple Silicon) Mac

* ARM (`aarch64`) VM using QEMU

    ```
    colima start --arch aarch64 --profile qemu_aarch64
    ```

    * The `--arch aarch64` option isn't strictly necessary, since it will be the default on an ARM-based Mac, but it doesn't hurt anything to include it.

* ARM (`aarch64`) VM using VZ

    ```
    colima start --arch aarch64 --vm-type=vz --profile vz_aarch64
    ```

    * The `--arch aarch64` option isn't strictly necessary, since it will be the default on an ARM-based Mac, but it doesn't hurt anything to include it.

* Intel (`x86_64`) VM using QEMU

    ```
    colima start --arch x86_64 --profile qemu_x86_64
    ```

* Intel (`x86_64`) VM using VZ and Rosetta 2

    ```
    colima start --arch x86_64 --vm-type=vz --vz-rosetta --profile qemu_x86_64
    ```

## Working with Colima VMs

### List Colima VMs

```
(jms1@M2Air15) 2 ~ $ colima list
PROFILE         STATUS     ARCH       CPUS    MEMORY    DISK      RUNTIME    ADDRESS
default         Running    x86_64     4       4GiB      100GiB    docker
qemu_aarch64    Stopped    aarch64    2       2GiB      60GiB
qemu_x86_64     Stopped    x86_64     2       2GiB      60GiB
vz_aarch64      Running    aarch64    2       2GiB      60GiB     docker
```

In this case, the `default` VM is using `x86_64` with VZ and Rosetta 2. I was recently using it to update some [CentOS 7 container images](centos7-vault.md).

### SSH

```
(jms1@M2Air15) 3 ~ $ colima ssh
jms1@colima:/Users/jms1/work$ uname -a
Linux colima 6.8.0-31-generic #31-Ubuntu SMP PREEMPT_DYNAMIC Sat Apr 20 00:40:06 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
jms1@colima:/Users/jms1/work$ exit
logout
```

```
(jms1@M2Air15) 4 ~ $ colima -p vz_aarch64 ssh
jms1@colima-vzaarch64:/Users/jms1/work$ uname -a
Linux colima-vzaarch64 6.8.0-31-generic #31-Ubuntu SMP PREEMPT_DYNAMIC Sat Apr 20 02:32:42 UTC 2024 aarch64 aarch64 aarch64 GNU/Linux
jms1@colima-vzaarch64:/Users/jms1/work$ exit
logout
```

## Using Docker with Specific Colima VMs

Docker uses "contexts" to configure which Linux VM it talks to. All `docker` commands use the currently active context, other than `docker context` itself.

```
(jms1@M2Air15) 6 ~ $ docker context ls
NAME                  DESCRIPTION                               DOCKER ENDPOINT                                     ERROR
colima                colima                                    unix:///Users/jms1/.colima/default/docker.sock
colima-vz_aarch64 *   colima [profile=vz_aarch64]               unix:///Users/jms1/.colima/vz_aarch64/docker.sock
default               Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
```

Running a container in the current context (which points to the `vz_aarch64` VM, as shown above) ...

```
(jms1@M2Air15) 7 ~ $ docker run -it --rm alpine uname -a
Linux f4f634a4b910 6.8.0-31-generic #31-Ubuntu SMP PREEMPT_DYNAMIC Sat Apr 20 02:32:42 UTC 2024 aarch64 Linux
```

Change to a different context and run a container there ...

```
(jms1@M2Air15) 8 ~ $ docker context use colima
colima
Current context is now "colima"
```

```
(jms1@M2Air15) 9 ~ $ docker run -it --rm alpine uname -a
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
ec99f8b99825: Pull complete
Digest: sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0
Status: Downloaded newer image for alpine:latest
Linux 8cf92535747a 6.8.0-31-generic #31-Ubuntu SMP PREEMPT_DYNAMIC Sat Apr 20 00:40:06 UTC 2024 x86_64 Linux
```

# Changelog

**2024-07-06** jms1

* copied from Obsidian notes
* wrote some human-readable descriptions, verified commands for other scenarios
