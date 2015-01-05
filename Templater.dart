library dart_templater;

import 'dart:io';
import 'dart:convert';

import 'Parser.dart';
import 'TplNode.dart';
import 'DataContext.dart';
import 'TreeBuilder.dart';
import 'services.dart';
import 'package:xml/xml.dart';

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
  Map _tplSyntax = {
      'tagShield': r'\',
      'startTag':'{',
      'endTag':'}',
      'closeTag':'/'
  };

  Templater({String template, String file, Map data, Map syntax}) {
    // read file
    //tplText = "<html><head><title>{title}</title></head><body><h1>{page.name}</h1></body></html>";
    if(file != null){
      this.fromFile(file, data, syntax);
      return;
    } else if (template != null){
      this.fromString(template, data, syntax);
      return;
    }
    _init(data);
  }

  Templater.fromString(String this.tplText, [Map data, Map syntax]){
    _init(data, syntax);
  }

  Templater.fromFile(String this.tplFile, [Map data, Map syntax]){
    // get text from file
    File file;
    try{
      file = new File(tplFile);
      if(!file.existsSync()){
        throw new Exception("No tpl file found: ${file.absolute}");
      }
     // p(file.absolute);
      _encoding = Encoding.getByName('utf-8');
      tplText = file.readAsStringSync(encoding: _encoding);
    } catch (e, s) {
      p(e);
      log(e);
      log(s.toString());
      return;
    }
    _init(data, syntax);
  }

  void _init([Map data, Map syntax]){
    if(data == null){
      data = {};
    }
    if(syntax is Map){
      setSyntax(syntax);
    }
    parser = new Parser();
    _context = new DataContext(data);

  }

  void prepare(){
    try{
      // parse source to lexeme list
      List<Lexeme> lexemes = lexemeList(tplText);
      // build node tree
      _tplTree = _builder.build(lexemes);
    }catch(e, s){
      p(e);
      p(s.toString());
    }
  }

  void setEncoding(Encoding enc){
    _encoding = enc;
  }

  void setSyntax(Map syntax){
    for(String key in syntax.keys){
      if(_tplSyntax.containsKey(key)){
        _tplSyntax[key] = syntax[key];
      }
    }
    parser.setParams(_tplSyntax);
    _builder.setSyntax(_tplSyntax);
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
    if(_tplTree == null){
      prepare();
    }
    return _tplTree.render(_context);
  }

}

