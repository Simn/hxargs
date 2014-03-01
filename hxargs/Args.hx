package hxargs;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;
using StringTools;

class Args {
	macro static public function generate(definition:Expr) {
		var p = Context.currentPos();
		var el = switch(definition.expr) {
			case EArrayDecl(el): el;
			case _: Context.error("Command mapping expected", p);
		}
		
		var unknownArgCallback = macro throw "Unknown command: " +arg;
		
		var docs = [];
		var cases = [];
		var maxCmdLength = 0;
		
		function addDoc(e, s, args:Array<FunctionArg>) {
			var e = switch(e.expr) {
				case EParenthesis(e): e;
				case _: e;
			}
			var argString = args.length == 0 ? "" : " " +args.map(function(arg) return '<${arg.name}>').join(" ");
			var cmdString = e.toString().replace('",', " |").replace('"', "") + argString;
			if (cmdString.length > maxCmdLength)
				maxCmdLength = cmdString.length;
			docs.push({
				cmd: cmdString,
				desc: s
			});
		}
		
		function addCase(cmds, action) {
			var args = [];
			var fArgs = switch(action.expr) {
				case EFunction(name, func):
					for (i in 0...func.args.length) {
						var e = macro __args[__index + $v{i}];
						var e = switch [func.args[i].type, func.args[i].value] {
							case [null, null]: e;
							case [TPath({ name: "String"}), _] | [null, macro $v{(_:String)}]: e;
							case [TPath({ name: "Int"}), _] | [null, macro $v{(_:Int)}]: macro Std.parseInt($e);
							case [TPath({ name: "Float"}), _] | [null, macro $v{(_:Float)}]: macro Std.parseFloat($e);
							case [TPath({ name: "Bool"}), _] | [null, (macro true) | (macro false)]: macro $e == "true" ? true : false;
							case [t, _]: Context.error('Unsupported argument type: $t', action.pos);
						}
						args.push(e);
					}
					func.args;
				case _: Context.error("Function expected", action.pos);
			}
			cmds = switch(cmds.expr) {
				case EMeta({name: "doc", params: [{expr: EConst(CString(s))}]}, e):
					addDoc(e, s, fArgs);
					e;
				case _: cmds;
			}
			var cmds = switch(cmds.expr) {
				case EArrayDecl(el):
					for (e in el) {
						switch(e.expr) {
							case EConst(CString(_)):
							case _: Context.error("String expected", e.pos);
						}
					}
					el;
				case EConst(CIdent("_")):
					unknownArgCallback = macro $action(arg);
					return;
				case EConst(CString(_)): [cmds];
				case _: Context.error("[commands] or command expected", cmds.pos);
			}
			var e = macro {
				if (__index + $v{fArgs.length} > __args.length)
					throw "Not enough arguments: " +__args[__index -1]+ " expects " + $v{fArgs.length};
				${action}($a{args});
				__index += $v{fArgs.length};
			}

			cases.push({
				values: cmds,
				guard: null,
				expr: e
			});
		}
				
		for (e in el) {
			switch(e.expr) {
				case EBinop(OpArrow, cmds, action):
					addCase(cmds, action);
				case _:
					Context.error("Command mapping expected", e.pos);
			}
		}
		
		cases.push({
			values: [macro arg],
			guard: null,
			expr: unknownArgCallback
		});
		
		var eswitch = {
			expr: ESwitch(macro __args[__index++], cases, null),
			pos: p
		};

		return macro {
			getDoc: function() {
				return $v{docs.map(function(doc) return doc.cmd.rpad(" ", maxCmdLength + 1) + ": " +doc.desc).join("\n")};
			},
			parse: function(__args:Array<Dynamic>) {
				var __index = 0;
				while (__index < __args.length) {
					$eswitch;
				}
			}
		}
	}
}