# Setting up SSH to use `gpg-agent` on Linux

> &#x1F6A8; **PROCEED WITH CAUTION** &#x1F6A8;
>
> I don't use Linux as a workstation very often, so parts of the information on this page are not as familiar to me as they probably should be.
>
> Treat the information below as "something that worked for me at least once, but I don't really understand well enough to try and teach it to others".

This page covers how to set things up on a Linux machine, so that SSH commands use `gpg-agent` instead of `ssh-agent`.

The primary reason for doing this would be if your SSH secret keys are physically [stored on a YubiKey](../../yubikey/ssh.md) or a [OpenPGP card](https://en.wikipedia.org/wiki/OpenPGP_card)-compatible smartcard. Because you will need to insert and remove a YubiKey in the computer itself, the directions below are written with the assumption that you are at or near the machine's console.

Note that the process may be somewhat different for different Linux distributions. This page will focus on the distributions I use on a regular basis, namely CentOS 7, AlmaLinux 10, and Debian 12/13.


## Quick Setup

If you're logged into the *console* of a Linux machine and need to use your YubiKey to authenticate outbound SSH connections, but you don't want to *permanently* configure the machine ...

<details><summary>CentOS 7</summary>

This requires permanently installing a few software packages, but will not permanently change how things work after you log out.

* **Install packages.** This will need to be done once on each machine, and will make the software available for every user on the system.

    ```
    sudo yum install gnupg2 gnupg2-smime pcsc-lite pinentry
    ```

* **The first time you log into the machine**, make sure the `pcscd` service is running. This is needed for `gpg-agent` to talk to a YubiKey.

    ```
    sudo systemctl start pcscd
    ```

    * This command will start the `pcscd` service system-wide. You may want to stop the service (using `systemctl stop`) when you're finished. If you don't do this, it will continue to run, but it will not start by itself when the machine reboots.

* **Configure the current shell.** This will need to be done every time you open a new shell.

    ```
    export GPG_TTY="$( tty )"
    eval $( gpg-agent --daemon --enable-ssh-support )
    ```

    > Note that you *must* export the `GPG_TTY` variable before running `gpg-agent`.

</details><!-- CentOS 7 -->

<details><summary>AlmaLinux, Rocky, RHEL 10</summary>

I use AlmaLinux 10 on my own servers. I'm *assuming* that whatever I write for AlamLinux 10 will also work for Rocky 10 and RHEL 10 , but I can't guarantee anything - especially not for Rocky, which I have never used.

I don't have a "quick" process for AlmaLinux 10 yet. At first glance, it looks like more extensive changes are needed before `gpg-agent` will be able to talk to the YubiKey hardware. See the permanent procedure below.

</details><!-- AlmaLinux, Rocky, RHEL 10 -->

<details><summary>Debian-flavoured distros - Debian, Ubuntu, etc.</summary>

* **Install packages.** This will need to be done once on each machine, and will make the software available for every user on the system.
    ```
    sudo apt install gpg-agent scdaemon
    ```

* **The first time you log into the machine**, make sure the necessary services are running.
    ```
    systemctl --user start gpg-agent.service
    ```

    > Debian-flavoured systems set up `gpg-agent` to run as a per-user systemd service. This means that when log out of the *last* login session using that username, the system will stop the `gpg-agent` service automatically.

* **Configure the current shell session.** This will need to be done every time you open a new shell session.
    ```
    export GPG_TTY="$( tty )"
    export SSH_AUTH_SOCK="$( gpgconf --list-dirs agent-ssh-socket )"
    ```

</details><!-- debian and friends -->


## Permanent Setup

### Install Software

The following packages need to be installed on the machine. Note that these are the same packages you need to install if you plan to do this temporarily, as shown above.

* CentOS 7, Fedora, RHEL 9/10, AlmaLinux 10, etc.

    ```
    sudo yum install openssh-clients gnupg2 gnupg2-smime pcsc-lite pinentry
    ```

* Debian, Ubuntu, etc.

    ```
    sudo apt install openssh-client gpg-agent scdaemon
    ```


### Maybe: configure `pcscd`

There are two different programs that `gpg-agent` *can* use to talk to a smartcard reader (or a YubiKey, which emulates a smartcard reader with a single permanently installed card.)

* `scdaemon`, which is part of GnuPG.

    From what I remember, Debian 12 sets things up so that `gpg-agent` uses `scdaemon`, without `pcscd` being involved. It also sets up the necessary permissions to find and communicate with the hardware, so there may not be anything to be done for Debian-flavoured systems.

    I'm assuming that Debian 13 does the same, but I haven't installed it on a laptop yet so I can't say for sure.

* `pcscd`

    RedHat-flavoured distros (including [AlmaLinux](https://almalinux.org/), which I use on my own servers) use this.

> &#x26A0;&#xFE0F; **Caution**
>
> What I've written below *seems* to work, or did at one time, possibly only on one machine. The truth, is I don't understand these programs as well as I probably should. It's possible that some of the details below are incomplete or incorrect, or that I entirely missed something important.
>
> FWIW, [this page](https://book.sequoia-pgp.org/hardware_keys.html) from the [Sequoia PGP](https://sequoia-pgp.org/) documentation, has a fairly clear expanation of how `scdaemon` and `pcscd` interact and how to make the two work together.


**On RedHat-flavoured systems** (AlmaLinux 10 etc.), the following steps need to be done, as the `root` user:

* Make the `pcscd` service start automatically when the system boots. (Also start it now, if it isn't already running.)

    ```
    systemctl enable --now pcscd.service
    ```

* RHEL 10 and AlmaLinux 10 use [Polkit](https://github.com/polkit-org/polkit) to control which processes are able to connect to `pcscd`. (This may be true of other distros, I don't know.) On these systems, you need to configure Polkit to allow certain users to access cards managed by `pcscd`.

    * Create a user group called `plugdev` and add the appropriate user(s) to it.

        ```
        useradd -r plugdev
        usermod -a -G plugdev jms1
        ```
        If any of these users are currently logged in, they will need to log out and log back in before their shell will know that they belong to the new group.

    * Create `/etc/polkit-1/rules.d/90-pcsc.rules` with a rule allowing members of the `plugdev` group, to access `pcscd` and the cards it manages. The file looks like this:

        ```
        cat > /etc/polkit-1/rules.d/90-pcsc.rules <<EOF
        // allow members of group 'plugdev' to access pcsc devices
        polkit.addRule(function(action, subject) {
            if ( (    action.id === "org.debian.pcsc-lite.access_pcsc"
                   || action.id === "org.debian.pcsc-lite.access_card" )
                 && subject.isInGroup("plugdev") )
            {
                return polkit.Result.YES;
            }
            return polkit.Result.NOT_HANDLED;
        });
        EOF
        ```

        Note that the filename doesn't have to be *exactly* this, but the file does need to be in this directory.

        > The word `debian` in this file doesn't mean that the file is only needed on Debian-flavoured systems. This is the *exact* file I'm using on the AlmaLinux 10 system where I tried this stuff while writing this page.
        >
        > The word `debian` is probably there because they had something to do with ... writing `pcsc-lite`? writing its integration with Polkit? ... I'm not sure, if anybody knows please [let me know](../../introduction.md#contact).

    * If any YubiKeys are currently pluged in, remove and re-insert them.

**To make sure it worked**, as your *non-root* user, run this command:

```
gpg --card-status
```

The first few lines of the output should tell you what kind of card reader it is and the "Application ID" of the OpenPGP application on the card.

```
Reader ...........: Yubico YubiKey FIDO CCID 00 00
Application ID ...: D2760001240100000006199999990000
Application type .: OpenPGP
Version ..........: 3.4
Manufacturer .....: Yubico
Serial number ....: 19999999
...
```


### Configure `gpg` and `gpg-agent`

In the home directory of each user who will need to use this ...

* `$HOME/.gnupg/gpg.conf` should contain the following line:
    ```
    use-agent
    ```

    This tells the `gpg` command to use `gpg-agent` for operations involving secret keys. This is the default behaviour for GnuPG 2.0 and later, but it doesn't hurt anything to be sure.

* `$HOME/.gnupg/gpg-agent.conf` should contain the following line:
    ```
    enable-ssh-support
    ```

    This tells `gpg-agent` to always start the extra listener which "speaks" the `ssh-agent` protocol.


### Maybe: XFCE

I normally use XFCE as my desktop envrionment for Linux workstations. Under XUbuntu 18.04 and Debian 12 its default configuration starts `ssh-agent` automatically while setting up the desktop session (i.e. every time I log into a GUI session). This was causing problems for me, so I ended up configuring XFCE *not* to do this.

The commands I used were:

```
xfconf-query -c xfce4-session -p /compat/LaunchGNOME -n -t bool -s false
xfconf-query -c xfce4-session -p /startup/ssh-agent/enabled -n -t bool -s false
```

This may or may not be necessary for you, I'm including the information here because I need to remember this when setting up a new Debian workstation.

> If you're curious, [this document](https://jms1.pub/notes/xubuntu/laptop-setup.md) was my checklist for setting up Xubuntu, back in 2020. I'm not sure that the *entire* document is still useful, because my Linux laptops are now running Debian 12 or 13. At some point I plan to update this document for Debian and include it on this site.
>
> Unfortunately [Keybase Sites](https://book.keybase.io/sites) doesn't render Markdown to HTML, but Markdown is pretty easy to read on its own.


### Configure your shell

You need to make sure that your shell always sets the `GPG_TTY` and `SSH_AUTH_SOCK` variables correctly.

I do this by including something like this in my `.bashrc` file:

```
export GPG_TTY="$( tty )"

ZZZ_SOCK="$( gpgconf --list-dirs agent-ssh-socket )"
if [[ -n "${ZZZ_SOCK:-}" ]]
then
    export SSH_AUTH_SOCK="$ZZZ_SOCK"
fi
unset ZZZ_SOCK
```

Once you have added this, every *new* interactive shell will have the correct values for these two variables. Note that setting the variables in this way will only affect shells and any processes started from those shells. In particular, it will NOT affect processes started by something other than your shell, such as cron jobs.

If your YubiKey [contains an SSH secret key](../../yubikey/load-pgp-key.md), you can test it all by running `ssh-add -L`. The output should be your SSH public key, in the same format needed by an `authorized_keys` file, with the YubiKey's serial number as the comment at the end.

```
$ ssh-add -L
ssh-rsa AAAAB3NzaC1yc2EAAAAD...evwOVnvi1eTUAkjIPw== cardno:19_999_999
```

### Final Test

Reboot the machine, log in on the console, insert the YubiKey, and run `ssh-add -L`.


