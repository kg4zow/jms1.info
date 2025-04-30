# My Configuration

I've been using `git` for over ten years. Over that time I've found a collection of configuration options that seem to work well for me. I normally configure all of my workstations with these options.

These options includes a collection of "aliases" which *really* make my life easier.

# Configuration Options

## Identity

These options set the default name, email, and PGP key used for commits. The *values* of the options are different on personal and work machines.

*  Personal machines

    ```
    git config --global user.name "John Simpson"
    git config --global user.email "jms1@jms1.net"
    git config --global user.signingkey "0xE3F7F5F76640299C5507FBAA49B9FD3BB4422EBB"
    ```

* For `$DAYJOB` machines

    ```
    git config --global user.name "John Simpson"
    git config --global user.email "jms1@domain.xyz"
    git config --global user.signingkey "0x1234C0FFEEC0FFEEC0FFEEC0FFEEC0FFEEC0FFEE"
    ```

Note that I also have aliases for cases where I might need to sign a commit using my personal "identity", on a `$DAYJOB` workstation. Because my PGP and SSH keys are stored on Yubikeys, I can just plug the "other" Yubikey into the machine and use the correct alias.

These aliases are documented [below](#sign-commits-using-specific-keys).

## For all machines

I use these configuration options on every machine.

```
git config --global core.editor "nano"
git config --global core.excludesfile "$HOME/.gitignore_global"
git config --global credential.helper "cache --timeout=300"
git config --global init.defaultBranch "main"
git config --global clone.defaultBranch main
git config --global log.showSignature true
git config --global push.default "simple"
git config --global pull.rebase false
git config --global gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
```

**All of my commits and tags are signed.** This is a requirement at `$DAYJOB`, and a [good idea in general](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification).

```
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```

## Commit message template

This sets up a text file which is used as a template when `git` uses a text editor to create or edit a commit message.

In particular, I generally use the [50/72 format](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html) format when writing commit messages. As you can see below, having the `^` marks at 50 and 72 characters makes it easier for me to stay within the limits.

* To configure the file:

    ```
    git config --global commit.template "$HOME/.stCommitMsg"
    ```

* The contents of the file:

    ```
    $ cat ~/.stCommitMsg


    #                                             50 ^                  72 ^
    # First line: start with ticket number(s), limit to 50 characters
    # BLANK LINE
    # Additional lines: limit to 72 characters
    $ git config --global commit.template "$HOME/.stCommitMsg"
    ```

Note that empty lines and lines starting with `#` are *not* included in the actual commit message.

# Aliases

Aliases allow you to "make up your own git commands". For example, if you were to do this ...

```
git config --global alias.showfiles "show --name-only"
```

... then `git showfiles` would be the same as `git show --name-only`.

## My Usual Aliases

These are the aliases I've built up over the years. Some of these I use dozens of times every day.

```
git config --global alias.log1 "log --oneline --no-show-signature --abbrev=8 '--pretty=tformat:%C(auto)%h%d %C(brightcyan)%as %C(brightgreen)%al(%G?)%C(reset) %s'"
git config --global alias.tree "log --graph --decorate"
git config --global alias.tree1 "log --date-order --decorate --graph --no-show-signature '--pretty=tformat:%C(auto)%h%d %C(brightcyan)%as %C(brightgreen)%al(%G?)%C(reset) %s'"
git config --global alias.tagdates "log --tags --simplify-by-decoration --pretty=\"format:%ai %d\" --no-show-signature"
git config --global alias.taghashes "log --tags --simplify-by-decoration --pretty=\"format:%H %d\" --no-show-signature"
git config --global alias.id "describe --always --tags --long --abbrev=8 --dirty"
git config --global alias.top "rev-parse --show-toplevel"
```

### Changes for older `git` versions

Some colours and tags were added between git 2.16.5 and 2.37.0.

* `%as` (commit date YYYY-MM-DD) -> `%ad` with `--date=short` option
* `%al` (author email local part) -> `%an` (author name)

For older versions without these newer colour codes, I use these aliases instead.

```
git config --global alias.log1 "log --oneline --no-show-signature --abbrev=8 --date=short '--pretty=tformat:%C(auto)%h%d %C(cyan)%ad %C(green)%an(%G?)%C(reset) %s'"
git config --global alias.tree1 "log --date-order --decorate --graph --no-show-signature --date=short '--pretty=tformat:%C(auto)%h%d %C(cyan)%ad %C(green)%an(%G?)%C(reset) %s'"
```

### Sign commits using specific keys

These aliases allow me to sign commits using my personal PGP key on the work machine, or vice-versa, by physically [plugging the correct Yubikey](../pgp/ssh-pgp-agent.md) into the machine. By themselves they won't be very useful to anybody else, but they could be useful as examples if you need to use different keys for different repos.

```
git config --global alias.commitp "commit --gpg-sign=E3F7F5F76640299C5507FBAA49B9FD3BB4422EBB --author='John Simpson <jms1@jms1.net>'"
git config --global alias.commitw "commit --gpg-sign=1234C0FFEEC0FFEEC0FFEEC0FFEEC0FFEEC0FFEE --author='John Simpson <jms1@domain.xyz>'"
```

# Notes

Random notes relating to `git`

## Commits signed with SSH keys

**If you're using 2.34.0 or later** you may see this error message work working with repos where others users may have signed commits using SSH keys instead of PGP keys.

```
error: gpg.ssh.allowedSignersFile needs to be configured and exist for ssh signature verification
```

[Reference](https://blog.dbrgn.ch/2021/11/16/git-ssh-signatures/)

`git` 2.34.0 added the ability to sign commits using SSH keys. This functionality is related to how OpenSSH implements "SSH certificates". I've looked into this in the past, but it seems to be a lot more trouble than it's worth.

> I don't really see the need for this, other than "some people can't, or don't want to, take the time to figure out PGP" ... but unfortunately, it's something we have to deal with, especially when you're working with shared repos (where other people are making commits).

Because these are not PGP keys, there is no concept of a "web of trust", so `git` has no way to tell if a signature created using an SSH key should be trusted or not. In order to work around this problem, `git` can be configured with a filename that, *if it exists*, will contain a list of email addresses and the SSH public keys which should be "trusted" for commits signed using those emails.

The file format is documented in the `ssh-keygen(1)` man page, in the "`ALLOWED SIGNERS`" section (near the end of the page). In most cases, each line will be an email address, followed by the public key's line from an `authorized_keys` file, like so:

```
jms1@jms1.net ssh-rsa AAAAB3Nz...Pw== jms1@jms1.net 2019-03-21 YubiKey Blue
jms1@domain.xyz ssh-ed25519 AAAAC3Nz...YDQu jms1@domain.xyz 2022-01-24 YubiKey Green
```

### Configure SSH Signature Verification

If you are using `git` 2.34.0 or later and are seeing this message, you can make it go away by doing the following:

* Configure a filename which, *if it exists*, will contain the list of known email addresses and SSH keys.

    ```
    git config --global gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
    ```

    Note that the file itself doesn't have to exist - just having this option present in your `$HOME/.gitconfig` file is enough to prevent the error message from being shown.

    &#x26A0;&#xFE0F; This is included in the list at the top of the page.

* If you work with people who use SSH keys to sign commits, you can *create* a `$HOME/.config/git/allowed_signers` file and add the email addresses and SSH public keys, in the format shown above.

## Configuration scope

The `git config` command operates on different files, depending on which options you give it.

| Option                | File                      | Scope
|:----------------------|:--------------------------|:-----------------
| `--local` (or none)   | `REPO_ROOT/.git/config`   | the current repo
| `--global`            | `$HOME/.gitconfig`        | the current user
| `--system`            | `/usr/local/etc/gitconfig` | all users on the system
| `--worktree`          | `WORKTREE_ROOT/.git/config.worktree`<br/>or `REPO_ROOT/.git/config` | the current "worktree"<br/>or `--local` if no worktree is active
| `--file ___`          | specified                 | depends on the file


# Changelog

### 2024-06-20 jms1

* Created this page (from pre-existing notes)
