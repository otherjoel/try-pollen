#lang racket

#|
  Pollen preprocessor file to generate a valid Atom 1.0 XML feed from a given
  ptree. Based heavily on sample code sent to me by Matthew Butterick, with the
  following minor changes:
   - Use Atom instead of RSS 2.0, and RFC 3339 dates
   - Allow additional filtering to determine which pages should be included
   - Allow poly sources to be loaded if .html.pm source does not exist
   - Add a call to (flatten) to support nested pagetrees
   -
|#

(require xml
         pollen/template
         pollen/file
         racket/date
         racket/format)   ; For ~r

#|
  Really only need datestring->date from here. If you wanted to make this file
  entirely self-contained you could copy/paste that function's definition here.
  This is the function that interprets datestrings in the markup sources, in
  this case in the format "yyyy-mm-dd" or "yyyy-mm-dd hh:mm".
|#
(require (only-in "pollen.rkt" datestring->date))

#|
  Customizeable values
|#

(define opt-feed-ptree   "index.ptree")
(define opt-author-name  "Joel Dueck")         ; The name given for the feed's <author>
(define opt-author-email "joel@jdueck.net")    ; Email for the feed's <author>
(define opt-feed-title   "Secretary of Foreign Relations")
(define opt-feed-site    "http://tilde.club/~joeld/secretary/") ; This should end with /

#|
  You should customize the timezone/DST settings to match those of the
  computer that will be generating this feed.
|#
(define opt-feed-timezone -6)         ; Enter as an integer offset from GMT
(define adjust-daylight-savings? #t)  ; Determines whether we add 1 to the
                                      ; offset for times that fall within DST

#|
  Here you can specify the metas in your Pollen sources from which the feed
  will get certain values.
|#
(define sym-author  'author)
(define sym-pubdate 'doc-publish-date)
(define sym-updated 'doc-updated)
(define sym-title   'title)
(define sym-summary 'summary)

#|
  This is where you’d normally be told not to change anything below this point.
  But you are expected to know how this works and change it if you need to!
|#

#|
  Defining a struct generates "accessor" functions for each of the struct's
  elements.
|#
(struct rss-item (title author link summary pubdate updated) #:transparent)

(define (as-cdata string)
  (cdata #f #f (format "<![CDATA[~a]]>" string)))

(define (email-encode str)
  (map char->integer (string->list str)))

; Atom feeds require dates to be in RFC 3339 format
(define (date->rfc3339 d)
  (string-append (format "~a-~a-~aT~a:~a:~a~a:00"
                         (date-year d)
                         (~r (date-month d) #:min-width 2 #:pad-string "0")
                         (~r (date-day d) #:min-width 2 #:pad-string "0")
                         (~r (date-hour d) #:min-width 2 #:pad-string "0")
                         (~r (date-minute d) #:min-width 2 #:pad-string "0")
                         (~r (date-second d) #:min-width 2 #:pad-string "0")
                         (if (and (date-dst? d) adjust-daylight-savings?)
                             (~r (+ 1 opt-feed-timezone) #:min-width 2 #:pad-string "0")
                             (~r opt-feed-timezone #:min-width 2 #:pad-string "0")))))

#|
  make-rss
  This function builds a complete X-expression representation of an RSS feed using
  the Atom 1.0 format.
|#
(define/contract (make-feed-xexpr title link rss-items)
  (string? string? (listof rss-item?) . -> . xexpr?)
  (define items (for/list ([ri (in-list rss-items)])
                          (define item-url (string-append* (list link (rss-item-link ri))))
                          `(entry
                            (author (name ,(rss-item-author ri)))
                            (published ,(date->rfc3339 (datestring->date (rss-item-pubdate ri))))
                            (updated ,(date->rfc3339 (datestring->date (rss-item-updated ri))))
                            (title [[type "text"]] ,(rss-item-title ri))
                            (link [[rel "alternate"] [href ,item-url]])
                            (id ,item-url)
                            (summary [[type "html"]]
                                     ,(as-cdata (string-append "<p>" (rss-item-summary ri) "</p>"
                                                               (xexpr->string `(p (a ((href ,item-url))
                                                                                     "Click here to read "
                                                                                     (i ,(rss-item-title ri)))))))))))

  `(feed [[xml:lang "en-us"] [xmlns "http://www.w3.org/2005/Atom"]]
         (title ,title)
         (link [[rel "self"] [href ,link]])
         (generator [[uri "http://pollenpub.com/"]] "Pollen (custom feed)")
         (id ,link)
         (updated ,(date->rfc3339 (current-date)))
         (author
          (name ,opt-author-name)
          (email ,@(email-encode opt-author-email)))
         ,@items))

#|
  A slightly smarter version of ->markup-source-path. A file listed as
  "page.html" in a pagetree might have a source page.html.pm, but it might
  instead have a source "page.poly.pm". This function tests for the existence
  of the .html.pm version; if that fails, the .poly.pm version is returned.
|#
(define (get-markup-source str)
  (let* ([default-source (->markup-source-path str)])
    (if (file-exists? default-source)
        default-source
        (string->path (string-replace (path->string default-source) ".html" ".poly")))))

#|
  This is the function that determines whether to include a page in the feed.
  This version simply tests for the existence of a publish date in the metas.
|#
(define (syndicate? sym)
   (if (not (select-from-metas sym-pubdate
                               (dynamic-require (get-markup-source (symbol->string sym)) 'metas)))
       #f
       #t))

#|
  This is function is where the feed actually meets your pagetree file. All the
  pages in that file are loaded with `dynamic-require`, filtered with the
  syndicate? function (above) and their metas parsed out using the sym-* constants
  defined at the top of this file.
    If any of the looked-for metas in a given page are missing, they are filled
  in with defaults:
    - Title default is a formatted version of the pubdate
    - Author default is the feed author defined at the top of this file
    - Summry default is "No summary given"
    - Updated time defaults to the pub date
    - Pub date has no default, it’s required!
|#
(define feed-item-structs
  (let* ([rss-items (filter syndicate? (flatten (cdr (dynamic-require opt-feed-ptree 'doc))))]
         [rss-unsorted-item-structs (map
                                     (λ(ri)
                                       (define item-link (symbol->string ri))
                                       (define item-path (get-markup-source item-link))
                                       (define item-metas (dynamic-require item-path 'metas))
                                       (define item-author (or (select-from-metas sym-author item-metas) opt-author-name))
                                       (define item-summary (or (select-from-metas sym-summary item-metas) "(No summary given)"))
                                       (define item-pubdate (select-from-metas sym-pubdate item-metas))
                                       (define item-updated (or (select-from-metas sym-updated item-metas) item-pubdate))
                                       (define item-title (or (select-from-metas sym-title item-metas)
                                                              (date->string (datestring->date item-pubdate))))
                                       (rss-item item-title item-author item-link item-summary item-pubdate item-updated))
                                     rss-items)])
    ;; sort from latest to earliest. Doesn't rely on order in ptree file, but rather pub date in source.
    (sort rss-unsorted-item-structs > #:key (λ(i) (date->seconds (datestring->date (rss-item-pubdate i)))))))

; Generates a string for the whole RSS feed
(define/contract (complete-feed rss-xexpr)
  (xexpr? . -> . string?)
  (string-append "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                 (xexpr->string rss-xexpr)))

#|
  Now we snap it all together. Because this file uses "lang racket" instead of
  "lang pollen" we have to manually take some steps that Pollen would normally
  take for us: defining 'doc and 'metas, and displaying the output (which will
  be stored in the target file).
|#
(provide doc metas)
(define rss-xpr (make-feed-xexpr opt-feed-title opt-feed-site feed-item-structs))
(define doc (complete-feed rss-xpr))
(define metas (hash))
(module+ main
  (display doc))
