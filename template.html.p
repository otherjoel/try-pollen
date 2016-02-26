<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>◊(hash-ref metas 'title)</title>
  ◊; Because I deploy this site in a sub-directory (rather than a domain root) I
  ◊; have to use relative paths instead of absolute ones. Defining path-prefix
  ◊; is just my way of coping with this.
  ◊(define path-prefix (if (string-contains (symbol->string here) "/") "../" ""))
  ◊(define source-file (select-from-metas 'here-path metas))
  ◊(define pollen-source-listing
      (regexp-replace #px"(.*)\\/(.+).html" (symbol->string here) "\\2.pollen.html"))
  <link rel="stylesheet" href="◊|path-prefix|css/tufte.css"/>
  <link rel="stylesheet" href="◊|path-prefix|css/joel.css"/>
  <link rel="alternate" type="application/atom+xml" title="Atom feed" href="◊|path-prefix|feed.xml" />
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style type="text/css">
   img { mix-blend-mode: multiply; }
  </style>
</head>
<body><article>
    <h1>◊(hash-ref metas 'title)</h1>
    ◊when/splice[(select-from-metas 'author metas)]{
        <h2>◊(hash-ref metas 'author)</h2>
    }
    <nav><ul>
        ◊when/splice[(and (previous here) (not (eq? (parent here) (previous here))))]{
            <li><a href="◊|path-prefix|◊|(previous here)|">&larr; Previous</a></li>
        }
        ◊when/splice[(not (eq? here 'index.html))]{
            <li><a href="◊|path-prefix|index.html">&uarr; Home</a></li>
        }
        ◊when/splice[(and (next here) (member (next here) (siblings here)))]{
            <li><a href="◊|path-prefix|◊|(next here)|">Next &rarr;</a></li>
        }
        ◊when/splice[(pdfable? source-file)]{
            <li><a href="◊pdfname[source-file]">
                  <img src="◊|path-prefix|css/pdficon.png" width="15" height="15" alt="Download PDF" />
                  <span class="caps" style="font-style: normal">PDF</span></a></li>
        }
        ◊when/splice[(string-contains path-prefix "/")]{
            <li style="width: auto;">
              <a href="◊|pollen-source-listing|" title="View the Pollen source for this file"
                 class=" sourcelink code">&loz; Pollen Source</a></li>
        }
    </ul></nav>

	◊(map ->html (select-from-doc 'body here))
</article>
◊when/splice[(equal? "Joel Dueck" (select-from-metas 'author here))]{
    <footer><hr>
    <p>My name is <a href="https://keybase.io/joeld">Joel Dueck</a>. I’ve been <a href="https://thelocalyarn.com/blog">writing online</a> since 1998. You can contact me on the Twitters <a href="https://twitter.com/joeld">@joeld</a> or by email at <a href="mailto:joel@jdueck.net">joel@jdueck.net</a>, or see my <a href="https://github.com/otherjoel">Github profile</a>. <a href="◊|path-prefix|colophon.html">Read about this site</a>.</p>
    </footer>
}
</body>
</html>
