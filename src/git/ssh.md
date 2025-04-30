# Signing commits with SSH keys

Newer versions of git support the ability to sign commits using an SSH key.

Specifically ...

* Git v2.34 or higher
* OpenSSH 8.0 or higher

## &#x1F6D1; Don't Do This

I *personally* think that using SSH keys to sign commits is a bad idea.

**The main reason** I say this is because SSH keys are not linked to specific identities. An SSH key pair is JUST a pair of numbers - there's nothing about an SSH key which says "I belong to John Simpson". If I don't *tell* you which SSH key I actually use, you have no way to know whether a given key belongs to me or not.

Git allows users to set their own name and email address when creating commits. This means that anybody can create a commit which claims to be made by *any* name and email address. Somebody could use your name and email address on a commit, and sign the commit using an SSH key that they created on their own. It wouldn't be the *correct* key (i.e. the key that you normally use), but it would be *signed*, and the commit would have your name and address as the author ... so if somebody was looking at the commit but not *verifying* the signature, there's a good chance this would be enough to fool them.

If a command like `git show` is looking at a commit which was signed using an SSH key, all it can really tell for sure is *which* SSH key signed it. It doesn't know who that key actually belongs to, *unless you tell it which keys belong to which people*. (I explain how to do this below.)

This is why you need to *verify* the signatures on commits - to be sure that the person who the commit *says* is the author, actually *is* the author.

Verifying commits signed by SSH keys involves some extra configuration which isn't required for commits signed by PGP keys.

**Another reason** for not using SSH keys to sign commits is that, if the secret key is compromised, there is no way to revoke the key. If your secret key escapes, YOU have to hunt down every person who has a copy of your public key and tell them to stop using it.

Again, I *personally* don't use SSH keys to sign commits, but I do feel like people should be allowed to make their own decisions. As long as you understand the risks, if you want to do it, more power to you.


# Overview

There are two basic operations involved with signed commits, no matter what key type is used: signing commits, and verifying signatures.

Git needs to be configured for both of these.


## Signing Commits

There are a few things to configure in order to make git sign your commits.


### Sign one commit

Creating a signed commit is done by adding the `-S` (uppercase) or `--gpg-sign` option to your `git commit` command line, like so:

```
git commit -S -m 'commit message'
```

Note that *only that one commit* will be signed.

### Tell git to sign commits by default

You can also configure git to sign commits *by default*, using this command:

```
git config --global commit.gpgsign true
```

After doing this, every `git commit` command will create a signed commit, without your having to include the `-S` option in the command.

> &#x2139;&#xFE0F; **Create an un-signed commit**
>
> If you do this and need to occasionally *not* sign a commit, you can add the `--no-gpg-sign` option to the `git commit` command, and *that one commit* will be created without a signature.

[Documentation](https://git-scm.com/docs/git-config#Documentation/git-config.txt-codecommitgpgSigncode) for the `commit.gpgsign` option


### Tell git to use an SSH key when signing commits

Git normally uses a PGP key to sign commits. Setting this config option tells it to use an SSH key instead.

```
git config --global gpg.format ssh
```

[Documentation](https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgformat) for the `gpg.format` option


### Tell git which SSH key to use

We can do this in one of two ways:

* Use the filename to the public key file:

    ```
    git config --global user.signingKey $HOME/.ssh/id_rsa.pub
    ```

* Include the public key itself in git's configuration:

    ```
    git config --global user.signingKey 'key::ssh-ed25519 AAAA... comment'
    ```

[Documentation](https://git-scm.com/docs/git-config#Documentation/git-config.txt-usersigningKey) for the `user.signingKey` option


## Verifying Commits

Before git will be able to verify commits, it first needs to be told which SSH keys belong to which people. We do this by creating an "allowed signers" file, which is a simple text file containing email addresses and SSH public keys.


### Create an Allowed Signers file

The file *can* be created wherever you like, as long as it's readable by the `git` command itself. The example below will use `$HOME/.git_allowed_signers` as the filename, but you can use whatever filename you like.

Each line in the file should contain ...

* One or more email addresses. If multiple email addresses use the same key, the addresses should be separated by commas.
* An SSH public key, optionally including the same coments you normally see after the key itself.

For example ...

```
jms1@example.com ssh-ed25519 AAAAC3NzxxxxxxxxxxxxxxxxxxxxxxxxxRK4m 2025-04-29 fake key
```

Documentation for the Allowed Signers file format is in the `ssh-keygen(1)` man page. If your system isn't set up to view man pages, [this web page](https://www.man7.org/linux/man-pages/man1/ssh-keygen.1.html#ALLOWED_SIGNERS) has a copy, however OpenSSH 8.0 was the first version to use an Allowed Signers file and I'm not sure what version of OpenSSH this web page was taken from.

> &#x2139;&#xFE0F; **Trust the man pages**
>
> You should always trust the documentation in your system's man pages over anything you find online. This is because the man pages are installed *with* the software itself, so they're guaranteed to be the same versions.
>
> This is *especially* true of programs like OpenSSH, where new options are being added with every new version.


### Tell git where to find the Allowed Signers file

This is just another `git config` command.

```
git config --global gpg.ssh.allowedSignersFile $HOME/.git_allowed_signers
```

[Documentation](https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgsshallowedSignersFile) for the `gpg.ssh.allowedSignersFile` option


### Tell git to always show signatures

**This is optional.** I do it as part of the [git configuration](config.md) on all of my machines.

This will make every `git log` or `git show` command use the `--show-signature` option by default, so you won't have to remember to include it in every command.

```
git config --global log.showSignature true
```



## Messages

You may run into the following messages when working with SSH-signed commits.


### `Good "git" signature`

```
Good "git" signature for user@example.com with RSA key SHA256:SHA256:oSAqmDr7/LKI+STyBrT79IcFmbyt3h1P1niXdg0I+94
```

&#x2705; This is good. It means that the commit was signed by an SSH key which is in your Allowed Signers file.

This message is actually telling you three things:

* `Good "git" signature` tells you that the commit's contents and message haven't been modified since the signature was created.

* `for user@example.com` tells you whose SSH key signed the message.

* `with RSA key ...` gives you the fingerprint of the key which signed the commit.


### `No principal matched.`

```
Good "git" signature with RSA key SHA256:oSAqmDr7/LKI+STyBrT79IcFmbyt3h1P1niXdg0I+94
No principal matched.
```

&#x2753; This means that the commit was signed by an SSH key that isn't recognized (i.e. isn't in your Allowed Signers file).

This mesage is actually telling you three things:

* `Good "git" signature` tells you that the commit's contents and message haven't been modified since the signature was created.

* `with RSA key ...` gives you the fingerprint of the key which signed the commit.

* `No principal matched` means that it can't tell you *who* signed the commit.

If you're able to contact the commit's author and get a copy of their SSH public key, you can get its fingerprint using `ssh-keygen -l`, like so:

```
$ ssh-keygen -l -f their_id_rsa.pub
4096 SHA256:oSAqmDr7/LKI+STyBrT79IcFmbyt3h1P1niXdg0I+94 user@example.com (RSA)
```

As you can see, the fingerprint printed by this command matches the fingerprint shown by the `git show` or `git log` command, so you *can* be sure that this commit was signed by that person.


### `gpg.ssh.allowedSignersFile needs to be configured and exist`

&#x2753; If you work with repos containing commits signed by SSH keys, and `git` is showing signatures, you may see this message when looking at commits that were signed by SSH keys:

```
error: gpg.ssh.allowedSignersFile needs to be configured and exist for ssh signature verification
```

The message means exactly what it says: either you haven't configured the `gpg.ssh.allowedSignersFile` option, or the file that it points to doesn't exist.

If you don't want to see this message, there are a few options:

* Use the `--no-show-signature` option in your command.

    ```
    git show --no-show-signature a1b2c3d4
    ```

    This option will override the `log.showSignature` config option.

* You can configure git to use an Allowed Signers file, but leave the file empty.

    ```
    > $HOME/.git_allowed_signers
    git config --global gpg.ssh.allowedSignersFile $HOME/.git_allowed_signers
    ```

    Note that the first command starts with `>`. This will create the file if it doesn't already exist, and empty the file if it does.

    > &#x2139;&#xFE0F; **Shell Output Redirect Operator**
    >
    > This is the same `>` operator that you would use to send the output of a command to a text file. In this case we're not *running* a command, so we're sending *nothing* to the file.

* You can configure git to use `/dev/null` as the Allowed Signers file.

    ```
    git config --global gpg.ssh.allowedSignersFile /dev/null
    ```

    This is just like setting up an Allowed Signers file and leaving it empty, except that you don't have to *create* the file at all. The `/dev/null` file always exists on macOS and Linux systems, and if anything (including `git`) tries to read data from it, it will act like any other empty file.
