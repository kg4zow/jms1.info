# Adding git commit/date info to mdbook "books"

**2022-03-08**

One of the limitations I ran into with [mdbook](https://rust-lang.github.io/mdBook/) is that it doesn't easily offer a way to automatically embed a version number or date into the generated pages. This makes it difficult for the reader to be sure that the documentation they're reading is the latest version, or that it matches a specific version of the "thing" the documentation is describing. This is something I normally use with any kind of automated documentation system, so I took the time to figure out how to do it.

This will add a section at the bottom of the navigation menu with the git commit and its timestamp, plus the timestamp when the HTML was generated.

[This comment](https://github.com/rust-lang/mdBook/issues/494#issuecomment-854760181) had most of the details, however what you see below is different enough to justify making my own write-up instead of just linking to the page.

### Pre-requisite

Install [jq](https://stedolan.github.io/jq/).

* macOS

    ```
    brew install jq
    ```

* Others - TODO

### Template

The first step is to modify the template used for every page, with updated HTML to position and format the information, as well as tokens where the dynamic information (the git commit and timestamps) will be substituted.

Note that the generated pages are all self-contained, there is no "frameset" with different HTML files shown on the left and right sides of the browser window.)

* In a new directory, run `mdbook init --theme` to create a dummy book, but *with* a `theme/` directory.

    Note: we're not going to *keep* this book, we just need somewhere to copy a couple of the default theme's files from.

* Copy `theme/index.hbs` from the dummy book, to `theme/index-template.hbs` in *your* book.

    This is the template we'll be modifying. Our copy will be used as a *template for that template*. (Very "meta", I know.) It will need to use a different filename, and a script will be triggered (below) to generate the values we need and substitute them into the contents of this file, to produce the actual `index.hbs` file that `mdbook` will use.

* Edit our new `theme/index-template.hbs` and add the version placeholders and other formatting within the existing `<nav>` element, as shown:

    ```html
        <nav id="sidebar" class="sidebar" aria-label="Table of contents">
            <div class="sidebar-scrollbox">
                {{#toc}}{{/toc}}
    <!-- start new content -->
                <hr/><div class="part-title">Version</div>
                <div id="commit" class="version">
                    <tt>VERSION_COMMIT_HASH</tt><br/>
                    <tt>VERSION_COMMIT_TIME</tt>
                </div>
                <div class="part-title">Generated</div>
                <div id="generated" class="version">
                    <tt>VERSION_NOW</tt>
                </div>
    <!-- end new content -->
            </div>
            <div id="sidebar-resize-handle" class="sidebar-resize-handle"></div>
        </nav>
    ```

* Add `/theme/index.hbs` to your `.gitignore` file. This file will be *generated* on the fly every time the book is processed.

### Stylesheets

The next step is to create a stylesheet, which will *format* the text added by our template modifications above.

In the root of the repo, create a `version-commit.css` file with the following contents:

```css
.version {
  font-size: 0.7em;
}
```

Now we need to tell `mdbook` to *include* that stylesheet in the generated pages.

* Edit your `book.toml` file.

* If it doesn't already have one, add an `[output.html]` section.

* If this section doesn't already have an `additional-css` key, add one.

* Add `"version-commit.css"` to that list.

The resulting section of the file will look like one of these:

* If this is the only custom CSS file...

    ```toml
    [output.html]
    additional-css = [ "version-commit.css" ]
    ```

* If there are other custom CSS files...

    ```toml
    [output.html]
    additional-css = [ "custom.css" , "version-commit.css" ]
    ```

The original web page also showed how to *not* include the version info in any printed output. I'm guessing this is because the "printed output" consists of one big long document containing the entire generated site, as opposed to just the one page you're looking at in the browser, and having the version info in between every page would get redundant.

I'm adding the version info to the "navigation bar" on the left, which already isn't included in printed output, so in my case this isn't necessary. However, if you're doing something different and find that you *need* this...

* Create `theme/css/print.css` with the following contents:

    ```
    .version {
        display: none ;
    }
    ```

### Add the preprocessor script

The `version-commit` script reads the template we copied earlier and substitutes the commit hash, commit time, and current time where the appropriate tokens exist in the template.

I wrote this first as a Perl script, and then tried to re-write it as a shell script. The script itself is a UNIX "filter" (i.e. it reads from STDIN and writes to STDOUT), so it seemed like it should be simple to just calculate the three values, then run a `sed` command to substitute the values ... but when I tried it, all of the generated output files ended up as zero bytes.

It was already working as a Perl script and I didn't have a lot of time to dig into it, so I left it alone and stuck with that. Maybe in the future if I get curious I'll have another go at making it into a shell script.

* Copy `version-commit` to the root of the repo.

* Set its permissions to allow execution (i.e. `chmod 0755` etc.). Make sure you do this *before* you `git commit` the file.

Once the script is in the repo, add the following to `book.toml`:

```toml
[preprocessor.generate-version]
renderers       = [ "html" ]
command         = """sh -c 'jq ".[1]"; ./version-commit theme/index-template.hbs > theme/index.hbs'"""
```

I'm not 100% sure whether the triple-quotes are a TOML thing, or a side effect of whatever code within `mdbook` parses the file, but *this is working*.

You will also note, it requires that `jq` be installed on the machine.

When `mdbook` runs a preprocessor, it sends a JSON array to the preprocessor's STDIN. This array contains two dictionaries, one being the "context" with information about the job itself, and the other being a JSON structure of the book's sections, chapters, and text. The preprocessor is expected to send a *potentially modified* version of this "book" JSON structure to its STDOUT.

The `jq ".[1]"` command simply copies the "book" JSON structure as-is, without making any modifications. In this case, we don't really *need* to modify anything in the content, we're just using the "preprocessor" to trigger the conversion of the template for the `index.hba` file, which is then used as the template for rendering the individual pages within the site.

This is why the string used as the `command` here, runs the `jq` command first, and then runs the `./version-commit` script to process the template and produce the `index.hbs` file.

### Test

I normally leave `mdbook serve` running while I work on documents, so I can preview my changes immediately in a browser window. I find that this encourages me to "save early, save often", as opposed to something like [MacDown](https://macdown.uranusjr.com/) which shows a live preview *while I'm typing* and therefore doesn't force me to save as often.

I tested this by making minor edits to one of the files that `mdbook serve` is watching - specifically, I added or removed extra empty lines at the end of the `src/SUMMARY.md` file, and then saved the change.

* Watch the output that `mdbook serve` writes while it's running. If there are problems with any of this, *that's* where any error messages will appear.

* Obviously, check the browser window where you're previewing the content, to see if the changes you're expecting, appear there.

If you don't use `mdbook serve`, you can run `mdbook build` by hand and check the results in a browser window.



# Changelog

**2024-06-19** jms1

- moved page to new `jms1.info` site, updated header

**2024-06-19** jms1

- moved page to new `jms1.info` site, updated header
- formtting changes due to Jekyll/mdbook differences


**2022-03-08** jms1

- Initial version
