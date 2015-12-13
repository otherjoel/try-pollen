◊(local-require racket/file racket/system)
◊(define latex-source ◊string-append{
    \documentclass[a4paper,12pt]{letter}
    \begin{document}
    ◊(apply string-append (cdr doc))
    \end{document}})

    
◊(define working-directory
    (build-path (current-directory) "pollen-latex-work"))
◊(unless (directory-exists? working-directory)
    (make-directory working-directory))
◊(define temp-ltx-path (build-path working-directory "temp.ltx"))
◊(display-to-file latex-source temp-ltx-path #:exists 'replace)
◊(define command (format "pdflatex '~a'" temp-ltx-path))
◊(if (system command)
    (file->bytes (build-path working-directory "temp.pdf"))
    (error "pdflatex: rendering error"))
