//part of dart_templater;

import 'TplNode.dart';
import 'ConditionNode.dart';
import 'CycleNode.dart';
import 'NodeParser.dart';
import 'Lexeme.dart';
import 'services.dart';

class TreeBuilder {
  Map _tplSyntax = {
    'tagShield':'\\',
    'startTag':'{',
    'endTag':'}',
    'closeTag':'/'
  };
  RegExp _tagShieldExpr;
  List<NodeParser> _parsers = new List<NodeParser>();
  CloseBlockParser _closeParser = new CloseBlockParser();
  ConditionNodeParser _condParser = new ConditionNodeParser();
  TreeBuilder() {
    _init();
  }

  void _init(){
    _parsers.addAll([
        // first - comments
        new CommentNodeParser(),
        // complicated cases
        new CycleNodeParser(), _condParser,
        // value case
        new VarNodeParser(),
        // in the end - simplest/text
        new SimpleNodeParser()]);
    _initSyntax();
  }

  void _initSyntax(){
    String shieldString(String src){
      StringBuffer shielded = new StringBuffer();
      src.runes.toList().forEach((var elem){shielded.write("\\${new String.fromCharCode(elem)}");});
      return shielded.toString();
    }
    String shldShield = shieldString(_tplSyntax['tagShield']);
    String shldStart = shieldString(_tplSyntax['startTag']);
    _tagShieldExpr = new RegExp(shldShield + shldStart);
   // p("shield pattern: ${_tagShieldExpr.pattern}");
  }

  void setSyntax(Map syntax){
    _tplSyntax = syntax;
    _initSyntax();
  }

  SyntaxTree build(List<Lexeme> lexemes){
    TreeNode tree = new TreeNode();
    List<BlockNode> curParents = [tree];
    BlockNode prevParent = null;
    for(Lexeme lex in lexemes){
    //  p("Builder 1): (${lex.type == #text ? 'is text' : 'no text'}) ${curParents} |type:${lex.type}| -=${lex.content.replaceAll(new RegExp(r'\n'), ' \\n ')}=- ");

      // if no tag lexeme (simple text)
      if(lex.type == #text){
        // clear text from shielded tags if has
        if(_tagShieldExpr.hasMatch(lex.content)){
          lex.content = lex.content.replaceAll(_tagShieldExpr, _tplSyntax['startTag']);
        }
        curParents.last.add(new TextNode(lex.content));
        continue;
      }
      // if close tag lexeme
      if(_closeParser.check(lex)){
        if(!_closeParser.simpleClose(lex)       // not just close block (else)
          && _condParser.check(lex)             // and if open condition block
          && curParents.last is ConditionNode){ // and if current parent is condition block
          // switch condition node to 'else' statement
          curParents.last.setElse();
        } else {
          curParents.removeLast();
        }
        continue;
      }
      // if not an close tag lexeme
      // trying to use each NodeParser from comment's and complicated to simplest (like print)
      for(NodeParser parser in _parsers){
        if(parser.check(lex)){
          SyntaxNode node = parser.getNode(lex);
          // add to parent if container:
          curParents.last.add(node);
          if(node.isContainer){
          //  p("parserNode.check() -> node: ${node} '${lex.content}'");
            curParents.add(node);
          }
          break;
        }
      }
      //curParents.last.add(new TextNode(lex.content)); // if we want show all uncaught cases
    }
    return tree;
  }
}
