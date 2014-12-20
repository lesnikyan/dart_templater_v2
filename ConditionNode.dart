
//part of dart_templater;

import 'TplNode.dart';
import 'DataContext.dart';
import 'Condition.dart';


// Tpl Nodes


class ConditionNode extends BlockNode {
  // if, elseif, else
  Condition _cond;

  ConditionNode(Condition this._cond){}

//  factory ConditionNode.create(String content){
//    return new SimpleConditionNode(content);
//  }

  bool _validate(DataContext context){
    return _cond.value(context);
  }

  String render(DataContext context){
    if(_validate(context)){
      return super.render(context);
    }
    return '';
  }
}


