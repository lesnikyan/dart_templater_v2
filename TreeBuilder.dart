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
  TreeBuilder() {
    _init();
  }

  void _init(){
    _parsers.addAll([
        // first - complicated cases
        new CycleNodeParser(), new ConditionNodeParser(),
        // value case
        new VarNodeParser(),
        // in the end - simplest/text
        new SimpleNodeParser()]);
  }

  SyntaxTree build(List<Lexeme> lexemes){
    TreeNode tree = new TreeNode();
    List<BlockNode> curParents = [tree];
    for(Lexeme lex in lexemes){
    //  p("Builder 1): ${curParents} -=${lex.content.replaceAll(new RegExp(r'\n'), ' \\ ')}=- ");
      // if no tag lexeme
      if(lex is TextLexeme){
        curParents.last.add(new TextNode(lex.content));
        continue;
      }
      // if close tag lexeme
      if(_closeParser.check(lex)){
    //    p("Close Block: ${lex.content}");
        curParents.removeLast();
        continue;
      }
      // if not an close tag lexeme
      // trying to use each NodeParser
      for(NodeParser parser in _parsers){
        if(parser.check(lex)){
          SyntaxNode node = parser.getNode(lex);
       //   p("parserNode.check() -> node: ${node}");
          // add to parent if container:
          curParents.last.add(node);
          if(node.isContainer){
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
