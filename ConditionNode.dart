
//part of dart_templater;

import 'TplNode.dart';
import 'DataContext.dart';
import 'Condition.dart';


// Tpl Nodes


class ConditionNode extends BlockNode {
  // if, elseif, else
  Condition _cond;
  BlockNode _thenBlock = new BlockNode(); // exec if true
  BlockNode _elseBlock = null; // exec else
  bool _actualBlock = 1; // 1 - if or 2 - else

  ConditionNode(Condition this._cond){}

  void setElse([BlockNode block]){
    if(block == null){
      block = new BlockNode();
    }
    _elseBlock = block;
    _actualBlock = 2;
  }

  // ?
  void switchBlock(int val){
    _actualBlock = val;
  }

  void add(SyntaxNode node){
    (_actualBlock == 1 ? _thenBlock : _elseBlock).add(node);
  }

//  factory ConditionNode.create(String content){
//    return new SimpleConditionNode(content);
//  }

  bool _validate(DataContext context){
   // print("ConditionNode. cond: $_cond");
    return _cond.value(context);
  }

  String render(DataContext context){
    if(_validate(context)){
      return _thenBlock.render(context);
    } else if (_elseBlock != null) {
      return _elseBlock.render(context);
    }
    return '';
  }
}


