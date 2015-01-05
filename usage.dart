import 'Templater.dart';
import 'services.dart';

void main(){
  print('Main: print');
  log('test');
  Templater tpl = new Templater.fromFile('usage_tpl.html');
  tpl.prepare();
  //String template = "<html><head><title>{#title#}</title></head><body><h1>{#page.name#}</h1></body></html>";
  //Template tpl = new Templater.fromString(template);
  tpl.put('title', 'Template usage');
  tpl.put({'test' : '123', 'conNum' : 20});
  tpl.put('page', {'name':'Test page'});
  tpl.put('user2', {'name':'Ostap'});
  tpl.put('testWords', ['word_1', 'word_2', 'word_3', 'word_4']);
  //
  String html = tpl.render();
  print(html);

  // Alternative syntax
//  Map syntaxDefinitions = {
//      'startTag' : '<tpl:',
//      'endTag' : '>',
//      'closeTag' : '/',
//      'tagShield' : '<--',
//      'comment' : 'comment'
//  };
  Map syntaxDefinitions = {
      'startTag' : '<%',
      'endTag' : '%>',
      'closeTag' : '/',
      'tagShield' : '<!',
      'comment' : '--'
  };
  Templater altpl = new Templater.fromString(''' <html>
  <head><title><%title%></title></head>
  <body>
  <h1><%page.name%></h1>
  <!<%pseudo tag %> <%-- just a comment%>
  <%if hasCycle%>
    <%for name in names%>
    <% index %>) <% name %>
    <%/%>
  <%/%></body></html> ''');
  altpl.setSyntax(syntaxDefinitions);
  altpl.prepare();

  altpl.put('hasCycle', true);
  altpl.put('title', 'Alter tpl usage');
  altpl.put('page', {'name':'Alter syntax'});
  altpl.put('names', ['Вася', 'Федя', 'Эдя']);

  p(altpl.render());

  // TODO:
  // dot-separated key-values like user.name -done
  // multi-expression with one-operator: if true && x == 10 -done
  // else - done
  // elseif
  // foreach Map
  // range(0, 10, 2)
  // userMethod(name)
  // кеширование связанных функций?
}

class Page{
  String name = '= Test page =';
}