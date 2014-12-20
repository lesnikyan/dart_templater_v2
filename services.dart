/**
 * helper functions
 */

void p(Object x){
  print ("${x.toString()}");
}

void log(String msg){
  return;
  File file = new File('tpl.log');
  p(file.absolute);
  if(!file.existsSync()){
    p('No log file!');
    file.createSync(recursive: true);
  }
  file.writeAsStringSync( "\n" +(new DateTime.now().toString()) + " :\n" + msg + "\n", mode: FileMode.APPEND, flush: true);
  p("Log test: $msg ");
}