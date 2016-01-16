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

    ◊;    This is a simple way of listing pages by an arbitrary grouping.
    ◊;    I call them ‘series’ but they're the same as what you’d call
    ◊;    ‘categories’ in a blog.
    ◊;      The function list-post-in-series takes a symbol and lists all the
    ◊;    pages that name a given symbol in the 'series key of their metas.
    ◊;      This function used to be located in pollen.rkt. But since it generates
    ◊;    output that's specific to our HTML design, it's a good idea to place it
    ◊;    right in the template.
    ◊(define (list-posts-in-series s #:author [author #t])
        (define (make-li post)
          (if author
              `(li (a [[href ,(symbol->string post)]]
                      (span [[class "smallcaps"]] ,(select-from-metas 'title post))) " by " ,(select-from-metas 'author post))
              `(li (a [[href ,(symbol->string post)]]
                      (span [[class "smallcaps"]] ,(select-from-metas 'title post))))))

        (define (is-child-post? p)
          (equal? s (string->symbol (select-from-metas 'series p))))

        `(section (h2 ,(select-from-metas 'title s))
                  (ul ,@(map make-li (filter is-child-post? (children 'posts.html))))))

    ◊;    For every child of series.html in the pagetree, we list that page’s
    ◊; title and summary, then we list all the children of posts.html that
    ◊; specify that series in their meta definitions.

    ◊(->html (list-posts-in-series 'series/notebook.html #:author #f))

    ◊(->html (list-posts-in-series 'series/poems.html))

    <h2>Flatland: A Romance of Many Dimensions</h2>

    <p><label for="margin-bookcover" class="margin-toggle">&#8853;</label>
        <input type="checkbox" id="margin-bookcover" class="margin-toggle" />
        <span class="marginnote"><img src="flatland/img/flatland-cover.png" /></span></p>

    ◊(define (chapter-li chapter)
             (->html `(li (span [[class "smallcaps"]]
                             (a [[href ,(symbol->string chapter)]]
                                ,(select-from-metas 'title chapter))))))

    <h3>Part I: This World</h3>
    <ol>
        ◊(map chapter-li (children 'flatland/part-1.html))
    </ol>

    <h3>Part II: Other Worlds</h3>
    <ol start="13">
        ◊(map chapter-li (children 'flatland/part-2.html))
    </ol>

    </article>
</body>
</html>
