library dart_templater;

import 'dart:io';
import 'dart:convert';

import 'Parser.dart';
import 'TplNode.dart';
import 'DataContext.dart';
import 'TreeBuilder.dart';
import 'services.dart';

/**
 * Very Simple Dart Template Solution (VSDTS)
 * and
 * Very Simple Dart Application Solution (VSDAS)
 */

class Templater {
  String tplFile = null;
  String tplText;
  Parser parser;
  //Map<String, Object> _values = new Map<String, Object>();
  DataContext _context;
  TreeBuilder _builder = new TreeBuilder();
  TreeNode _tplTree;
  Encoding _encoding;

  Templater({String template:'', Map data}) {
    // read file
    tplText = "<html><head><title>{#title#}</title></head><body><h1>{#page.name#}</h1></body></html>";
    _init(data);
  }

  Templater.fromString(String this.tplText, [Map data]){
    _init(data);
  }

  Templater.fromFile(String this.tplFile, [Map data]){
    // get text from file
    File file;
    try{
      file = new File(tplFile);
      if(!file.existsSync()){
        throw new Exception("No tpl file found: ${file.absolute}");
      }
      p(file.absolute);
      _encoding = Encoding.getByName('utf-8');
      tplText = file.readAsStringSync(encoding: _encoding);
    } catch (e, s) {
      p(e);
      log(e);
      log(s.toString());
      return;
    }
    _init(data);
  }

  void _init([Map data]){
    if(data == null){
      data = {};
    }
    try{
      p(tplText);
      p("**************************************");
      // parse source to lexeme list
      parser = new Parser();
      _context = new DataContext(data);
      List<Lexeme> lexemes = lexemeList(tplText);
      _tplTree = _builder.build(lexemes);
      print("isTree = ${_tplTree is TreeNode}");
//      for(Lexeme lex in lexemes){
//        //p("[${lex.type.toString()}:${lex.content}]");
//        p(lex.content);
//      }
      // build tree of
    }catch(e, s){
      p(e);
      p(s.toString());
    }
  }

  void setEncoding(Encoding enc){
    _encoding = enc;
  }

  List<Lexeme> lexemeList(String tplCode){
    return parser.parse(tplCode);
  }

  void put(Object key, [Object value]){
    if(key is  Map && value == null){
      Map data = key;
      _context.addAll(data);
    } else {
      _context.add(key, value);
    }
  }


  String render(){
//    for(String k in _values.keys){
//      p("$k => ${_values[k].toString()}");
//    }
//    return "in dev";
    return _tplTree.render(_context);
  }

}

