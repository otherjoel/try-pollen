<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>◊(hash-ref metas 'title)</title>
  <link rel="stylesheet" href="css/tufte.css"/>
  <link rel="stylesheet" href="css/joel.css"/>
  <link rel="alternate" type="application/atom+xml" title="Atom feed" href="feed.xml" />
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style type="text/css">
   img { mix-blend-mode: multiply; }
  </style>
</head>
<body>
    <article>
	<h1>◊(hash-ref metas 'title)</h1>
    <h2>◊(hash-ref metas 'author)</h2>

    ◊; Insert the content from the page (index.html.pm in this case)
    ◊(map ->html (select-from-doc 'body here))

    <p>
        <a href="colophon.html">Notes</a> &middot;
        <a href="bookindex.html">Index</a> &middot;
        <a href="feed.xml"><span class="caps">RSS</span> Feed</a>
    </p>

    ◊; HERE IS a simple way of listing pages by an arbitrary grouping.
    ◊; I call them ‘series’ but they're the same as what you’d call
    ◊; ‘categories’ in a blog.
    ◊;    For every child of series.html in the pagetree, we list that page’s
    ◊; title and summary, then we list all the children of posts.html that
    ◊; specify that series in their meta definitions.
    ◊;    See the function `list-posts-in-series` in pollen.rkt for more.

    ◊(map (lambda(ss) (->html `(section (h2 ,(select-from-metas 'title ss))
                                        (p ,(select-from-metas 'summary ss))
                                        ,(list-posts-in-series ss))))
          (children 'series.html))

    <h2>Flatland: A Romance of Many Dimensions</h2>

    <p><label for="margin-bookcover" class="margin-toggle">&#8853;</label>
        <input type="checkbox" id="margin-bookcover" class="margin-toggle" />
        <span class="marginnote"><img src="flatland/img/flatland-cover.png" /></span></p>

    ◊(define (chapter-li chapter)
             (->html `(li (span [[class "smallcaps"]]
                             ,(select-from-metas 'chapter-num chapter) ". "
                             (a [[href ,(symbol->string chapter)]]
                                ,(select-from-metas 'title chapter))))))

    <h3>Part I: This World</h3>
    <ul>
        ◊(map chapter-li (children 'flatland/part-1.html))
    </ul>

    <h3>Part II: Other Worlds</h3>
    <ul>
        ◊(map chapter-li (children 'flatland/part-2.html))
    </ul>

    </article>
</body>
</html>
