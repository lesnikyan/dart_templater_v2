Simple Dart Templater.
Dev Version 2.

author: lessmember@gmail.com
pseudonym: sergio.lesnik@gmail.com

What it is?
It is a just simple hand-made templater with flexible syntax.

Tmplr can:
1. print value of variable: ' My name is {userName}!' => ' My name is Vasya!'
2. execute blocks in cycle by lists: ' {for user in user} User {user.name} has {user.age} years old. '
3. include logic block by 'if' sentence: ' {if x < 10 and user.name != "Vasya"} <div>Hello, {user.name}!</div> '
4. handle simple var names and fields/getters of objects: {title} {user.name} {data.users.students.first.properties.name} // TODO
5. have comments: {# some comment }
6. Change pattern of includes after running of Tmpltr: from {name} => <%name%> // TODO
7. running methods - in possible plans. // TODO
