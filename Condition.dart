// Condition classes
import 'DataContext.dart';

class Operand {
  String _name;
  Object _value;
  bool _isConst;

  Operand(bool this._isConst, {name, value}){
    _name = name;
    _value = value;
  }

  bool value(DataContext context){
    return _isConst ? _value : context.value(_name);
  }

  String toString(){
    return "{const = ${_isConst}; value: (${_value.runtimeType})$_value, name: $_name}";
  }
}

abstract class Condition {
  bool value(DataContext context);
}

class OneValueCondition {
  Operand _oper;
  OneValueCondition(Operand this._oper);

  bool value(DataContext context){
    return _oper.value(context);
  }

  String toString(){
    return "OneValueCondition($_oper)";
  }
}

class SimpleCondition {
  // types
  String operator;
  Operand left;
  Operand right;
  SimpleCondition(String this.operator, Operand this.left, Operand this.right);

  bool value(DataContext context){
    var x = left.value(context); // left operand
    var y = right.value(context); // right operand
    return _compare(x, y);
  }

  bool _compare(x, y){
    switch(operator){
      case '==' : return x == y;
      case '!=' : return x != y;
      case '<=' : return x <= y;
      case '>=' : return x >= y;
      case '<' : return x < y;
      case '>' : return x > y;
    }
  }

  String toString(){
    return "SimpleCondition($left $operator $right)";
  }
}

//class ConditionOperator {
//
//}

class MultiCondition extends Condition {
  List<SimpleCondition> _subConditions = [];
  String _logicOperator = '&&';
  List<String> _validOperators = ['&&', '||'];

  MultiCondition(String _logicOperator, [List<SimpleCondition> subConditions]){
    if(subConditions is List){
      _subConditions = subConditions;
    }
    if(! _validOperators.contains(_logicOperator)){
      throw new Exception('MultiCondition: trying to use incorrect logic operator');
    }
  }

  void addCondition(SimpleCondition cond){
    _subConditions.add(cond);
  }

  bool value(DataContext context){
    bool res = false;
    for(SimpleCondition cond in _subConditions){
      bool sub = cond.value(context);
      if(_logicOperator == '&&' && ! sub){  // false with 1 false
        return false;
      } else if(_logicOperator == '||' && sub){ // true with 1 true
        return true;
      }
      res = sub;    // && -> true if no one false; || -> false if no one true
    }
    return res;
  }

  String toString(){
    StringBuffer res = new StringBuffer("operator ($_logicOperator) :\n");
    for(SimpleCondition cond in _subConditions){
      res.writeln(cond.toString());
    }
    return res.toString();
  }
}
