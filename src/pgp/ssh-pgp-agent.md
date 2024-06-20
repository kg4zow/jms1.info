# Make SSH use `gpg-agent`

**2018-04-01**

This document covers how to "trick" SSH commands into using `gpg-agent` instead of `ssh-agent`, which makes it possible to hold your SSH secret keys on a YubiKey.

## Quick setup - CentOS 7

If you're standing at the console of a CentOS 7 machine and need to use your YubiKey to authenticate outbound SSH connections...

```
sudo yum install gnupg2-smime pcsc-lite
sudo systemctl start pcscd
eval $( gpg-agent --daemon --enable-ssh-support )
export SSH_AUTH_SOCK="$( gpgconf --list-dirs agent-ssh-socket )"
```

Now you *should be* good to go.

## Pre-requisites

The two obvious dependencies are an SSH client, and `gnupg`. One or both of these are usually installed on most Linux and macOS machines.

### Linux

Most Linux distros come with `openssh` already installed, however some distros may split the client and server bits into separate packages. *Some* distros may install `gnupg` as well - if not, you should be able to use `yum`, `apt-get`, or a similar command, to install the necessary packages. Search

#### CentOS, Fedora, RedHat, etc.

```
yum install openssh-clients gnupg2 gnupg2-smime
```

#### Debian, Ubuntu, etc.

I'm using Xubuntu 18.04 on a few workstations at home. The commands I use to configure SSH to use `gpg-agent` on these machines are...

```
sudo apt install scdaemon gpg-agent

mkdir -p ~/.gnupg
echo use-agent >> ~/.gnupg/gpg.conf
echo enable-ssh-support >> ~/.gnupg/gpg-agent.conf

xfconf-query -c xfce4-session -p /compat/LaunchGNOME -n -t bool -s false
xfconf-query -c xfce4-session -p /startup/ssh-agent/enabled -n -t bool -s false
```

If you're curious, [this document](https://keybase.pub/jms1/notes/xubuntu/laptop-setup.md) is my checklist for setting up Xubuntu. Unfortulately Keybase doesn't render Markdown to HTML like my web server does, but Markdown is pretty easy to read on its own.

#### Other Linux distros

I don't have the exact commands for every other distro out there.  For `gnupg` you should search for packages with names like `gnupg`, `gpg2`, or maybe just `gpg`.

### macOS - GPGTools

**Note:** I don't use GPGTools anymore, but I'm leaving this info here. See "macOS - Homebrew" below for more information.

For macOS, the `openssh` client is installed as a basic part of the OS, however `gnupg` is not. There are two ways to install the `gnupg` tools:

* Visit [`https://gpgtools.org/`](https://gpgtools.org/) and install the current version of GPG Suite.

    Not only will this give you the `gpg` command line tools, but it also includes a System Preferences widget to control some aspects of how `gpg` and `gpg-agent` work, along with a Mail.app plugin to support signing and encrypting email.

* **`brew install --cask gpg-suite`** will install the same package, using [Homebrew](https://brew.sh/).

    Note: you can also use **`brew install --cask gpg-suite-no-mail`** if you don't need the Mail.app plugin.

Note that both methods end up installing the same software, I just find it easier to use the command line, so I use Homebrew on my macOS machines.

Also note that **the Mail.app plugin is not free**. It's not *horribly* expensive, and it's not a "subscription" (it's a one-time purchase for each "major version" of the GPG Suite package), however they only allow five "activations", and the "Paddle" framework wants to connect to `api.paddle.com` on a regular basis.

I don't like the whole "limited number of activations" thing, and I hate any kind of system which contstantly "phones home" like like this, so ... while I do believe in supporting the authors of the software I use, I figure the donation I sent them a few back covers my use of the command line tools and the Preferences widget, and I use Thunderbird with Enigmail instead of their Mail.app plugin.

### macOS - Homebrew

I was working on another page today (2022-01-22) and noticed that the machine (a MacBook Air M1) appeared to have three different versions of `gpg` installed, from a combination of "MacGPG2", "GPGTools", and Homebrew. In the interest of "cleaning up", I decided to remove all but one - and the Homebrew version is what I decided to keep, since it's a dependency of a few other Homebrew packages I use, and because it's quicker and easier to install. (I'm familiar enough with `gpg` and key management that I don't really need the key management GUI and System Preferences widget.)

After downloading and running the [GPGTools Uninstaller](https://gpgtools.tenderapp.com/kb/faq/uninstall-gpg-suite) ([direct download link](https://gpgtools.org/uninstaller)) I discovered that the "MacGPG2" version was also gone, and the Homebrew version was the only thing left on the machine. (Apparently "GPG Suite", "GPG Tools", and "MacGPG2" are all the same thing.) I ran into some issues after removing GPGTools ... long story short, GPG uses a program called `pinentry` to ask the user for a PIN code when a "card" requires one. The `pinentry` program from GPGTools *was* the only one on the machine, so the error was because `gpg-agent` wanted to ask for a PIN but had no way to do so.

The fix was to install a "pinentry" program using Homebrew. Running "`brew search pinentry`" command showed that there's a "`pinentry-mac`" package, and "`brew info pinentry-mac`" confirmed that it *is* what it sounds like, and after installing it, I'm able to `ssh` just like I did before removing GPGTools.

**TL;DR** This command will install the necessary packages from Homebrew.

```
brew install gnupg pinentry-mac
```

I also had to configure `gpg-agent`. Details are below, but here's the short version:

```
mkdir -p $HOME/.gnupg
cat > $HOME/.gnupg/gpg-agent.conf <<EOF
enable-ssh-support
pinentry-program    /opt/homebrew/bin/pinentry-mac
EOF
gpg-connect-agent killagent /bye
gpg-connect-agent /bye
```

After restarting `gpg-agent`, everything is working again.

## Setup - Linux

To make *the current shell* use `gpg-agent` (and therefore the YubiKey) instead of the normal `ssh-agent` ...

### Manual process

* Make sure the `GPG_TTY` variable is set.

    ```
    export GPG_TTY=$(tty)
    ```

* Make sure that the `SSH_AUTH_SOCK` variable points to the `S.gpg-agent.ssh` socket.

    ```
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="$( gpgconf --list-dirs agent-ssh-socket )"
    ```

Any commands executed in this shell will use `gpg-agent` as the SSH agent.

### Automatic process (shell, per-user)

To make sure that your shell always sets the `GPG_TTY` and `SSH_AUTH_SOCK` variables correctly, add the following to your `.bash_profile` (or the appropriate file, if your login shell is not `bash`)

```
########################################
# Set things up for using gpg-agent

export GPG_TTY=$(tty)

function use-gpg-agent-for-ssh {
    SOCK="$( gpgconf --list-dirs agent-ssh-socket )"
    if [[ -n "${SOCK:-}" ]]
    then
        unset SSH_AGENT_PID
        export SSH_AUTH_SOCK="$SOCK"
    fi
}

use-gpg-agent-for-ssh
```

Note that this creates a function to "do the work", and then calls that function. This way if you decide you don't want this all the time, you can comment out just the function call (the last line), and then you can type `use-gpg-agent-for-ssh` in any shell to easily "activate" the change within that shell.

Once you have added this, every new interactive shell will use the changes. A quick way to test it is to open a new terminal window, which will contain a new shell. Once you have verified that it's working, you can either close the shell you're working in and open a new window, or you can run "`source ~/.bash_profile`" to read the updated profile into the current shell.

Note that setting the variables in this way will only affect shells and any processes started from those shells. In particular, it will NOT affect processes started by something other than your shell, such as cron jobs.

### Automatic process (all users)

The process is the same as the "shell, per-user" process above, except that instead of editing your `~/.bash_profile` file...

* You will edit `/etc/profile`, so that all users will use it.

* On some systems (such as CentOS 6 or 7, and probably 8 although I haven't tried it yet) you may be able to create an `/etc/profile.d/use-gpg-agent-for-ssh.sh` file instead.

If your system *has* multiple users, and some of them may wants to use the normal `ssh-agent`, you may want to not include calling the function (i.e. the final `use-gpg-agent-for-ssh` line) in what you add to the system-wide profile. In this case, users who *do* want to use `gpg-agent` by default can add a `user-gpg-agent-for-ssh` line to their `~/.bash_profile`, and *anybody* on the system can manually type that command to use `gpg-agent` within that shell.

# Setup - macOS

In macOS, LaunchAgents are configurations which starts a process or runs a command automatically. macOS comes with a LaunchAgent which does the following, every time a user logs in:

* Creates a UNIX socket with a dynamic name, and sets things up so that `ssh-agent` is automatically started, listening on on that socket, the first time a process connects to the socket. (If multiple users are logged in, each user will have their own socket and their own `ssh-agent` process.)

* Exports an `SSH_AUTH_SOCK` environment variable whose value is the path to that dynamically generated socket.


We need to change things around so that the `SSH_AUTH_SOCK` variable points to the name of a socket where `gpg-agent` is listening.

My first thought was to change the value of the `SSH_AUTH_SOCK` variable itself, and I did figure out how to do this automatically when the user logs in, by disabling the built-in LaunchAgent which runs `ssh-agent`. However...

* OS X 10.11 "El Capitan" added a security feature called System Integrity Protection (or "SIP"). This made things more difficult, in that you had to disable SIP (which requires rebooting into "recovery mode") before you could disable the LaunchAgent, and then reboot to re-enable SIP again afterward (because SIP itself *is* actually a good idea, I just don't think that the automatic `ssh-agent` startup should have been included within its scope.)

* macOS 10.15 "Catalina" added another feature where the root filesystem is mounted "read only", which added another set of hoops that had to be jumped through.

* macOS 11.0 "Big Sur" took it a step further by *digitally signing* the contents of the root filesystem. I haven't actually tried it, but it sounds like if you were to delete or change the LaunchAgent file, the signatures won't match and the OS would refuse to boot at all.

While I was hunting for information about how to disable this LaunchAgent in Catalina, I found [this article](https://evilmartians.com/chronicles/stick-with-security-yubikey-ssh-gnupg-macos) which explained a different way to solve the problem. Instead of disabling the macOS LaunchAgent, we can add our own LaunchAgent which runs *after* theirs, which replaces the UNIX socket created by the built-in LaunchAgent, with a symbolic link to the UNIX socket where `gpg-agent` is listening for SSH agent requrests. By doing this, any client which uses the `$SSH_AUTH_SOCK` value to connect to an SSH agent, still uses the randomly generated filename which was pointing to `ssh-agent`, however now points to to `gpg-agent`, and that's what the SSH client ends up talking to.

The only part of this I'm not clear about is how to ensure that our LaunchAgent runs *after* Apple's LaunchAgent. It's probably something as simple as "`launchd` processes the system LaunchAgents before any user LaunchAgents", but I haven't seen any official documentation which says that, so ... while I've never seen it happen, I'm not totally convinced that the two LaunchAgents wont accidentally run in the wrong order at some point.

## Quick version

* Install the GPG software, using one of the following methods:

    * Install [GPG Tools](https://gpgtools.org/), with or without the GPG Mail support. (I haven't used "GPG Mail" since they started charging for it, and I don't use "GPG Tools" at all anymore.)

    * Homebrew.

        ```
        brew install gnupg pinentry-mac
        ```

        Quick configuration:

        ```
        mkdir -p $HOME/.gnupg
        cat > $HOME/.gnupg/gpg-agent.conf <<EOF
        enable-ssh-support
        pinentry-program    /opt/homebrew/bin/pinentry-mac
        EOF
        gpg-connect-agent killagent /bye
        gpg-connect-agent /bye
        ```

* Install the two LaunchAgent files.

    ```
    cd ~/Library/LaunchAgents
    curl -O https://jms1.net/yubikey/net.jms1.gpg-agent.plist
    curl -O https://jms1.net/yubikey/net.jms1.gpg-agent-symlink.plist
    ```

* Either log out and log back in, or reboot the machine.

* When you log back in, verify that the `SSH_AUTH_SOCK` environment variable points to a temp file which is a symlink to your `$HOME/.gnupg/S.gpg-agent.ssh` file (or technically a named pipe).

    ```
    % ls -l $SSH_AUTH_SOCK
    lrwxr-xr-x  1 jms1  wheel  34 Dec  6 10:44 /private/tmp/com.apple.launchd.gR4WHD21R5/Listeners -> /Users/jms1/.gnupg/S.gpg-agent.ssh
    ```

* If you already have a YubiKey with an SSH key loaded, verify that you're able to see the key.

    With the YubiKey NOT inserted:

    ```
    % ssh-add -l
    The agent has no identities.
    ```

    With the YubiKey inserted:

    ```
    % ssh-add -l
    4096 SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx cardno:nnnnnnnnnnnn (RSA)
    ```

    In both commands. "`-l`" is a lowercase "L", not the digit "one".

    Also note that the SSH public key doesn't have the same "comment" that you might normally have after a key. Remember that the YubiKey only really stores the *secret* key, from which the public key is derived. It doesn't store any kind of metadata about the key. The comment it shows is the serial number of the YubiKey.

### Download links for the LaunchAgent files

* [`net.jms1.gpg-agent.plist`](/assets/net.jms1.gpg-agent.plist) - starts `gpg-agent`
* [`net.jms1.gpg-agent-symlink.plist`](/assets/net.jms1.gpg-agent-symlink.plist) - replaces the UNIX socket with a symlink

## Details

### Configure `gpg-agent`

To configure `gpg-agent` to support SSH, add this line to `$HOME/.gnupg/gpg-agent.conf`:

```
enable-ssh-support
```

To configure `gpg-agent` to find its "pinentry" program...

* Find the full path to the `pinentry` program. I did this by typing "`pinent`" and then hitting TAB, which showed the following output:

    ```
    pinentry         pinentry-curses  pinentry-mac     pinentry-tty
    ```

    From these, it seemed obvious to me that "`pinentry-mac`" was the one I wanted, so I found the full path to that...

    ```
    $ which -a pinentry-mac
    /opt/homebrew/bin/pinentry-mac
    ```

* Once you have the path, add this line to `$HOME/.gnupg/gpg-agent.conf`:

    ```
    pinentry-program    /opt/homebrew/bin/pinentry-mac
    ```

If you changed the `gpg-agent.conf` file for any reason, you should restart the running `gpg-agent` process:

```
gpg-connect-agent killagent /bye
gpg-connect-agent /bye
```

### Make `gpg-agent` start automatically

Create `$HOME/Library/LaunchAgents/net.jms1.gpg-agent.plist` with the following contents: (adjust the path to `gpg-connect-agent` as needed)

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>net.jms1.gpg-agent</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/local/MacGPG2/bin/gpg-connect-agent</string>
      <string>/bye</string>
    </array>
  </dict>
</plist>
```

Tell `launchd` to use it.

```
launchctl load net.jms1.gpg-agent.plist
```

### Replace the socket with a symlink

Create `$HOME/Library/LaunchAgents/net.jms1.gpg-agent-symlink.plist` with the following contents: (adjust the path to the socket file as needed)

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/ProperyList-1.0/dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>net.jms1.gpg-agent-symlink</string>
    <key>ProgramArguments</key>
    <array>
      <string>/bin/sh</string>
      <string>-c</string>
      <string>/bin/ln -sf $HOME/.gnupg/S.gpg-agent.ssh $SSH_AUTH_SOCK</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
```

Tell `launchd` to use it.

```
launchctl load net.jms1.gpg-agent-symlink.plist
```

### Restart

You will need to either reboot, or log out and log back in, in order to activate these changes.

### Make sure it worked

After rebooting or logging back in, make sure it worked.

* Make sure the variable exists, pointing to a random name.

    ```
    $ env | grep SSH
    SSH_AUTH_SOCK=/private/tmp/com.apple.launchd.CaehyEWKPw/Listeners
    ```

    The "`CaehyEWKPw`" portion of the name will be different every time you log into the machine. This is normal.

* Make sure that name is a symlink, pointing to the `gpg-agent` SSH socket.

    ```
    $ ls -l $SSH_AUTH_SOCK
    lrwxr-xr-x  1 jms1  wheel  34  Feb 18 00:55 /private/tmp/com.apple.launchd.CaehyEWKPw/Listeners -> /Users/jms1/.gnupg/S.gpg-agent.ssh
    ```

    Note: the command has a "lowercase L" option.

* Make sure the agent is reachable.

    ```
    $ gpg-connect-agent -v /bye
    gpg-connect-agent: closing connection to agent
    ```

    You should just see the message shown above.

* Make sure the YubiKey is connected.

* Make sure `gpg` is able to talk to your YubiKey.

    ```
    $ gpg --card-status
    Reader ...........: Yubico YubiKey OTP FIDO CCID
    Application ID ...: D276000124010304xxxxxx
    ...
    ```

* Make sure the agent is able to talk to the YubiKey.

    ```
    $ ssh-add -l
    4096 SHA256:l7CsDA23ENutkRsZ5jhlqJfl2syaiJfHni7b95e8dQ4 cardno:0006xxxxxxxx (RSA)
    ```

## Usage

If you've gone through the setup process above, and the `SSH_AUTH_SOCK` variable points to the `S.gpg-agent.ssh` socket, you don't really need to *do* anything differently - just use `ssh`, `scp`, `sftp`, or whatever, the same way you already do. As long as your SSH client works with an agent, and your YubiKey is physically plugged into the computer, it should all "just work".

If you haven't gone through the steps above ... do so.

## `authorized_keys`

To get the public key line needed for `authorized_keys` files...

* Insert the YubiKey and wait a few seconds.

* Run "`ssh-add -L`".

    ```
    $ ssh-add -L
    ssh-rsa AAAAB3NzaC1yc...9toFRmxejrbw== cardno:0006xxxxxxxx
    ```

The "`cardno:xxxxx`" at the end of the line is a comment. When using the value in an `authorized_keys` file I normally replace this with something more useful than the serial number...

```
$ cat .ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc...9toFRmxejrbw== jms1@jms1.net 2019-03-21 hardware token
```

# Notes

The `gpg-agent` automatically "contains" the Authentication Keys stored on the YubiKeys (or other OpenPGP cards) present on the system. When `gpg-agent` receives an authentication request, it passes it along to the YubiKey, which does the work of signing the request without sending the secret key anywhere.

Other keys *can* be added to the agent using `ssh-add`. When you do this, a copy of the secret key will be written to a file in the `~/.gnupg/private-keys-v1.d/` directory, named after the "key grip" (another kind of fingerprint, which includes the options rather than just the public key).

However, there are a few things to be aware of.

**These files are stored separately, and may be encrypted using a different passphrase than the SSH secret key file.**

* When you add a key, you will be prompted first for the existing passphrase (to read the secret key), and then for a new passphrase (to encrypt the secret key in this new file).

* Later, when you're prompted for a passphrase in order to *use* the key, you will need to enter the "new passphrase" rather than the original one.

**The "`ssh-add -d`" (or `-D`) command will not remove these keys.**

* `gpg-agent` adds the key grips (similar to a Key ID) to a file called "`~/.gnupg/sshcontrol`".

* Removing the key grip from this file makes the key no loger appear in the "`ssh-add -l`" output, and no longer be available for SSH authentication.

* Removing the `~/.gnupg/sshcontrol` file itself will make ALL keys no longer appear in the "`ssh-add -l`" output, or be available for SSH authentication. (This does not include keys stored on YubiKeys or other cards.)

* **Editing or removing this file will not remove the files under the `~/.gnupg/private-keys-v1.d/` directory.** You will need to remove those files by hand.

# Changelog

**2024-06-19** jms1

- moved page to new `jms1.info` site, updated header

**2022-01-22** jms1

- Updated with more info about "GPG from Homebrew" and less about GPGTools, since I don't use GPGTools anymore.
- Also added more details about what a "pinentry" program does.

**2021-01-07** jms1

- changed "`brew cask install`" to "`brew install --cask`"

**2020-12-20** jms1

- Moved to `jms1.info`, moved this Changelog to the end of the file
- Added macOS versions where security changes were added
- Other minor formatting updates

**2020-12-06** jms1

- Verified that the macOS setup process described below (i.e. installing the two LaunchAgent files and log out/in) DOES work with macOS 11.0 "Big Sur", on both Intel and Apple Silicon processors.

    This is a LOT easier to set up, so this is what I'm doing with my own machines as I upgrade them to Catalina. I've updated this page with information about that process.

**2020-02-23** jms1

- A few weeks ago I updated this page with information about how to set this up on Catalina. While I was thinking about it I happened across [this article](https://evilmartians.com/chronicles/stick-with-security-yubikey-ssh-gnupg-macos) which accomplishes the same overall goal, but instead of disabling the macOS `com.openssh.ssh-agent` LaunchAgent, it creates a symlink with whatever name `$SSH_AUTH_SOCK` contains, pointing to `$HOME/.gnupg/S.gpg-agent.ssh`.

**2019-09-01** jms1

- last version updated on [Keybase](https://keybase.pub/jms1/notes/Yubikey/make-ssh-use-gpg-agent.md)

**Older** jms1

- I wasn't keeping any kind of changelog before this, so I can't really include more details here, other than the fact that the very first version of this page was written some time in 2018.
