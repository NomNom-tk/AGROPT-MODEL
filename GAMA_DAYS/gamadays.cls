%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Document style for Gama Days submissions
% Author : Dominique.Longin@irit.fr
% Date : Jan. 15, 2020
% Version : V1.0
% Update : creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{gamadays}[2020/01/05 V1.0 Document class for Gama Days submissions]

\LoadClass[10pt]{article}

% ---------------------------------
% PACKAGES
% ---------------------------------

\usepackage{calc}
\usepackage{xspace}
\usepackage{times}
\usepackage{geometry}
\usepackage{titlesec}
\usepackage[english]{babel}

% ---------------------------------
% LAYOUT
% ---------------------------------



\flushbottom

% taille du papier et de la zone de texte
% hauteur contient un nombre entier de lignes
\geometry{a4paper,text={6.875in,63\baselineskip},centering}

% espacement entre les colonnes
\setlength{\columnsep}{1cm}

% pas d'indentation des paragraphes
\setlength{\parindent}{0em}

% style des pages
\pagestyle{empty}

% gestion automatique des dépassements dans les marges
\sloppy

% ---------------------------------
% SHORTHANDS
% ---------------------------------

\providecommand{\up}[1]{\textsuperscript{#1}}

% ---------------------------------
% INSERTS
% ---------------------------------

% espacement des sections
\titlespacing{\section}% command
{0em}% left
{*1}% before
{*1}% after
[0em]% right-sep margin increasing

% espacement des sous-sections
\titlespacing{\subsection}% command
{0em}% left
{*1}% before
{*0.7}% after
[0em]% right-sep margin increasing

% espacement des sous-sous-sections
\titlespacing{\subsubsection}% command
{0em}% left
{*0.8}% before
{*0.5}% after
[0em]% right-sep margin increasing

% espacement des sous-sous-sections
\titlespacing{\paragraph}% command
{0em}% left
{*0.5}% before
{*0.5}% after
[0em]% right-sep margin increasing

% résumé en anglais
\renewenvironment{abstract}{%
    \subsection*{Abstract}
    \thispagestyle{empty}
}{%
}

% mots-clés en français
\newenvironment{keywords}{\subsection*{Keywords}}{}

% additionnal content
\newenvironment{additionnalMaterial}{%
    \subsection*{Additional material}
}{}

