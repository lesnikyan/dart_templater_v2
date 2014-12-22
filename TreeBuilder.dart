//part of dart_templater;

import 'TplNode.dart';
import 'ConditionNode.dart';
import 'CycleNode.dart';
import 'NodeParser.dart';

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
    SyntaxTree tree;
    List<BlockNode> curParents = [tree];
    for(lex in lexemes){
      if(lex is TextLexeme){
        curParents.last.add(new TextNode(lex.content));
        continue;
      }
      // if close tag lexeme
      if(_closeParser.check(lex)){
        curParents.removeLast();
        continue;
      }
      // if not an close tag lexeme
      for(parser in _parsers){
        if(parser.check(lex)){
          SyntaxNode node = parser.getNode(lex);
          continue;
        }
        // add to parent if container:
        curParents.last.add(node);
        if(node.isContainer){
          curParents.add(node);
          continue;
        }
      }
    }
    return tree;
  }
}
