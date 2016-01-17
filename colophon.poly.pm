#lang pollen

◊(define-meta title            "Colophon")
◊(define-meta doc-publish-date "2016-01-04")
◊(define-meta author           "Joel Dueck")

These pages are my playground for trying out ◊hyperlink["http://pollenpub.com"]{Pollen}, a system for publishing books on the web or anywhere else.

In particular, I’m trying to experiment with marrying web documents with printed books: generating high quality print-ready PDF files from the same markup used to create the web pages. The ◊hyperlink["http://www.daveliepmann.com/tufte-css/"]{Tufte ◊smallcaps{CSS}} project, and the ◊hyperlink["https://tufte-latex.github.io/tufte-latex/"]{Tufte-◊Latex[]} project on which it is based, turned out to be the perfect tools for the job.

On most pages (including this one!) you can click the PDF link to see the ◊Latex[]-generated print version of that page. The home page also includes a PDF of the complete book ◊i{Flatland}. Again, the point of interest here isn’t that each page has a corresponding PDF, but that the same text files generate both the website and the PDF files, using a custom, light-weight markup that can take full advantage of both HTML and ◊Latex[].

The Pollen source code for this site is available ◊hyperlink["https://github.com/otherjoel/try-pollen"]{on Github}.

I'm ◊hyperlink["http://twitter.com/joeld"]{on Twitter}. You can also find me at my ◊hyperlink["http://tilde.club/~joeld"]{tilde.club page} and my main site, ◊hyperlink["http://thelocalyarn.com"]{◊i{The Local Yarn}}, neither of which (yet) use Pollen.
