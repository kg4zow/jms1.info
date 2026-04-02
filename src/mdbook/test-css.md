# Testing CSS Attributes

This page lists the values of the CSS variables involved in the theme. I use this when testing values for a new theme. I do this by changing the values in the `variables.css` file, then reloading the browser window, to make sure the colours look the way I want them to.

The page contains an embedded Javascript function which reads the variables' values and inserts them into `<span>` tags in the tables below. If you change the theme you're using in your browser, you'll need to click one of the <button onclick='update_values()'>Refresh</button> buttons (or reload the page) to update the values.


Notes:

* This is NOT a complete list of the CSS variables used in the pages that mdbook generates. These are only the ones I have found useful when creating different coloured themes.
* The <button onclick='update_values()'>Refresh</button> buttons only run the Javascript function to update the values in the tables. They do not reload the entire page.
* The list of variables can change between different mdbook versions. The list below is accurate for mdbook v0.5.2, which is the latest version as of the time I'm writing this (2026-03-16).

## Examples

### Core Background & Text Colours

<button onclick='update_values()'>Refresh</button>

| Variable              | Value | Example
|:----------------------|:------|:--------
| `--color-scheme`      | <tt><span class='show-value' data-var='--color-scheme'      /></tt> |
| `--bg`                | <tt><span class='show-value' data-var='--bg'                /></tt> |
| `--fg`                | <tt><span class='show-value' data-var='--fg'                /></tt> | testing
| `--inline-code-color` | <tt><span class='show-value' data-var='--inline-code-color' /></tt> | `testing`
| `--links`             | <tt><span class='show-value' data-var='--links'             /></tt> | [testing](#)
| `--icons`             | <tt><span class='show-value' data-var='--icons'             /></tt> | <span class=fa-svg><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 496 512"><!--! Font Awesome Free 6.2.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. --><path d="M165.9 397.4c0 2-2.3 3.6-5.2 3.6-3.3.3-5.6-1.3-5.6-3.6 0-2 2.3-3.6 5.2-3.6 3-.3 5.6 1.3 5.6 3.6zm-31.1-4.5c-.7 2 1.3 4.3 4.3 4.9 2.6 1 5.6 0 6.2-2s-1.3-4.3-4.3-5.2c-2.6-.7-5.5.3-6.2 2.3zm44.2-1.7c-2.9.7-4.9 2.6-4.6 4.9.3 2 2.9 3.3 5.9 2.6 2.9-.7 4.9-2.6 4.6-4.6-.3-1.9-3-3.2-5.9-2.9zM244.8 8C106.1 8 0 113.3 0 252c0 110.9 69.8 205.8 169.5 239.2 12.8 2.3 17.3-5.6 17.3-12.1 0-6.2-.3-40.4-.3-61.4 0 0-70 15-84.7-29.8 0 0-11.4-29.1-27.8-36.6 0 0-22.9-15.7 1.6-15.4 0 0 24.9 2 38.6 25.8 21.9 38.6 58.6 27.5 72.9 20.9 2.3-16 8.8-27.1 16-33.7-55.9-6.2-112.3-14.3-112.3-110.5 0-27.5 7.6-41.3 23.6-58.9-2.6-6.5-11.1-33.3 2.6-67.9 20.9-6.5 69 27 69 27 20-5.6 41.5-8.5 62.8-8.5s42.8 2.9 62.8 8.5c0 0 48.1-33.6 69-27 13.7 34.7 5.2 61.4 2.6 67.9 16 17.7 25.8 31.5 25.8 58.9 0 96.5-58.9 104.2-114.8 110.5 9.2 7.9 17 22.9 17 46.4 0 33.7-.3 75.4-.3 83.6 0 6.5 4.6 14.4 17.3 12.1C428.2 457.8 496 362.9 496 252 496 113.3 383.5 8 244.8 8zM97.2 352.9c-1.3 1-1 3.3.7 5.2 1.6 1.6 3.9 2.3 5.2 1 1.3-1 1-3.3-.7-5.2-1.6-1.6-3.9-2.3-5.2-1zm-10.8-8.1c-.7 1.3.3 2.9 2.3 3.9 1.6 1 3.6.7 4.3-.7.7-1.3-.3-2.9-2.3-3.9-2-.6-3.6-.3-4.3.7zm32.4 35.6c-1.6 1.3-1 4.3 1.3 6.2 2.3 2.3 5.2 2.6 6.5 1 1.3-1.3.7-4.3-1.3-6.2-2.2-2.3-5.2-2.6-6.5-1zm-11.4-14.7c-1.6 1-1.6 3.6 0 5.9 1.6 2.3 4.3 3.3 5.6 2.3 1.6-1.3 1.6-3.9 0-6.2-1.4-2.3-4-3.3-5.6-2z"/></svg></span>
| `--icons-hover`       | <tt><span class='show-value' data-var='--icons-hover'       /></tt> | <span class=fa-svg style='color: var(--icons-hover);'><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 496 512"><!--! Font Awesome Free 6.2.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) Copyright 2022 Fonticons, Inc. --><path d="M165.9 397.4c0 2-2.3 3.6-5.2 3.6-3.3.3-5.6-1.3-5.6-3.6 0-2 2.3-3.6 5.2-3.6 3-.3 5.6 1.3 5.6 3.6zm-31.1-4.5c-.7 2 1.3 4.3 4.3 4.9 2.6 1 5.6 0 6.2-2s-1.3-4.3-4.3-5.2c-2.6-.7-5.5.3-6.2 2.3zm44.2-1.7c-2.9.7-4.9 2.6-4.6 4.9.3 2 2.9 3.3 5.9 2.6 2.9-.7 4.9-2.6 4.6-4.6-.3-1.9-3-3.2-5.9-2.9zM244.8 8C106.1 8 0 113.3 0 252c0 110.9 69.8 205.8 169.5 239.2 12.8 2.3 17.3-5.6 17.3-12.1 0-6.2-.3-40.4-.3-61.4 0 0-70 15-84.7-29.8 0 0-11.4-29.1-27.8-36.6 0 0-22.9-15.7 1.6-15.4 0 0 24.9 2 38.6 25.8 21.9 38.6 58.6 27.5 72.9 20.9 2.3-16 8.8-27.1 16-33.7-55.9-6.2-112.3-14.3-112.3-110.5 0-27.5 7.6-41.3 23.6-58.9-2.6-6.5-11.1-33.3 2.6-67.9 20.9-6.5 69 27 69 27 20-5.6 41.5-8.5 62.8-8.5s42.8 2.9 62.8 8.5c0 0 48.1-33.6 69-27 13.7 34.7 5.2 61.4 2.6 67.9 16 17.7 25.8 31.5 25.8 58.9 0 96.5-58.9 104.2-114.8 110.5 9.2 7.9 17 22.9 17 46.4 0 33.7-.3 75.4-.3 83.6 0 6.5 4.6 14.4 17.3 12.1C428.2 457.8 496 362.9 496 252 496 113.3 383.5 8 244.8 8zM97.2 352.9c-1.3 1-1 3.3.7 5.2 1.6 1.6 3.9 2.3 5.2 1 1.3-1 1-3.3-.7-5.2-1.6-1.6-3.9-2.3-5.2-1zm-10.8-8.1c-.7 1.3.3 2.9 2.3 3.9 1.6 1 3.6.7 4.3-.7.7-1.3-.3-2.9-2.3-3.9-2-.6-3.6-.3-4.3.7zm32.4 35.6c-1.6 1.3-1 4.3 1.3 6.2 2.3 2.3 5.2 2.6 6.5 1 1.3-1.3.7-4.3-1.3-6.2-2.2-2.3-5.2-2.6-6.5-1zm-11.4-14.7c-1.6 1-1.6 3.6 0 5.9 1.6 2.3 4.3 3.3 5.6 2.3 1.6-1.3 1.6-3.9 0-6.2-1.4-2.3-4-3.3-5.6-2z"/></svg></span>

This is regular text, with some `inline` text.

```
This is a block of pre-formatted text.
```


### Sidebar

<button onclick='update_values()'>Refresh</button>

| Variable                              | Value
|:--------------------------------------|:-----------
| `--sidebar-active`                    | <tt><span class='show-value' data-var='--sidebar-active'              /></tt>
| `--sidebar-bg`                        | <tt><span class='show-value' data-var='--sidebar-bg'                  /></tt>
| `--sidebar-fg`                        | <tt><span class='show-value' data-var='--sidebar-fg'                  /></tt>
| `--sidebar-header-border-color`       | <tt><span class='show-value' data-var='--sidebar-header-border-color' /></tt>
| `--sidebar-non-existant`              | <tt><span class='show-value' data-var='--sidebar-non-existant'        /></tt>
| `--sidebar-spacer`                    | <tt><span class='show-value' data-var='--sidebar-spacer'              /></tt>


### Blockquotes

<button onclick='update_values()'>Refresh</button>

| Variable          | Value
|:------------------|:-----------
| `--quote-bg`      | <tt><span class='show-value' data-var='--quote-bg'     /></tt>
| `--quote-border`  | <tt><span class='show-value' data-var='--quote-border' /></tt>

> This is a blockquote.


### Tables

<button onclick='update_values()'>Refresh</button>

| Variable                  | Value
|:--------------------------|:-----------
| `--table-alternate-bg`    | <tt><span class='show-value' data-var='--table-alternate-bg' /></tt>
| `--table-border-color`    | <tt><span class='show-value' data-var='--table-border-color' /></tt>
| `--table-header-bg`       | <tt><span class='show-value' data-var='--table-header-bg'    /></tt>
| &nbsp; |
| Extra rows to give the    |
| table enough rows so you  |
| can see the alternate     |
| background colours        |


### Code Highlighting

<button onclick='update_values()'>Refresh</button>

| Variable      | Value
|:--------------|:-----------
| `--code-bg`   | <tt><span class='show-value' data-var='--code-bg' /></tt>
| `--code-fg`   | <tt><span class='show-value' data-var='--code-fg' /></tt>

```perl
#!/usr/bin/env perl

require 5.005 ;
use strict ;
use warnings ;      # since 'env' won't let us add the '-w' option on the #! line

my $x = 0 ;
while ( $x <= 5 )
{
    $x ++ ;
    print "$x\n" ;
}
```


### Interactive Elements

<button onclick='update_values()'>Refresh</button>

| Variable                          | Value
|:----------------------------------|:-----------
| `--scrollbar`                     | <tt><span class='show-value' data-var='--scrollbar'                   /></tt>
| `--searchbar-border-color`        | <tt><span class='show-value' data-var='--searchbar-border-color'      /></tt>
| `--searchbar-bg`                  | <tt><span class='show-value' data-var='--searchbar-bg'                /></tt>
| `--searchbar-fg`                  | <tt><span class='show-value' data-var='--searchbar-fg'                /></tt>
| `--searchbar-shadow-color`        | <tt><span class='show-value' data-var='--searchbar-shadow-color'      /></tt>
| `--searchresults-header-fg`       | <tt><span class='show-value' data-var='--searchresults-header-fg'     /></tt>
| `--searchresults-border-color`    | <tt><span class='show-value' data-var='--searchresults-border-color'  /></tt>
| `--searchresults-li-bg`           | <tt><span class='show-value' data-var='--searchresults-li-bg'         /></tt>
| `--search-mark-bg`                | <tt><span class='show-value' data-var='--search-mark-bg'              /></tt>
| `--theme-popup-bg`                | <tt><span class='show-value' data-var='--theme-popup-bg'              /></tt>
| `--theme-popup-border`            | <tt><span class='show-value' data-var='--theme-popup-border'          /></tt>
| `--theme-hover`                   | <tt><span class='show-value' data-var='--theme-hover'                 /></tt>


## Embedded in this page

If you look at [this page's Markdown source](https://raw.githubusercontent.com/kg4zow/jms1.info/refs/heads/main/src/mdbook/test-css.md), you'll see that it contains some HTML fragments. I don't normally include HTML when writing Markdown, however I wanted this page to show not only the *effects* of the different colour values I'm trying, but the actual *values* as well.

You will also notice (in the Markdown source) that the values in the tables are enclosed with `<tt>...</tt>` rather than with backticks. This is because part of how mdbook handles backticks involves converting any `<` and `>` characters in the monospaced text to `&lt;` and `&gt;`, which makes the browser show the `<span>` *tags* instead of the values.

To save you the hassle of viewing the source in your browser and digging through that to see how I did this, I'm including visible copies of these HTML fragments here.

### Javascript - Show CSS Variable Values

This is a Javascript function which walks through every element on the rendered page which has `class='show-value'`, and sets the element's contents to the value of the CSS variable whose name is in the element's `data-var=` attribute.

<!-- Update every `<span/>` with `class='show-value'` to have the value of
     the CSS variable named in the `data-var=` attribute, as its content. -->
<script>
function update_values() {
    var elements = document.querySelectorAll( '.show-value' ) ;
    elements.forEach( e => {
        e.innerHTML = getComputedStyle( e ).getPropertyValue( e.dataset.var ) ;
    } )
}
update_values()
</script>

```js
<!-- Update every `<span/>` with `class='show-value'` to have the value of
     the CSS variable named in the `data-var=` attribute, as its content. -->
<script>
function update_values() {
    var elements = document.querySelectorAll( '.show-value' ) ;
    elements.forEach( e => {
        e.innerHTML = getComputedStyle( e ).getPropertyValue( e.dataset.var ) ;
    } )
}
update_values()
</script>
```

### Stylesheet - Do Not Center Tables

The default stylesheets that come with mdbook make tables centered on the page. I don't particularly like this, I think the pages look better with tables aligned to the left (which is HTML's default behaviour), so I'm adding this little block of CSS to override the `margin: auto` in mdbook's default stylesheet.

<!-- Do not center tables. -->
<style>
table {
    margin : 0 ;
}
</style>

```css
<!-- Do not center tables. -->
<style>
table {
    margin : 0 ;
}
</style>
```
