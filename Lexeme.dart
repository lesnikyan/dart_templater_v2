
class Lexeme {
  String content;
  Symbol type = #none;
  Lexeme(String this.content, this.type){

  }
}

class TextLexeme extends Lexeme {
  TextLexeme(String content):super(content, #text);
}

class TplLexeme extends Lexeme {
  TplLexeme(String content):super(content, #tpl);
}