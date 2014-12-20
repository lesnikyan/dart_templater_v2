class DataContext {

  Map data;

  DataContext([Map data]) {
    if(data == null){
      data = {};
    }
  }

  void add(String key, Object val){
    data[key] = val;
  }

  void remove(Object names){
    List deletions;
    if(names is String) {
      deletions = [names];
    }
    for(name in deletions){
      removeOne(name);
    }
  }

  /**
   * simplest realisation
   * TODO: make treelike (or list of maps) context instead of one-level map
   */
  void removeOne(String name){
    data.remove(name);
  }

  Object value(String name){
    if(data.containsKey(name)){
      return data[key];
    }
  }
}
