Simple Dart Templater.
Dev Version 2.

author: lessmember@gmail.com
pseudonym: sergio.lesnik@gmail.com

What is it?
It is a just simple hand-made templater with flexible syntax.

Tmplr can:
<pre>
1. print value of variable: ' My name is {userName}!' => ' My name is Vasya!', 
	prepared by Template.put(key, val) method.

2. execute blocks in cycle by lists: 
	' {for user in user} &lt;div>User {user.name} has {user.age} years old.&lt;/div> {/}'.
	Each iteration has auto-generated {index} as local var.

3. include logic block by 'if' sentence: 
	{if x < 10 and user.name != "Vasya"} Hello, {user.name}! {/}
	conditions can use complicated expressions:
	{if user.name == 'Vasya' && user.age > 20 && isAdmin} [code of block] {/}
	But only one type of connecting	 logic: && or ||. And without brackets.

4. handle simple var names and fields/getters of objects: 
	{title} {user.name} {data.users.students.first.properties.name}
	-- read sub-value from variable, like object's field.
		But use Map as value in #Templater.put(name, value);
		# instead of real Class Object. Like JS.
		Using of real class.fields seems to be too slow, 
		because needs to use reflections.

5. have comments: {# some comment }

6. Change pattern of includes after running of Tmpltr: 
	from {name} => &lt;%name%&gt;, use Templater.setSyntax(Map);

7. In each inserted block all parent variables exists, 
	and every value requested by variable name will be returned from last possible definition.

8. running methods - in possible plans. // TODO

9. See usage.dart and usage.tpl.html for examples.

TODO:

1. United elseif statement.
2. Flexible values in simplest print expression {"print me"}, {123} 
	instead of just prepared var names (like {user.name}).
</pre>
