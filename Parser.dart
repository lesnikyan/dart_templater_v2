// part of dart_templater;
import 'services.dart';

class Parser {
  String startX = '{'; // chars open tag: {tag content ...
  String endX = '}';   // chars close tag: ... tag content}
  Strng tagShield = '\\'; // makes next placed chars open tag unavailable: \{not a tag}
  RegExp _newLineExp = new RegExp(r'^\n$');
  RegExp _controlExpr = new RegExp(r'^#\.*|if\s+|else|else\s+if|elseif|for\s+|\/');

//  Parser(String tpl) {
//
//  }

  List<String> parse(String src){
    List<Lexeme> res = new List<Lexeme>();
    src.replaceAll(_newLineExp, "\n");
    int len = src.length;
    int lastIndex = len - 1;
    String prefStart = startX.substring(0,0);
    int startXLen = startX.length;
    int endXLen = endX.length;
    int emptyTagLen = startXLen + endXLen;
//    for(int i = 0; i < len; ++i){
    int curIndex = 0;
    bool inTag = false;

    String lexeme = "";
    String lastCaret = -1;
    RegExp spacesExp = new RegExp(r'^\s*$');

    while(curIndex < len){
    //  if(res.length > 20) break; // DEBUG ONLY

    //  bool isEnd = false;
    //  bool isStart = false;
    //  String curSub = lexeme.substring(curIndex, curIndex + startXLen);
    //  p("Parser: 1) $curIndex: $lexeme; ");
    //  p("[$curIndex]: ${startXLen}, ${lexeme.length - endXLen - 1}");
      if(inTag){
        if(curIndex < len - endXLen &&  src.substring(curIndex, curIndex + endXLen) == endX){
          // end tag
          lexeme += src.substring(curIndex, curIndex + endXLen);
          //p("$lexeme : ${lexeme.length}");

          // если оставшаяся часть строки пустая или содержит только пробельные символы,
          // и предыдущая лексема была текстовой, содержала перенос строки
          // и последняя её строка, после "каретки" была пустой или содержала только пробельные символы
          // то 1) вырезать из предыдущей лексемы текущую строку, 2) передвинуть индекс на конец текущей строки
          String lexExpression = lexeme.substring(startXLen, lexeme.length - endXLen).trim();
          String prevLexPartIndex = res.last.content.lastIndexOf("\n");
          bool singleString = false; // flag of single tag in line
          if( prevLexPartIndex >= 0 && _controlExpr.hasMatch(lexExpression)){
            int nextCaret = src.indexOf("\n", curIndex + endXLen);
            String partToCaret = src.substring(curIndex + endXLen, nextCaret);
          //  p("pr: prevPart: ${res.last.content.substring(prevLexPartIndex).replaceAll(new RegExp(r'\n'), ' \\n ')}");
            if( prevLexPartIndex >= 0
              && spacesExp.hasMatch(partToCaret)
              && spacesExp.hasMatch(res.last.content.substring(prevLexPartIndex))
            ){
            //  p("Parser: prev: ${res.last.content.replaceAll(new RegExp(r'\n'), ' \\n ')}; next: ${lexeme.replaceAll(new RegExp(r'\n'), ' \\n ')}");
              res.last.content = res.last.content.substring(0, prevLexPartIndex  );
              singleString = true;
              curIndex = nextCaret;
            }
          }

          res.add(new TplLexeme(lexExpression)); // save tpl lexeme // .substring(startXLen, lexeme.length - endXLen - 1)

          // move cursor if tag is not single in line
          if (! singleString){
            curIndex += endXLen;
          }
          lexeme = ""; // clear tpl lexeme, start new lexeme
          inTag = false;
          continue;
        } else {

        }
      } else {
        if(curIndex < (len - emptyTagLen) // has enough length for shortest (empty) tag
          && src.substring(curIndex, curIndex + startXLen) == startX  //
          && (curIndex >= tagShield.length && src.substring(curIndex - tagShield.length, curIndex) != tagShield)  // prevent start tag when current char was shielded
        ){
          // start tag, end prev text lexeme
          if(lexeme.length > 0){
            res.add(new TextLexeme(lexeme)); // save prev text lexeme
          }
          lexeme = src.substring(curIndex, curIndex + endXLen);
          curIndex += startXLen;
          inTag = true;
          continue;
        }

        // finish of tpl
        if(curIndex == lastIndex){
          lexeme += src.substring(curIndex, curIndex + 1);
          res.add(new TextLexeme(lexeme)); // save last lexeme
          lexeme = "";
          break;
        }
      }

      // if no special cases:
      lexeme += src[curIndex];// src.substring(curIndex, curIndex + 1);

      // if new line, remember index
      if(src[curIndex] == "\n"){
        lastCaret = curIndex;
      }
      // if current = space-like text lexeme, and previously lex = tpl, and next prev has space-like last string

      curIndex++;
    }
    return res;
  }
}


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