# Using colima to run x86 Containers on ARM

**2024-07-29**

I started off using [Docker Desktop](https://www.docker.com/products/docker-desktop/) to run containers on my macOS workstation, both at work and for personal projects. For a while it was actually pretty cool.

However, Docker (the company) changed. They started collecting detailed usage information from the software, they wouldn't let you *use* the software without logging into a "Docker account" (which lets them correlate the usage information with a specific person), and then they changed their licensing and started demanding that commercial users to pay for it - with a *ridiculously* high pricetag at the time ($25/mo per user? really?)

So I started looking for alternatives, and a colleague pointed me to [colima](https://github.com/abiosoft/colima). This is an open source program which combines [Lima](https://github.com/lima-vm/lima) (LInux MAchines, which runs Linux VMs on macOS) and a container runtime (Docker, [Podman](https://podman.io/), or [containerd](https://containerd.io/)). I've been using this at work, and for personal projects, for a few years now.

### Rosetta 2

One of my home machines is a MacBook Air with an Apple M2 processor, and now that Apple no longer sells Intel machines, it looks like any future Apple machines I buy will also use "Apple Silicon" (aka "ARM") processors as well. Being a different processor architecture, it has a totally different instruction set, and therefore cannot run x86 code by itself.

When Apple switched from PowerPC to Intel processors, they also released a program called Rosetta, which allowed PowerPC executables to run on Intel-based machines. When they released the first M1 machine, they also released [Rosetta 2](https://support.apple.com/guide/security/rosetta-2-on-a-mac-with-apple-silicon-secebb113be1/web), which translates x86_64 code into ARM code, either "on the fly" while a process is running, or "ahead of time" the first time you run a program.

### Colima

Colima on macOS works by creating Linux VMs with Docker or Podman running in them, and passing any `docker` or `podman` commands to that VM.

It can use one of two methods to create these Linux VMs:

* [QEMU](https://www.qemu.org/) is an open-source software-based virtualization framework which has been around for 20+ years. This is the default technology used by [KVM](https://www.linux-kvm.org/page/Main_Page), which I've been using for many years to run Linux VMs on Linux hosts.

    QEMU has the ability to create VMs running a wide [range of CPU architectures](https://www.qemu.org/docs/master/about/emulation.html), on a range of host operating systems and architectures. For the purposes of this page, this includes being able to run `x86_64` (64-bit Intel) VMs on an `aarch64` (64-bit ARM, aka "Apple Silicon") host.

    Colima uses QEMU by default.

* VZ is Apple's native [virtualization framework](https://developer.apple.com/documentation/virtualization) in macOS 11 and later. The framework itself is built into macOS, but Apple doesn't offer any kind of user interface to manage VMs, just an [API](https://developer.apple.com/documentation/virtualization) for other programs to use. If you're interested, there are programs out there to create VMs using VZ, such as [UTM](https://mac.getutm.app/) and [VirtualBuddy](https://github.com/insidegui/VirtualBuddy).

    **Colima can use VZ under macOS 13 and later.** On earlier macOS versions, colima will only use QEMU.

With colima on macOS, the container runtime is a process running within the Linux VM that colima creates. This means that the images you pull are actually stored within that VM, and the containers you run are running on that VM.

Note that colima *can* run multiple Linux VMs at the same time.

## Creating Colima VMs

The `colima start` command will create a new Linux VM, if one doesn't already exist.

Each Linux VM is identified using a "profile" name. If you create a Linux VM without giving it a profile name, it will use the name `default`. If you have a profile called `default`, other `colima` commands will use it *unless* you include a `--profile` option in those commands.

For me, 99% of what I use containers for is to run `x86_64` containers, so my `default` profile is an "x86_64 using VZ and Rosetta 2" VM.


> The commands listed below only cover the options needed to set the virtualization runtime (QEMU or VM) and CPU architecture of the VM (aarch64 or x86_64). Other options, such as CPU count, RAM, and disk size, are not shown, but should be added to these commands if needed.

### On an Intel Mac

* Intel (`x86_64`) VM using QEMU

    ```
    colima start --profile qemu_x86_64 \
        --cpu-type max
    ```

    * The `--cpu-type max` option tells QEMU to mirror the [x86 CPU capabilities](x86-64-v.md) of the underlying host. Without this, the virtualized CPU won't be able to run AlmaLinux/RHEL 9.

    * You *can* also use the `--arch x86_64` option, but it isn't necessary since it will be the default on an Intel-based Mac.


* Intel (`x86_64`) VM using VZ (&#x2753; not tested yet)

    ```
    colima start --profile vz_x86_64 \
        --cpu-type max \
        --vm-type vz \
    ```

    * The `--cpu-type max` option tells VZ to mirror the [x86 CPU capabilities](x86-64-v.md) of the underlying host. Without this, the virtualized CPU won't be able to run AlmaLinux/RHEL 9.

    * You *can* also use the `--arch x86_64` option, but it isn't necessary since it will be the default on an Intel-based Mac.

* ARM (`aarch64`) VM using QEMU (&#x2753; not tested yet)

    ```
    colima start --profile qemu_aarch64 \
        --arch aarch64
    ```

### On an ARM (Apple Silicon) Mac

* ARM (`aarch64`) VM using QEMU

    ```
    colima start --profile qemu_aarch64
    ```

    * You *can* also use the `--arch aarch64` option, but it isn't necessary since it will be the default on an Intel-based Mac.

* ARM (`aarch64`) VM using VZ

    ```
    colima start --profile vz_aarch64 \
        --vm-type vz
    ```

    * You *can* also use the `--arch aarch64` option, but it isn't necessary since it will be the default on an Intel-based Mac.

* Intel (`x86_64`) VM using QEMU

    ```
    colima start --profile qemu_x86_64 \
        --arch x86_64 --cpu-type max
    ```

    * The `--cpu-type max` option tells QEMU to mirror the [x86 CPU capabilities](x86-64-v.md) of the underlying host. Without this, the virtualized CPU won't be able to run AlmaLinux/RHEL 9.

* Intel (`x86_64`) VM using VZ and Rosetta 2

    ```
    colima start --profile vzr_x86_64 \
        --arch x86_64 --cpu-type max \
        --vm-type vz --vz-rosetta
    ```

    * The `--cpu-type max` option tells VZ to mirror the [x86 CPU capabilities](x86-64-v.md) of the underlying host. Without this, the virtualized CPU won't be able to run AlmaLinux/RHEL 9.


## Working with Colima VMs

### Colima VMs

The `colima list` command will show you some basic information about all of the colima VMs on the machine.

```
$ colima list
PROFILE         STATUS     ARCH       CPUS    MEMORY    DISK      RUNTIME    ADDRESS
default         Running    x86_64     4       4GiB      100GiB    docker
qemu_aarch64    Stopped    aarch64    2       2GiB      60GiB
qemu_x86_64     Stopped    x86_64     2       2GiB      60GiB
vz_aarch64      Running    aarch64    2       2GiB      60GiB     docker
```

The `colima status` command will show you which virtualization framework (i.e. QEMU or VZ) the VM is running under, along with the path to the unix socket used by `docker` or `podman` commands to talk to the container runtime.

```
$ colima status --profile vz_x86_64
INFO[0000] colima [profile=vz_x86_64] is running using macOS Virtualization.Framework
INFO[0000] arch: x86_64
INFO[0000] runtime: docker
INFO[0000] mountType: virtiofs
INFO[0000] socket: unix:///Users/jms1/.colima/vz_x86_64/docker.sock
```

The only way I've found to see more detailed information is to look lat the YAML file colima creates. You will find these as `$HOME/.colima/PROFILE/colima.yaml`.

### SSH

The `colima ssh` command will SSH directly into the Linux VM that `colima` creates.

```
(jms1@M2Air15) 3 ~ $ colima ssh
jms1@colima:/Users/jms1/work$ uname -a
Linux colima 6.8.0-31-generic #31-Ubuntu SMP PREEMPT_DYNAMIC Sat Apr 20 00:40:06 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
jms1@colima:/Users/jms1/work$ exit
logout
```

If you're using a profile other than `default`, be sure to specify the profile name in the command.

```
(jms1@M2Air15) 4 ~ $ colima -p vz_aarch64 ssh
jms1@colima-vzaarch64:/Users/jms1/work$ uname -a
Linux colima-vzaarch64 6.8.0-31-generic #31-Ubuntu SMP PREEMPT_DYNAMIC Sat Apr 20 02:32:42 UTC 2024 aarch64 aarch64 aarch64 GNU/Linux
jms1@colima-vzaarch64:/Users/jms1/work$ exit
logout
```

I have SSH'd into colima VMs a few times out of curiosity, but the truth is I've never *needed* to do it. If you're going to do it, be careful not to change anything. Any settings you might need to change, should be changed by editing the VM's `$HOME/.colima/PROFILE/colima.yaml` file while the VM is stopped, or by deleting the VM and running the `colima start` command with different options. (I keep the command lines I use to create colima VMs in an [Obsidian](../obsidian/index.md) notebook.)

## Using Docker with Specific Colima VMs

If you have multiple colima VMs, you need a way to tell `docker` commands which VM to talk to. Docker uses "contexts" for this.

At any time, Docker will be a "current" context that all `docker` commands will use. When colima creates a VM, it also creates a Docker context pointing to that VM (or technically, pointing to a unix socket which is connected to the unix socket where the container runtime within the VM is listening).

If you have multiple contexts and need to control which one a particular `docker` command uses, you need to "use" the correct context first.

### List Contexts

The `docker context ls` command lists all contexts that the `docker` command (on the Mac) is aware of.

```
$ docker context ls
NAME                DESCRIPTION                               DOCKER ENDPOINT                                  ERROR
colima *            colima                                    unix:///Users/jms1/.colima/default/docker.sock
colima-vz_aarch64   colima [profile=vz_aarch64]               unix:///Users/jms1/.colima/vz_aarch64/docker.sock
default             Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
```

One of the contexts will have a `*` after the context name. This is the "current" context, which other `docker` commands will use.

### Using a Different Context

The `docker context use` command will set the context used by other `docker` commands.

As an example, starting with the following VMs and contexts ...

```
$ colima list
PROFILE       STATUS     ARCH       CPUS    MEMORY    DISK      RUNTIME    ADDRESS
default       Running    x86_64     4       4GiB      100GiB    docker
vz_aarch64    Running    aarch64    2       2GiB      60GiB     docker

$ docker context ls
NAME                  DESCRIPTION                               DOCKER ENDPOINT                                     ERROR
colima                colima                                    unix:///Users/jms1/.colima/default/docker.sock
colima-vz_aarch64 *   colima [profile=vz_aarch64]               unix:///Users/jms1/.colima/vz_aarch64/docker.sock
default               Current DOCKER_HOST based configuration   unix:///var/run/docker.sock

$ docker run -it --rm alpine:latest uname -m
aarch64
```

The `docker context use` command will change which context future `docker` commands will use.

```
$ docker context use colima
colima
Current context is now "colima"

$ docker run -it --rm alpine:latest uname -m
x86_64
```

# Changelog

**2024-07-29** jms1

* added info about `--cpu-type max` option
* other updates

**2024-07-06** jms1

* copied from Obsidian notes
* wrote some human-readable descriptions, verified commands for other scenarios
