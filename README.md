# CPB Beamer template

A CPB-style Beamer theme for presentations. You can use it in two ways:

- **LaTeX / Overleaf**: write slides directly in LaTeX.
- **R Markdown**: write slides in Markdown and knit them to a PDF in CPB style.

Both use the same style file, `cpb-beamer.sty`.

## Folder structure

```
.
├── cpb-beamer.sty              CPB style: colours, fonts, title/agenda/section/end slides,
│                               header, footer, disclaimer and source commands (shared)
├── cpb-beamer-template.tex     LaTeX example presentation (main document for Overleaf)
├── references.bib              Example bibliography
├── Images/                     Template images (cover, backgrounds, logo)
├── Figures/                    Your own figures (subfolders allowed)
├── Tables/                     Your own tables (.tex files used with \input)
├── rmarkdown/                  R Markdown theme components
│   ├── cpb-rmarkdown-template.tex   Pandoc template
│   ├── cpb-blocks.lua               > [!BLOCK] callouts
│   ├── cpb-diagrams.lua             > [!DIAGRAM] callouts
│   ├── cpb-split.lua                {.split} two-column slides
│   ├── cpb-slides.lua               CPB slide layouts and figures
│   └── examples/
│       ├── rmarkdown-template.rmd   Full example of all features
│       └── split-example.rmd        Two-column slides (PDF and HTML)
└── docs/                       Rendered example PDFs (preview)
```

`Images/` is for the template itself (place alternative backgrounds here).
`Figures/` and `Tables/` are for your project's content.

## LaTeX / Overleaf

1. Upload this repository as a ZIP to a new Overleaf project, or copy
   the files into an existing project.
2. Set `cpb-beamer-template.tex` as the main document.
3. Compile with pdfLaTeX and BibTeX (Overleaf runs the bibliography automatically).

Edit `cpb-beamer-template.tex` to write your presentation. You only need the
root files and the folders `Images/`, `Figures/` and `Tables/`; the
`rmarkdown/` and `docs/` folders can be left out.

### Settings

```latex
\title[Short title]{Main title}
\author{F. Author, S. Author}
\disclaimer{Disclaimer}
\date{\today}
\cpbfooter{F. Author, S. Author}
\cpbtitelafbeelding{Images/cover_bg.png} % Image on the cover slide
```

Language:

```latex
\usepackage[dutch,english]{babel}  % Use [english,dutch]{babel} for Dutch date formatting
```

Captions switch automatically between Figuur/Figure and Tabel/Table.

Navigation buttons:

```latex
% \cpbbutton{destination}{text}{position}
% Position options: inline, bottom left, bottom right
```

## R Markdown

Requirements: R with the `rmarkdown` package, Pandoc (bundled with RStudio)
and a LaTeX distribution with pdfLaTeX (for example TinyTeX).

Open `rmarkdown/examples/rmarkdown-template.rmd` in RStudio and click **Knit**,
or run from the repository root:

```r
rmarkdown::render("rmarkdown/examples/rmarkdown-template.rmd")
rmarkdown::render("rmarkdown/examples/split-example.rmd", output_format = "all")
```

To start your own presentation, copy one of the examples into
`rmarkdown/examples/` (or `rmarkdown/`) and edit it. The template finds
`cpb-beamer.sty`, `Images/`, `Figures/` and `Tables/` from either folder.
The paths to the Pandoc template and Lua filters in the YAML header are
relative to the `.rmd` file (`../` from `rmarkdown/examples/`); adjust them
if you place your file elsewhere. Image paths in Markdown (`![](...)`) are
also relative to the `.rmd` file, for example `../../Figures/plot.png`.

The comment at the top of `rmarkdown-template.rmd` lists all slide options:
CPB title/section/agenda/end slides, `{.split}` two-column slides,
`> [!BLOCK]` blocks and `> [!DIAGRAM]` diagrams.

Rendered output (`.tex`, `.pdf`, `.html`, `.log`) is ignored by git. Example
results are in `docs/`.
