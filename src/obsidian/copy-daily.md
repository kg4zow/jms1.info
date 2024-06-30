# Copy Daily Note

**2024-06-26**

I use Obsidian's "Daily Notes" feature to keep a daily list of what I want to get done, and what I *did* get done, at work each day.

Much of my job involves working on things that nobody else *can* do - or at least, not as well as I can do it. Tasks that would take me a few hours might take most other people a few days. Because of this, I tend to manage my own day-to-day tasks. Every morning I use email, chat, and an internal ticketing system to figure out what needs to get done. When it's not obvious, management helps me figure out which tasks need to be prioritized. And once I've got a clear picture of the day, I start working on whatever needs my attention the most.

Once or twice a week somebody will ask me what I'm working on and what's on my list for the day. This happened few weeks ago, and rather than stopping what I was working on to explain it to them, I just copied the current day's "Daily Note" Markdown file to a shared directory on [Keybase](https://book.keybase.io/files) and told them to look at that. I'm assuming this was enough for whatever they needed, because they didn't ask any more questions at the time.

Since then, when people have asked about this, I just copied the file to the same location - which saves time, but it's still an interruption to have to copy the file when people ask for it. I edit the file in Obsidian while I'm in my morning "planning" phase, but after that I don't do much with it, other than moving tasks to a "Done" section at the bottom of the page as things get done.

In order to avoid the interruptions (and make sure I don't forget to copy the file after making changes), I wrote a script which copies "today's" Daily Notes file to a specific filename on a shared drive, and set up a cron job on my macOS workstation to run the script every five minutes. It also adds a header at the top of the file which tells when the file was copied, so people can tell how up-to-date the file is.



## Script

This is `$HOME/bin/cron.copy.today` on my workstation.

```bash
#!/bin/bash
#
# cron.copy.today
# jms1 2024-06-25
#
# Copy my Obsidian Daily Note where others can see it

SRC_DIR="${HOME}/Documents/Obsidian/DAYJOB/Daily Notes"
DST_DIR="/keybase/team/KEYBASE_TEAM_NAME/jms1-today.md"

SUM_FILE="${0}.sum"

###############################################################################
###############################################################################
###############################################################################
#
# If KBFS isn't mounted, do nothing.

if [[ ! -d "$DST_DIR" ]]
then
    exit 1
fi

########################################
# Obsidian is configured with "Daily notes - Date format" `YYYY-MM-DD ddd`
# This `date` command generates the same exact name, so the script can find
# the correct file.

TODAY="$( date '+%Y-%m-%d %a' )"

########################################
# I add the current time into the file created by the script,
# so we can tell when it was copied.

NOW="$( date -u '+%Y-%m-%d %H:%M:%S %Z' )"

########################################
# If today's Daily Notes file doesn't exist, do nothing.

if [[ ! -f "$SRC_DIR/$TODAY.md" ]]
then
    exit 1
fi

########################################
# Figure out if the file in the shared drive needs to be copied or not.
# - If the checksum file exists
#   - and it contains today's filename
#     - and the checksum itself is correct, then do nothing.

if [[ -f "$SUM_FILE" ]]
then
    if grep -q "$TODAY.md" "$SUM_FILE"
    then
        if sha256sum --status -c "$SUM_FILE"
        then
            exit 0
        fi
    fi
fi

########################################
# Copy the file

(
    printf '# %s\ncopied `%s`\n\n' "$TODAY" "$NOW"
    cat "$SRC_DIR/$TODAY.md"
) > "$DST_DIR/today.md"

########################################
# Create/update checksum file for next time

sha256sum "$SRC_DIR/$TODAY.md" > "$SUM_FILE"
```

## Cron job

The crontab entry which runs the script is fairly simple. It looks like this.

```
1/5 * * * *     /Users/jms1/bin/cron.copy.daily
```

This makes the machine run the script every five minutes, at 1, 6, 11, etc. minutes after the hour.

### TAB characters in crontab files

Back in the day, UNIX systems *required* that crontab files use a TAB character between the time spec (here `1/5 * * * *`) and the command itself. More recent systems *allow* them, but will work with spaces as well. I'm *pretty sure* macOS falls in the "more recent systems" category, but I've been in the habit of using TAB characters in crontab files for the past 30+ years, so I do it anyway.

You may want to check your own system's documentation to be sure. If you're going to use TABs, you should also make sure you understand how to make your text editor *use* TAB characters when you need them.
