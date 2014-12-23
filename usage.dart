import 'Templater.dart';
import 'services.dart';

void main(){
  print('Main: print');
  log('test');
  Template tpl = new Templater.fromFile('usage_tpl.html');
  //String template = "<html><head><title>{#title#}</title></head><body><h1>{#page.name#}</h1></body></html>";
  //Template tpl = new Templater.fromString(template);
  tpl.put('title', 'Template usage');
  tpl.put({'test' : '123'});
  tpl.put('page.name', 'Test page');
  tpl.put('testWords', ['word_1', 'word_2', 'word_3', 'word_4']);
  //
  String html = tpl.render();
  print(html);
}

class Page{
  String name = '= Test page =';
}