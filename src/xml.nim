# xml
# Copyright Huy Doan
# Pure Nim XML parser

type
  TokenKind* = enum
    TAG_BEGIN
    TAG_END
    NAME
    SIMPLE_TAG_CLOSE
    TAG_CLOSE
    STRING
    TEXT
    EQUALS
    CDATA_BEGIN
    CDATA_END
    EOF

  XmlToken* = object
    kind*: TokenKind
    text*: string

  XmlTokenizer* = object
    input*: string
    pos*: int
    textParseMode*: bool
    cdataMode*: bool



proc initXmlTokenizer(input: string): XmlTokenizer =
  result.input = input
  result.pos = 0

template skip_until(c: char) =
  while(input[pos] != c):
    inc(pos)

iterator tokens*(input: string): XmlToken {.inline.} =
  var
    pos = 0
    length = input.len
    is_cdata = false
    is_text = false

  var ch = input[pos]

  while pos < length and input[pos] != '\0':
    let ch = input[pos]
    case ch
    #of ' ', '\t', '\r', '\n':
    #  inc(pos)
    of '<':
      if not is_cdata:
        case input[pos + 1]:
        of '?':
          # skips prologue
          skip_until('>')
          echo input[0..pos]
        of '!':
          echo input[pos..pos+6]
          if input[pos..pos+6] == "[CDATA[":
            # cdata
            discard
          elif input[pos..pos+2] == "--":
            # commment
            discard
        else:
          discard

    of ']':
      is_text =  true
      is_cdata = false
    else:
      inc(pos)
    var t: XmlToken
    #  yield t


when isMainModule:
  let xml = """<?xml version="1.0" encoding="UTF-8"?>
<!-- example -->
<classes>
    <class name="Klient">
        <attr type="int">id</attr>
        <attr type="String">imie</attr>
        <attr type="String">nazwisko</attr>
        <attr type="Date">dataUr</attr>
    </class>
    <class name="Wizyta">
        <attr type="int">id</attr>
        <attr type="Klient">klient</attr>
        <attr type="Date">data</attr>
    </class>
</classes>
"""

  for t in  xml.tokens:
    echo t
