#lang pollen

◊(local-require racket/file racket/system pollen/file racket/string pollen/template)

◊(define main-pagetree (dynamic-require "../index.ptree" 'doc))

◊; This helper function makes the rest of the code in here more reusable.
◊(define (local-fix-path str)
  (string-replace str "flatland/" ""))

◊(define part1-chapters (children 'flatland/part-1.html main-pagetree))
◊(define part2-chapters (children 'flatland/part-2.html main-pagetree))

◊(define (my-markup-source str)
  (let* ([default-source (->markup-source-path (local-fix-path str))])
    (if (file-exists? default-source)
        default-source
        (string->path (string-replace (path->string default-source) ".html" ".poly")))))

◊(define (print-chapter sym)
   (define chapter-link  (symbol->string sym))
   (define chapter-path  (my-markup-source chapter-link))
   (define chapter-metas (dynamic-require chapter-path 'metas))
   (define chapter-doc   (dynamic-require chapter-path 'doc))

   (apply string-append `("\n\n\\chapter{"
     ,(select-from-metas 'title chapter-metas) "}\n\n"
     ,@(select-from-doc 'body chapter-doc)
     )))

◊string-append{
    \documentclass[notoc]{tufte-book}

    %\hypersetup{colorlinks}% uncomment this line if you prefer colored hyperlinks (e.g., for onscreen viewing)

    % Redesign the title page and provide \subtitle command
    % See https://groups.google.com/d/msg/tufte-latex/94mf-bDHdOk/6JtCYOsd1pAJ
    \newcommand{\subtitle}[1]{%
      \gdef\@subtitle{#1}%
      \gdef\plainsubtitle{#1}%
      \ifthenelse{\isundefined{\hypersetup}}%
        {}% hyperref is not loaded; do nothing
        {\hypersetup{pdftitle={\plaintitle: \plainsubtitle}}}% set the PDF metadata title
    }
    \renewcommand{\maketitlepage}{%
      \cleardoublepage%
      {%
      \begin{fullwidth}%
      \setlength{\parindent}{0pt}%
      \fontsize{20}{24}\selectfont\textit{\plainauthor}\par
      \vspace{1.75in}\fontsize{48}{54}\selectfont{\plaintitle}\par
      \vspace{0.25in}\fontsize{20}{24}\selectfont{\plainsubtitle}\par
      \vfill\fontsize{14}{14}\selectfont\textit{\plainpublisher}\par
      \end{fullwidth}%
      }%
      \thispagestyle{empty}%
      \clearpage%
    }

    %%
    % Book metadata
    \title{Flatland}
    \subtitle{A Romance of Many Dimensions}
    \author{Edwin A. Abbot}
    \publisher{Secretary of Foreign Relations}

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

    %\usepackage{amsmath}

    %%
    % Prints a trailing space in a smart way.
    \usepackage{xspace}

    % Set the main and monospaced fonts
    %
    \setromanfont[Mapping=tex-text,Ligatures={Common, Rare, Discretionary},Numbers=OldStyle]{Adobe Caslon Pro}
    \setmonofont[Mapping=tex-text,Scale=MatchLowercase]{Triplicate T4c}

    % For this book, sans-serif fonts would seem to be anachronistic.
    \setsansfont[Mapping=tex-text,Ligatures={Common, Rare, Discretionary},Numbers=OldStyle]{Adobe Caslon Pro}

    %%
    % For nicely typeset tabular material
    \usepackage{booktabs}

    % The fancyvrb package lets us customize the formatting of verbatim
    % environments.  We use a slightly smaller font.
    \usepackage{fancyvrb}
    \fvset{fontsize=\normalsize}

    % Set up the images/graphics package
    \usepackage{graphicx}
    \setkeys{Gin}{width=\linewidth,totalheight=\textheight,keepaspectratio}
    \graphicspath{{graphics/}}

    % The following package makes prettier tables.  We're all about the bling!
    \usepackage{booktabs}

    % Inserts a blank page
    \newcommand{\blankpage}{\newpage\hbox{}\thispagestyle{empty}\newpage}

    % The units package provides nice, non-stacked fractions and better spacing
    % for units.
    \usepackage{units}

    % Prints the month name (e.g., January) and the year (e.g., 2008)
    \newcommand{\monthyear}{%
      \ifcase\month\or January\or February\or March\or April\or May\or June\or
      July\or August\or September\or October\or November\or
      December\fi\space\number\year
    }

    % Prints an epigraph and speaker in sans serif, all-caps type.
    % \newcommand{\openepigraph}[2]{%
      %\sffamily\fontsize{14}{16}\selectfont
    %  \begin{fullwidth}
    %  \sffamily\large
    %  \begin{doublespace}
    %  \noindent\allcaps{#1}\\% epigraph
    %  \noindent\allcaps{#2}% author
    %  \end{doublespace}
    %  \end{fullwidth}
    % }

    %\usepackage{epigraph}

    %\makeatletter
    %  \let\@epipart\@endpart
    %  \renewcommand{\@endpart}{\thispagestyle{epigraph}\@epipart}
    %\makeatother

    \titleformat{\part}[display]
      {\Huge\itshape\filright\centering}
      {\partname~\thepart}
      {20pt}
      {}
    %\setlength\epigraphwidth{.6\textwidth}

    % Small sections of multiple columns
    \usepackage{multicol}

    % Provides paragraphs of dummy text
    %\usepackage{lipsum}

    % Make hyperlinks appear as footnotes
    % Taken from https://groups.google.com/forum/#!topic/pandoc-discuss/O-N0H1eBnVU
    \usepackage{url}
    % This bit ensures hyperlinks can have linebreaks on hyphens
    % see http://tex.stackexchange.com/questions/3033/forcing-linebreaks-in-url
    \makeatletter
    \g@addto@macro{\UrlBreaks}{\UrlOrds}
    \makeatother
    \renewcommand{\href}[2]{#2\footnote{\raggedright\url{#1}}}
    % optionally add \itshape to get italics, or replace \rmfamily with \ttfamily
    \renewcommand\UrlFont{\rmfamily\itshape}

    % These commands are used to pretty-print LaTeX commands
    %\newcommand{\doccmd}[1]{\texttt{\textbackslash#1}}% command name -- adds backslash automatically
    %\newcommand{\docopt}[1]{\ensuremath{\langle}\textrm{\textit{#1}}\ensuremath{\rangle}}% optional command argument
    %\newcommand{\docarg}[1]{\textrm{\textit{#1}}}% (required) command argument
    %\newenvironment{docspec}{\begin{quote}\noindent}{\end{quote}}% command specification environment
    %\newcommand{\docenv}[1]{\textsf{#1}}% environment name
    %\newcommand{\docpkg}[1]{\texttt{#1}}% package name
    %\newcommand{\doccls}[1]{\texttt{#1}}% document class name
    %\newcommand{\docclsopt}[1]{\texttt{#1}}% document class option name

    %\setcounter{secnumdepth}{0} % Uncomment to have chapters numbered

    % Generates the index
    %\usepackage{makeidx}
    %\makeindex

    \begin{document}

    % Front matter
    \frontmatter

    % r.1 blank page
    % \blankpage

    \maketitlepage

    % v.4 copyright page
    \newpage
    \begin{fullwidth}
    ~\vfill
    \thispagestyle{empty}
    \setlength{\parindent}{0pt}
    \setlength{\parskip}{\baselineskip}
    Originally written by \thanklessauthor, published 1884 by Seely \& Co.

    \par\smallcaps{This edition published \the\year\ by \thanklesspublisher}

    \par\smallcaps{thelocalyarn.com/excursus/secretary}

    \par This work has been identified as being free of known restrictions under copyright law, including all related and neighboring rights. You can copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission.

    \par The design and \smallcaps{PDF} data comprising this edition, which are owing almost wholly to the work of the Tufte-\LaTeX\xspace project’s contributors, are also released to the public domain. To the extent possible under law, Joel Dueck has waived all copyright and related or neighboring rights to this production of Edwin Abbot’s \textit{Flatland: A Romance of Many Dimensions}. This work is published from: United States \index{license}

    \par\textit{First printing, \monthyear}
    \end{fullwidth}

    % r.5 contents
    \tableofcontents

    %\listoffigures

    %\listoftables

    % r.7 dedication
    \cleardoublepage
    ~\vfill
    \begin{doublespace}
    \noindent\fontsize{18}{22}\selectfont\itshape
    \nohyphenation
    To the Inhabitants of \textsc{Space in General}
    and \textsc{H. C. in Particular} this Work is Dedicated
    by a Humble Native of Flatland in the Hope that
    Even as he was Initiated into the Mysteries
    of \textsc{Three} Dimensions, having been previously conversant
    with \textsc{Only Two,} so the Citizens of that Celestial Region
    may aspire yet higher and higher to the Secrets of
    \textsc{Four Five or Even Six} Dimensions thereby contributing
    to the Enlargement of \textsc{The Imagination}
    and the possible Development of that most rare and
    excellent Gift of \textsc{Modesty} among the Superior Races
    of \textsc{Solid Humanity}

    \end{doublespace}
    \vfill
    \vfill

    % r.9 introduction
    \cleardoublepage
    ◊(print-chapter 'flatland/00-preface.html)

    %%
    % Start the main matter (normal chapters)
    \mainmatter

    \part{This World}
    % This bit’s not working correctly
    % \epigraphhead[200]{\textit{"Be patient, for the world is broad and wide."}}
    
    ◊(apply string-append (map print-chapter part1-chapters))

    % \epigraphhead[200]{\textit{O brave new worlds \\ that have such people in them!}}
    \part{Other Worlds}

    ◊(apply string-append (map print-chapter part2-chapters))

    \end{document}
    }
