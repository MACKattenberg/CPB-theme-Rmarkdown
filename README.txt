CPB Beamer template

Upload this ZIP as a new Overleaf project (or copy the entire overleaf project in case you access from there), or replace the corresponding files
in your existing project. Set cpb-beamer-template.tex as the main document.
Use pdfLaTeX and BibTeX (Overleaf runs the bibliography automatically).

cpb-beamer.sty: CPB colours, fonts, title/agenda/section/end slides, header,
footer, disclaimer and source commands.
cpb-beamer-template.tex: document class, language, content packages, metadata
and all example slides. Edit this file to write your presentation.
Images/: images used in the template. In case you want other backgrounds, place them here.
Figures/: Suggested folder for the project figures that are not for the background of the slides
Tables/ and references.bib: original table and bibliography.

User inputs:

\title[Short title]{Main titel}
\author{F. Author, S. Author}
\disclaimer{Disclaimer}
\date{\today}
\cpbfooter{F. Author, S. Author}
\cpbtitelafbeelding{Images/figuur.png} % Title of the fiure you want in the cover

Language:

\usepackage[dutch,english]{babel}  % Gebruik [english, dutch]{babel} voor nederlandse datumnotatie

The captions will alternate from Figuur/Figure and Tabel/Table automatically

Navigation buttons:
% Command: \cpbbutton{destination}{text}{position}
% Position options: inline, bottom left, bottom right
