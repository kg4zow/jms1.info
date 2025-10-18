# Coloured line functions

This is a collection of shell functions which print coloured lines of text.

Coloured lines can make it easy to tell where a piece of text starts or ends.

![blueline](blueline.png)

![redline](redline.png)

## Functions

These could be stand-alone scripts, however I found it easier to write them as functions and `source` them into my shell when it starts.

```bash
# Shell functions to emit coloured lines

function redline {
    printf "\e[0;1;37;41m%s\e[0K\e[0m\n" "$*"
}

function yellowline {
    printf "\e[0;30;43m%s\e[K\e[0m\n" "$*"
}

function blueline {
    printf "\e[0;1;37;44m%s\e[0K\e[0m\n" "$*"
}

function greenline {
    printf "\e[0;1;37;42m%s\e[0K\e[0m\n" "$*"
}

function cyanline {
    printf "\e[0;1;37;46m%s\e[0K\e[0m\n" "$*"
}

function purpleline {
    printf "\e[0;1;37;45m%s\e[0K\e[0m\n" "$*"
}

function whiteline {
    printf "\e[0;1;37;47m%s\e[0K\e[0m\n" "$*"
}
```

These functions work by printing [ANSI Escape Codes](https://en.wikipedia.org/wiki/ANSI_escape_code) to change the colour of the text printed *after* the code, and to clear the remainder of the line after the supplied string.


One thing to note is that the functions, as written above, will *always* print the codes to generate coloured lines. You *can* change them so that they only print the "colour codes" when run in a terminal, and print some kind of plain-text version, without the colour codes. As an example ...

```bash
function redline {
    if [[ -t 1 ]]
    then
        printf "\e[0;1;37;41m%s\e[0K\e[0m\n" "$*"
    else
        echo "***** $* *****"
    fi
}
```

## `fail` Function

In many of my scripts, when an error occurs I want to draw the user's eye to it. I do this using the `fail` function, which is pretty simple - it uses `redline` to print the message it received in a red line, then exits from the script.

This function is useful within scripts, but you probably *don't* want to include it in your `.bashrc` file. If you were to type `fail` in a shell, it would print the message and then immediately exit from the shell.

```
function fail {
    redline "$@"
    exit 1
}
```
