# `set_x` and `show_x` functions

These functions simulate what `set -x` does, but only for specific commands.

## Functions

### `set_x`

The `set_x` function simulates `set -x` for just the one command. I use this in a lot of the scripts I write.

```sh
###############################################################################
#
# Maybe print a command before executing it

SET_X="${SET_X:-false}"

function set_x {
    if [[ "${SET_X:-false}" == "true" ]]
    then
        local IFS=$' '
        echo "$PS4$*" 1>&2
    fi
    "$@"
}
```

A one-liner to accomplish the same thing looks like this:

```
set -x ; COMMAND ; { set +x ; } 2>/dev/null
```

### `show_x`

This shows the same output that `set_x` shows, but doesn't actually *run* the command.

```sh
###############################################################################
#
# Show the same output that set_x would show,
# but don't actually run the command

function show_x {
    if [[ "${SET_X:-false}" == "true" ]]
    then
        local IFS=$' '
        echo "$PS4$*" 1>&2
    fi
}
```

As you can see, it's identical to `set_x` other than the `"$@"` at the end.

## Example

```sh
#!/bin/bash

###############################################################################
#
# Usage message. Every good script should have one.

function usage {
    MSG="${1:-}"

    cat <<EOF
$0 [options]

Example program.

-x      Show commands being executed.

-h      Show this help message.

EOF

    if [[ -n "$MSG" ]]
    then
        echo "$MSG"
        exit 1
    fi

    exit 0
}

###############################################################################
#
# Maybe print a command before executing it

SET_X="${SET_X:-false}"

function set_x {
    if [[ "${SET_X:-false}" == "true" ]]
    then
        local IFS=$' '
        echo "$PS4$*" 1>&2
    fi
    "$@"
}

###############################################################################
###############################################################################
###############################################################################

SET_X=false

while getopts ':hx' OPT
do
    case $OPT in
        h)  usage
            ;;
        x)  SET_X=true
            ;;
        *)  echo "ERROR: unknown option '$OPTARG'"
            exit 1
    esac
done
shift $(( OPTIND - 1 ))

########################################
# Examples

set_x echo hello

ID="$( set_x gh pr list ... )"
```
