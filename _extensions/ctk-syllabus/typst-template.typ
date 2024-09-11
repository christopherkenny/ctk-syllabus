// better way to avoid escape characters, rather than doing a regex for \\@
#let to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// ctk-syllabus definition starts here
// everything above is inserted by Quarto

#let ctk-syllabus(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  headerleft: none,
  headerright: none,
  cols: 1,
  margin: (x: 1in, y: 1in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  mathfont: "New Computer Modern Math",
  codefont: "DejaVu Sans Mono",
  sectionnumbering: "1.1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  linestretch: 1,
  linkcolor: "#800000",
  doc,
) = {

  if headerleft == none {
    headerleft = hide("left")
  }
  if headerright == none {
    headerright = hide("right")
  }

  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
        header: [
      #headerleft
      #h(1fr) #headerright
      #v(-8pt)
      #line(length: 100%)
    ],
    header-ascent: 30%,
  )

  set par(
    justify: true,
    leading: 1.15 * 0.65em,
  )
  // Font stuff
  set text(
    lang: lang,
    region: region,
    font: font,
    size: fontsize,
  )
  show math.equation: set text(font: mathfont)
  show raw: set text(font: codefont)


  show figure.caption: it => [
    #v(-1em)
    #align(left)[
      #block(inset: 1em)[
        #text(weight: "bold")[
          #it.supplement
          #context it.counter.display(it.numbering)
        ]
        #it.separator
        #it.body
      ]
    ]
  ]


  set heading(numbering: sectionnumbering)

  // metadata
  set document(
    title: title,
    date: auto,
  )

  if (authors != none) {
    set document(
        author: authors.map(author => to-string(author.name)).join(", ", last: ", and "),
    )
  }

  // show rules
  // show figure.where(kind: "quarto-float-fig"): set figure.caption(position: top)

  show link: this => {
    if type(this.dest) != label {
      text(this, fill: rgb(linkcolor.replace("\\#", "#")))
    } else {
      text(this, fill: rgb("#0000CC"))
    }
  }

  show ref: this => {
    text(this, fill: rgb("#640872"))
  }

  // start article content
  if title != none {
    align(center)[
      #block(inset: 2em)[
        #text(weight: "bold", size: 30pt)[
          #title
        ]
        #if subtitle != none {
          linebreak()
          text(subtitle, size: 24pt, weight: "semibold")
        }
      ]
    ]
  }


  // author spacing based on Quarto ieee licenced CC0 1.0 Universal
  // https://github.com/quarto-ext/typst-templates/blob/main/ieee/_extensions/ieee/typst-template.typ
  if (authors != none) {
    for i in range(calc.ceil(authors.len() / 3)) {
      let end = calc.min((i + 1) * 3, authors.len())
      let slice = authors.slice(i * 3, end)
      grid(
        columns: slice.len() * (1fr,),
        gutter: 12pt,
        ..slice.map(author => align(
          center,
          {
            text(weight: "bold", author.name)
            if "orcid" in author [
              #link("https://https://orcid.org/" + author.orcid)[
                #box(height: 9pt, image("ORCIDiD.svg"))
              ]
            ]
            if "department" in author [
              \ #author.department
            ]
            if "university" in author [
              \ #author.university
            ]
            if location in author [
              \ #author.location
            ]
            if "email" in author [
              \ #link("mailto:" + to-string(author.email))
            ]
          },
        ))
      )

      v(20pt, weak: true)
    }
    }

  if date != none {
    align(center)[#block(inset: 1em)[
        #date
      ]]
  }

  align(center)[
    #line(length: 80%)
  ]

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
      #outline(
        title: toc_title,
        depth: toc_depth,
        indent: toc_indent,
      )
    ]
  }

  set par(
    justify: true,
    first-line-indent: 1em,
    leading: linestretch * 0.65em,
  )

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none,
)
