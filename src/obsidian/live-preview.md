# Obsidian - Live Preview Pane

**2024-06-29**

## Problem

The first issue I found when I tried Obsidian was the fact that it doesn't have a "live preview" pane. Other Markdown editors I've used all had two panes, with an editor on the left (usually) and a live preview on the right, so that as you're typing in the editor, you see the rendered output on the right, while you're typing.

I couldn't find an option to  enable this, so I [asked about it](https://forum.obsidian.md/t/side-by-side-live-preview/72763) on the Obsidian forum. (I am [jms1](https://forum.obsidian.md/u/jms1/) there, if that isn't obvious).

The responses contained several pieces of information that I found useful, especially the images showing what the various UI elements are called, i.e. "tab groups". However, I finally found the answer to the question on [this page](https://help.obsidian.md/Editing+and+formatting/Edit+and+preview+Markdown#Editor+views) in Obsidian's documentation.

## Solution

* When you're looking at a document, at the top right will be an icon, either a pencil or a book, to control whether that tab is an "editing view" or a "reading view".

* If you hold down &#x2318; (or CTRL for Linux) while clicking this icon, it will open a new tab, in a different tab group (so it's visible next to the current tab), showing the same document. The new tab will be "linked" with the old tab, so if you scroll up or down in one tab, the other will scroll itself to keep them "in sync" with each other.

I also found that with the tabs linked, if I select a different document in one tab, the other tab changes itself to show the same document.

It seems pretty simple once you know how Obsidian's UI works, but it took me a few days to figure out because it isn't really obvious, and nobody reads *all* of the documentation up front.

## Other

One "weird" thing I later noticed is that, if I create a new document, it opens a new tab for the new document, but the "live preview" in the other tab group doesn't "follow" it. This is because the new document *has* its own tab, and is not open in the existing "linked" tab.

My "solution" for this is to close the new tab, then when the existing "linked" tab is active again, click the new note in the file selector to open it.

