# “Try Pollen”, a test Pollen Site

*(Version 0.22)*

I’ve created this site as a way of playing around with [Pollen](http://pollenpub.com) for myself, but also to help explain it to people who might be interested in using it for themselves. The documentation is well done and improving all the time, and you should really start by reading it thoroughly. But a guided tour through a simple working site might help put the pieces together, and illustrate the benefits of the Pollen system.

You can see it live at <http://tilde.club/~joeld/secretary>. The design and CSS come from [Tufte CSS](http://www.daveliepmann.com/tufte-css/).

The code is not very well commented yet. I’m working on it though.

Thanks to Matthew Butterick and Malcolm Still for their help with my Racket and Pollen questions.

## Setup

1. Install Pollen ([instructions](http://pkg-build.racket-lang.org/doc/pollen/Installation.html))
2. Install libuuid at the command line with `raco pkg install libuuid`
3. (Optional) to be able to generate PDFs as well as HTML, you should have a working installation of LaTeX (specifically `xelatex`) and the [Tufte-Latex classes](https://tufte-latex.github.io/tufte-latex/) installed. If you're on a Mac, installing [MacTeX](http://tug.org/mactex/) will satisfy both of these. (Note, if your shell is something other than bash, you'll need to take steps to ensure `/Library/TeX/texbin` is on your PATH.)
3. Clone or download this repo
4. `raco pollen start` from the main folder, then point your browser to `http://localhost:8080`

To generate the static website into a folder on your desktop, do `raco pollen publish`. See the [docs on `raco pollen`](http://pkg-build.racket-lang.org/doc/pollen/raco-pollen.html) for info on other ways of generating the files.

## Points of interest

A brief and incomplete self-guided tour of the code follows. I add new things from time to time, so check back.

* Look at `pollen.rkt` to see the definitions for the markup I use in this project, and the code that glues everything together.
* Look through the `.pm` files to see what writing in Pollen markup looks like.

### Custom markup

So far I’ve added two minor markup innovations to this project:

 1. A `◊verse` tag for poetry: This is one example of any area that Markdown does not (and likely will never) address properly. By using this tag I can output the exact HTML markup I need, which I can then style with CSS to center based on the width of the longest line. In LaTeX/PDF, this tag also automatically replaces double-spaces with `\vin` to indent lines.

 2. An `◊index-entry` tag: Intended to mark passages of text for inclusion in a book-style index. A separate page, `bookindex.html`, iterates through the pagetree, gathers up all of these entries and displays them in alphabetical order, grouped by heading. (Basically just like the index at the back of any serious book you have on your shelf.) This is another example of something that would be impossible in Markdown. Of course, on the web, this is something of an anachronism: it would probably be better for the reader to have a normal search form to use. However, besides serving as an illustration, this tag will allow for effortless inclusion of an index when I add support for this in LaTeX/PDF.

     You can see the code used to generate the index at the bottom of `pollen.rkt` and in `template-bookindex.html` file.

### LaTeX/PDF support

Any file with the `.poly.pm` extension can be generated as a `.ltx` file or a `.pdf` file as well as HTML. My LaTeX templates make use of the Tufte-LaTeX document classes, to match the Tufte-CSS in use on the web side.

You may want to edit the fonts specified `\setromanfont` and `\setmonofont` commands in both `template.ltx.p` and `template.pdf.p`; I have them set to Adobe Caslon Pro and Triplicate, respectively, so if you don't have those fonts installed you may get errors.

The official Pollen docs describe [the basic method for LaTeX and PDF targets](http://pkg-build.racket-lang.org/doc/pollen/fourth-tutorial.html), but my method differs somewhat due to the need for additional cleverness.

In my LaTeX template, any hyperlinks also get auto-converted to numbered side-notes. Unfortunately, this niftiness also means that when targeting LaTeX, you can't have a hyperlink inside a side-note since that would equate to a side-note within a side-note, which causes Problems.

I could simply stipulate "don't put hyperlinks in margin notes" but I wanted a more elegant solution. Solving this problem meant departing from the methods in the official tutorial. The details are in [this post at the Pollen mailing list](https://groups.google.com/d/msg/pollenpub/SoxbXRHnyMs/fP7hCSLADwAJ)

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

I’ve created a basic custom writer for [pandoc](http://pandoc.org) that allows you to convert Markdown files (or anything, really) into Pollen markup. The code is in `pandoc-pollen.lua`, and you can use it like so:

    pandoc -t pandoc-pollen.lua -o pollen-out.html.pm sourcefile.txt

Ideally you should open up `pandoc-pollen.lua` and customize the code to match the Pollen markup for your project.

I’d see three appropriate uses for this. One is for banging out first drafts that consist of long stretches of simple prose. In those cases there's not a lot of structure or metadata to be concerned with at the very outset, and you can take advantage of editors and tools that recognize Markdown syntax. Second, it allows you to more easily accept drafts in other formats from other people who aren't familiar with Pollen concepts. Third (the big one for me) it can help a lot with automating the process of mass-importing old material into a Pollen publication.

## Other good examples

Besides getting answers to my inane noob questions in the discussion group (which I try my best to keep to a minimum), I’m greatly assisted by being able to peruse the code of a couple of other Pollen creations.

It’s linked from the main Pollen site, but Matthew Butterick's article [Making a dual typed/untyped Racket library](http://unitscale.com/mb/technique/dual-typed-untyped-library.html) was created with Pollen and is a good learning resource. I initially missed the links at the bottom to the Pollen source code for the article, which is very well commented. (The article itself is a little beyond me.)

Malcolm Still also has the code for [his blog](http://mstill.io) in a [public repository](https://github.com/malcolmstill/mstill.io).
