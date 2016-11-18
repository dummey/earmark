defmodule Functional.Scanner.LineTypeTest do
  use ExUnit.Case

  alias Earmark.Line

  id1 = ~S{[ID1]: http://example.com  "The title"}
  id2 = ~S{[ID2]: http://example.com  'The title'}
  id3 = ~S{[ID3]: http://example.com  (The title)}
  id4 = ~S{[ID4]: http://example.com}
  id5 = ~S{[ID5]: <http://example.com>  "The title"}
  id6 = ~S{ [ID6]: http://example.com  "The title"}
  id7 = ~S{  [ID7]: http://example.com  "The title"}
  id8 = ~S{   [ID8]: http://example.com  "The title"}
  id9 = ~S{    [ID9]: http://example.com  "The title"}

  id10 = ~S{[ID10]: /url/ "Title with "quotes" inside"}
  id11 = ~S{[ID11]: http://example.com "Title with trailing whitespace" }

  [
    { "",         %Line.Blank{spacing: 0}, 0 },
    { "        ", %Line.Blank{spacing: 8}, 1 },

    { "<!-- comment -->", %Line.HtmlComment{complete: true}, 2 },
    { "<!-- comment",     %Line.HtmlComment{complete: false}, 3 },

    { "- -",   %Line.ListItem{type: :ul, bullet: "-", content: "-"}, 4 },
    { "- - -", %Line.Ruler{type: "-"}, 5 },
    { "--",    %Line.SetextUnderlineHeading{level: 2}, 6 },
    { "---",   %Line.Ruler{type: "-"}, 7 },

    { "* *",   %Line.ListItem{type: :ul, bullet: "*", content: "*"}, 8 },
    { " * *",   %Line.ListItem{type: :ul, bullet: "*", content: "*",   initial_indent: 1, spacing: 1}, 9 },
    { "  * *",   %Line.ListItem{type: :ul, bullet: "*", content: "*",  initial_indent: 2, spacing: 2}, 10 },
    { "   * *",   %Line.ListItem{type: :ul, bullet: "*", content: "*", initial_indent: 3, spacing: 3}, 11 },
    { "* * *", %Line.Ruler{type: "*"}, 12 },
    { "**",    %Line.Text{content: "**"}, 13 },
    { "***",   %Line.Ruler{type: "*"}, 14 },

    { "_ _",   %Line.Text{content: "_ _"}, 15 },
    { "_ _ _", %Line.Ruler{type: "_"}, 16 },
    { "__",    %Line.Text{content: "__"}, 17 },
    { "___",   %Line.Ruler{type: "_"}, 18 },

    { "# H1",       %Line.Heading{level: 1, content: "H1"}, 19 },
    { "## H2",      %Line.Heading{level: 2, content: "H2"}, 20 },
    { "### H3",     %Line.Heading{level: 3, content: "H3"}, 21 },
    { "#### H4",    %Line.Heading{level: 4, content: "H4"}, 22 },
    { "##### H5",   %Line.Heading{level: 5, content: "H5"}, 23 },
    { "###### H6",  %Line.Heading{level: 6, content: "H6"}, 24 },
    { "####### H7", %Line.Text{content: "####### H7"}, 25 },

    { "> quote",    %Line.BlockQuote{content: "quote"}, 26 },
    { ">    quote", %Line.BlockQuote{content: "   quote"}, 27 },
    { ">quote",     %Line.Text{content: ">quote"}, 28 },

      #1234567890
    { "   a",        %Line.Text{content: "   a", spacing: 3}, 29 },
    { "    b",       %Line.Indent{level: 1, content: "b", spacing: 4}, 30 },
    { "      c",     %Line.Indent{level: 1, content: "  c", spacing: 6}, 31 },
    { "        d",   %Line.Indent{level: 2, content: "d", spacing: 8}, 32 },
    { "          e", %Line.Indent{level: 2, content: "  e", spacing: 10}, 33 },

    { "```",      %Line.Fence{delimiter: "```", language: "",     line: "```"}, 34 },
    { "``` java", %Line.Fence{delimiter: "```", language: "java", line: "``` java"}, 35 },
    { " ``` java", %Line.Fence{delimiter: "```", language: "java", line: " ``` java", spacing: 1}, 36 },
    { "```java",  %Line.Fence{delimiter: "```", language: "java", line: "```java"}, 37 },
    { "```language-java",  %Line.Fence{delimiter: "```", language: "language-java"}, 38 },
    { "```language-élixir",  %Line.Fence{delimiter: "```", language: "language-élixir"}, 39 },

    { "~~~",      %Line.Fence{delimiter: "~~~", language: "",     line: "~~~"}, 40 },
    { "~~~ java", %Line.Fence{delimiter: "~~~", language: "java", line: "~~~ java"}, 41 },
    { "  ~~~java",  %Line.Fence{delimiter: "~~~", language: "java", line: "  ~~~java", spacing: 2}, 42 },
    { "~~~ language-java", %Line.Fence{delimiter: "~~~", language: "language-java"}, 43 },
    { "~~~ language-élixir",  %Line.Fence{delimiter: "~~~", language: "language-élixir"}, 44 },

    { "``` hello ```", %Line.Text{content: "``` hello ```"}, 45 },
    { "```hello```", %Line.Text{content: "```hello```"}, 46 },
    { "```hello world", %Line.Text{content: "```hello world"}, 47 },

    { "<pre>",             %Line.HtmlOpenTag{tag: "pre", content: "<pre>"}, 48 },
    { "<pre class='123'>", %Line.HtmlOpenTag{tag: "pre", content: "<pre class='123'>"}, 49 },
    { "</pre>",            %Line.HtmlCloseTag{tag: "pre"}, 50 },

    { "<pre>a</pre>",      %Line.HtmlOneLine{tag: "pre", content: "<pre>a</pre>"}, 51 },

    { "<area>",              %Line.HtmlOneLine{tag: "area", content: "<area>"}, 52 },
    { "<area/>",             %Line.HtmlOneLine{tag: "area", content: "<area/>"}, 53 },
    { "<area class='a'>",    %Line.HtmlOneLine{tag: "area", content: "<area class='a'>"}, 54 },

    { "<br>",              %Line.HtmlOneLine{tag: "br", content: "<br>"}, 55 },
    { "<br/>",             %Line.HtmlOneLine{tag: "br", content: "<br/>"}, 56 },
    { "<br class='a'>",    %Line.HtmlOneLine{tag: "br", content: "<br class='a'>"}, 57 },

    { "<hr>",              %Line.HtmlOneLine{tag: "hr", content: "<hr>"}, 58 },
    { "<hr/>",             %Line.HtmlOneLine{tag: "hr", content: "<hr/>"}, 59 },
    { "<hr class='a'>",    %Line.HtmlOneLine{tag: "hr", content: "<hr class='a'>"}, 60 },

    { "<img>",              %Line.HtmlOneLine{tag: "img", content: "<img>"}, 61 },
    { "<img/>",             %Line.HtmlOneLine{tag: "img", content: "<img/>"}, 62 },
    { "<img class='a'>",    %Line.HtmlOneLine{tag: "img", content: "<img class='a'>"}, 63 },

    { "<wbr>",              %Line.HtmlOneLine{tag: "wbr", content: "<wbr>"}, 64 },
    { "<wbr/>",             %Line.HtmlOneLine{tag: "wbr", content: "<wbr/>"}, 65 },
    { "<wbr class='a'>",    %Line.HtmlOneLine{tag: "wbr", content: "<wbr class='a'>"}, 66 },

    { "<h2>Headline</h2>",               %Line.HtmlOneLine{tag: "h2", content: "<h2>Headline</h2>"}, 67 },
    { "<h2 id='headline'>Headline</h2>", %Line.HtmlOneLine{tag: "h2", content: "<h2 id='headline'>Headline</h2>"}, 68 },

    { id1, %Line.IdDef{id: "ID1", url: "http://example.com", title: "The title"}, 69 },
    { id2, %Line.IdDef{id: "ID2", url: "http://example.com", title: "The title"}, 70 },
    { id3, %Line.IdDef{id: "ID3", url: "http://example.com", title: "The title"}, 71 },
    { id4, %Line.IdDef{id: "ID4", url: "http://example.com", title: ""}, 72 },
    { id5, %Line.IdDef{id: "ID5", url: "http://example.com", title: "The title"}, 73 },
    { id6, %Line.IdDef{id: "ID6", url: "http://example.com", title: "The title", spacing: 1}, 74 },
    { id7, %Line.IdDef{id: "ID7", url: "http://example.com", title: "The title", spacing: 2}, 75 },
    { id8, %Line.IdDef{id: "ID8", url: "http://example.com", title: "The title", spacing: 3}, 76 },
    { id9, %Line.Indent{content: "[ID9]: http://example.com  \"The title\"",
        level: 1,       line: "    [ID9]: http://example.com  \"The title\"", spacing: 4}, 77 },

      {id10, %Line.IdDef{id: "ID10", url: "/url/", title: "Title with \"quotes\" inside"}, 78},
      {id11, %Line.IdDef{id: "ID11", url: "http://example.com", title: "Title with trailing whitespace"}, 79},


      { "* ul1", %Line.ListItem{ type: :ul, bullet: "*", content: "ul1"}, 80 },
      { "+ ul2", %Line.ListItem{ type: :ul, bullet: "+", content: "ul2"}, 81 },
      { "- ul3", %Line.ListItem{ type: :ul, bullet: "-", content: "ul3"}, 82 },

      { "*     ul1", %Line.ListItem{ type: :ul, bullet: "*", content: "ul1"}, 83 },
      { "*ul1",      %Line.Text{content: "*ul1"}, 84 },

      { "1. ol1",          %Line.ListItem{ type: :ol, bullet: "1.", content: "ol1"}, 85 },
      { "12345.      ol1", %Line.ListItem{ type: :ol, bullet: "12345.", content: "ol1"}, 86 },
      { "1.ol1", %Line.Text{ content: "1.ol1"}, 87 },

      { "=",        %Line.SetextUnderlineHeading{level: 1}, 88 },
      { "========", %Line.SetextUnderlineHeading{level: 1}, 89 },
      { "-",        %Line.SetextUnderlineHeading{level: 2}, 90 },
      { "= and so", %Line.Text{content: "= and so"}, 91 },

      { "   (title)", %Line.Text{content: "   (title)", spacing: 3}, 92 },

      { "{: .attr }",       %Line.Ial{attrs: ".attr"}, 93 },
      { "{:.a1 .a2}",       %Line.Ial{attrs: ".a1 .a2"}, 94 },

      { "  | a | b | c | ", %Line.TableLine{content: "  | a | b | c | ",
          columns: ~w{a b c}, spacing: 2}, 95 },
      { "  | a         | ", %Line.TableLine{content: "  | a         | ",
          columns: ~w{a}, spacing: 2}, 96 },
      { "  a | b | c  ",    %Line.TableLine{content: "  a | b | c  ",
          columns: ~w{a b c}, spacing: 2}, 97 },
      { "  a \\| b | c  ",  %Line.TableLine{content: "  a \\| b | c  ",
          columns: [ "a | b",  "c"], spacing: 2}, 98 },

      #
      # Plugins
      #
      { "$$",                       %Line.Plugin{prefix: "", content: ""}, 99 },
      { "$$ ",                      %Line.Plugin{prefix: "", content: ""}, 100 },
      { "$$pfx ",                   %Line.Plugin{prefix: "pfx", content: ""}, 101 },
      { "$$pfx",                    %Line.Plugin{prefix: "pfx", content: ""}, 102 },

      { "$$ my line for plugin",    %Line.Plugin{prefix: "", content: "my line for plugin"}, 103 },
      { "$$pfx my line for plugin", %Line.Plugin{prefix: "pfx", content: "my line for plugin"}, 104 },

          ]
  |> Enum.each(fn { text, type, numba } ->
    @tag :"line_type_#{numba}"
    test("line: '" <> text <> "'") do
      struct = unquote(Macro.escape type)
      struct = %{ struct | line: unquote(text), lnb: 42 }
      assert Line.type_with_spacing({unquote(text), 42}, Support.Helpers.options, false) == struct
    end
  end)

end
