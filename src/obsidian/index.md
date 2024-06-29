# Obsidian

[Obsidian](https://obsidian.md/) is a note-taking app. Individual notes are stored (and written) as [Markdown](https://daringfireball.net/projects/markdown/) files, stored in a directory tree that it calls a "vault". The files in the vault appear as a "tree view" pane within the app, and clicking on a file there will open that file in an editor pane.

It also tracks links between documents within the vault, and can produce a "graph view" with the documents as nodes and lines connecting them to other documents. I don't use this functionality much, since it requires you to add the links between documents, and my mind doesn't really work that way - to me it makes more sense to organize my documents in a directory structure.

Obsidian is available for macOS *and* Linux. It's also apparently available for ms-windows as well, if you're into that sort of thing. I don't use ms-windows unless something at `$DAYJOB` requires it, and that hasn't happened in over a year now.

Obsidian has an [API](https://docs.obsidian.md/Home) which allows people to write their own [plugins](https://obsidian.md/plugins) to extend or modify how Obsidian works. These plugins can be uploaded to Obsidian's servers, and other users can download and use them from there. It also allows users to make their own [themes](https://help.obsidian.md/Extending+Obsidian/Themes), which control the visual appearance of the notes you're editing or viewing.

I use a small set of plugins on a regular basis:

* [obsidian-git](https://github.com/denolehov/obsidian-git) makes Obsidian automatically commit and push changes to a git repo, as edits are made to the files in a vault. I track own vaults (both personal and for `$DAYJOB`) using [Keybase git](https://book.keybase.io/git) repos.

* [Minimal Theme](https://minimal.guide/) provides more options to customize the appearance of an editing pane, separately from a preview pane. This was the only way I could find to use different fonts for editing and previews.

    The author also provides a plugin to configure its settings.

## Similar or Related Programs

### Quiver

[Quiver](https://yliansoft.com/) ([macOS App Store link](https://apps.apple.com/us/app/quiver-take-better-notes/id866773894?mt=12&ls=1)) is a "notebook built for programmers". Its documents are stored as a series of blocks, each of which can be plain text, code, Markdown, or LaTeX. (99% of my documents had a single Markdown block.)

I stopped using Quiver for a few reasons.

* It has bugs. Nothing serious, I never lost any data - for me it was a tagging feature that *was* working for a long time, but is no longer working in the most recent release.

* The last release was 2019-09-29 (over 4&#xBD; years now). The only change I've seen since then is that its web site changed from `happenapps.comm` to `yliansoft.com` - the site's content appears to be the same.

* The only avenue for support I could find was an email address. The one time I tried to email the developer about tags not working, I never got any response.

Basically, I'm left with the conclusion that the app itself has been abandoned. Which is sad, because it was almost perfect for my needs.

### Logseq

At first glance, [Logseq](https://logseq.com/) seems to be very similar to Obsidian, however I ended up not going with it for a few reasons:

* Logseq's documents are structured more as outlines than as free-form Markdown documents. Outlines have their uses, but I've been very happy with [OmniOutliner](https://www.omnigroup.com/omnioutliner) for many years now. If I ever feel the need to use something other than OmniOutliner, Logseq will be on the list.

    The problem I was trying to solve was a way to organize and edit Markdown files, many of which already existed. For this problem, Obsidian was a better fit for me.

* Logseq's user interface seems to be a lot more heavily centered on the graph view. It's cool, but I found myself constantly thinking about adding links between documents, then checking the graph to make sure I wasn't missing any, then going back into the documents and figuring out how to work links into them.

    In other words, I was spending more time thinking about Logseq than about the contents of the documents I was writing.

### mdbook

[mdbook](https://rust-lang.github.io/mdBook/) is a program which converts a directory tree full of Markdown files, into a web site containing static HTML files. If you're reading this on the `jms1.info` site, you're looking at mdbook's output.

mdbook is not really an *alternative* to Obsidian, however until I *found* Obsidian, I was thinking seriously about using it as part of a workflow to try and provide the things I was using Quiver for.

I am using mdbook to maintain half a dozen internal documentation web sites for `$DAYJOB`, and I'm starting to use it for my own personal web sites (both public and private) as well.

There is an mdbook section in the menu on the left, where you will find more information about mdbook.

### ReText

[ReText](https://github.com/retext-project/retext) is an open-source (GPL2) editor for Markdown and [reStructuredText](https://www.docutils.org/rst.html). I had never heard of it until I installed [Debian 12](https://debian.org/) on a laptop and ran `apt search markdown` to see what was available.

From what I've seen it works well enough - it works with individual files rather than having a "vault" mechanism (i.e. no built-in file selector), however I couldn't find an already-packaged version for macOS. It's written in Python and the source code is available on Github, so if I hadn't found Obsidian, I was thinking about maybe packaging it for macOS so I could use it there.
