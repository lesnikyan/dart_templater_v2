import 'TplNode.dart';

class CycleNode extends BlockNode {
  // {for value in list}
  String _listName;
  String _varName;

  CycleNode(String this._listName, String this._varName){
    //
  }

  String render(DataContext context){
    StringBuffer res = new StringBuffer();
    List list = context.value(_listName);
    for(int i=0; i < list.length; ++i){
      context.add('index', i);  // experimental part, var index with current iteration number
      context.add(_varName, list[i]); // value of current position
      res.write(super.render(context));
      context.remove(['index', _varName]);
    }
    return res.toString();
  }

  String toString(){
    return "$_listName, $_varName";
  }
}
