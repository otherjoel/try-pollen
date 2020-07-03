# “Secretary of Foreign Relations”

*(A test Pollen site: version 0.25)*

I’ve created this site to experiment with [making websites that are also printed books](https://thelocalyarn.com/excursus/secretary/posts/web-books.html) using [Pollen](http://pollenpub.com), as well as to help explain Pollen to people who might be interested in using it for themselves. The [official Pollen documentation](http://pkg-build.racket-lang.org/doc/pollen/index.html) is well done and improving all the time, and you should really start by reading it thoroughly. But a quasi-guided tour through a simple working site might help put the pieces together, and illustrate the benefits of the Pollen system.

You can see the site live at <https://thelocalyarn.com/excursus/secretary>. While browsing there, be sure to click on the “◊ Pollen Source” links at the top of the individual pages to see the Pollen markup that was used to generate that page.

Thanks to [Matthew Butterick](http://typographyforlawyers.com/about.html) and [Malcolm Still](http://mstill.io) for their help with my Racket and Pollen questions.

### Support

If you find this project helpful, consider chipping a few bucks towards the author!

<a href='https://ko-fi.com/B0B1MJ3B' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

## Setup

1. Install Pollen ([instructions](http://pkg-build.racket-lang.org/doc/pollen/Installation.html))
2. (Optional) To be able to generate PDFs as well as HTML, you should have a working installation of LaTeX (specifically `xelatex`) and the [Tufte-Latex classes](https://tufte-latex.github.io/tufte-latex/) installed. If you're on a Mac, installing [MacTeX](http://tug.org/mactex/) will satisfy both of these. (Note, if your shell is something other than bash, you'll need to take steps to ensure `/Library/TeX/texbin` is on your PATH.) Also see the note in the [LaTeX/PDF](#latexpdf-support) section (further down) on specifying fonts that you have installed on your system, otherwise PDF builds may fail.
3. Clone or download this repo
4. `raco pollen start` from the main folder, then point your browser to `http://localhost:8080`

If you have GNU Make installed (Mac or Linux) you can run `make all` from the main project folder. Run `make spritz` to clean up various working directories, or `make zap` to delete all the output files and start fresh. See the [makefile](makefile) for more info (it’s pretty well commented), and of course see the [docs on `raco pollen`](http://pkg-build.racket-lang.org/doc/pollen/raco-pollen.html) for more on generating the files in Pollen.

## Points of interest

A brief and incomplete self-guided tour of the code follows. I add new things from time to time, so check back.

* Look at `pollen.rkt` to see the definitions for the markup I use in this project, and the code that glues everything together.
* `feed.xml.pp` is where the RSS feed is generated.
* The two files `flatland-book.pdf.pp` and `flatland-book.ltx.pp` generate a complete PDF book of Flatland using the same `.poly.pm` source files in the `flatland/` subfolder. This PDF file can be sent right to CreateSpace or any other print-on-demand service; as a demonstration, I’ve made the print book [available for order at CreateSpace](https://www.createspace.com/6059658).
* Look through the `.pm` files to see what writing in Pollen markup looks like. (Another way to do this is to click the “Pollen source” links on sub-pages at the [live site](https://thelocalyarn/excursus/secretary/).)

### Custom markup

So far I’ve added two minor markup innovations to this project:

 1. A `◊verse` tag for poetry: This is one example of an area that Markdown does not (and likely will never) address properly. By using this tag I can output the exact HTML markup I need, which I can then style with CSS to center based on the width of the longest line. In LaTeX/PDF, this tag also automatically replaces double-spaces with `\vin` to indent lines.

 2. An `◊index-entry` tag: Intended to mark passages of text for inclusion in a book-style index. A separate page, `bookindex.html`, iterates through the pagetree, gathers up all of these entries and displays them in alphabetical order, grouped by heading. (Basically just like the index at the back of any serious book you have on your shelf.) This is another example of something that would be impossible in Markdown. Of course, on the web, this is something of an anachronism: it would probably be better for the reader to have a normal search form to use. However, besides serving as an illustration, this tag will allow for effortless inclusion of an index when I add support for this in LaTeX/PDF.

     You can see the code used to generate the index at the bottom of `pollen.rkt` and in the `template-bookindex.html` file.

### LaTeX/PDF support

Any file with the `.poly.pm` extension can be generated as a pretty darn nice-looking PDF file as well as HTML. My LaTeX templates make use of the Tufte-LaTeX document classes, to match the Tufte-CSS in use on the web side.

In addition, the preprocessor files `flatland/flatland-book.ltx.pp` and `flatland/flatland-book.pdf.pp` generate a complete PDF of the entire Flatland book.

You may want to edit the fonts specified in the `\setromanfont` and `\setmonofont` commands in  `template.ltx.p`, `template.pdf.p` and `flatland/flatland-book.ltx.pp`; I have them set to Adobe Caslon Pro and Triplicate, respectively, so if you don't have those fonts installed you will get errors.

The official Pollen docs describe [the basic method for LaTeX and PDF targets](http://pkg-build.racket-lang.org/doc/pollen/fourth-tutorial.html), but my method differs somewhat due to the need for additional cleverness.

In my LaTeX template, any hyperlinks also get auto-converted to numbered side-notes. Unfortunately, this niftiness also means that when targeting LaTeX, you can't have a hyperlink inside a side-note since that would equate to a side-note within a side-note, which causes Problems. I could simply stipulate "don't put hyperlinks in margin notes" but I wanted a more elegant solution. Solving this problem meant departing from the methods in the official tutorial. The details are in [this post at the Pollen mailing list](https://groups.google.com/d/msg/pollenpub/SoxbXRHnyMs/fP7hCSLADwAJ).

### RSS feed

The site now generates an RSS feed in Atom 1.0 format (tested at the Feed Validator, of course). The `feed.xml.pp` file is heavily commented and explains how this works.

### Grouping pages by series

I implemented a simple system for grouping pages according to a “series” — think of a series of articles in a journal or magazine (or maybe what you’d call *categories* in a blog).

As specified in `index.ptree` all posts sit together in one big pool in the `posts` subfolder. Each post can optionally specify a series:

    ◊(define-meta series "series/poems.html")

I opted to specify the series by the Pollen target filename, but it could just as easily be the human-friendly name of the series (doing it this way allows me to change that name without affecting the posts that refer to it).

Then for every series, I create a Pollen file in the `series` subfolder which serves as a brief introduction to the series, and manually add that to `index.ptree`.

The file `template-index.html` (the template specified in `index.html.pm`) includes code that iterates over all the pages in the `series` subfolder, prints out its contents, then lists all the posts that specify that series in their metadata (using the `list-posts-in-series` function defined in `pollen.rkt`).

### Converting Markdown to Pollen

I’ve created a basic custom writer for [pandoc](http://pandoc.org) that allows you to convert Markdown files (or anything, really) into Pollen markup. I’d see three appropriate uses for this. One is for banging out first drafts that consist of long stretches of simple prose. In those cases there's not a lot of structure or metadata to be concerned with at the very outset, and you can take advantage of editors and tools that recognize Markdown syntax. Second, it allows you to more easily accept drafts in other formats from other people who aren't familiar with Pollen concepts. Third (the big one for me) it can help a lot with automating the process of mass-importing old material into a Pollen publication.

The code is in `util/pandoc-pollen.lua`, and the template file is in `util/pandoc-pollen-template.pm`. You can use it like so from within the project root folder:

    pandoc -t util/pandoc-pollen.lua -o YOUR-OUTPUT.poly.pm --template=util/pandoc-pollen-template.pm SOURCEFILE.md

Or to convert a bunch of Markdown files at once, run this Bash script:

    #!/bin/bash

    for f in *.md; do \
     pandoc --template=util/pandoc-pollen-template.pm -t pandoc-pollen.lua "$f" > "$f.poly.pm"
    done

You should open up `util/pandoc-pollen.lua` and `util/pandoc-pollen-template.pm` and customize the code to match the Pollen markup for your project. You’ll likely still need to clean up the resulting files once they’ve been sent through the wringer, but this will do a lot of the tedious work for you.

## Other good examples

Besides getting answers to my inane newbie questions in the discussion group (which I try my best to keep to a minimum), I’m greatly assisted by being able to peruse the code of a couple of other Pollen creations.

Matthew Butterick's article [Making a dual typed/untyped Racket library](http://unitscale.com/mb/technique/dual-typed-untyped-library.html) was created with Pollen and is a good learning resource. I initially missed the links at the bottom to the Pollen source code for the article, which is very well commented.

Malcolm Still also has the code for [his blog](http://mstill.io) in a [public repository](https://github.com/malcolmstill/mstill.io).

Matthew Butterick also keeps [a list of other Pollen projects and guides](https://docs.racket-lang.org/pollen/Getting_more_help.html?q=pollen#%28part._.More_projects___guides%29) in the official Pollen documentation.
