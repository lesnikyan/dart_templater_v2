library dart_templater;

import 'dart:io';
import 'dart:convert';

import 'Parser.dart';
import 'TplNode.dart';
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
  Map<String, Object> _values = new Map<String, Object>();
  Encoding _encoding;

  Templater() {
    // read file
    tplText = "<html><head><title>{#title#}</title></head><body><h1>{#page.name#}</h1></body></html>";
    _init();
  }

  Templater.fromString(String this.tplText){
    _init();
  }

  Templater.fromFile(String this.tplFile){
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
    _init();
  }

  void _init(){
    try{
      p(tplText);
      p("**************************************");
      parser = new Parser();
      List<Lexeme> lexemes = lexemeList(tplText);
      //lexemes.every((Lexeme lex){});
      for(Lexeme lex in lexemes){
        //p("[${lex.type.toString()}:${lex.content}]");
        p(lex.content);
      }
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
    if(key is  Map){
      Map data = key;
      for(String k in data.keys){
        _addValue(k, data[k]);
      }
    } else {
      _addValue(key.toString(), value);
    }
  }

  void _addValue(String key, Object val){
    _values[key] = val;
  }

  String render(){
    for(String k in _values.keys){
      p("$k => ${_values[k].toString()}");
    }
    return "in dev";
  }

}

