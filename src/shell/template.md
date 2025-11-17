# Template

For many years I've kept a collection of pieces of shell code that I end up using when I start a new script. At one point I had to create about ten scripts in the same day, and realized that for each script I was copying a basic `getopts` loop, then copying the [`set_x` function](set_x.md), then copying the [coloured line functions](lines.md), and realized that it would be easier if I had a "template" with these things already in place, so I started a `template.txt` file in my home directory.

A few months later I discovered the [cheat](https://github.com/cheat/cheat/) program, and stored the template as a [cheatsheet](cheat.md). When I start a new script, I type something like this:

```
cheat template > new-script
```

... and then edit the `new-script` file from there.

## Download

My cheatsheet collection is backed up to Github. You can download the `template` cheatsheet from [this link](https://github.com/kg4zow/jms1-cheatsheets/blob/main/cheatsheets/template).

