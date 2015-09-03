#lang racket/base

(require libuuid)
(require pollen/decode
	 txexpr
	 pollen/tag
	 pollen/template)

(provide (all-defined-out))

(define (root . elements)
   (make-txexpr 'body null (decode-elements elements
    #:inline-txexpr-proc (compose margin-figure-decoder numbered-note-decoder)
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

(register-block-tag 'pre)
(register-block-tag 'figure)

(define (author . words) `(p [(class "subtitle")] ,@words))

(define (newthought . words) `(span [[class "newthought"]] ,@words))

(define (doc-section title . text)
    `(section (h2 ,title) ,@text))

(define (margin-note . text)
		(define refid (uuid-generate))
		`(span (label [[for ,refid] [class "margin-toggle"]] 8853 )
			(input [[type "checkbox"] [id ,refid] [class "margin-toggle"]] )
			(span [[class "marginnote"]] ,@text)))

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
  `(div [[class "poem"]] (pre [[class "verse"]] ,@text))
)

(define (poem-heading . words)
    `(p [[class "poem-heading"]] ,@words))

(define (grey . text)
  `(span [[style "color: #777"]] ,@text)
)

(define (hyperlink url . words)
    `(a [[href ,url]] ,@words))
