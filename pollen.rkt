#lang racket

(require pollen/decode
         pollen/world       ; For world:current-poly-target
         txexpr
         pollen/tag
         pollen/template
         pollen/pagetree
         libuuid            ; for uuid-generate
         srfi/13)           ; for string-search

(provide add-between
         attr-ref
         attrs-have-key?
         make-txexpr
         string-contains)
(provide (all-defined-out))

(module config racket/base
    (provide (all-defined-out))
    (define poly-targets '(html ltx)))

(define (root . elements)
  (make-txexpr 'body null
               (decode-elements elements
                                #:txexpr-elements-proc (compose1 detect-paragraphs splice)
                                #:string-proc (compose1 smart-quotes smart-dashes)
                                #:exclude-tags '(script style figure))))

#|
`splice` lifts the elements of an X-expression into its enclosing X-expression.
|#
(define (splice xs)
  (define tags-to-splice '(splice-me))
  (apply append (for/list ([x (in-list xs)])
                  (if (and (txexpr? x) (member (get-tag x) tags-to-splice))
                      (get-elements x)
                      (list x)))))

(define (numbered-note . text)
    (define refid (uuid-generate))
    (case (world:current-poly-target)
      [(ltx pdf) (apply string-append `("\\footnote{" ,@text "}"))]
      [else
        `(splice-me (label [[for ,refid] [class "margin-toggle sidenote-number"]])
                    (input [[type "checkbox"] [id ,refid] [class "margin-toggle"]])
                    (span [(class "sidenote")] ,@text))]))

(define (margin-figure source . caption)
    (define refid (uuid-generate))
    (case (world:current-poly-target)
      [(ltx pdf) (apply string-append `("\\begin{marginfigure}"
                                        "\\includegraphics{" ,source "}"
                                        "\\caption{" ,@caption "}"
                                        "\\end{marginfigure}"))]
      [else
        `(splice-me (label [[for ,refid] [class "margin-toggle"]] 8853)
                    (input [[type "checkbox"] [id ,refid] [class "margin-toggle"]])
                    (span [[class "marginnote"]] (img [[src ,source]]) ,@caption))]))

(define (margin-note . text)
    (define refid (uuid-generate))
    (case (world:current-poly-target)
      [(ltx pdf) (apply string-append `("\\marginnote{" ,@text "}"))]
      [else
        `(splice-me (label [[for ,refid] [class "margin-toggle"]] 8853)
                    (input [[type "checkbox"] [id ,refid] [class "margin-toggle"]])
                    (span [[class "marginnote"]] ,@text))]))

(register-block-tag 'pre)
(register-block-tag 'figure)
(register-block-tag 'center)
(register-block-tag 'blockquote)

;DEPRECATED
(define (author . words) `(p [(class "subtitle")] ,@words))

(define (newthought . words)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\newthought{" ,@words "}"))]
    [else `(span [[class "newthought"]] ,@words)]))

(define (smallcaps . words)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\textsc{" ,@words "}"))]
    [else `(span [[class "smallcaps"]] ,@words)]))

(define (center . words)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\begin{center}" ,@words "\\end{center}"))]
    [else `(div [[style "text-align: center"]] ,@words)]))

(define (doc-section title . text)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\section*{" ,title "}" ,@text))]
    [else `(section (h2 ,title) ,@text)]))

(define (index-entry entry . text)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\index{" ,entry "}" ,@text))]
    [else `(a [[id ,entry] [class "index-entry"]] ,@text)]))

(define (figure source . caption)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\begin{figure}"
                                      "\\includegraphics{" ,source "}"
                                      "\\caption{" ,caption "}"
                                      "\\end{figure}"))]
    [else `(figure (img [[src ,source]]) (figcaption ,@caption))]))

(define (fullwidthfigure source . caption)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\begin{figure}"
                                      "\\includegraphics[width=\\linewidth]{" ,source "}"
                                      "\\caption{" ,caption "}"
                                      "\\end{figure}"))]
    [else `(figure [[class "fullwidth"]] (img [[src ,source] [alt ,@caption]]) (figcaption ,@caption))]))

(define (code . text)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\texttt{" ,@text "}"))]
    [else `(span [[class "code"]] ,@text)]))

(define (blockcode . text)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\begin{verbatim}" ,@text "\\end{verbatim}"))]
    [else `(pre [[class "code"]] ,@text)]))

#|
Typesetting poetry in LaTeX or HTML. HTML uses a straightforward <pre> with
appropriate CSS. In LaTeX we explicitly specify the longest line for centering
purposes, and replace double-spaces with \vin to indent lines.
|#
(define (verse title . text)
  (case (world:current-poly-target)
    [(ltf pdf) (apply string-append `("\\poemtitle{" ,title "}"
                                      "\\settowidth{\\versewidth}{"
                                      ,(longest-line (apply string-append (list text)))
                                      "}"
                                      "\\begin{verse}[\\versewidth]"
                                      ,(string-replace (apply string-append (list text)
                                                        "  " "\\vin "))
                                      "\\end{verse}"))]
    [else `(div [[class "poem"]] (pre [[class "verse"]] ,@text))]))

#|
Helper function for typesetting poetry in LaTeX. Poetry should be centered
on the longest line. Browsers will do this automatically with proper CSS but
in LaTeX we need to tell it what the longest line is.
|#
(define (longest-line str)
  (first (sort (string-split str (~a #\newline))
               (λ(x y) (> (string-length x) (string-length y))))))

; DEPRECATED
(define (poem-heading . words)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\poemtitle{" ,@words "}"))]
    [else `(p [[class "poem-heading"]] ,@words)]))

(define (grey . text)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\textcolor{gray}{" ,@text "}"))]
    [else `(span [[style "color: #777"]] ,@text)]))

(define (hyperlink url . words)
  (case (world:current-poly-target)
    [(ltx pdf) (apply string-append `("\\href{" ,url "}"
                                      "{" ,@words "}"))]
    [else `(a [[href ,url]] ,@words)]))

(define (list-posts-in-series s)
    (define (make-li post)
      `(li (a [[href ,(symbol->string post)]]
              (i ,(select-from-metas 'title post))) " by " ,(select-from-metas 'author post)))

    `(ul ,@(filter identity
                   (map (λ(post)
                          (if (equal? s (string->symbol (select-from-metas 'series post)))
                              (make-li post)
                              #f))
                        (children 'posts.html)))))

#|
Index functionality: allows creation of a book-style keyword index.

* An index ENTRY refers to the heading that will appear in the index.
* An index LINK is a txexpr that has class="index-entry" and
  id="ENTRY-WORD". (Created in docs with the ◊index-entry tag above)

|#

; Returns a list of all elements in xpr that have class="index-entry"
; and an id key.
(define (filter-index-entries xpr)
  (define is-index-entry? (λ(x) (and (txexpr? x)
                                     (attrs-have-key? x 'class)
                                     (attrs-have-key? x 'id)
                                     (equal? "index-entry" (attr-ref x 'class)))))
  (let-values ([(x y) (splitf-txexpr xpr is-index-entry?)]) y))

; Given a file, returns a list of links to each index entry within that file
(define (get-index-links file)
  (define file-body (select-from-doc 'body file))
  (if file-body
      (map (λ(x)
             `(a [[href ,(string-append (symbol->string file) "#" (attr-ref x 'id))]
                  [id ,(attr-ref x 'id)]]
                 ,(select-from-metas 'title file)))
           (filter-index-entries (make-txexpr 'div '() file-body)))
      ; return a dummy entry when `file` has no 'body (for debugging)
      (list `(a [[class "index-entry"] [id ,(symbol->string file)]]
                "Not a txexpr: " ,(symbol->string file)))))

; Returns a list of index links (not entries!) for all files in file-list.
(define (collect-index-links file-list)
  (apply append (map get-index-links file-list)))

; Given a list of index links, returns a list of headings (keywords). This list
; has duplicates removed and is sorted in ascending alphabetical order.
; Note that the list is case-sensitive by design; "thing" and "Thing" are
; treated as separate keywords.
(define (index-headings entrylink-list)
  (sort (remove-duplicates (map (λ(tx) (attr-ref tx 'id))
                                entrylink-list))
        string-ci<?))

; Given a heading and a list of index links, returns only the links that match
; the heading.((
(define (match-index-links keyword entrylink-list)
  (filter (λ(link)(string=? (attr-ref link 'id) keyword))
          entrylink-list))
