# cheat

My memory isn't perfect, I'm finding I have to look up the documentation for commands I use all the time, just to remember what the command line options are or what they do. Just as an example, the `rsync` command has half a dozen different "delete" options, based on whether you want to delete files on the source or on the destination, and to do the deleting before or after copying the file.

I found a program called [cheat](https://github.com/cheat/cheat) which lets you create "cheat sheets" with quick reminders of just the details you need for the commands you need them for, and it has become a real time-saver for me.

They also have a collection of [cheatsheets](https://github.com/cheat/cheatsheets), maintained by the community, with information that others find useful.

The program was designed to hold information about command line options that people might forget, however it *can* be used for just about anything that can be stored as plain text. As an example, you could use it to store a list of peoples' email addresses, phone numbers, social media names, or other contact information.

### Example

As a more concrete example ... I store my [shell scripting template](template.md) as a cheatsheet file. When I need to start a new shell script, I run something like this:

```
cheat template > new-script
```

This creates the "skeleton" of a shell script, with most of the functions I end up using in 95% of my scripts, arleady in place. This lets me concentrate on making the script do what I need it to do, and then once it's working, I *remove* the bits I ended up not needeing.


## My Configuration

The `cheat` program itself can be configured with multiple collections of cheatsheets, and each one can be flagged as "read-only" or "read-write". I find it useful to use both the community cheatsheets *and* a collection of my own cheatsheets. I set this up on my workstations using ...

```
########################################
# clone community cheatsheets

mkdir -p ~/git/cheat
git clone https://github.com/cheat/cheatsheets ~/git/cheat/cheatsheets

########################################
# clone my own cheatsheets and set up github additional target

git clone foks://(redacted)/cheatsheets ~/git/jms1-cheatsheets
cd ~/git/jms1-cheatsheets/
git remote set-url --add origin git@github.com:kg4zow/jms1-cheatsheets
```

Once the repos are cloned, I set up the config file for `cheat` using the following:

```yaml
cheatpaths:
  - name     : community
    path     : /Users/jms1/git/cheat/cheatsheets
    tags     : [ community ]
    readonly : true

  - name     : jms1
    path     : /Users/jms1/git/jms1-cheatsheets
    tags     : [ jms1 ]
    readonly : false
```

With this configuration ...

* When I type `cheat xxx`, it looks for a cheatsheet called `xxx` in both collections.

    * If it only exists in one collection, it shows the contents of that file.
    * If it exists in both collections, it shows the contents of the file from my personal collection.

    I couldn't find any documentation which explicitly *says* this, but it looks like it uses the *last* matching file.

* When I type `cheat -e xxx` (to edit a cheatsheet file) ...

    * If the file exists in my personal collection, it runs my editor (normally [BBEdit](https://barebones.com/products/bbedit/)) against that file.
    * If the file exists in the community collection, it copies that file to my personal collection and opens my copy for editing.
    * If the file doesn't exist in either, it opens the editor with the filename where the file belongs in my personal collection. When the editor *saves* the file, that creates it in my collection.

### Other Notes

* When I edit cheatsheets, I need to remember to commit and push the changes in my git repos, and then run `git pull` on my other workstations.

    Part of this could be automated using a cron job that runs `git pull`, however committing and pushing *has* to be a manual process, since I don't want to commit/push until I *know* the changes are correct. (I make typos just like everybody else.)

* On my work machines, there is a third cheatsheet collection, shared with members of the team I work with. `cheat` has a `-p` option to specify which collection to use, especially when creating or editing cheatsheet files.

    You can use `cheat -h` to see all of its options. Or run `cheat cheat`, if the community cheatsheets repo is part of your configuration. &#x1F60E;


## My Cheatsheets

The "master copy" of *my* cheatsheets are stored in an encrypted [FOKS](https://foks.pub/) git repo, with a Github repo as an [additional push target](../git/multi-remote.md), so that whenever I push changes to FOKS, Github is updated at the same time.

```
$ cd ~/git/jms1-cheatsheets
$ git remote -v
origin  foks://(redacted)/cheatsheets (fetch)
origin  foks://(redacted)/cheatsheets (push)
origin  git@github.com:kg4zow/jms1-cheatsheets (push)
```

If you're curious, you're welcome to look at [the Github repo](https://github.com/kg4zow/jms1-cheatsheets).
