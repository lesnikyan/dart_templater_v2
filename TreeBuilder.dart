//part of dart_templater;

import 'TplNode.dart';
import 'ConditionNode.dart';
import 'CycleNode.dart';
import 'NodeParser.dart';
import 'Lexeme.dart';
import 'services.dart';

class TreeBuilder {
  List<NodeParser> _parsers = new List<NodeParser>();
  CloseBlockParser _closeParser = new CloseBlockParser();
  ConditionNodeParser _condParser = new ConditionNodeParser();
  TreeBuilder() {
    _init();
  }

  void _init(){
    _parsers.addAll([
        // first - complicated cases
        new CycleNodeParser(), _condParser,
        // value case
        new VarNodeParser(),
        // in the end - simplest/text
        new SimpleNodeParser()]);
  }

  SyntaxTree build(List<Lexeme> lexemes){
    TreeNode tree = new TreeNode();
    List<BlockNode> curParents = [tree];
    BlockNode prevParent = null;
    for(Lexeme lex in lexemes){
    //  p("Builder 1): ${curParents} |type:${lex.type}| -=${lex.content.replaceAll(new RegExp(r'\n'), ' \\n ')}=- ");
      // if no tag lexeme
      if(lex is TextLexeme){
        curParents.last.add(new TextNode(lex.content));
        continue;
      }
      // if close tag lexeme
      if(_closeParser.check(lex)){
      //  p("Close Block: ${lex.content}");

        if(!_closeParser.simpleClose(lex)       // not just close block (else)
          && _condParser.check(lex)             // and if open condition block
          && curParents.last is ConditionNode){ // and if current parent is condition block
        //  p("--- switch to else");
          curParents.last.setElse();
        } else {
          curParents.removeLast();
        }
        continue;
      }
      // if not an close tag lexeme
      // trying to use each NodeParser
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
