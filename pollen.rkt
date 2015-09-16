#lang racket

(require pollen/decode
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

(define (root . elements)
  (make-txexpr 'body null
               (decode-elements elements
                                #:inline-txexpr-proc (compose margin-figure-decoder
                                                              numbered-note-decoder
                                                              margin-note-decoder)
                                #:txexpr-elements-proc detect-paragraphs
                                #:string-proc (compose smart-quotes smart-dashes)
                                #:exclude-tags '(script style)
                                )))

(define (numbered-note-decoder itx)
  (define (numbered-note . text)
    (define refid (uuid-generate))
    (list `(label [[for ,refid] [class "margin-toggle sidenote-number"]] )
          `(input [[type "checkbox"] [id ,refid] [class "margin-toggle"]] )
          `(span [(class "sidenote")] ,@text)))
  (if (eq? 'numbered-note (get-tag itx)) ; check if it's the tag we want
      (apply numbered-note (get-elements itx)) ; if so, apply processing
      itx)) ; if not, pass it through

(define (margin-figure-decoder itx)
  (define (margin-figure source . caption)
    (define refid (uuid-generate))
    (list `(label [[for ,refid] [class "margin-toggle"]] 8853)
          `(input [[type "checkbox"] [id ,refid] [class "margin-toggle"]])
          `(span [[class "marginnote"]] (img [[src ,source]]) ,@caption))
    )
  (if (eq? 'margin-figure (get-tag itx)) ; check if it's the tag we want
      (apply margin-figure (get-elements itx)) ; if so, apply processing
      itx)) ; if not, pass it through

(define (margin-note-decoder itx)
  (define (margin-note . text)
    (define refid (uuid-generate))
    (list `(label [[for ,refid] [class "margin-toggle"]] 8853 )
          `(input [[type "checkbox"] [id ,refid] [class "margin-toggle"]] )
          `(span [[class "marginnote"]] ,@text)))
  (if (eq? 'margin-note (get-tag itx))
      (apply margin-note (get-elements itx))
      itx))

(register-block-tag 'pre)
(register-block-tag 'figure)

(define (author . words) `(p [(class "subtitle")] ,@words))

(define (newthought . words) `(span [[class "newthought"]] ,@words))

(define (doc-section title . text)
  `(section (h2 ,title) ,@text))

(define (index-entry entry . text)
  `(a [[id ,entry] [class "index-entry"]] ,@text))

(define (figure source . caption)
  `(figure (img [[src ,source]]) (figcaption ,@caption)))

(define (margin-image src)
  `(img [[src ,src]]))

(define (fullwidthfigure source . caption)
  `(figure [[class "fullwidth"]] (img [[src ,source] [alt ,@caption]]) (figcaption ,@caption)))

(define (code . text)
  `(span [[class "code"]] ,@text))

(define (blockcode . text)
  `(pre [[class "code"]] ,@text))

(define (verse . text)
  `(div [[class "poem"]] (pre [[class "verse"]] ,@text)))

(define (poem-heading . words)
  `(p [[class "poem-heading"]] ,@words))

(define (grey . text)
  `(span [[style "color: #777"]] ,@text))

(define (hyperlink url . words)
  `(a [[href ,url]] ,@words))

(define (list-posts-in-series s)
    (define (make-li post)
      `(li (a [[href ,(symbol->string post)]]
              (i ,(select-from-metas 'title post))) " by " ,(select-from-metas 'author post)))

    `(ul ,@(map (λ(post)
                  (if (equal? s (string->symbol (select-from-metas 'series post)))
                      (make-li post)
                      '()))
                (children 'posts.html))))

; Index functionality: allows creation of a book-style keyword index.
;
; An index ENTRY refers to the heading that will appear in the index.
; An index LINK is a txexpr that has class="index-entry" and
; id="ENTRY-WORD". (Created in docs with the ◊index-entry tag above)

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
                "Not a txexpr: " ,(symbol->string file)) )))

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
; the heading.
(define (match-index-links keyword entrylink-list)
  (filter (λ(link)(string=? (attr-ref link 'id) keyword))
          entrylink-list))
