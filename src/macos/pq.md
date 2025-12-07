# macOS - SSH Post-Quantum Encryption

**2025-12-05**

This page explains how I dealt with an issue with having multiple versions of OpenSSH on my macOS workstations.

## Background

I use [Homebrew](https://brew.sh/) to install software that macOS doesn't come with, and also to install newer versions of software that macOS *does* come with. My "work" workstation (a 2018 Mac Mini with an Intel processor) is currently running macOS 15.7.2, which came with OpenSSH v9.9, but I actually *use* OpenSSH 10.2 from Homebrew.

I control which version is used by controlling the order in which directories appear in my `PATH`. As long as Homebrew's `bin` directory comes *before* the standard `/usr/bin` directory, programs installed by Homebrew will "override" programs installed by macOS.

> &#x2139;&#xFE0F; **PATH Order for Homebrew**
>
> My actual shell profile is a bit more complex than this, but you can do this by adding the following to the END of your `.bashrc` for (or its equivalent, depending on what shell you're using) ...
>
> ```
> PATH="$( brew --prefix )/bin:$PATH"
> ```


## The Problem

When I use `ssh` to connect to a server whose `sshd` is from an older version of OpenSSH, the `ssh` command prints this warning:

```
** WARNING: connection is not using a post-quantum key exchange algorithm.
** This session may be vulnerable to "store now, decrypt later" attacks.
** The server may need to be upgraded. See https://openssh.com/pq.html
```

This is distracting, and in the case of a script which runs an `ssh` command and processes the output, it can cause problems. The obvious (and more secure) solution would be upgrade `sshd` on every server I connect to, however 98% of them are running RHEL 7 or RHEL 9, and Red Hat doesn't have OpenSSH packages which support the PQ algorithms yet.

According to [the page listed in the warning](https://www.openssh.org/pq.html), I can disable the warning by adding `WarnWeakCrypto no` to my `.ssh/config` file to disable this warning. I did this, and the warning no longer appears.

BUT.

When programs are started by `launchd` or Finder, my `.bashrc` file isn't used, so I have no way to modify the `PATH` that the program inherits. This means that if those programs run `ssh`, they end up running `/usr/bin/ssh`, which is the older version that comes with macOS. If this older version doesn't recognize the `WarnWeakCrypto` option, it causes an error.


## The Solution

There is an `IgnoreUnknown` directive, which *is* recognized by older OpenSSH versions. This tells it to ignore *specific* unknown option names if they appear in the config.

So, to work around the problem for now, I have done the following in my `$HOME/.ssh/config` file:

* At/near top of file (this is actually the first line of my `config` file)
    ```
    IgnoreUnknown   WarnWeakCrypto
    ```

* In the appropriate `Host` block(s)
    ```
    Host *.example.com
        WarnWeakCrypto  no
    ```


## Other Information

OpenSSH's page explaining the warning

* [`https://www.openssh.org/pq.html`](https://www.openssh.org/pq.html)

Timeline

* OpenSSH 9.0 (2022-04)
    * added `sntrup761x25519-sha512` as a host key exchange algorithm
* OpenSSH 9.9 (2024-09)
    * added `mlkem768x25519-sha256` as a host key exchange algorithm
* OpenSSH 10.0 (2025-04)
    * made `mlkem768x25519-sha256` the default host key exchange algorithm
* OpenSSH 10.1 (2025-10)
    * added the warning when connecting to a server which doesn't offer a PQ host key exchange algorithm
    * Also added the `WarnWeakCrypto` option to disable this warning
