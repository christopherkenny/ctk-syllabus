# `ctk-syllabus` Format

The `ctk-syllabus` Quarto template is a syllabus template.
It is relatively simple, but provides a clean layout which prints full citations without a bibliography.

<!-- pdftools::pdf_convert('template.pdf', pages = 1) -->
![[template.qmd](template.qmd)](template_1.png)

## Installing

```bash
quarto use template christopherkenny/ctk-syllabus
```

This will install the format extension and create an example qmd file
that you can use as a starting place for your document.

## Using `ctk-syllabus`

This template is relatively simple and allows you to write with general Quarto syntax.
For an introduction to Quarto, see the [Quarto documentation](https://quarto.org/).

### Template YAML Options

- `title`: Your course's title
- `subtitle`: Your course's subtitle
- `author`: Author information. Provide subfields below:
  - `name`: Your name
  - `email`: Your email address
- `header-left`: A header on the top left
- `header-right`: A header on the top right
- `date`: The date of the syllabus
- `date-format`: To specify a non-real date, such as a semester, use this with `[Semester Year]`, e.g., `[Fall 2027]`

### Bibliography

This template is designed to allow you to include a `bib` file (or Hayagriva yaml format file) for citations.
The trick is that citations like:

`[@author2023]` will be transformed into a full citation in the text, but will not appear in a bibliography at the end of the document.
To use this, you need to set the `bibliography` option in the YAML header, e.g.:

```yaml

bibliography: bibliography.bib
```

Normal prose citations will still work, e.g. @smith2023 becomes `Smith (2023)`.

The bibliography printing is suppressed by default. You can turn this back on with:

```yaml
suppress-bibliography: false
```

### Fonts

By default, the `ctk-syllabus` format uses the Spectral font. This can be installed from [Google Fonts](https://fonts.google.com/specimen/Spectral).

To check that it is installed, run:

```
quarto typst fonts
```

Otherwise, set the yaml option `mainfont` to your preferred font, e.g. `mainfont: "Crimson Pro"`.

## License

This template is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
