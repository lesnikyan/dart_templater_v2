class DataContext {

  List<Map> _nodes = [];
  int _lastIndex = 0;

  DataContext([Map<String, Object> data]) {
    addSubData(data is Map ? data : {});
  }

  void add(String key, Object val){
    _nodes.last[key] = val;
  }

  void addAll(Map<String, Object> data){
    _nodes.last.addAll(data);
  }

  void addSubData([Map<String, Object> sub]){
    if(sub is! Map){
      sub = {};
    }
    _nodes.add(sub);
    _resetIndex();
  }

  void removeSubData(){
    _nodes.removeLast();
    _resetIndex();
  }

  void _resetIndex(){
    _lastIndex = _nodes.length - 1;
  }

  /**
   * simplest realisation
   * TODO: make treelike (or list of maps) context instead of one-level map
   */
  void removeOne(String name){
    _data.remove(name);
  }

  Object value(String name){
    for(int i = _lastIndex; i >= 0 ; --i){
      Map data = _nodes[i];
      if(_nodes[i].containsKey(name)){
        return _nodes[i][name];
      }
    }
    return null;
  }

  String toString(){
    String tab = "\t";
    StringBuffer res = new StringBuffer("DataContext:\n");
    for(int i=0; i < _nodes.length; ++i){
      res.writeln("$tab(node:$i)");
      tab ="\t\t";
      for(var key in _nodes[i].keys){
        res.writeln("$tab $key : ${_nodes[i][key]}");
      }
      tab = "\t";
    }
    return res.toString();
  }
}

