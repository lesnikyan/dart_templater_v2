//part of dart_templater;

import 'DataContext.dart';

class TplNode {

  String _content;

  TplNode(String this._content);

  String render(){
    return _content;
  }

  static void test(){
    print('part of Tpl.lib included');
  }
}


abstract class SyntaxNode {
  bool isContainer = false;
  SyntaxNode([this.isContainer]);
  String render();
}

class TextNode extends SyntaxNode {
  String _content;
  TextNode(String this._content);
  String render(){
    return _content;
  }
}

class CommentNode extends SyntaxNode{
  String render(){
    return '';
  }
}

class ValueNode extends SyntaxNode {
  String _variable;

  ValueNode(String this._variable);

  String render(DataContext context){
    return context.value(_variable);
  }
}

abstract class BlockNode extends SyntaxNode {
  List<SyntaxNode> _subNodes = new List<SyntaxNode>();
  BlockNode():super(true);

  SyntaxNode add(SyntaxNode node){
    _subNodes.add(node);
    return node;
  }

  String render(DataContext context){
    StringBuffer res = new StringBuffer();
    for(node in _subNodes){
      res.write(node.render(context));
    }
    return res.toString();
  }
}


class FunctionNode extends BlockNode {
  // ?
  String render();
}

class SyntaxTree extends BlockNode{

}
