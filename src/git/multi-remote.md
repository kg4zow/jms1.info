# Multiple Remote URLs

When you clone a git repo to your machine, it creates a "remote" called `origin`, pointing to wherever you cloned the repo from. This allows you to use commands like `git fetch` and `git pull` to download updates from the same source, and `git push` to upload changes back to that source.

In some cases, you may want a repo to have multiple "remotes". There could be any number of reasons for this, I do it in order to maintain backup copies of my own repos in case the repo's "primary" server is unavailable.

There are a few ways to handle this.

## Multiple Remotes

Repo directories *can* have multiple "remotes". As a (contrived) example ...

```
$ git remote -v
foks    foks://(redacted)/jms1.info (fetch)
foks    foks://(redacted)/jms1.info (push)
github  git@github.com:kg4zow/jms1.info (fetch)
github  git@github.com:kg4zow/jms1.info (push)
```

With this kind of configuration, you can pull or push commits from either remote, as needed. I've done this with repos in the past, usually as part of a migration from one git hosting service to another.

For example, to copy the repo from FOKS to Github, I could do something like this:

```
git fetch -p foks
git push --all github
git push --tags github
```

One problem with doing this is, you have to keep track of which remotes have which commits, and be sure to use the correct remote names with your commands.

### Setting this up

Assuming you've cloned a repo from a remote called `origin` ...

* If you're creating a new repo on a remote host (such as Github), be sure to create an *empty* repo. If it offers you any options to set up a README or LICENSE file, don't use them. These options work by starting an empty repo and adding a commit which *adds* those files. Pushing an existing repo into a non-empty repo is ... not imposisble, but it's not simple (you have to "merge" the two).

* On your local machine, use `git remote add` to create a new remote.

    ```
    git rmeote add github git@github.com:kg4zow/jms1.info
    ```

* Many services (like Github) will set a repo's "primary" branch to the first branch pushed into the repo. In order to avoid later issues, your first push should contain *only* the branch that *you* consider to be "primary".

    I normally use `main` as the primary branch name in my repos.

    ```
    git checkout main
    git push github main
    ```

* Push the other branches, and any tags.

    ```
    git push --all github
    git push --tags github
    ```

At this point, the new `github` remote contains every commit, branch, and tag that the `.git/` directory on your workstation knows about.


## Multiple URLS in the Same Remote

Another option is to add multiple "push" URLs to the same remote.

With this configuration, every time you push commits to that remote, it will push them to *all* of the URLs, one after the other.

I do this with most of my personal repos, in order to have "backup copies" of my repos in case their "primary servers" are not available.

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

* Add the Github URL to the existing remote.

    ```
    cd ~/git/jms1.info/
    git remote set-url --add origin git@github.com:kg4zow/jms1.info
    ```

* Push the contents to Github.

    ```
    git push main
    git push --all
    git push --tags
    ```

    Note that these commands don't require a "remote" name, because the repo (the directory on my workstation) only *has* one remote, called `origin`.

    Also note that these `git push` commands *did* try to push commits to FOKS. However, nothing was actually pushed because the FOKS server already *had* the commits and tags I was pushing.

From this point forward, whenever I make changes and push commits, the `git push` command pushes those changes to *both* locations, one after the other.
