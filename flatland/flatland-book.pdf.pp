#lang racket
(local-require racket/file racket/system)

#|
  This file is included as a proof-of-concept for generating binary files
  in a Pollen preprocessor context, but its usefulness is limited. Note that
  it depends on your having already generated the LaTeX source by rendering the
  separate flatland-book.ltx.pp file. Also, Pollen doesn’t automatically detect
  when that file has changed, so if you make changes elsewhere in the project,
  they won’t be reflected in this file’s output PDF unless you force Pollen to
  regenerate it, either by running "touch flatland-book.pdf.pp" or by deleting
  Pollen’s cache.
|#

(define working-directory
    (build-path (current-directory) "pollen-latex-work"))
(unless (directory-exists? working-directory)
    (make-directory working-directory))
(define temp-ltx-path (build-path (current-directory) "flatland-book.ltx"))
(define command (format "xelatex -output-directory='~a' '~a'" working-directory temp-ltx-path))
(define doc
    ; We run the command once, then if successful we run it again.
    ; This is because two passes are required to ensure the TOC is updated.
    (if (and (system command) (system command))
        (file->bytes (build-path working-directory "flatland-book.pdf"))
        (error "xelatex: rendering error")))
(define metas (hash))
(provide doc metas)

(module+ main
  (display doc))
