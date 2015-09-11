I've created this site as a way of playing around with [Pollen](http://pollenpub.com) for myself, but also to help explain it to people who might be interested in using it for themselves. The documentation is well done and improving all the time, and you should really start by reading it thoroughly. But a guided tour through a simple working site might help put the pieces together, and illustrate the benefits of the Pollen system.

You can see it live at <http://tilde.club/~joeld/secretary>. The design and CSS come from [Tufte CSS](http://www.daveliepmann.com/tufte-css/).

The code is not very well commented yet. Maybe soon though.

Thanks to Matthew Butterick and Malcolm Still for their help with my Racket and Pollen questions.

## Points of interest

Look at `pollen.rkt` to see the definitions for the markup I use in this project, and the code that glues everything together.

Look through the `.pm` files to see what writing in Pollen markup looks like.

### Custom markup

So far I've added two minor innovations to this project:

 1. A `◊verse` tag for poetry: This is one example of any area that Markdown does not (and likely will never) address properly. By using this tag I can output the exact HTML markup I need, which I can then style with CSS to center based on the width of the longest line.

 2. An `◊index-entry` tag: Intended to mark passages of text for inclusion in a book-style index. A separate page, `bookindex.html`, iterates through the pagetree, gathers up all of these entries and displays them in alphabetical order, grouped by heading. (Basically just like the index at the back of any serious book you have on your shelf.) This is another example of something that would be impossible in Markdown. Of course, on the web, this is something of an anachronism: it would probably be better for the reader to have a normal search form to use. However, besides serving as an illustration, this tag will allow for effortless inclusion of an index when I add support for targeting LaTeX/PDF.

     You can see the code used to generate the index at the bottom of `pollen.rkt` and in `template-bookindex.html` file.

### Converting Markdown to Pollen

I've created a basic custom writer for [pandoc]() that allows you to convert Markdown files (or anything, really) into Pollen markup. The code is in `pandoc-pollen.lua`, and you can use it like so:

    pandoc -t pandoc-pollen.lua -o pollen-out.html.pm sourcefile.txt

Ideally you should open up `pandoc-pollen.lua` and customize the code to match the Pollen markup for your project.

I’d see three possible uses for this. One is for banging out first drafts that consist of long stretches of simple prose. In those cases there's not a lot of structure or metadata to be concerned with at the very outset, and you can take advantage of editors and tools that recognize Markdown syntax. Second, it allows you to more easily accept drafts in other formats from other people who aren't familiar with Pollen concepts. Third (the big one for me) it can help a lot with automating the process of mass-importing old material into a Pollen publication.

## Other good examples

Besides getting answers to my inane noob questions in the discussion group (which I try my best to keep to a minimum), I'm greatly assisted by being able to peruse the code of a couple of other Pollen creations.

It's linked from the main Pollen site, but Matthew Butterick's article [Making a dual typed/untyped Racket library](http://unitscale.com/mb/technique/dual-typed-untyped-library.html) was created with Pollen and is a good learning resource. I initially missed the links at the bottom to the Pollen source code for the article, which is very well commented. (The article itself is a little beyond me.)

Malcolm Still also has the code for [his blog](http://mstill.io) in a [public repository](https://github.com/malcolmstill/mstill.io).
