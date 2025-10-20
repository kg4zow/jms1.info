# Shell Scripting

I've been writing shell scripts since the early 1990's. Over the years I've built up a collection of useful scripts, functions and one-liners, that others might find useful.

## My Shell Setup

I use `bash` on all of my machines, mostly because I've been using it for the past 20+ years and it's what I'm used to. I also find it useful to be able to be able to *type* the same commands I use in my scripts, and know that the shell I'm typing them into will do exactly what the shell that executes the script will do.

My `.bashrc` file is fairly small, however it includes this:

```bash
for F in "$HOME"/.bashrc.d/*
do
    if [[ -f "$F" ]]
    then
        source "$F"
    fi
done
```

This lets me add files to my `$HOME/.bashrc.d/` directory, where they will be included while the `$HOME/.bashrc` file is being processed. The filenames within the directory are automatically sorted by name when the shell expands the `*` into a list of filenames, so the filenames control what order the files are processed.
