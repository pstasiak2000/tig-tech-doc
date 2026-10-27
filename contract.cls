%%
%% contract.cls
%%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{contract}[2026/09/17 Contract document class]

\LoadClass[12pt]{article}

\RequirePackage[
    a4paper,
    margin=20mm
]{geometry}

\RequirePackage{enumitem}
\RequirePackage{titlesec}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{fancyhdr}
\RequirePackage{lastpage}
\RequirePackage{tikz}
\RequirePackage{titletoc}
%\RequirePackage[hidelinks]{hyperref}
\RequirePackage[
    colorlinks=true,
    urlcolor=contractlink,
    linkcolor=contractblue,
    citecolor=contractblue
]{hyperref}

%%% Font 
%\RequirePackage{mathpazo}
%\RequirePackage{newtxtext}
%\RequirePackage{libertine}
\RequirePackage{palatino}
%\RequirePackage{mathptmx}


% ============================================================
% GENERAL FORMATTING
% ============================================================

\urlstyle{same}

\setlength{\parindent}{0pt}
\setlength{\parskip}{0.5em}


\fancypagestyle{contractfirstpage}{%
    \fancyhf{}
    \renewcommand{\headrulewidth}{0pt}
    \renewcommand{\footrulewidth}{0pt}

    % Footer
    \fancyfoot[R]{%
        \small
        \color{contractgray}
        Page \thepage\ of \pageref{LastPage}
    }

}

\fancypagestyle{contractpages}{%
    \fancyhf{}

    % Header
    \fancyhead[L]{%
        \small
        \color{contractgray}
        \contract@title
    }

%    \fancyhead[R]{%
%        \small
%        \color{contractgray}
%        \contract@number
%    }

    % Footer
    \fancyfoot[R]{%
        \small
        \color{contractgray}
        Page \thepage\ of \pageref{LastPage}
    }

    % Lines
    \renewcommand{\headrulewidth}{0.4pt}
    \renewcommand{\footrulewidth}{0pt}
}

% ============================================================
% COLOURS
% ============================================================

\definecolor{contractblue}{RGB}{35,55,75}
\definecolor{contractlink}{RGB}{45,85,120}
\definecolor{contractgray}{RGB}{100,100,100}

% ============================================================
% SECTION FORMATTING
% ============================================================

\titleformat{\section}
    {\normalfont\Large\bfseries\color{contractblue}}
    {\thesection}
    {1em}
    {}

\titlespacing*{\section}
    {0pt}
    {2ex plus .5ex minus .2ex}
    {1.2ex plus .2ex}

% ============================================================
% CONTRACT COUNTERS
% ============================================================

\newcounter{contractitem}[section]
\newcounter{contractsubitem}[contractitem]

\renewcommand{\thecontractitem}{%
    \thesection.\arabic{contractitem}%
}

\renewcommand{\thecontractsubitem}{%
    \thecontractitem.\arabic{contractsubitem}%
}


% ============================================================
% CLAUSES
% ============================================================

% Treat [bold] as a text style, rather than as a replacement item label.
\def\contract@boldoption{bold}
\def\contract@styleditem[#1]{%
    \def\contract@itemoption{#1}%
    \ifx\contract@itemoption\contract@boldoption
        \@noitemargtrue
        \contract@baseitem[\@itemlabel]%
        \bfseries
    \else
        \contract@baseitem[#1]%
        \fontseries{\contract@itemseries}\selectfont
    \fi
    \ignorespaces
}

\def\contract@item[#1]{%
    \let\contract@itemhandler\contract@baseitem
    % Ordinary lists nested inside a clause keep their usual item syntax.
    \if@nmbrlist
        \ifnum\@listdepth=\contract@itemdepth\relax
            \let\contract@itemhandler\contract@styleditem
        \fi
    \fi
    \contract@itemhandler[#1]%
}

% Use LaTeX's item counter machinery so that \label immediately after
% \item sees the clause number. Unlike \usecounter, this does not reset
% the counter when a clauses/subclauses environment is reopened.
\newcommand*{\contract@listsetup}[1]{%
    \@nmbrlisttrue
    \def\@listctr{#1}%
    % Save the underlying item command only once when nesting clause environments.
    \ifx\@item\contract@item\else
        \let\contract@baseitem\@item
    \fi
    \edef\contract@itemdepth{\number\@listdepth}%
    \edef\contract@itemseries{\f@series}%
    \let\@item\contract@item
    % Allow natural page breaks within clauses and at list boundaries.
    % Keep the normal widow/orphan protection; do not box clause bodies.
    \interlinepenalty=0\relax
    \@beginparpenalty=0\relax
    \@itempenalty=0\relax
    \@endparpenalty=0\relax
}

\newenvironment{clauses}
{%
    \begin{list}
        {\textbf{\thecontractitem}}
        {%
            \contract@listsetup{contractitem}%
            \setlength{\labelwidth}{3.5em}%
            \setlength{\labelsep}{0.75em}%
            \setlength{\leftmargin}{2.10em}%
            \setlength{\itemindent}{0pt}%
            \setlength{\listparindent}{0pt}%
            \setlength{\parsep}{0pt}%
            \setlength{\itemsep}{0.75em}%
        }%
}
{%
    \end{list}%
}



% ============================================================
% TABLE OF CONTENTS
% ============================================================
%
% A section block in the contents looks like this:
%
%   [1]  Section title .................................. 4
%    |   Optional description set with \tocdescription
%    |   1.1  Subsection ................................ 4
%    |   1.2  Subsection ................................ 5
%    |
%   [2]  Next section ................................... 6
%
% The vertical bar hangs from the number box and runs down to just
% above the next box.  It is drawn with the framed package: the entries
% of a section are collected in a box that framed splits across pages
% where the page breaker would, so the bar ends with the last entry on
% one page and resumes with the first entry on the next.

\RequirePackage{framed}

\definecolor{contractpale}{RGB}{224,232,239}
\definecolor{contracttocbar}{RGB}{46,96,150}   % the vertical bar

% Every position in the contents derives from these lengths, so the
% number boxes, the bar, titles, descriptions and labels stay aligned
% when one of them is changed.
\newlength{\contracttocboxsize}      % side of the square number box
\newlength{\contracttocindent}       % left edge of titles, descriptions and subsection numbers
\newlength{\contracttocsublabel}     % width reserved for a subsection number
\newlength{\contracttocsubsublabel}  % width reserved for a subsubsection number
\newlength{\contracttocbarwidth}     % thickness of the vertical bar
\newlength{\contracttocbargap}       % gap between the bar and the number boxes above and below it
\newlength{\contracttocsectionskip}  % vertical space before a section entry
\newlength{\contracttocsubsep}       % vertical space between consecutive subsection entries
\newlength{\contracttocheadskip}     % vertical space above the "Contents" heading
\newlength{\contracttocdescabove}    % space between a section line and its description
\newlength{\contracttocdescbelow}    % space between a description and the first entry

\setlength{\contracttocboxsize}{24.5pt}
\setlength{\contracttocindent}{37.5pt}
\setlength{\contracttocsublabel}{28pt}
\setlength{\contracttocsubsublabel}{36pt}
\setlength{\contracttocbarwidth}{2.0pt}
\setlength{\contracttocbargap}{10pt}
\setlength{\contracttocsectionskip}{18pt}
\setlength{\contracttocsubsep}{2pt}
\setlength{\contracttocheadskip}{24pt}
\setlength{\contracttocdescabove}{0pt}
\setlength{\contracttocdescbelow}{6.pt}

% Font of the descriptions set with \tocdescription
\newcommand*{\contracttocdescfont}{\footnotesize\color{contractgray}}

% Section number in a pale blue square.  It hangs in the left margin so
% that a title which wraps aligns under its first line.
\newcommand*{\contract@tocsecbox}[1]{%
    \hspace*{-\contracttocindent}%
    \makebox[\contracttocindent][l]{%
        \tikz[baseline=(num.base)]{%
            \node[
                fill=contractpale,
                text=contractblue,
                minimum size=\contracttocboxsize,
                inner sep=0pt,
                font=\large\bfseries
            ] (num) {#1};
        }%
    }%
}

% Section entries.  \contract@tocsecskip is the space above the entry;
% it is smaller when the entry follows a bar, which already carries most
% of the separation.
\titlecontents{section}
    [\contracttocindent]
    {\addvspace{\contract@tocsecskip}%
     \advance\rightskip\z@\@plus1fil % ragged right if a title wraps
     \large\bfseries\color{contractblue}}
    {\contract@tocsecbox{\thecontentslabel}}
    {}
    {\hfill\contentspage}

% Subsections: number aligned with the section title, dotted leaders
\titlecontents{subsection}
    [\dimexpr\contracttocindent+\contracttocsublabel\relax]
    {\advance\rightskip\z@\@plus1fil
     \small\color{contractblue}}
    {\contentslabel{\contracttocsublabel}}
    {}
    {\titlerule*[0.6pc]{.}\contentspage}

% Subsubsections, if needed
\titlecontents{subsubsection}
    [\dimexpr\contracttocindent+\contracttocsublabel+\contracttocsubsublabel\relax]
    {\advance\rightskip\z@\@plus1fil
     \small\color{contractblue}}
    {\contentslabel{\contracttocsubsublabel}}
    {}
    {\titlerule*[0.6pc]{.}\contentspage}

% ---- Vertical bar beside each section block -------------------------

\newif\ifcontract@tocbar      % true while a bar is open
\newif\ifcontract@tocfirst    % true until the first section entry is set
\newdimen\contract@tocfha     % height of the first line inside a bar
% Local versions of \@nobreaktrue/false.  They must be macros: a literal
% \let\if@nobreak\iftrue inside a conditional branch would be miscounted
% as a nested \if while TeX skips that branch.
\def\contract@tocnobreaktrue{\let\if@nobreak\iftrue}
\def\contract@tocnobreakfalse{\let\if@nobreak\iffalse}
\def\contract@tocsecskip{\contracttocsectionskip}

% Open a bar (no-op if one is already open).  It starts
% \contracttocbargap below the preceding line, i.e. just under the box.
\newcommand*{\contract@tocbar@open}{%
    \ifcontract@tocbar\else
        \global\contract@tocbartrue
        \par\nointerlineskip
        \vskip\contracttocbargap
        \begingroup
            \contract@tocnobreaktrue % no page break between the box and its bar
            \begingroup\small\global\contract@tocfha\ht\strutbox\endgroup
            \setlength{\OuterFrameSep}{\z@}%
            % Count the depth of the last line when framed splits the box,
            % otherwise each page piece overflows by up to that depth.
            \splitmaxdepth\z@
            % framed packs each page piece to the space available, which is
            % nearly always underfull by less than a line; do not report it.
            \vbadness\@M
            % On a continuation page the first entry then sits exactly
            % where the first line of ordinary text would.
            \def\FrameHeightAdjust{\contract@tocfha}%
            % Draw the bar in the margin without taking any width.
            \def\FrameCommand##1{%
                \hbox{%
                    \hskip\dimexpr.5\contracttocboxsize-.5\contracttocbarwidth\relax
                    {\color{contracttocbar}\vrule\@width\contracttocbarwidth}%
                    \hskip-\dimexpr.5\contracttocboxsize+.5\contracttocbarwidth\relax
                    ##1%
                }%
            }%
            \MakeFramed{%
                \contract@tocnobreakfalse % page breaks are allowed between entries
                \linewidth\hsize
                \parskip\contracttocsubsep
            }%
    \fi
}

% Close the open bar, if any, extending it by #1 below the last entry.
\newcommand*{\contract@tocbar@close}[1]{%
    \ifcontract@tocbar
            \par\nobreak
            \vskip#1\relax
        \endMakeFramed
        \endgroup
        \global\contract@tocbarfalse
    \fi
}

% Start a new page unless at least #1 remains on the current one, so
% that a section entry is never left alone at the foot of a page.
\newcommand*{\contract@tocneedspace}[1]{%
    \par
    \penalty\z@ % runs the page builder so that \pagetotal is current
    \ifdim\pagegoal=\maxdimen\else
        \dimen@\pagegoal
        \advance\dimen@-\pagetotal
        \ifdim\dimen@<#1\relax
            \newpage
        \fi
    \fi
}

% Hook the entry commands: a section entry closes the previous bar, a
% subsection entry opens one.  Done at \begin{document} so that a
% \titlecontents in a preamble cannot undo the hooks.
\AtBeginDocument{%
    \let\contract@l@section\l@section
    \let\contract@l@subsection\l@subsection
    \let\contract@l@subsubsection\l@subsubsection
    \def\l@section{%
        \ifcontract@tocbar
            \contract@tocbar@close{\dimexpr\contracttocsectionskip-\contracttocbargap\relax}%
            \def\contract@tocsecskip{\contracttocbargap}%
        \else
            \def\contract@tocsecskip{\contracttocsectionskip}%
        \fi
        \ifcontract@tocfirst
            \global\contract@tocfirstfalse
        \else
            % room for the section line and at least two of its entries
            \contract@tocneedspace{5\baselineskip}%
        \fi
        \contract@l@section
    }%
    \def\l@subsection{%
        \ifnum 2>\c@tocdepth\else\contract@tocbar@open\fi
        \contract@l@subsection
    }%
    \def\l@subsubsection{%
        \ifnum 3>\c@tocdepth\else\contract@tocbar@open\fi
        \contract@l@subsubsection
    }%
}

% Description beneath a section entry, set in grey inside the bar.
\newcommand{\tocdescription}[1]{%
    \addtocontents{toc}{\protect\contract@tocdesc{#1}}%
}
\newcommand{\contract@tocdesc}[1]{%
    \contract@tocbar@open
    \begingroup
        % The bar starts \contracttocbargap below the section line and the
        % paragraph adds \contracttocsubsep; correct so that the text starts
        % \contracttocdescabove below the section line.
        \vskip\dimexpr\contracttocdescabove-\contracttocbargap-\contracttocsubsep\relax
        \parindent\z@
        \leftskip\contracttocindent
        \rightskip\@tocrmarg\@plus1fil
        \contracttocdescfont
        \noindent#1\par
        % The next entry adds \contracttocsubsep itself; make the whole gap
        % below the description \contracttocdescbelow.
        \nobreak
        \vskip\dimexpr\contracttocdescbelow-\contracttocsubsep\relax
    \endgroup
}

% Contents page
\newcommand{\contracttableofcontents}{%
    \begingroup
        \parindent\z@
        \parskip\z@
        % Keep the heading with the first entries rather than leaving it
        % alone at the foot of the title page.
        \contract@tocneedspace{10\baselineskip}%
        \addvspace{\contracttocheadskip}%
        \noindent
        {\fontsize{27}{32}\selectfont\bfseries\color{contractblue}Contents\par}%
        \nobreak
        \global\contract@tocfirsttrue
        \global\contract@tocbarfalse
        % The kernel's \@starttoc, plus closing the bar of the last
        % section once the file has been read.
        \begingroup
            \makeatletter
            \@input{\jobname.toc}%
            \contract@tocbar@close{\contracttocbargap}%
            \if@filesw
                \expandafter\newwrite\csname tf@toc\endcsname
                \immediate\openout\csname tf@toc\endcsname\jobname.toc\relax
            \fi
            \@nobreakfalse
        \endgroup
    \endgroup
    \clearpage
}


% ============================================================
% SUBCLAUSES
% ============================================================



\newenvironment{subclauses}
{%
    \begin{list}
        {\textbf{\thecontractsubitem}}
        {%
            \contract@listsetup{contractsubitem}%
            % More substantial indentation for sub-clauses
            \setlength{\labelwidth}{4.5em}%
            \setlength{\labelsep}{0.75em}%
            \setlength{\leftmargin}{4em}%
            \setlength{\itemindent}{0pt}%
            \setlength{\listparindent}{0pt}%
            \setlength{\parsep}{0pt}%
            \setlength{\itemsep}{0.5em}%
        }%
}
{%
    \end{list}%
}

% ============================================================
% DOCUMENT INFORMATION
% ============================================================


\newcommand{\contract@title}{}
\newcommand{\contract@subtitle}{}
\newcommand{\contract@date}{}
\newcommand{\contract@number}{}
\newcommand{\contract@parties}{}
\newcommand{\contract@logo}{}
\newcommand{\contract@url}{}


\newcommand{\titletext}[1]{%
    \renewcommand{\contract@title}{#1}%
}

\newcommand{\subtitletext}[1]{%
    \renewcommand{\contract@subtitle}{#1}%
}

\newcommand{\contractdate}[1]{%
    \renewcommand{\contract@date}{#1}%
}

\newcommand{\contractnumber}[1]{%
    \renewcommand{\contract@number}{#1}%
}

\newcommand{\parties}[1]{%
    \renewcommand{\contract@parties}{#1}%
}

\newcommand{\logo}[1]{%
    \renewcommand{\contract@logo}{#1}%
}

\newcommand{\contracturl}[1]{%
	\renewcommand{\contract@url}{\url{#1}}%
}

% ============================================================
% CONTRACT HEADER
% ============================================================

\newcommand{\makecontracttitle}{%
    \thispagestyle{contractfirstpage}%

    % ------------------------------------------------------------
    % First-page title block
    % ------------------------------------------------------------

    \noindent
    \begin{minipage}{\textwidth}
        \vspace{0pt}

        % Title + logo
        \noindent
        \begin{minipage}[c]{0.70\textwidth}
            \vspace{0pt}
            \raggedright

            {\fontsize{24}{28}\selectfont
             \bfseries
             \color{contractblue}
             \contract@title
            }

            \ifx\contract@subtitle\empty
            \else
                \par\vspace{0.15cm}
                {\large\color{contractgray}\contract@subtitle}
            \fi

            \par\vspace{0.35cm}

            \ifx\contract@number\empty
            \else
                {\small
                 \textbf{Document No.}\quad\contract@number
                }
            \fi
            %
            \ifx\contract@date\empty
            \else
                \hspace{1.5cm}
                {\small
                 \textbf{Date}\quad\contract@date
                }
            \fi
	
            \ifx\contract@url\empty
            \else
                \hspace{1.5cm}
                {\small
                 \textbf{Url}\quad\contract@url
                }
            \fi

        \end{minipage}%
        \hfill
        \begin{minipage}[c]{0.20\textwidth}
            \centering
            \ifx\contract@logo\empty
            \else
				\raisebox{0.5cm}{
                \includegraphics[
                    width=\linewidth,
                    height=2.5cm,
                    keepaspectratio
                ]{\contract@logo}
			}
			\fi
        \end{minipage}

        \vspace{0.45cm}

        % Divider
        \noindent
        {\color{contractblue}\rule{\textwidth}{1.2pt}}

        \vspace{0.5cm}

        % Parties
        \ifx\contract@parties\empty
        \else
            {\small\contract@parties}
        \fi

    \end{minipage}%

	\pagestyle{contractpages}

}


% ============================================================
% LEGAL DEFINITIONS
% ============================================================

\newif\ifcontractcompactdefs
\contractcompactdefsfalse

\newenvironment{definitions}[1][]
{%
    \contractcompactdefsfalse
    \def\contract@defsoption{#1}%
    \def\contract@compact{compact}%

    \ifx\contract@defsoption\contract@compact
        \contractcompactdefstrue
    \fi

    \begin{list}{}{%
        \setlength{\leftmargin}{0pt}%
        \setlength{\rightmargin}{0pt}%
        \setlength{\labelwidth}{0pt}%
        \setlength{\labelsep}{0pt}%
        \setlength{\itemindent}{0pt}%
        \setlength{\listparindent}{0pt}%
        \setlength{\parsep}{0pt}%
        \ifcontractcompactdefs
            \setlength{\itemsep}{0.35em}%
        \else
            \setlength{\itemsep}{0.8em}%
        \fi
    }%
}
{%
    \end{list}%
}

\newcommand{\definition}[2]{%
    \item
    \noindent
    \begin{minipage}[t]{0.27\textwidth}
        \vspace{0pt}
        \textbf{#1}
    \end{minipage}%
    \begin{minipage}[t]{0.73\textwidth}
        \vspace{0pt}
        #2
    \end{minipage}%
}
