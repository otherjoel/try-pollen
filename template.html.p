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
  <link rel="stylesheet" href="◊|path-prefix|css/tufte.css"/>
  <link rel="stylesheet" href="◊|path-prefix|css/joel.css"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style type="text/css">
   img { mix-blend-mode: multiply; }
  </style>
</head>
<body><article>
    <h1>◊(hash-ref metas 'title)</h1>
    ◊when/block[(select-from-metas 'author metas)]{
        <h2>◊(hash-ref metas 'author)</h2>
    }
    <nav><ul>
        ◊when/block[(and (previous here) (not (eq? (parent here) (previous here))))]{
            <li><a href="◊|path-prefix|◊|(previous here)|">&larr; Previous</a></li>
        }
        ◊when/block[(and (parent here) (not (eq? (parent here) 'pagetree-root)))]{<li><a href="◊|path-prefix|◊|(parent here)|">&uarr; Up</a></li>}
        ◊when/block[(or (not (parent here)) (eq? (parent here) 'pagetree-root))]{<li><a href="◊|path-prefix|index.html">&uarr; Up</a></li>}
        ◊when/block[(next here)]{
            <li><a href="◊|path-prefix|◊|(next here)|">Next &rarr;</a></li>
        }
        ◊when/block[(pdfable? source-file)]{
            <li><a href="◊pdfname[source-file]">
                  <img src="◊|path-prefix|css/pdficon.png" height="15" alt="Download PDF" />
                  <span class="caps">PDF</span></a></li>
        }
    </ul></nav>

	◊(map ->html (select-from-doc 'body here))
</article>
</body>
</html>
