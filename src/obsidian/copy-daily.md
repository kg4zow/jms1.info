# Copy Obsidian Daily Note

**2024-07-14**

I use Obsidian's "Daily Notes" feature to keep a daily list of what I want to get done, and what I *did* get done, at work each day.

Much of my job involves working on things that nobody else *can* do - or at least, not as well as I can do it. (I'm not trying to brag, I've just been doing this a lot longer than most of my cow-orkers.) Tasks that would take me a few hours might take most other people a few days. Because of this, I tend to manage my own day-to-day tasks. Every morning I use email, chat, and an internal ticketing system to figure out what needs to get done. When it's not obvious, management helps me figure out which tasks need to be prioritized. And once I've got a clear picture of the day, I start working on whatever things need my attention the most, in that order.

Once or twice a week somebody will ask me what I'm working on and what's on my list for the day. This has happened a few times in the last week, and rather than stopping what I was working on to explain it to them, I just copied the current day's "Daily Note" Markdown file to a shared directory on [Keybase](https://book.keybase.io/files) and told them to look at that. I'm assuming this was enough for whatever they needed, because they didn't ask any more questions at the time.

Since then, when people have asked about it, I just copied the file to the same location - which saves time, but it's still an interruption to have to copy the file when people ask for it. I edit the file in Obsidian while I'm in my morning "planning" phase, and then during the day I'll add notes to the tasks, or if I'm lucky, move items to a "Done" section at the bottom of the page.

In order to avoid the interruptions (and to make sure I don't forget to copy the file after making changes), I automated the process of copying "today's" Daily Notes file to a specific filename on a shared drive. And then I found a different way to do it, that I like better, although both versions work.

# Option 1: cron job

Most unix-type systems, including macOS, use a program called [cron](https://en.wikipedia.org/wiki/Cron) to run programs in the background on a regular basis. The programs that it runs automatically are referred to as "cron jobs". The cron "engine" program which runs the jobs, uses text files called "crontabs" to configure which commands to run at what times.

I wrote a script which copies "today's" Daily Notes file to a specific filename on a shared drive, and set up a cron job on my macOS workstation to run the script every five minutes. The script also adds a header at the top of the file which tells when the file was copied, so people can tell how up-to-date the file is.

### Download the script

* [Download](cron.copy.today)
* [View](cron.copy.today.txt)

Save the script somewhere in your `PATH`. (I normally have `$HOME/bin` in my `PATH`, so I save the script there.)

Wherever you save it, make sure that the file has executable permissions.

```
chmod +x cron.copy.today
```

The crontab entry which runs the script is fairly simple. It looks like this.

```
1/5 * * * *     /Users/jms1/bin/cron.copy.daily
```

This file makes the machine run the script every five minutes, at 1, 6, 11, etc. minutes after the hour. (Obviously adjust the filename to point to wherever you

### TAB characters in crontab files

Back in the day, UNIX systems *required* that crontab files use a TAB character between the time spec (here `1/5 * * * *`) and the command itself. More recent systems *allow* them, but will work with spaces as well. I'm *pretty sure* macOS falls in the "more recent systems" category, but I've been in the habit of using TAB characters in crontab files for the past 30+ years, so I do it anyway.

You may want to check your own system's documentation to be sure. If you're going to use TABs, you should also make sure you understand how to make your text editor *use* TAB characters when you need them.

# Option 2: Shell commands plugin

One problem with using a cron job to copy the file is that the copy *can* only happen at the scheduled time. When the file is updated, it may be up to five minutes before it gets copied. It's possible to change the schedule so the script runs once every minute, but cron itself can't schedule jobs any more often than that.

As it turns out, there's an Obsidian plugin called [Shell commands](https://github.com/Taitava/obsidian-shellcommands) which, as the name suggests, runs shell commands. One of the things it can be configured to do is to run commands when files are saved or updated in a vault.

I wrote a script called `copy-daily-note`, designed to be called from this plugin with two pieces of information: the name of the file that was updated, and the name of a file that the current day's Daily note should be copied to. When it runs, it does the following:

* Calculate the filename of the current Daily note.

    By default this will be `YYYY-MM-DD.md` (for the current date, obviously) in the root directory of the vault, although both the filename and the directory are configurable. Personally, I have a "Daily Notes" folder inside the vault, and my filenames look like `2024-07-14 Sun.md` because I find it helpful to have the day of the week in the filename. (The "Date format" value I use for this is `YYYY-MM-DD ddd`.)

* If the filename that was updated is *not* the same as the one we just calculated, exit.

* If a "checksum file" exists, and contains information about the correct file, and the checksum in that file matches the current Daily note file, exit.

* Create an output file containing a header with the current Daily note's filename and a line telling when the file was copied, followed by the contents of the file that was updated (which we now know is today's Daily note).

* Write a checksum file containing the checksum of the file that was updated, so the next time the script runs, it can tell if the file has changed since *this* time.

After being configured below, the Shell commands plugin will run this script automatically every time a file in the vault changes.

### Download the script

* [Download](copy-daily-note)
* [View](copy-daily-note.txt)

You can save the script wherever you like, just be sure it has executable permissions.

```
chmod +x copy-daily-note
```

In the vault where I'm using this, I saved it within the vault itself, in a directory called `.bin`. This lets it "stay with" the vault, plus because I'm also using the obsidian-git plugin with that vault, any updates I make to the script are automatically sync'ed with the rest of the vault's contents.

The examples below will assume you're doing the same thing. If not, you'll need to adjust the path to run the script below.

```
cd ~/Documents/Obsidian/vaultname/
mkdir -p .bin
cp ~/Downloads/copy-daily-note .bin/
chmod 0755 .bin/copy-daily-note
```

### Options

The script contains a few command line options which can be used to control how the script works. You may or may not need them.

* `-c ___` = Specify a checksum program. (Default `sha256sum`)

    The script only writes an output file if the input file has changed since the last time the output file was written. The output file is not an *exact* copy of the input file (it will have an extra header added to it, to tell the reader when the file was copied), so it can't directly compare the two files. Instead, the script writes a second output file containing a *checksum* of the original input file, and uses that checksum to tell if the input file changed or not.

    This option sets what program is used to generate and verify the checksum files. By default it uses `sha256sum`, but it can also use `sha512sum`, `sha1sum`, or `md5sum`, depending on what's available on the machines where the script will run.

    The program you specify here needs to support the same `-c` option that `sha256sum` has.

* `-d ___` = Specify a custom date format.

    The Daily notes plugin allows the user to configure the filename it builds for each day's note, as well as the directory within the vault where it stores the daily notes. **This script needs to build the same filename, in the same directory.** It does this by reading the "Daily notes" plugin's configuration and converting the "Date format" setting to a string which can be used with the 'date' command to build the name of "today's" Daily note.

    The library used by the Daily notes plugin uses different "tags" to format the date, than what the `date` command (used by this script) uses. For example, the plugin's default is `YYYY-MM-DD`, but the `date` command would use `%Y-%m-%d` to format a date the same way. The script has a function to convert the commonly used tags from the plugin's format to the `date` command's format, but it doesn't cover every possible tag - only the ones that seemed like they would be useful, and for which the `date` command has corresponding tags for.

    If you're using a custom date format, and the automatic conversion function doesn't work, you can use the `-d` option to specify the format by hand.

    Documentation

    * [moment.js library](https://momentjs.com/docs/#/displaying/format/), used by the "Daily notes" plugin
    * [`strftime()`](https://www.man7.org/linux/man-pages/man3/strftime.3.html), used by the `date` command (and many other programs over the past 40 years)

    Examples

    | Daily notes plugin | `-d` option   | Notes
    |:-------------------|:--------------|:--------
    | `YYYY-MM-DD`       | `%Y-%m-%d`    | Default format
    | `YYYY-MM-DD ddd`   | `%Y-%m-%d %a` | The format I use in my vaults

    To test a string, to make sure it looks right:

    ```
    $ date '+%Y-%m-%d %a'
    2024-07-14 Sun
    ```

* `-i` = Log ignored files.

    If the script is called with a file that isn't the current daily note, it will exit without doing anything. If this option is given, the script will log (or notify you) that this happened.

* `-l ___` = Specify a log file. (The option is a lowercase "L", not a digit "one".)

    This option will make the script log what it does, every time it runs.

    If the vault is sync'ed to multiple computers (using a plugin like obsidian-git, or by storing it on a sync'ed or shared drive), you should make sure that the filename you use for this option will "work" on every machine. It may be helpful to use a value like `$HOME/copy-daily-note.log` so the log files on each machine are created in your home directory on that machine.

    The log file should probably NOT be stored within the vault, especially if the vault is sync'ed.

* `-n` = Do not include a link to this page when building output files.

    The script normally makes the "Copied from Obsidian" text in the header (before the timestamp) a link to this page, so others can read about how the file was created. If you use this option, that text will be normal text which doesn't link to anything.

Make a note of any options you'd like to use, you will need them below.

## Install the Plugin

Run Obsidian, and open the vault you want to use the Shell commands plugin with.

* Click ![obsidian-settings-button](../../images/obsidian-settings-button.png) on the ribbon on the left. (On macOS you can press "&#x2318;," for this.)

* Select "Community plugins" on the left.

* Next to "Community plugins", click the "Browse" button.

* Enter "shell" in the search box at the top of the window. Look for the "Git" plugin.

    ![shell-commands-plugin](../../images/shell-commands-plugin.png)

* Click on the plugin.

* Click on the "Install" button.

* After installing it, click the "Enable" button.

* Close the settings window (the X at the top right)

## Configure the Plugin

* Click ![obsidian-settings-button](../../images/obsidian-settings-button.png) on the ribbon on the left. (On macOS you can press "&#x2318;," for this.)

* Select "Shell commands" on the left. (It will be near the bottom of the list, under the "Community Plugins" section.)

* On the right, along the top, make sure the "Shell commands" tab is selected.

* Click the "New shell command" button. A new row should appear above the button.

    ![shell-command-entry](../../images/shell-command-entry.png)

* In the text entry box, enter the following:

    ```
    {{vault_path}}/.bin/copy-daily-note {{event_file_path:absolute}} /output/file/name.md
    ```

    Any additional [options](#options) should be added *after* `copy-daily-note` and *before* `{{event_file_path:absolute}}`.

* Above the text entry box, click the ![shell-command-events](../../images/shell-command-events.png) button. On the menu which appears ...

    Debouncing (experimental)

    * Execute before cooldown: NO
    * Execute after cooldown: YES
    * Cooldown duration (seconds): 3
        * This is how long the plugin waits before running the script, after you stop typing.
    * Prolong cooldown: YES

    Execute this shell command automatically when:

    * File content modified: YES

* Close the settings windows (the X at the top right, twice)



# Changelog

**2024-07-14**

- updated to include and explain both scripts
- moved scripts to be downloads rather than inline on the page
- added symlinks with `.txt` in the name, to allow web browsers to view the scripts without downloading them

**2024-06-26**

- created this page
