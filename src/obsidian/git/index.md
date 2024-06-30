# obsidian-git

**2024-06-30**

[obsidian-git](https://github.com/denolehov/obsidian-git) is a plugin for Obsidian which automatically tracks changes to a vault in a git repo. If the repo is linked to a "remote" (like Github, Keybase, etc.) the plugin can also push the changes to that remote as they happen.

For me, this serves a few purposes:

* The git repo, by itself, provides a way to go back and see previous versions of notes which change over time.

* The git remote serves as a built-in backup mechanism. For non-public vaults I use [Keybase git](https://book.keybase.io/git/), so it's a cryptographically secure backup - even Keybase themselves can't decrypt what's in the repo.

* Using a git remote also provides a way to use the same vaults on multiple computers.

I ran into some issues when I started using obsidian-git, because some of the documentation out there wasn't written in a way that "clicked" for me. I went through several iterations of creating dummy vaults, adding the plugin to them, and figuring out how it works. I kept my own notes while I was doing this, and I almost feel like I understand it now.

I'm adding my notes on this site in case somebody else might find them useful. You know, because there isn't enough documentation about it already.

![Standards](../../images/standards.png)

[Original - xkcd #927](https://xkcd.com/927)
