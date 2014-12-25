
import 'Lexeme.dart';
import 'TplNode.dart';
import 'Condition.dart';
import 'ConditionNode.dart';
import 'CycleNode.dart';
import 'services.dart';

/**
 * just base superclass
 */
abstract class NodeParser {
  /**
   * check whether this parser is suitable to current lexeme
   */
  bool check(Lexeme lex);

  /**
   * parse lexeme and create appropriate node
   */
  SyntaxNode getNode(Lexeme lex){
    return null;
  }
}

/**
 * only for plane text node
 */
class SimpleNodeParser extends NodeParser {
  bool check(Lexeme lex){
    return true;
  }

  SyntaxNode getNode(Lexeme lex){
    return new TextNode(lex.content);
  }
}

/**
 * for variables: name, user.name, ets..
 */
class VarNodeParser extends NodeParser {

  RegExp _rule = new RegExp(r'^[a-zA-Z_]\w*(\.[a-zA-Z_]\w*)*$');

  bool check(Lexeme lex){
    return _rule.hasMatch(lex.content);
  }

  SyntaxNode getNode(Lexeme lex){
    return new ValueNode(lex.content);
  }
}

/**
 * for end of block
 */
class CloseBlockParser {
  List<String> _closes = ['/', 'else'];

  bool check(Lexeme lex){
    return _closes.contains(lex.content.trim());
  }

  bool simpleClose(Lexeme lex){
    return lex.content.trim() == '/';
  }
}

/**
 * parser of cycle (for) lexeme
 */
class CycleNodeParser extends NodeParser {

  RegExp _rgx = new RegExp(r'^\s*for\s+\w+\s+in\s+[a-zA-Z_]\w*(?:\.[a-zA-Z_]\w*)*\s*$');

  bool check(Lexeme lex){
    return _rgx.hasMatch(lex.content);
  }

  SyntaxNode getNode(Lexeme lex){
    RegExp rgx = new RegExp(r'^\s*for\s+(\w+)\s+in\s+([\w\.]+)\s*$');
    Match m = rgx.firstMatch(lex.content);
    String varName = m.group(1);
    String listName = m.group(2);
  //  p("Cycle Parser. getNode: $varName, $listName");
    return new CycleNode(listName, varName);
  }
}

/**
 * parser of condition(if, else, elseif) lexeme
 */
class ConditionNodeParser extends NodeParser {

  RegExp _checkExpr = new RegExp(r'^((if\s+\w+)|else)');
  RegExp _commandExpr = new RegExp(r'\s*(if|else)\s*');
  RegExp _oneVarExpr = new RegExp(r'^[\w][\w\.]*$');
  RegExp _oneExpr = new RegExp(r'^[^|&]+$');
  String _simpleExprRule = r'([^=<>!&\|]+)\s+(==|!=|>|<|>=|<=)\s+([^=<>!&\|]+)';
  RegExp _simpleExpr;
  String _multiExprRule;
  String _logicOper;

  ConditionNodeParser(){
    _init();
  }

  void _init(){
    _simpleExpr = new RegExp("^$_simpleExprRule\$");
    _logicOper = r'(&&|\|\|)';
    _multiExprRule = "^$_simpleExprRule(\\s*$_logicOper\\s*$_simpleExprRule)+\$";
    _multiExprRule = "^[^|&]+(\\s*$_logicOper\\s*[^|&]+)+\$";
  }

  bool check(Lexeme lex){
    return _checkExpr.hasMatch(lex.content.trim());
  }

  SyntaxNode getNode(Lexeme lex){

    String syntaxPrefix = _commandExpr.firstMatch(lex.content).group(1);
   // p("getNode: {${lex.content}} : ($syntaxPrefix) ");
    String expr = lex.content.trim().substring(syntaxPrefix.length).trim();
   // p("ConditionNodeParser. expr: $expr");

    if(_oneExpr.hasMatch(expr)){
     // p("ConditionNodeParser._oneExpr");
      return new ConditionNode(
          getOneExprCondition(expr)
      );
     // return getOneExprCondition(expr);
    }
    // 3. multiexpression with pairs of operators:  a < 10 && a > 5; age >= 20 || name == 'Vasya'

    RegExp multiExpr = new RegExp(_multiExprRule); //??
    if(multiExpr.hasMatch(expr)){
      return new ConditionNode(getMultiCondition(expr));
    }
   // p("ConditionParser: no matches");
    return null;
  }

  SimpleCondition getOneExprCondition(String expr){
    // 1. one value operator
    if(_oneVarExpr.hasMatch(expr)){
      //  p('ConditionNodeParser: OneValue');
      return new OneValueCondition(getOperand(expr));
    }

    // 2. bool expression
    if(_simpleExpr.hasMatch(expr)){
      return getSimpleExpressionCondition(expr);
    }
  }

  SimpleCondition getSimpleExpressionCondition(String expr){
    Match m = _simpleExpr.firstMatch(expr);
    Operand left = getOperand(m.group(1));
    Operand right = getOperand(m.group(3));
    String _operator = m.group(2);
    return new SimpleExpressionCondition(_operator, left, right);
  }

  Condition getMultiCondition(String expr){
    RegExp operDiv = new RegExp(r'\s*' + _logicOper + r'\s*'); // ([&|])\1

    List<Match> logicOperators = operDiv.allMatches(expr);
    List<String> logics = [];
    for(Match m in logicOperators){
      logics.add(m.group(1));
    }
    // dirty and brutally prevent expressions with both of logic operators (not sure tmpltr need same case)
    if(logics.contains('&&') && logics.contains('||')){
      throw new Expression('NodeParser: too complicated logic (&& and || operators in expression)');
    }
    if(logics.length == 0){
      throw new Expression('NodeParser: too simple expression for multipart condition');
    }
    List pairs = expr.split(operDiv);
    //p("paist len = ${pairs.length}");
    MultiCondition multiCond = new MultiCondition(logics[0]);
    for(var subExpr in pairs){
      multiCond.addCondition( getOneExprCondition(subExpr));
    };
    return multiCond;
  }

  Operand getOperand(String src){
    List<String> boolConsts = ['true', 'false'];
    String quotes = "\'|\"";
    RegExp strConst = new RegExp(r'^('+quotes+r')([^\1]*)\1$');
    RegExp numConst = new RegExp(r'^(\d+(?:\.\d+)?)$');
    RegExp varName = new RegExp(r'^([a-zA-Z_]\w*(?:\.[a-zA-Z_]\w*)*)$');

    var value = null;
    var name = null;
    if(boolConsts.contains(src)){ // bool values
      value = src == 'true';
    } else if(src == 'null'){   // null value
      value = null;
    } else if(strConst.hasMatch(src)){    // String value
      Match m = strConst.firstMatch(src);
      value = m.group(2);
    } else if (numConst.hasMatch(src)){   // num value
      Match m = strConst.firstMatch(src);
      value = num.parse(src);
    } else if(varName.hasMatch(src)){     // variable name
      name = src;
    } else {
      throw new Exception("Incorrect operator syntax: $src");
    }

    return new Operand(name == null, value: value, name: name);
  }
}