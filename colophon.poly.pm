#lang pollen

◊(define-meta title            "Colophon")
◊(define-meta doc-publish-date "2016-01-04")

These pages are my experiment in ◊hyperlink["posts/web-books.html"]{marrying web documents with printed books}: generating high quality print-ready PDF files from the same markup used to create the web pages.

For this I am using ◊hyperlink["http://pollenpub.com"]{Pollen}, a system and language for publishing books on the web or anywhere else. Most of the visual design and layout comes from the ◊hyperlink["https://github.com/edwardtufte/tufte-css"]{Tufte CSS project}, and the ◊hyperlink["https://tufte-latex.github.io/tufte-latex/"]{Tufte-◊Latex[]} project on which it is based.

The Pollen source code for this site is available ◊hyperlink["https://github.com/otherjoel/try-pollen"]{on Github}. The content and code on this site are available for liberal reuse as described in the ◊hyperlink["https://github.com/otherjoel/try-pollen/blob/master/LICENSE.md"]{license} provided in the repository.

On most pages (including this one!) you can click the PDF link to see the ◊Latex[]-generated print version of that page, as well as a link to see the Pollen source code for that page. Again, the point of interest here isn’t that each page has a corresponding PDF, but that the same text files generate both the website and the PDF files, using a custom, light-weight markup that can take full advantage of both HTML and ◊Latex[].

I'm ◊hyperlink["http://twitter.com/joeld"]{◊code{@joeld}} on Twitter and ◊hyperlink["https://keybase.io/joeld"]{verified on Keybase}. You can also find me at my ◊hyperlink["http://tilde.club/~joeld"]{tilde.club page}, and my main site, ◊hyperlink["http://thelocalyarn.com/blog"]{◊i{The Local Yarn}}, neither of which (yet) use Pollen.
