hxargs
======

A really small command line parser

Usage
======

```haxe
var yourArgHandler = hxargs.Args.generate([
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

[Example](https://github.com/Simn/dox/blob/master/src/dox/Dox.hx#L25-L51)

Features
=======

- parses commands
- comes in a class
