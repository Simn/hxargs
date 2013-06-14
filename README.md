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

yourArgHandler.parse(Sys.args());
```