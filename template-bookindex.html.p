<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>INDEX</title>
  <link rel="stylesheet" href="css/tufte.css"/>
  <link rel="stylesheet" href="css/joel.css"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style type="text/css">
   img { mix-blend-mode: multiply; }
  </style>
</head>
<body><article>
    <h1>Index</h1>
    <ul>
        ◊; Get two lists: one of all index links in the current pagetree,
        ◊; another of all the unique headings used in the first list.

        ◊(define klinks (collect-index-links (pagetree->list (current-pagetree))))
        ◊(define kwords (index-headings klinks))

        ◊(map (λ(entry)
            (->html `(li ,entry ": "
                         ,@(add-between (map i (match-index-links entry klinks))
                                        ", "))))
            kwords)
    </ul>
</article>
</body>
</html>
