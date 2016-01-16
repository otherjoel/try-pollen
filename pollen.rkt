#lang racket

(require pollen/decode
         pollen/world       ; For world:current-poly-target
         pollen/file
         txexpr
         pollen/tag
         pollen/template
         pollen/pagetree
         racket/date
         libuuid)            ; for uuid-generate

; We want srfi/13 for string-contains but need to avoid collision between
; its string-replace function and the one in racket/string
(require (only-in srfi/13 string-contains))

(provide add-between
         attr-ref
         attrs-have-key?
         make-txexpr
         string-contains)
(provide (all-defined-out))

(module config racket/base
    (provide (all-defined-out))
    (define poly-targets '(html ltx pdf)))

(define (pdfable? file-path)
  (string-contains? file-path ".poly"))

(define (pdfname page) (string-replace (path->string (file-name-from-path page))
                                       "poly.pm" "pdf"))

(define (root . elements)
  (case (world:current-poly-target)
    [(ltx pdf)
     (make-txexpr 'body null
                   (decode-elements elements
                                    ;#:txexpr-elements-proc detect-paragraphs
                                    #:inline-txexpr-proc (compose1 txt-decode hyperlink-decoder)
                                    #:string-proc (compose1 ltx-escape-str smart-quotes smart-dashes)
                                    #:exclude-tags '(script style figure)))]

    [else
      (define first-pass (decode-elements elements
                                          #:txexpr-elements-proc (compose1 detect-paragraphs splice)
                                          #:exclude-tags '(script style figure)))
      (make-txexpr 'body null
                   (decode-elements first-pass
                                    #:inline-txexpr-proc hyperlink-decoder
                                    #:string-proc (compose1 smart-quotes smart-dashes)
                                    #:exclude-tags '(script style)))]))

#|
`splice` lifts the elements of an X-expression into its enclosing X-expression.
|#
(define (splice xs)
  (define tags-to-splice '(splice-me))
  (apply append (for/list ([x (in-list xs)])
                  (if (and (txexpr? x) (member (get-tag x) tags-to-splice))
                      (get-elements x)
                      (list x)))))

; Escape $,%,# and & for LaTeX
; The approach here is rather indiscriminate; I’ll probably have to change
; it once I get around to handline inline math, etc.
(define (ltx-escape-str str)
  (regexp-replace* #px"([$#%&])" str "\\\\\\1"))

#|
`txt` is called by root when targeting LaTeX/PDF. It converts all elements inside
a ◊txt tag into a single concatenated string. ◊txt is not intended to be used in
normal markup; its sole purpose is to allow other tag functions to return LaTeX
code as a valid X-expression rather than as a string.
|#
(define (txt-decode xs)
    (if (eq? 'txt (get-tag xs))
        (apply string-append (get-elements xs))
        xs))

#|
◊numbered-note, ◊margin-figure, ◊margin-note:
  These three tag functions produce markup for "sidenotes" in HTML and LaTeX.
  In our LaTeX template, any hyperlinks also get auto-converted to numbered
  sidenotes, which is kinda neat. Unfortunately, this also means that when
  targeting LaTeX, you can't have a hyperlink inside a sidenote since that would
  equate to a sidenote within a sidenote, which causes Problems.

  We handle this by not using a normal tag function for hyperlinks. Instead,
  within these three tag functions we call latex-no-hyperlinks-in-margin to
  filter out any hyperlinks inside these tags (for LaTeX/PDF only). Then the
  root function uses a separate decoder to properly handle any hyperlinks that
  sit outside any of these three tags.
|#

(define (numbered-note . text)
    (define refid (uuid-generate))
    (case (world:current-poly-target)
      [(ltx pdf)
       `(txt "\\footnote{" ,@(latex-no-hyperlinks-in-margin text) "}")]
      [else
        `(splice-me (label [[for ,refid] [class "margin-toggle sidenote-number"]])
                    (input [[type "checkbox"] [id ,refid] [class "margin-toggle"]])
                    (span [(class "sidenote")] ,@text))]))

(define (margin-figure source . caption)
    (define refid (uuid-generate))
    (case (world:current-poly-target)
      [(ltx pdf)
       `(txt "\\begin{marginfigure}"
             "\\includegraphics{" ,source "}"
             "\\caption{" ,@(latex-no-hyperlinks-in-margin caption) "}"
             "\\end{marginfigure}")]
      [else
        `(splice-me (label [[for ,refid] [class "margin-toggle"]] 8853)
                    (input [[type "checkbox"] [id ,refid] [class "margin-toggle"]])
                    (span [[class "marginnote"]] (img [[src ,source]]) ,@caption))]))

(define (margin-note . text)
    (define refid (uuid-generate))
    (case (world:current-poly-target)
      [(ltx pdf)
       `(txt "\\marginnote{" ,@(latex-no-hyperlinks-in-margin text) "}")]
      [else
        `(splice-me (label [[for ,refid] [class "margin-toggle"]] 8853)
                    (input [[type "checkbox"] [id ,refid] [class "margin-toggle"]])
                    (span [[class "marginnote"]] ,@text))]))
#|
  This function is called from within the margin/sidenote functions when
  targeting Latex/PDF, to filter out hyperlinks from within those tags.
  (See notes above)
|#
(define (latex-no-hyperlinks-in-margin txpr)
  ; First define a local function that will transform each ◊hyperlink
  (define (cleanlinks inline-tx)
      (if (eq? 'hyperlink (get-tag inline-tx))
        `(txt ,@(cdr (get-elements inline-tx))
              ; Return the text with the URI in parentheses
              " (\\url{" ,(ltx-escape-str (car (get-elements inline-tx))) "})")
        inline-tx)) ; otherwise pass through unchanged
  ; Run txpr through the decode-elements wringer using the above function to
  ; flatten out any ◊hyperlink tags
  (decode-elements txpr #:inline-txexpr-proc cleanlinks))

(define (hyperlink-decoder inline-tx)
  (define (hyperlinker url . words)
    (case (world:current-poly-target)
      [(ltx pdf) `(txt "\\href{" ,url "}" "{" ,@words "}")]
      [else `(a [[href ,url]] ,@words)]))

  (if (eq? 'hyperlink (get-tag inline-tx))
      (apply hyperlinker (get-elements inline-tx))
      inline-tx))

(register-block-tag 'pre)
(register-block-tag 'figure)
(register-block-tag 'center)
(register-block-tag 'blockquote)

(define (p . words)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt ,@words)]
    [else `(p ,@words)]))

(define (blockquote . words)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\begin{quote}" ,@words "\\end{quote}")]
    [else `(blockquote ,@words)]))

(define (newthought . words)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\newthought{" ,@words "}")]
    [else `(span [[class "newthought"]] ,@words)]))

(define (smallcaps . words)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\smallcaps{" ,@words "}")]
    [else `(span [[class "smallcaps"]] ,@words)]))

(define ∆ smallcaps)

(define (center . words)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\begin{center}" ,@words "\\end{center}")]
    [else `(div [[style "text-align: center"]] ,@words)]))

(define (doc-section title . text)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\section*{" ,title "}" ,@text)]
    [else `(section (h2 ,title) ,@text)]))

(define (index-entry entry . text)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\index{" ,entry "}" ,@text)]
    [else
      (case (apply string-append text)
        [("") `(a [[id ,entry] [class "index-entry"]])]
        [else `(a [[id ,entry] [class "index-entry"]] ,@text)])]))

(define (figure source . caption)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\begin{figure}"
                     "\\includegraphics{" ,source "}"
                     "\\caption{" ,@(latex-no-hyperlinks-in-margin caption) "}"
                     "\\end{figure}")]
    [else `(figure (img [[src ,source]]) (figcaption ,@caption))]))

(define (fullwidthfigure source . caption)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\begin{figure}"
                     "\\includegraphics[width=\\linewidth]{" ,source "}"
                     "\\caption{" ,@caption "}"
                     "\\end{figure}")]
    [else `(figure [[class "fullwidth"]] (img [[src ,source] [alt ,@caption]]) (figcaption ,@caption))]))

(define (code . text)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\texttt{" ,@text "}")]
    [else `(span [[class "code"]] ,@text)]))

(define (blockcode . text)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\begin{verbatim}" ,@text "\\end{verbatim}")]
    [else `(pre [[class "code"]] ,@text)]))

(define (ol . elements)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\begin{enumerate}" ,@elements "\\end{enumerate}")]
    [else `(ol ,@elements)]))

(define (ul . elements)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\begin{itemize}" ,@elements "\\end{itemize}")]
    [else `(ul ,@elements)]))

(define (li . elements)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\item " ,@elements)]
    [else `(li ,@elements)]))

(define (sup . text)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\textsuperscript{" ,@text "}")]
    [else `(sup ,@text)]))

#|
  Just because we can, here's a tag function for typesetting the LaTeX logo
  in both HTML and (obv.) LaTeX.
|#
(define (Latex)
  (case (world:current-poly-target)
    [(ltx pdf)
     `(txt "\\LaTeX\\xspace")]      ; \xspace adds a space if the next char is not punctuation
    [else `(span [[class "latex"]]
             "L"
             (span [[class "latex-sup"]] "a")
             "T"
             (span [[class "latex-sub"]] "e")
             "X")]))

; In HTML these two tags won't look much different. But when outputting to
; LaTeX, ◊i will italicize multiple blocks of text, where ◊emph should be
; used for words or phrases that are intended to be emphasized. In LaTeX,
; if the surrounding text is already italic then the emphasized words will be
; non-italicized.
(define (i . text)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "{\\itshape " ,@text "}")]
    [else `(i ,@text)]))

(define (emph . text)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\emph{" ,@text "}")]
    [else `(em ,@text)]))

#|
Typesetting poetry in LaTeX or HTML. HTML uses a straightforward <pre> with
appropriate CSS. In LaTeX we explicitly specify the longest line for centering
purposes, and replace double-spaces with \vin to indent lines.
|#
(define verse
    (lambda (#:title [title ""] #:italic [italic #f] . text)
     (case (world:current-poly-target)
      [(ltx pdf)
       (define poem-title (if (non-empty-string? title)
                              (apply string-append `("\\poemtitle{" ,title "}"))
                              ""))

       ; Replace double spaces with "\vin " to indent lines
       (define poem-text (string-replace (apply string-append text) "  " "\\vin "))

       ; Optionally italicize poem text
       (define fmt-text (if italic (format "{\\itshape ~a}" (latex-poem-linebreaks poem-text))
                                   (latex-poem-linebreaks poem-text)))

       `(txt "\n\n" ,poem-title
             "\n\\settowidth{\\versewidth}{"
             ,(longest-line poem-text)
             "}"
             "\n\\begin{verse}[\\versewidth]"
             ,fmt-text
             "\\end{verse}\n\n")]
      [else
        (define pre-attrs (if italic '([class "verse"] [style "font-style: italic"])
                                     '([class "verse"])))
        (define poem-xpr (if (non-empty-string? title)
                             `(pre ,pre-attrs
                                   (p [[class "poem-heading"]] ,title)
                                   ,@text)
                             `(pre ,pre-attrs
                                   ,@text)))
        `(div [[class "poem"]] ,poem-xpr)])))
#|
Helper function for typesetting poetry in LaTeX. Poetry should be centered
on the longest line. Browsers will do this automatically with proper CSS but
in LaTeX we need to tell it what the longest line is.
|#
(define (longest-line str)
  (first (sort (string-split str "\n")
               (λ(x y) (> (string-length x) (string-length y))))))

(define (latex-poem-linebreaks text)
  (regexp-replace* #px"([^[:space:]])\n(?!\n)" ; match newlines that follow non-whitespace
                                               ; and which are not followed by another newline
                   text
                   "\\1 \\\\\\\\\n"))

(define (grey . text)
  (case (world:current-poly-target)
    [(ltx pdf) `(txt "\\textcolor{gray}{" ,@text "}")]
    [else `(span [[style "color: #777"]] ,@text)]))

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

; Modified from https://github.com/malcolmstill/mstill.io/blob/master/blog/pollen.rkt
; Converts a string "2015-12-19" or "2015-12-19 16:02" to a Racket date value
(define (datestring->date datetime)
  (match (string-split datetime)
    [(list date time) (match (map string->number (append (string-split date "-") (string-split time ":")))
                        [(list year month day hour minutes) (seconds->date (find-seconds 0
                                                                                         minutes
                                                                                         hour
                                                                                         day
                                                                                         month
                                                                                         year))])]
    [(list date) (match (map string->number (string-split date "-"))
                   [(list year month day) (seconds->date (find-seconds 0
                                                                       0
                                                                       0
                                                                       day
                                                                       month
                                                                       year))])]))
#|
  Converts a string "2015-12-19" or "2015-12-19 16:02" to a string
  "Saturday, December 19th, 2015" by way of the datestring->date function above
|#
(define (pubdate->english datetime)
  (date->string (datestring->date datetime)))
