◊(local-require racket/file racket/system)
◊(define latex-source ◊string-append{
    \documentclass{tufte-handout}
    \let\orignewcommand\newcommand  % store the original \newcommand
    \let\newcommand\providecommand  % make \newcommand behave like \providecommand
    \RequirePackage{verse}
    \let\newcommand\orignewcommand  % use the original `\newcommand` in future
    \makeatletter
    % Use the original definition from verse.sty
    \renewcommand*{\theHpoemline}{\arabic{verse@envctr}.\arabic{poemline}}
    \makeatother

    % Set up the spacing using fontspec features
    % See https://groups.google.com/d/topic/tufte-latex-commits/JcgGP-1R138/discussion
       \renewcommand\allcapsspacing[1]{{\addfontfeature{LetterSpace=15}#1}}
       \renewcommand\smallcapsspacing[1]{{\addfontfeature{LetterSpace=10}#1}}

    %\geometry{showframe}% for debugging purposes -- displays the margins

    \usepackage{amsmath}

    % Set the main and monospaced fonts
    %
    \setromanfont[Mapping=tex-text,Ligatures={Common, Rare, Discretionary},Numbers=OldStyle]{Adobe Caslon Pro}
    \setmonofont[Mapping=tex-text,Scale=MatchLowercase]{Triplicate T4c}

    % Set up the images/graphics package
    \usepackage{graphicx}
    \setkeys{Gin}{width=\linewidth,totalheight=\textheight,keepaspectratio}
    \graphicspath{{graphics/}}

    \title{◊(hash-ref metas 'chapter-num). ◊(hash-ref metas 'title)}
    % \author{ }
    % \date{◊(datestring->date (hash-ref metas 'doc-publish-date))}  % if the \date{} command is left out, the current date will be used

    % The following package makes prettier tables.  We're all about the bling!
    \usepackage{booktabs}

    % The units package provides nice, non-stacked fractions and better spacing
    % for units.
    \usepackage{units}

    % The fancyvrb package lets us customize the formatting of verbatim
    % environments.  We use a slightly smaller font.
    \usepackage{fancyvrb}
    \fvset{fontsize=\normalsize}

    % Small sections of multiple columns
    \usepackage{multicol}

    % Provides paragraphs of dummy text
    \usepackage{lipsum}

    % Make hyperlinks appear as footnotes
    % Taken from https://groups.google.com/forum/#!topic/pandoc-discuss/O-N0H1eBnVU
    \usepackage{url}
    \renewcommand{\href}[2]{#2\footnote{\raggedright\url{#1}}}
    \renewcommand\UrlFont{\rmfamily\itshape}

    % These commands are used to pretty-print LaTeX commands
    \newcommand{\doccmd}[1]{\texttt{\textbackslash#1}}% command name -- adds backslash automatically
    \newcommand{\docopt}[1]{\ensuremath{\langle}\textrm{\textit{#1}}\ensuremath{\rangle}}% optional command argument
    \newcommand{\docarg}[1]{\textrm{\textit{#1}}}% (required) command argument
    \newenvironment{docspec}{\begin{quote}\noindent}{\end{quote}}% command specification environment
    \newcommand{\docenv}[1]{\textsf{#1}}% environment name
    \newcommand{\docpkg}[1]{\texttt{#1}}% package name
    \newcommand{\doccls}[1]{\texttt{#1}}% document class name
    \newcommand{\docclsopt}[1]{\texttt{#1}}% document class option name

    \begin{document}

    \maketitle% this prints the handout title, author, and date

    ◊(apply string-append (cdr doc))
    \end{document}
    })


◊(define working-directory
    (build-path (current-directory) "pollen-latex-work"))
◊(unless (directory-exists? working-directory)
    (make-directory working-directory))
◊(define temp-ltx-path (build-path working-directory "temp.ltx"))
◊(display-to-file latex-source temp-ltx-path #:exists 'replace)
◊(define command (format "xelatex -output-directory='~a' '~a'" working-directory temp-ltx-path))
◊(if (system command)
    (file->bytes (build-path working-directory "temp.pdf"))
    (error "xelatex: rendering error"))
◊;(system (format "rm *.out; rm *.aux; rm *.log"))
