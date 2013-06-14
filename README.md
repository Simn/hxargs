hxargs
======

A really small command line parser

Usage
======

```
var yourArgHandler = args.Args.generate([
	@doc("Documentation for your command")
	["-cmd", "--alternative-command"] => function(arg:String) {
		// action
	},

	_ => function(arg:String) {
		// unknown command
	}
]);

var args = Sys.args();
if (args.length == 0) Sys.println(yourArgHandler.getDoc());
else yourArgHandler.parse(args);
```

Features
=======

- parses commands
- comes in a class