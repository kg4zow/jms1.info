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

There used to be a brief explanation here, I've moved this to its own page.

&#x21D2; [Signing commits with SSH keys](ssh.md)

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

### 2025-04-30 jms1

* Fixed a typo
* Removed info about git commits signed by SSH keys, since there's now a dedicated page for that

### 2024-06-20 jms1

* Created this page (from pre-existing notes)
