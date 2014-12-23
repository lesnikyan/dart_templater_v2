// part of dart_templater;
import 'services.dart';

class Parser {
  String startX = '{'; // chars open tag: {tag content ...
  String endX = '}';   // chars close tag: ... tag content}
  Strng tagShield = '\\'; // makes next placed chars open tag unavailable: \{not a tag}

//  Parser(String tpl) {
//
//  }

  List<String> parse(String src){
    List<String> res = new List<String>();
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
          res.add(new TplLexeme(lexeme.substring(startXLen, lexeme.length - endXLen).trim())); // save tpl lexeme // .substring(startXLen, lexeme.length - endXLen - 1)
          curIndex += endXLen;
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

      lexeme += src.substring(curIndex, curIndex + 1);
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