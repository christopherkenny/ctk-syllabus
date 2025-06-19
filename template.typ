// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}

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
  suppress-bibliography: true,
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
      author: authors.map(author => to-string(author.name)).join(
        ", ",
        last: ", and ",
      ),
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
            if "location" in author [
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
  
  show cite.where(form: "normal"): it => cite(it.key, form: "full")
  
  show bibliography: this => {
    if suppress-bibliography {
      none
    } else {
      this
    }
  }

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

// start typst-show within ctk-syllabus

#show: doc => ctk-syllabus(
  title: [A Course Syllabus],
  subtitle: [Built in Quarto + Typst],
  authors: (
    ( name: [Christopher T. Kenny],
      last: [Kenny],
              email: [email\@university.edu],
              ),
    ),
  date: [Fall 2027],
  headerleft: "A Course Syllabus",
  headerright: "Dept 1234",
  font: ("Spectral",),
  codefont: ("Fira Code",),
  sectionnumbering: none,
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  linestretch: 1.25,
  linkcolor: "\#800000",
  suppress-bibliography: true,
  doc,
)

The introduction to a course usually introduces the major themes and goals of the course. This template aims to simplify the writing of a syllabus by providing a fast-rendering and clean style. It uses the normal fonts, sizes, and colors that the template author uses for writing.

This means that you should install the #link("https://fonts.google.com/specimen/Spectral")[Spectral] font. If it is installed, it will be used by default. Otherwise, you can set `mainfont: someotherfont` in the YAML header to use a different font.

Currently, for author information on the first page, only the name and email are used. If this is insufficient, please open an issue at #link("https://github.com/christopherkenny/ctk-syllabus");.

= Course meetings
<course-meetings>
Typically, information should be included on the course meetings.

== Lectures
<lectures>
Especially with regard to lecture expectations.

== Sections
<sections>
And section meetings, if applicable.

= Assignments
<assignments>
Grading schemes can be specified in a table format. Tables in this template work off of #link("https://quarto.org/docs/authoring/tables.html")[Quarto's markdown syntax];.

#figure([
#table(
  columns: 3,
  align: (left,right,right,),
  table.header([Assignment], [Points], [Percentage],),
  table.hline(),
  [Lecture attendance], [25], [12.5%],
  [Section attendance], [25], [12.5%],
  [Problem Sets], [70], [35%],
  [Prelim \#1], [20], [10%],
  [Prelim \#2], [20], [10%],
  [Final proposal], [10], [5%],
  [Final], [30], [15%],
)
], caption: figure.caption(
position: top, 
[
You can add a caption like this, but it's probably not necessary.
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-grading>


But, giving it a name like above is helpful so you can reference #ref(<tbl-grading>, supplement: [Table]) in the text.

= Course policies
<course-policies>
Then, it's probably helpful to add some policies.

== Use of Large Language Models
<use-of-large-language-models>
#quote(block: true)[
Using ChatGPT to complete assignments short-circuits the learning process, depriving students of the critical thinking and problem-solving skills that college is meant to develop. - ChatGPT, 4o
]

= Course Materials
<course-materials>
A list of course materials can be included here.

This template allows you to include a bibliography to reference. Citations in brackets will display as the full cite. Citations without brackets will display as a prose cite, so that you can reference it. General details about citations in Quarto can be found #link("https://quarto.org/docs/authoring/citations.html")[here];. The end bibliography is suppressed by default, so that you can include full cites in the full text.

== Monday, January 45th
<monday-january-45th>
- @kenny2023widespread

Note: In #cite(<kenny2023widespread>, form: "prose");, focus on the introduction and discussion of competitiveness.

#horizontalrule

 

#set bibliography(style: "chicago-author-date")


#bibliography("bibliography.bib")

