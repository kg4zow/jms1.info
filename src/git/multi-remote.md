# Multiple Remote URLs

A git "remote" is a logical construct representing another copy of the same repository, which may be updated at different times than the local repo (i.e. the directory on your workstation, with the `.git/` directory in it). Each remote has one or more URLs, pointing to the other copy of that repo.

When you first clone a git repo to your machine, it automatically creates a "remote" called `origin`, pointing to the URL that you cloned the repo from. In most cases this is enough, especially in a typical "git server" scenario, where one machine acts as a central location that everybody else working with the repo, treats as authoritative.

This allows you to use commands like `git fetch` and `git pull` to download updates from the same source, and `git push` to upload changes back to that source.

In some cases, you may want a repo (on your workstation) to have multiple "remotes". There are several possible reasons you may need/want to do this.

There are a few ways to handle this.

## Multiple Remotes

Repos (such as the directories on your workstation) *can* have multiple "remotes". I've done this in the past as a way to migrate repos from one service to another (i.e. from Bitbucket to Github), and occasionally need to do this in cases where the remotes get out of sync with each other.

As an example ...

```
$ git remote -v
foks    foks://(redacted)/jms1.info (fetch)
foks    foks://(redacted)/jms1.info (push)
github  git@github.com:kg4zow/jms1.info (fetch)
github  git@github.com:kg4zow/jms1.info (push)
```

With this kind of configuration, you can pull or push commits from either remote, as needed.

For example, to update Github's copy of the repo with any new commits that FOKS knows about, I could do something like this:

```
git fetch -p foks
git push --all github
git push --tags github
```


### Setting this up

Assuming you've cloned a repo from a remote called `origin` ...

* Create an empty repo on the remote server. The mechanics of this will vary based on the remote server. Using Github as an example, you could use their web interface *or* their command line utility.

    ```
    gh repo create --private USERNAME/REPONAME
    ```

    > &#x26A0;&#xFE0F; **Create an EMPTY repo.**
    >
    > If the repo-creation process offers you any options to set up any README, LICENSE, or other files, do not use them. These options work by starting an empty repo and adding a commit which *adds* those files. Pushing an existing repo into a non-empty repo like this is ... not impossible, but it's not simple (you would have to "merge" the two).

* On your local machine, use `git remote add` to create a new remote.

    ```
    git remote add github git@github.com:USERNAME/REPONAME
    ```

* Make sure your local repo is up to date with the current "primary" copy of the repo.

    ```
    git fetch -p
    ```

* Many services (like Github) will set a repo's "primary" branch to the first branch pushed into the repo. In order to avoid issues in the future, your first push should contain *only* the branch that *you* consider to be "primary".

    First make sure your local directory is up to date with that branch.

    ```
    git checkout main
    git pull
    ```

* Push the primary branch. Because this is the first branch you're pushing, Github will set it as the primary branch in its copy of the repo (i.e. the branch that gets checked out if somebody clones the repo from Github without specifying a branch name).

    ```
    git push github main
    ```

* Push all other branches, and any tags.

    ```
    git push --all github
    git push --tags github
    ```

At this point, the new `github` remote contains every commit, branch, and tag that the `.git/` directory on your workstation knows about.

Going forward, you can manage which commits get pulled or pushed to which remotes by specifying the remote names as part of your `git` commands. For example, if you push new commits to Github and need to copy them back to the original server, you might do something like this:

```
git fetch -p github
git checkout main
git merge github/main
git push origin main
```


## Multiple URLS in the Same Remote

Another option is to add multiple "push" URLs to the same remote.

Every git remote has a "fetch" URL, used by operations that *read* from the remote. Remotes can also have "push" URLs, separate from the "fetch" URL.

> Operations that *write* to the remote will use the "push" URLs if there are any, otherwise they will use the "fetch" URL.

If a remote has multiple push URLs, every time commits are pushed to that remote, they are sent to *all* of those URLs, one after the other. A single `git push` command can send updates to multiple remote locations.

I do this with most of my personal repos, in order to have "backup copies" of my repos on other servers, in case their "primary servers" are not available.

### Setting this up

As an example, this is how I set up the repo holding the `jms1.info` site's source code. (These are the *actual* commands I typed on my workstation when I added Github as a second URL for this repo on 2025-10-17.)

* Create the Github repo.

    ```
    gh repo create --public kg4zow/jms1.info
    ```

* Clone the existing FOKS repo to a new directory.

    ```
    cd ~/git/
    git clone foks://(redacted)/jms1.info jms1.info
    ```

* Add the same URL as the first push URL.

    When a remote is created, `git remote add` adds the "fetch" URL. The `git push` command uses this *only when* the remote doesn't have any specific "push" URLs.

    If a remote has one or more "push" URLs, the `git push` command will not use the fetch URL. This means if you want pushes to go to the same server you pull from, you need to add a copy of the fetch URL, *as* a push URL.

    ```
    git remote set-url --add --push foks://(redacted)/jms1.info
    ```

    > &#x2139;&#xFE0F; If you don't do this, you'll end up with a situation where "fetch" operations will pull data from one server, while "push" operations will send data to a different server. This would be unusual, but there are occasionally cases where this can be useful.

* Add the Github URL as a new push URL.

    ```
    cd ~/git/jms1.info/
    git remote set-url --add --push origin git@github.com:kg4zow/jms1.info
    ```

* Push the contents to Github.

    Note that the first `git push` is only pushing the `main` branch. This is so that Github will make `main` the primary branch in its copy of the repo.

    ```
    git push main
    git push --all
    git push --tags
    ```

    You may notice that these commands don't have a "remote" name. This is because the repo (the directory on my workstation) only *has* one remote, called `origin`.

    Also note that these `git push` commands *did* try to push commits to FOKS. However, nothing was actually pushed because the FOKS server already *had* the commits and tags I was pushing.

From this point forward, whenever I make changes and push commits, the `git push` command pushes those changes to *both* locations, one after the other.

Note that the `git push` has a `-v` option which makes it show "Pushing to [URL]" for each URL it pushes to. This can be useful if you're troubleshooting an issue with not being able to push to one or more remote services.

## The `git-fix-remote-order` script

[Download](../scripts/git-fix-remote-order)

When I first started adding multiple push URLs to remotes, I sometimes ran into problems when adding URLs or changing which URL was the primary "fetch" URL. These were usually caused by my own typos, but sometimes I would forget about a URL, forget to add the fetch URL as a push URL, or add the URLs in the wrong order (making the wrong URL the "fetch" URL).

To clean this up, I found myself having to run the same set of commands every time:

* `git remote -v` to see what the current remotes and URLs were
* `git remote remove` to remove the current remotes
* `git remote create` to create the remote with just the fetch URL
* `git remote set-url --add` to add the fetch URL *as* a push URL, then to add the additional push URLs

And in order to avoid making the same mistakes again, I would type out the commands in a text editor, then double-check them before running anything, and THEN running them (by copy/pasting them from the text editor, to avoid typos).

This got to be rather tedious, so I wrote a script called `git-fix-remote-order` to take care of this. It uses a config file containing ...

* Sections for each repo I use on my workstations
* The URLs which belong in the `origin` remote, in the correct order, i.e. the first URL is the "fetch" URL and the others are all "push" URLs.
* Alternate remote names for each URL. (This is explained [below](#splitting-remotes-and-alternate-remote-names).)

As an example, this is what *some* of the blocks in my config file look like:

```
# my "cheatsheets", https://github.com/cheat/cheat
=cheatsheets
foks        foks://(redacted)/cheatsheets
internal    git@git.internal:jms1/cheatsheets
github      git@github.com:kg4zow/jms1-cheatsheets

# source for jms1.info site
=jms1.info
foks        foks://(redacted)/jms1.info
internal    git@git.internal:jms1/jms1.info
github      git@github.com:kg4zow/jms1.info

# source for kg4zow.us site
=kg4zow.us
internal    git@git.internal:jms1/kg4zow.us
foks        foks://(redacted)/kg4zow.us

# source for qmail.jms1.net site
=qmail.jms1.net
internal    git@git.internal:jms1/qmail.jms1.net
```

### Using the script

* Make sure the script is installed somewhere in your PATH.

    I normally have the `$HOME/bin/` directory in my PATH, so I copy it there. (Others may use `$HOME/.local/bin/` for the same purpose, do whatever works on *your* system.)

* `cd` into the working directory of the repo whose remote URLs need to be updated.

* Run the script with no options.

    This will examine the directory and the current remotes, and show you what it thinks needs to be done. The cyan-coloured lines are the actual `git` commands involved. (Commands starting with `+` are actually executed, while commands with `-` are just being shown but *not* executed.)

* Assuming everything looks right, run the same command but add the `-g` option.

    This does the same thing, but it acutally *runs* the commands.

The last command it runs will be `git remote -v`, which shows you the state of the remotes *after* the commands were executed. Note that if you run the script without the `-g` option, this output will be the same as when it ran `git remote -v` at the beginning, since nothing will have been changed.

> &#x2139;&#xFE0F; **Alternate Command**
>
> You can also type `git fix-remote-order` instead of `git-fix-remote-order`.
>
> This is because if the `git` command sees a sub-command that it doesn't recognize (like `fix-remote-order`), it searches your PATH for an executable called `git-{subcommand}`, and if it finds one, runs it instead.
>
> This mechanism can be used to "create your own `git` commands", by writing scripts (or compiling executables) and storing them in your PATH with names starting with `git-`.


### Splitting Remotes and Alternate Remote Names

The script works by removing all existing remotes, then adding *just* the remote(s) which need to exist, with the correct URLs. Normally this means it creates a single remote called `origin` with the URLs in the order showin the config file.

There are cases where you may need each URL to "be" its own remote. I've needed this as part of the cleanup process when commits get pushed to some remote servers but not others.

**The script has a "split" mode where, instead of creating a single `origin` remote with all of the URLs, it creates a separate remote for each URL.** The alternate remote names in the config file are used as the remote names when "splitting" a repo's remotes.

Splitting the repo's URLs into separate remotes can be useful when troubleshooting a repo where one of the remote URLs is "out of sync" with the others. The basic process looks like this:

* Run `git-fix-remote-order -sg` to split the URLs into separate remotes.

* Use whatever commands are needed to fix things by hand.

    I can't really offer more detail than this, because there are too many possible ways that repos can be "out of sync" with each other. However, the following commands might be useful ...

    * `git fetch` with a remote name
    * `git pull` with a remote name
    * `git push` with a remote name, and possibly with other options (including specific `local:remote` branch names)
    * `git log1 --all`
        * `log1` is one of [my aliases](config.md). The output will be a single line for each commit, and will include indicators showing where each remote's idea of each branch is pointing.
    * `git tree1 --all`
        * `tree1` is another one of [my aliases](config.md).
    * `git commit`
    * `git merge`
    * `git reset`

* Once everything is back to its expected state (i.e. all remotes' copies of the branches are pointing to the same commits), run `git-fix-remote-order -g` to rejoin the remotes.

    If you see a yellow warning saying `NOTE: cannot re-link branches`, this means that whatever branches *were* originally linked to upstream branches, are no longer linked. (This kind of link is what makes `git push` work correctly without any branch or repo names.)

    You can re-create the link using the `git branch -u` command. For example, to link the local `main` branch to the `origin/main` upstream branch ...

    ```
    git branch -u origin main
    ```
