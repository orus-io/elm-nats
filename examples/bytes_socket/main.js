(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

console.warn('Compiled in DEV mode. Follow the advice at https://elm-lang.org/0.19.1/optimize for better performance and smaller assets.');


var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log_UNUSED = F2(function(tag, value)
{
	return value;
});

var _Debug_log = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString_UNUSED(value)
{
	return '<internals>';
}

function _Debug_toString(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash_UNUSED(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.start.line === region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'on lines ' + region.start.line + ' through ' + region.end.line;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**_UNUSED/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**_UNUSED/
	if (typeof x.$ === 'undefined')
	//*/
	/**/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0_UNUSED = 0;
var _Utils_Tuple0 = { $: '#0' };

function _Utils_Tuple2_UNUSED(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3_UNUSED(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr_UNUSED(c) { return c; }
function _Utils_chr(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil_UNUSED = { $: 0 };
var _List_Nil = { $: '[]' };

function _List_Cons_UNUSED(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap(value) { return { $: 0, a: value }; }
function _Json_unwrap(value) { return value.a; }

function _Json_wrap_UNUSED(value) { return value; }
function _Json_unwrap_UNUSED(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**_UNUSED/
	var node = args['node'];
	//*/
	/**/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS
//
// For some reason, tabs can appear in href protocols and it still works.
// So '\tjava\tSCRIPT:alert("!!!")' and 'javascript:alert("!!!")' are the same
// in practice. That is why _VirtualDom_RE_js and _VirtualDom_RE_js_html look
// so freaky.
//
// Pulling the regular expressions out to the top level gives a slight speed
// boost in small benchmarks (4-10%) but hoisting values to reduce allocation
// can be unpredictable in large programs where JIT may have a harder time with
// functions are not fully self-contained. The benefit is more that the js and
// js_html ones are so weird that I prefer to see them near each other.


var _VirtualDom_RE_script = /^script$/i;
var _VirtualDom_RE_on_formAction = /^(on|formAction$)/i;
var _VirtualDom_RE_js = /^\s*j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:/i;
var _VirtualDom_RE_js_html = /^\s*(j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:|d\s*a\s*t\s*a\s*:\s*t\s*e\s*x\s*t\s*\/\s*h\s*t\s*m\s*l\s*(,|;))/i;


function _VirtualDom_noScript(tag)
{
	return _VirtualDom_RE_script.test(tag) ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return _VirtualDom_RE_on_formAction.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return _VirtualDom_RE_js.test(value)
		? /**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return _VirtualDom_RE_js_html.test(value)
		? /**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlJson(value)
{
	return (typeof _Json_unwrap(value) === 'string' && _VirtualDom_RE_js_html.test(_Json_unwrap(value)))
		? _Json_wrap(
			/**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		) : value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		message: func(record.message),
		stopPropagation: record.stopPropagation,
		preventDefault: record.preventDefault
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.message;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.stopPropagation;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.preventDefault) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var view = impl.view;
			/**_UNUSED/
			var domNode = args['node'];
			//*/
			/**/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.setup && impl.setup(sendToApp)
			var view = impl.view;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.body);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.title) && (_VirtualDom_doc.title = title = doc.title);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.onUrlChange;
	var onUrlRequest = impl.onUrlRequest;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		setup: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.protocol === next.protocol
							&& curr.host === next.host
							&& curr.port_.a === next.port_.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		init: function(flags)
		{
			return A3(impl.init, flags, _Browser_getUrl(), key);
		},
		view: impl.view,
		update: impl.update,
		subscriptions: impl.subscriptions
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { hidden: 'hidden', change: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { hidden: 'mozHidden', change: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { hidden: 'msHidden', change: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { hidden: 'webkitHidden', change: 'webkitvisibilitychange' }
		: { hidden: 'hidden', change: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		scene: _Browser_getScene(),
		viewport: {
			x: _Browser_window.pageXOffset,
			y: _Browser_window.pageYOffset,
			width: _Browser_doc.documentElement.clientWidth,
			height: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		width: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		height: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			scene: {
				width: node.scrollWidth,
				height: node.scrollHeight
			},
			viewport: {
				x: node.scrollLeft,
				y: node.scrollTop,
				width: node.clientWidth,
				height: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			scene: _Browser_getScene(),
			viewport: {
				x: x,
				y: y,
				width: _Browser_doc.documentElement.clientWidth,
				height: _Browser_doc.documentElement.clientHeight
			},
			element: {
				x: x + rect.left,
				y: y + rect.top,
				width: rect.width,
				height: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});


// BYTES

function _Bytes_width(bytes)
{
	return bytes.byteLength;
}

var _Bytes_getHostEndianness = F2(function(le, be)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(new Uint8Array(new Uint32Array([1]))[0] === 1 ? le : be));
	});
});


// ENCODERS

function _Bytes_encode(encoder)
{
	var mutableBytes = new DataView(new ArrayBuffer($elm$bytes$Bytes$Encode$getWidth(encoder)));
	$elm$bytes$Bytes$Encode$write(encoder)(mutableBytes)(0);
	return mutableBytes;
}


// SIGNED INTEGERS

var _Bytes_write_i8  = F3(function(mb, i, n) { mb.setInt8(i, n); return i + 1; });
var _Bytes_write_i16 = F4(function(mb, i, n, isLE) { mb.setInt16(i, n, isLE); return i + 2; });
var _Bytes_write_i32 = F4(function(mb, i, n, isLE) { mb.setInt32(i, n, isLE); return i + 4; });


// UNSIGNED INTEGERS

var _Bytes_write_u8  = F3(function(mb, i, n) { mb.setUint8(i, n); return i + 1 ;});
var _Bytes_write_u16 = F4(function(mb, i, n, isLE) { mb.setUint16(i, n, isLE); return i + 2; });
var _Bytes_write_u32 = F4(function(mb, i, n, isLE) { mb.setUint32(i, n, isLE); return i + 4; });


// FLOATS

var _Bytes_write_f32 = F4(function(mb, i, n, isLE) { mb.setFloat32(i, n, isLE); return i + 4; });
var _Bytes_write_f64 = F4(function(mb, i, n, isLE) { mb.setFloat64(i, n, isLE); return i + 8; });


// BYTES

var _Bytes_write_bytes = F3(function(mb, offset, bytes)
{
	for (var i = 0, len = bytes.byteLength, limit = len - 4; i <= limit; i += 4)
	{
		mb.setUint32(offset + i, bytes.getUint32(i));
	}
	for (; i < len; i++)
	{
		mb.setUint8(offset + i, bytes.getUint8(i));
	}
	return offset + len;
});


// STRINGS

function _Bytes_getStringWidth(string)
{
	for (var width = 0, i = 0; i < string.length; i++)
	{
		var code = string.charCodeAt(i);
		width +=
			(code < 0x80) ? 1 :
			(code < 0x800) ? 2 :
			(code < 0xD800 || 0xDBFF < code) ? 3 : (i++, 4);
	}
	return width;
}

var _Bytes_write_string = F3(function(mb, offset, string)
{
	for (var i = 0; i < string.length; i++)
	{
		var code = string.charCodeAt(i);
		offset +=
			(code < 0x80)
				? (mb.setUint8(offset, code)
				, 1
				)
				:
			(code < 0x800)
				? (mb.setUint16(offset, 0xC080 /* 0b1100000010000000 */
					| (code >>> 6 & 0x1F /* 0b00011111 */) << 8
					| code & 0x3F /* 0b00111111 */)
				, 2
				)
				:
			(code < 0xD800 || 0xDBFF < code)
				? (mb.setUint16(offset, 0xE080 /* 0b1110000010000000 */
					| (code >>> 12 & 0xF /* 0b00001111 */) << 8
					| code >>> 6 & 0x3F /* 0b00111111 */)
				, mb.setUint8(offset + 2, 0x80 /* 0b10000000 */
					| code & 0x3F /* 0b00111111 */)
				, 3
				)
				:
			(code = (code - 0xD800) * 0x400 + string.charCodeAt(++i) - 0xDC00 + 0x10000
			, mb.setUint32(offset, 0xF0808080 /* 0b11110000100000001000000010000000 */
				| (code >>> 18 & 0x7 /* 0b00000111 */) << 24
				| (code >>> 12 & 0x3F /* 0b00111111 */) << 16
				| (code >>> 6 & 0x3F /* 0b00111111 */) << 8
				| code & 0x3F /* 0b00111111 */)
			, 4
			);
	}
	return offset;
});


// DECODER

var _Bytes_decode = F2(function(decoder, bytes)
{
	try {
		return $elm$core$Maybe$Just(A2(decoder, bytes, 0).b);
	} catch(e) {
		return $elm$core$Maybe$Nothing;
	}
});

var _Bytes_read_i8  = F2(function(      bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getInt8(offset)); });
var _Bytes_read_i16 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getInt16(offset, isLE)); });
var _Bytes_read_i32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getInt32(offset, isLE)); });
var _Bytes_read_u8  = F2(function(      bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getUint8(offset)); });
var _Bytes_read_u16 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getUint16(offset, isLE)); });
var _Bytes_read_u32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getUint32(offset, isLE)); });
var _Bytes_read_f32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getFloat32(offset, isLE)); });
var _Bytes_read_f64 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 8, bytes.getFloat64(offset, isLE)); });

var _Bytes_read_bytes = F3(function(len, bytes, offset)
{
	return _Utils_Tuple2(offset + len, new DataView(bytes.buffer, bytes.byteOffset + offset, len));
});

var _Bytes_read_string = F3(function(len, bytes, offset)
{
	var string = '';
	var end = offset + len;
	for (; offset < end;)
	{
		var byte = bytes.getUint8(offset++);
		string +=
			(byte < 128)
				? String.fromCharCode(byte)
				:
			((byte & 0xE0 /* 0b11100000 */) === 0xC0 /* 0b11000000 */)
				? String.fromCharCode((byte & 0x1F /* 0b00011111 */) << 6 | bytes.getUint8(offset++) & 0x3F /* 0b00111111 */)
				:
			((byte & 0xF0 /* 0b11110000 */) === 0xE0 /* 0b11100000 */)
				? String.fromCharCode(
					(byte & 0xF /* 0b00001111 */) << 12
					| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 6
					| bytes.getUint8(offset++) & 0x3F /* 0b00111111 */
				)
				:
				(byte =
					((byte & 0x7 /* 0b00000111 */) << 18
						| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 12
						| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 6
						| bytes.getUint8(offset++) & 0x3F /* 0b00111111 */
					) - 0x10000
				, String.fromCharCode(Math.floor(byte / 0x400) + 0xD800, byte % 0x400 + 0xDC00)
				);
	}
	return _Utils_Tuple2(offset, string);
});

var _Bytes_decodeFailure = F2(function() { throw 0; });


// CREATE

var _Regex_never = /.^/;

var _Regex_fromStringWith = F2(function(options, string)
{
	var flags = 'g';
	if (options.multiline) { flags += 'm'; }
	if (options.caseInsensitive) { flags += 'i'; }

	try
	{
		return $elm$core$Maybe$Just(new RegExp(string, flags));
	}
	catch(error)
	{
		return $elm$core$Maybe$Nothing;
	}
});


// USE

var _Regex_contains = F2(function(re, string)
{
	return string.match(re) !== null;
});


var _Regex_findAtMost = F3(function(n, re, str)
{
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex == re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		out.push(A4($elm$regex$Regex$Match, result[0], result.index, number, _List_fromArray(subs)));
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _List_fromArray(out);
});


var _Regex_replaceAtMost = F4(function(n, re, replacer, string)
{
	var count = 0;
	function jsReplacer(match)
	{
		if (count++ >= n)
		{
			return match;
		}
		var i = arguments.length - 3;
		var submatches = new Array(i);
		while (i > 0)
		{
			var submatch = arguments[i];
			submatches[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		return replacer(A4($elm$regex$Regex$Match, match, arguments[arguments.length - 2], count, _List_fromArray(submatches)));
	}
	return string.replace(re, jsReplacer);
});

var _Regex_splitAtMost = F3(function(n, re, str)
{
	var string = str;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		var result = re.exec(string);
		if (!result) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _List_fromArray(out);
});

var _Regex_infinity = Infinity;



function _Time_now(millisToPosix)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(millisToPosix(Date.now())));
	});
}

var _Time_setInterval = F2(function(interval, task)
{
	return _Scheduler_binding(function(callback)
	{
		var id = setInterval(function() { _Scheduler_rawSpawn(task); }, interval);
		return function() { clearInterval(id); };
	});
});

function _Time_here()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(
			A2($elm$time$Time$customZone, -(new Date().getTimezoneOffset()), _List_Nil)
		));
	});
}


function _Time_getZoneName()
{
	return _Scheduler_binding(function(callback)
	{
		try
		{
			var name = $elm$time$Time$Name(Intl.DateTimeFormat().resolvedOptions().timeZone);
		}
		catch (e)
		{
			var name = $elm$time$Time$Offset(new Date().getTimezoneOffset());
		}
		callback(_Scheduler_succeed(name));
	});
}
var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0.a;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$EQ = {$: 'EQ'};
var $elm$core$Basics$GT = {$: 'GT'};
var $elm$core$Basics$LT = {$: 'LT'};
var $elm$core$Result$Err = function (a) {
	return {$: 'Err', a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 'Field', a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 'Index', a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 'Ok', a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 'OneOf', a: a};
};
var $elm$core$Basics$False = {$: 'False'};
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 'Just', a: a};
};
var $elm$core$Maybe$Nothing = {$: 'Nothing'};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 'Field':
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 'Nothing') {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'Index':
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'OneOf':
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 'Array_elm_builtin', a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 'SubTree', a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.nodeListSize) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.tail);
		} else {
			var treeLen = builder.nodeListSize * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.nodeList) : builder.nodeList;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.nodeListSize);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.tail);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{nodeList: nodeList, nodeListSize: (len / $elm$core$Array$branchFactor) | 0, tail: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = {$: 'True'};
var $elm$core$Result$isOk = function (result) {
	if (result.$ === 'Ok') {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 'Normal':
			return 0;
		case 'MayStopPropagation':
			return 1;
		case 'MayPreventDefault':
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 'External', a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 'Internal', a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = function (a) {
	return {$: 'NotFound', a: a};
};
var $elm$url$Url$Http = {$: 'Http'};
var $elm$url$Url$Https = {$: 'Https'};
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {fragment: fragment, host: host, path: path, port_: port_, protocol: protocol, query: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 'Nothing') {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Http,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Https,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0.a;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = function (a) {
	return {$: 'Perform', a: a};
};
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(_Utils_Tuple0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0.a;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return _Utils_Tuple0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(_Utils_Tuple0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0.a;
		return $elm$core$Task$Perform(
			A2($elm$core$Task$map, tagger, task));
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2($elm$core$Task$map, toMessage, task)));
	});
var $elm$browser$Browser$document = _Browser_document;
var $elm$json$Json$Decode$field = _Json_decodeField;
var $author$project$Nats$State = function (a) {
	return {$: 'State', a: a};
};
var $author$project$Nats$Internal$SocketStateCollection$SocketStateCollection = function (a) {
	return {$: 'SocketStateCollection', a: a};
};
var $author$project$Nats$Internal$SocketStateCollection$empty = $author$project$Nats$Internal$SocketStateCollection$SocketStateCollection(_List_Nil);
var $author$project$Nats$Nuid$Nuid = F3(
	function (a, b, c) {
		return {$: 'Nuid', a: a, b: b, c: c};
	});
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $elm$core$Basics$abs = function (n) {
	return (n < 0) ? (-n) : n;
};
var $elm$random$Random$Generator = function (a) {
	return {$: 'Generator', a: a};
};
var $elm$random$Random$andThen = F2(
	function (callback, _v0) {
		var genA = _v0.a;
		return $elm$random$Random$Generator(
			function (seed) {
				var _v1 = genA(seed);
				var result = _v1.a;
				var newSeed = _v1.b;
				var _v2 = callback(result);
				var genB = _v2.a;
				return genB(newSeed);
			});
	});
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$random$Random$Seed = F2(
	function (a, b) {
		return {$: 'Seed', a: a, b: b};
	});
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$random$Random$next = function (_v0) {
	var state0 = _v0.a;
	var incr = _v0.b;
	return A2($elm$random$Random$Seed, ((state0 * 1664525) + incr) >>> 0, incr);
};
var $elm$core$Bitwise$xor = _Bitwise_xor;
var $elm$random$Random$peel = function (_v0) {
	var state = _v0.a;
	var word = (state ^ (state >>> ((state >>> 28) + 4))) * 277803737;
	return ((word >>> 22) ^ word) >>> 0;
};
var $elm$random$Random$float = F2(
	function (a, b) {
		return $elm$random$Random$Generator(
			function (seed0) {
				var seed1 = $elm$random$Random$next(seed0);
				var range = $elm$core$Basics$abs(b - a);
				var n1 = $elm$random$Random$peel(seed1);
				var n0 = $elm$random$Random$peel(seed0);
				var lo = (134217727 & n1) * 1.0;
				var hi = (67108863 & n0) * 1.0;
				var val = ((hi * 134217728.0) + lo) / 9007199254740992.0;
				var scaled = (val * range) + a;
				return _Utils_Tuple2(
					scaled,
					$elm$random$Random$next(seed1));
			});
	});
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $elm$core$List$sum = function (numbers) {
	return A3($elm$core$List$foldl, $elm$core$Basics$add, 0, numbers);
};
var $elm_community$random_extra$Random$Extra$frequency = F2(
	function (head, pairs) {
		var total = $elm$core$List$sum(
			A2(
				$elm$core$List$map,
				A2($elm$core$Basics$composeL, $elm$core$Basics$abs, $elm$core$Tuple$first),
				A2($elm$core$List$cons, head, pairs)));
		var pick = F2(
			function (someChoices, n) {
				pick:
				while (true) {
					if (someChoices.b) {
						var _v1 = someChoices.a;
						var k = _v1.a;
						var g = _v1.b;
						var rest = someChoices.b;
						if (_Utils_cmp(n, k) < 1) {
							return g;
						} else {
							var $temp$someChoices = rest,
								$temp$n = n - k;
							someChoices = $temp$someChoices;
							n = $temp$n;
							continue pick;
						}
					} else {
						return head.b;
					}
				}
			});
		return A2(
			$elm$random$Random$andThen,
			pick(
				A2($elm$core$List$cons, head, pairs)),
			A2($elm$random$Random$float, 0, total));
	});
var $elm_community$random_extra$Random$Extra$choices = F2(
	function (hd, gens) {
		return A2(
			$elm_community$random_extra$Random$Extra$frequency,
			_Utils_Tuple2(1, hd),
			A2(
				$elm$core$List$map,
				function (g) {
					return _Utils_Tuple2(1, g);
				},
				gens));
	});
var $elm$core$Char$fromCode = _Char_fromCode;
var $elm$random$Random$int = F2(
	function (a, b) {
		return $elm$random$Random$Generator(
			function (seed0) {
				var _v0 = (_Utils_cmp(a, b) < 0) ? _Utils_Tuple2(a, b) : _Utils_Tuple2(b, a);
				var lo = _v0.a;
				var hi = _v0.b;
				var range = (hi - lo) + 1;
				if (!((range - 1) & range)) {
					return _Utils_Tuple2(
						(((range - 1) & $elm$random$Random$peel(seed0)) >>> 0) + lo,
						$elm$random$Random$next(seed0));
				} else {
					var threshhold = (((-range) >>> 0) % range) >>> 0;
					var accountForBias = function (seed) {
						accountForBias:
						while (true) {
							var x = $elm$random$Random$peel(seed);
							var seedN = $elm$random$Random$next(seed);
							if (_Utils_cmp(x, threshhold) < 0) {
								var $temp$seed = seedN;
								seed = $temp$seed;
								continue accountForBias;
							} else {
								return _Utils_Tuple2((x % range) + lo, seedN);
							}
						}
					};
					return accountForBias(seed0);
				}
			});
	});
var $elm$random$Random$map = F2(
	function (func, _v0) {
		var genA = _v0.a;
		return $elm$random$Random$Generator(
			function (seed0) {
				var _v1 = genA(seed0);
				var a = _v1.a;
				var seed1 = _v1.b;
				return _Utils_Tuple2(
					func(a),
					seed1);
			});
	});
var $elm_community$random_extra$Random$Char$char = F2(
	function (start, end) {
		return A2(
			$elm$random$Random$map,
			$elm$core$Char$fromCode,
			A2($elm$random$Random$int, start, end));
	});
var $elm_community$random_extra$Random$Char$lowerCaseLatin = A2($elm_community$random_extra$Random$Char$char, 97, 122);
var $author$project$Nats$Nuid$num = A2($elm_community$random_extra$Random$Char$char, 48, 57);
var $elm_community$random_extra$Random$Char$upperCaseLatin = A2($elm_community$random_extra$Random$Char$char, 65, 90);
var $author$project$Nats$Nuid$alphaNum = A2(
	$elm_community$random_extra$Random$Extra$choices,
	$elm_community$random_extra$Random$Char$lowerCaseLatin,
	_List_fromArray(
		[$elm_community$random_extra$Random$Char$upperCaseLatin, $author$project$Nats$Nuid$num]));
var $author$project$Nats$Nuid$defaultLen = 22;
var $author$project$Nats$Nuid$new = A2($author$project$Nats$Nuid$Nuid, $author$project$Nats$Nuid$defaultLen, $author$project$Nats$Nuid$alphaNum);
var $elm$random$Random$step = F2(
	function (_v0, seed) {
		var generator = _v0.a;
		return generator(seed);
	});
var $elm$core$String$fromList = _String_fromList;
var $elm$random$Random$listHelp = F4(
	function (revList, n, gen, seed) {
		listHelp:
		while (true) {
			if (n < 1) {
				return _Utils_Tuple2(revList, seed);
			} else {
				var _v0 = gen(seed);
				var value = _v0.a;
				var newSeed = _v0.b;
				var $temp$revList = A2($elm$core$List$cons, value, revList),
					$temp$n = n - 1,
					$temp$gen = gen,
					$temp$seed = newSeed;
				revList = $temp$revList;
				n = $temp$n;
				gen = $temp$gen;
				seed = $temp$seed;
				continue listHelp;
			}
		}
	});
var $elm$random$Random$list = F2(
	function (n, _v0) {
		var gen = _v0.a;
		return $elm$random$Random$Generator(
			function (seed) {
				return A4($elm$random$Random$listHelp, _List_Nil, n, gen, seed);
			});
	});
var $elm_community$random_extra$Random$String$string = F2(
	function (stringLength, charGenerator) {
		return A2(
			$elm$random$Random$map,
			$elm$core$String$fromList,
			A2($elm$random$Random$list, stringLength, charGenerator));
	});
var $author$project$Nats$Nuid$next = function (_v0) {
	var len = _v0.a;
	var charGen = _v0.b;
	var seed = _v0.c;
	var _v1 = A2(
		$elm$random$Random$step,
		A2($elm_community$random_extra$Random$String$string, len, charGen),
		seed);
	var value = _v1.a;
	var nextSeed = _v1.b;
	return _Utils_Tuple2(
		value,
		A3($author$project$Nats$Nuid$Nuid, len, charGen, nextSeed));
};
var $elm$time$Time$posixToMillis = function (_v0) {
	var millis = _v0.a;
	return millis;
};
var $author$project$Nats$init = F2(
	function (seed, now) {
		var _v0 = $author$project$Nats$Nuid$next(
			$author$project$Nats$Nuid$new(seed));
		var inboxPrefix = _v0.a;
		var nuid = _v0.b;
		return $author$project$Nats$State(
			{
				defaultSocket: $elm$core$Maybe$Nothing,
				inboxPrefix: inboxPrefix + '.',
				nuid: nuid,
				sockets: $author$project$Nats$Internal$SocketStateCollection$empty,
				time: $elm$time$Time$posixToMillis(now)
			});
	});
var $author$project$SubComp$init = {received: _List_Nil, subCounter: 0};
var $elm$random$Random$initialSeed = function (x) {
	var _v0 = $elm$random$Random$next(
		A2($elm$random$Random$Seed, 0, 1013904223));
	var state1 = _v0.a;
	var incr = _v0.b;
	var state2 = (state1 + x) >>> 0;
	return $elm$random$Random$next(
		A2($elm$random$Random$Seed, state2, incr));
};
var $elm$time$Time$Posix = function (a) {
	return {$: 'Posix', a: a};
};
var $elm$time$Time$millisToPosix = $elm$time$Time$Posix;
var $author$project$Nats$Internal$Types$Socket = function (a) {
	return {$: 'Socket', a: a};
};
var $author$project$Nats$Socket$new = F2(
	function (sid, url) {
		return $author$project$Nats$Internal$Types$Socket(
			{debug: false, _default: false, id: sid, url: url});
	});
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $author$project$Main$init = function (flags) {
	var nats = A2(
		$author$project$Nats$init,
		$elm$random$Random$initialSeed(flags.now),
		$elm$time$Time$millisToPosix(flags.now));
	return _Utils_Tuple2(
		{
			inputText: '',
			nats: nats,
			response: $elm$core$Maybe$Nothing,
			serverInfo: $elm$core$Maybe$Nothing,
			socket: A2($author$project$Nats$Socket$new, '0', 'ws://localhost:8087'),
			subcomp: $author$project$SubComp$init
		},
		$elm$core$Platform$Cmd$none);
};
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $author$project$Main$NatsMsg = function (a) {
	return {$: 'NatsMsg', a: a};
};
var $chelovek0v$bbase64$Base64$Decode$Decoder = function (a) {
	return {$: 'Decoder', a: a};
};
var $elm$bytes$Bytes$Encode$getWidth = function (builder) {
	switch (builder.$) {
		case 'I8':
			return 1;
		case 'I16':
			return 2;
		case 'I32':
			return 4;
		case 'U8':
			return 1;
		case 'U16':
			return 2;
		case 'U32':
			return 4;
		case 'F32':
			return 4;
		case 'F64':
			return 8;
		case 'Seq':
			var w = builder.a;
			return w;
		case 'Utf8':
			var w = builder.a;
			return w;
		default:
			var bs = builder.a;
			return _Bytes_width(bs);
	}
};
var $elm$bytes$Bytes$LE = {$: 'LE'};
var $elm$bytes$Bytes$Encode$write = F3(
	function (builder, mb, offset) {
		switch (builder.$) {
			case 'I8':
				var n = builder.a;
				return A3(_Bytes_write_i8, mb, offset, n);
			case 'I16':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_i16,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'I32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_i32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'U8':
				var n = builder.a;
				return A3(_Bytes_write_u8, mb, offset, n);
			case 'U16':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_u16,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'U32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_u32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'F32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_f32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'F64':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_f64,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'Seq':
				var bs = builder.b;
				return A3($elm$bytes$Bytes$Encode$writeSequence, bs, mb, offset);
			case 'Utf8':
				var s = builder.b;
				return A3(_Bytes_write_string, mb, offset, s);
			default:
				var bs = builder.a;
				return A3(_Bytes_write_bytes, mb, offset, bs);
		}
	});
var $elm$bytes$Bytes$Encode$writeSequence = F3(
	function (builders, mb, offset) {
		writeSequence:
		while (true) {
			if (!builders.b) {
				return offset;
			} else {
				var b = builders.a;
				var bs = builders.b;
				var $temp$builders = bs,
					$temp$mb = mb,
					$temp$offset = A3($elm$bytes$Bytes$Encode$write, b, mb, offset);
				builders = $temp$builders;
				mb = $temp$mb;
				offset = $temp$offset;
				continue writeSequence;
			}
		}
	});
var $elm$bytes$Bytes$Encode$encode = _Bytes_encode;
var $elm$bytes$Bytes$Encode$Seq = F2(
	function (a, b) {
		return {$: 'Seq', a: a, b: b};
	});
var $elm$bytes$Bytes$Encode$getWidths = F2(
	function (width, builders) {
		getWidths:
		while (true) {
			if (!builders.b) {
				return width;
			} else {
				var b = builders.a;
				var bs = builders.b;
				var $temp$width = width + $elm$bytes$Bytes$Encode$getWidth(b),
					$temp$builders = bs;
				width = $temp$width;
				builders = $temp$builders;
				continue getWidths;
			}
		}
	});
var $elm$bytes$Bytes$Encode$sequence = function (builders) {
	return A2(
		$elm$bytes$Bytes$Encode$Seq,
		A2($elm$bytes$Bytes$Encode$getWidths, 0, builders),
		builders);
};
var $chelovek0v$bbase64$Base64$Decode$encodeBytes = function (encoders) {
	return $elm$bytes$Bytes$Encode$encode(
		$elm$bytes$Bytes$Encode$sequence(
			$elm$core$List$reverse(encoders)));
};
var $elm$core$Result$andThen = F2(
	function (callback, result) {
		if (result.$ === 'Ok') {
			var value = result.a;
			return callback(value);
		} else {
			var msg = result.a;
			return $elm$core$Result$Err(msg);
		}
	});
var $elm$core$Dict$RBEmpty_elm_builtin = {$: 'RBEmpty_elm_builtin'};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Dict$Black = {$: 'Black'};
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: 'RBNode_elm_builtin', a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$Red = {$: 'Red'};
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Red')) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) && (left.d.$ === 'RBNode_elm_builtin')) && (left.d.a.$ === 'Red')) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1.$) {
				case 'LT':
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 'EQ':
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $chelovek0v$bbase64$Base64$Table$charToCodeMap = $elm$core$Dict$fromList(
	_List_fromArray(
		[
			_Utils_Tuple2('A', 0),
			_Utils_Tuple2('B', 1),
			_Utils_Tuple2('C', 2),
			_Utils_Tuple2('D', 3),
			_Utils_Tuple2('E', 4),
			_Utils_Tuple2('F', 5),
			_Utils_Tuple2('G', 6),
			_Utils_Tuple2('H', 7),
			_Utils_Tuple2('I', 8),
			_Utils_Tuple2('J', 9),
			_Utils_Tuple2('K', 10),
			_Utils_Tuple2('L', 11),
			_Utils_Tuple2('M', 12),
			_Utils_Tuple2('N', 13),
			_Utils_Tuple2('O', 14),
			_Utils_Tuple2('P', 15),
			_Utils_Tuple2('Q', 16),
			_Utils_Tuple2('R', 17),
			_Utils_Tuple2('S', 18),
			_Utils_Tuple2('T', 19),
			_Utils_Tuple2('U', 20),
			_Utils_Tuple2('V', 21),
			_Utils_Tuple2('W', 22),
			_Utils_Tuple2('X', 23),
			_Utils_Tuple2('Y', 24),
			_Utils_Tuple2('Z', 25),
			_Utils_Tuple2('a', 26),
			_Utils_Tuple2('b', 27),
			_Utils_Tuple2('c', 28),
			_Utils_Tuple2('d', 29),
			_Utils_Tuple2('e', 30),
			_Utils_Tuple2('f', 31),
			_Utils_Tuple2('g', 32),
			_Utils_Tuple2('h', 33),
			_Utils_Tuple2('i', 34),
			_Utils_Tuple2('j', 35),
			_Utils_Tuple2('k', 36),
			_Utils_Tuple2('l', 37),
			_Utils_Tuple2('m', 38),
			_Utils_Tuple2('n', 39),
			_Utils_Tuple2('o', 40),
			_Utils_Tuple2('p', 41),
			_Utils_Tuple2('q', 42),
			_Utils_Tuple2('r', 43),
			_Utils_Tuple2('s', 44),
			_Utils_Tuple2('t', 45),
			_Utils_Tuple2('u', 46),
			_Utils_Tuple2('v', 47),
			_Utils_Tuple2('w', 48),
			_Utils_Tuple2('x', 49),
			_Utils_Tuple2('y', 50),
			_Utils_Tuple2('z', 51),
			_Utils_Tuple2('0', 52),
			_Utils_Tuple2('1', 53),
			_Utils_Tuple2('2', 54),
			_Utils_Tuple2('3', 55),
			_Utils_Tuple2('4', 56),
			_Utils_Tuple2('5', 57),
			_Utils_Tuple2('6', 58),
			_Utils_Tuple2('7', 59),
			_Utils_Tuple2('8', 60),
			_Utils_Tuple2('9', 61),
			_Utils_Tuple2('+', 62),
			_Utils_Tuple2('/', 63)
		]));
var $elm$core$String$cons = _String_cons;
var $elm$core$String$fromChar = function (_char) {
	return A2($elm$core$String$cons, _char, '');
};
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1.$) {
					case 'LT':
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 'EQ':
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $chelovek0v$bbase64$Base64$Table$decode = function (_char) {
	return A2(
		$elm$core$Dict$get,
		$elm$core$String$fromChar(_char),
		$chelovek0v$bbase64$Base64$Table$charToCodeMap);
};
var $chelovek0v$bbase64$Base64$Shift$Shift2 = {$: 'Shift2'};
var $chelovek0v$bbase64$Base64$Shift$Shift4 = {$: 'Shift4'};
var $chelovek0v$bbase64$Base64$Shift$Shift6 = {$: 'Shift6'};
var $chelovek0v$bbase64$Base64$Shift$Shift0 = {$: 'Shift0'};
var $chelovek0v$bbase64$Base64$Shift$decodeNext = function (shift) {
	switch (shift.$) {
		case 'Shift0':
			return $chelovek0v$bbase64$Base64$Shift$Shift2;
		case 'Shift2':
			return $chelovek0v$bbase64$Base64$Shift$Shift4;
		case 'Shift4':
			return $chelovek0v$bbase64$Base64$Shift$Shift6;
		default:
			return $chelovek0v$bbase64$Base64$Shift$Shift0;
	}
};
var $elm$core$Bitwise$or = _Bitwise_or;
var $chelovek0v$bbase64$Base64$Shift$toInt = function (shift) {
	switch (shift.$) {
		case 'Shift0':
			return 0;
		case 'Shift2':
			return 2;
		case 'Shift4':
			return 4;
		default:
			return 6;
	}
};
var $chelovek0v$bbase64$Base64$Shift$shiftRightZfBy = F2(
	function (shift, value) {
		return value >>> $chelovek0v$bbase64$Base64$Shift$toInt(shift);
	});
var $chelovek0v$bbase64$Base64$Decode$finishPartialByte = F3(
	function (shift, sextet, partialByte) {
		return partialByte | A2($chelovek0v$bbase64$Base64$Shift$shiftRightZfBy, shift, sextet);
	});
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $chelovek0v$bbase64$Base64$Shift$shiftLeftBy = F2(
	function (shift, value) {
		return value << $chelovek0v$bbase64$Base64$Shift$toInt(shift);
	});
var $elm$bytes$Bytes$Encode$U8 = function (a) {
	return {$: 'U8', a: a};
};
var $elm$bytes$Bytes$Encode$unsignedInt8 = $elm$bytes$Bytes$Encode$U8;
var $chelovek0v$bbase64$Base64$Decode$decodeStep = F2(
	function (sextet, _v0) {
		var shift = _v0.a;
		var partialByte = _v0.b;
		var deferredEncoders = _v0.c;
		var nextBlankByte = function () {
			switch (shift.$) {
				case 'Shift0':
					return A2($chelovek0v$bbase64$Base64$Shift$shiftLeftBy, $chelovek0v$bbase64$Base64$Shift$Shift2, sextet);
				case 'Shift2':
					return A2($chelovek0v$bbase64$Base64$Shift$shiftLeftBy, $chelovek0v$bbase64$Base64$Shift$Shift4, sextet);
				case 'Shift4':
					return A2($chelovek0v$bbase64$Base64$Shift$shiftLeftBy, $chelovek0v$bbase64$Base64$Shift$Shift6, sextet);
				default:
					return 0;
			}
		}();
		var finishedByte = function () {
			switch (shift.$) {
				case 'Shift0':
					return $elm$core$Maybe$Nothing;
				case 'Shift2':
					return $elm$core$Maybe$Just(
						A3($chelovek0v$bbase64$Base64$Decode$finishPartialByte, $chelovek0v$bbase64$Base64$Shift$Shift4, sextet, partialByte));
				case 'Shift4':
					return $elm$core$Maybe$Just(
						A3($chelovek0v$bbase64$Base64$Decode$finishPartialByte, $chelovek0v$bbase64$Base64$Shift$Shift2, sextet, partialByte));
				default:
					return $elm$core$Maybe$Just(partialByte | sextet);
			}
		}();
		var nextDeferredDecoders = function () {
			if (finishedByte.$ === 'Just') {
				var byte_ = finishedByte.a;
				return A2(
					$elm$core$List$cons,
					$elm$bytes$Bytes$Encode$unsignedInt8(byte_),
					deferredEncoders);
			} else {
				return deferredEncoders;
			}
		}();
		return _Utils_Tuple3(
			$chelovek0v$bbase64$Base64$Shift$decodeNext(shift),
			nextBlankByte,
			nextDeferredDecoders);
	});
var $elm$core$String$foldl = _String_foldl;
var $chelovek0v$bbase64$Base64$Decode$initialState = _Utils_Tuple3($chelovek0v$bbase64$Base64$Shift$Shift0, 0, _List_Nil);
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Result$map = F2(
	function (func, ra) {
		if (ra.$ === 'Ok') {
			var a = ra.a;
			return $elm$core$Result$Ok(
				func(a));
		} else {
			var e = ra.a;
			return $elm$core$Result$Err(e);
		}
	});
var $elm$core$String$dropRight = F2(
	function (n, string) {
		return (n < 1) ? string : A3($elm$core$String$slice, 0, -n, string);
	});
var $elm$core$String$endsWith = _String_endsWith;
var $chelovek0v$bbase64$Base64$Decode$strip = function (input) {
	return A2($elm$core$String$endsWith, '==', input) ? $elm$core$Result$Ok(
		A2($elm$core$String$dropRight, 2, input)) : (A2($elm$core$String$endsWith, '=', input) ? $elm$core$Result$Ok(
		A2($elm$core$String$dropRight, 1, input)) : $elm$core$Result$Ok(input));
};
var $chelovek0v$bbase64$Base64$Decode$ValidationError = {$: 'ValidationError'};
var $elm$regex$Regex$Match = F4(
	function (match, index, number, submatches) {
		return {index: index, match: match, number: number, submatches: submatches};
	});
var $elm$regex$Regex$contains = _Regex_contains;
var $elm$regex$Regex$fromStringWith = _Regex_fromStringWith;
var $elm$regex$Regex$fromString = function (string) {
	return A2(
		$elm$regex$Regex$fromStringWith,
		{caseInsensitive: false, multiline: false},
		string);
};
var $elm$regex$Regex$never = _Regex_never;
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $chelovek0v$bbase64$Base64$Decode$validate = function (input) {
	var regex = A2(
		$elm$core$Maybe$withDefault,
		$elm$regex$Regex$never,
		$elm$regex$Regex$fromString('^[A-Za-z0-9\\/+]*$'));
	return A2($elm$regex$Regex$contains, regex, input) ? $elm$core$Result$Ok(input) : $elm$core$Result$Err($chelovek0v$bbase64$Base64$Decode$ValidationError);
};
var $chelovek0v$bbase64$Base64$Decode$tryDecode = function (input) {
	return A2(
		$elm$core$Result$map,
		A2(
			$elm$core$String$foldl,
			F2(
				function (_char, state) {
					return A2(
						$elm$core$Maybe$withDefault,
						state,
						A2(
							$elm$core$Maybe$map,
							function (sextet) {
								return A2($chelovek0v$bbase64$Base64$Decode$decodeStep, sextet, state);
							},
							$chelovek0v$bbase64$Base64$Table$decode(_char)));
				}),
			$chelovek0v$bbase64$Base64$Decode$initialState),
		A2(
			$elm$core$Result$andThen,
			$chelovek0v$bbase64$Base64$Decode$validate,
			$chelovek0v$bbase64$Base64$Decode$strip(input)));
};
var $chelovek0v$bbase64$Base64$Decode$bytes = $chelovek0v$bbase64$Base64$Decode$Decoder(
	function (input) {
		var _v0 = $chelovek0v$bbase64$Base64$Decode$tryDecode(input);
		if (_v0.$ === 'Ok') {
			var _v1 = _v0.a;
			var deferredEncoders = _v1.c;
			return $elm$core$Result$Ok(
				$chelovek0v$bbase64$Base64$Decode$encodeBytes(deferredEncoders));
		} else {
			var e = _v0.a;
			return $elm$core$Result$Err(e);
		}
	});
var $chelovek0v$bbase64$Base64$Encode$BytesEncoder = function (a) {
	return {$: 'BytesEncoder', a: a};
};
var $chelovek0v$bbase64$Base64$Encode$bytes = function (input) {
	return $chelovek0v$bbase64$Base64$Encode$BytesEncoder(input);
};
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $chelovek0v$bbase64$Base64$Decode$decode = F2(
	function (_v0, input) {
		var decoder = _v0.a;
		return decoder(input);
	});
var $elm$bytes$Bytes$Encode$Utf8 = F2(
	function (a, b) {
		return {$: 'Utf8', a: a, b: b};
	});
var $elm$bytes$Bytes$Encode$string = function (str) {
	return A2(
		$elm$bytes$Bytes$Encode$Utf8,
		_Bytes_getStringWidth(str),
		str);
};
var $elm$bytes$Bytes$Decode$decode = F2(
	function (_v0, bs) {
		var decoder = _v0.a;
		return A2(_Bytes_decode, decoder, bs);
	});
var $elm$bytes$Bytes$Decode$Done = function (a) {
	return {$: 'Done', a: a};
};
var $elm$bytes$Bytes$Decode$Loop = function (a) {
	return {$: 'Loop', a: a};
};
var $chelovek0v$bbase64$Base64$Shift$and = F2(
	function (shift, value) {
		switch (shift.$) {
			case 'Shift0':
				return value;
			case 'Shift2':
				return 3 & value;
			case 'Shift4':
				return 15 & value;
			default:
				return 63 & value;
		}
	});
var $chelovek0v$bbase64$Base64$Table$codeToCharMap = $elm$core$Dict$fromList(
	_List_fromArray(
		[
			_Utils_Tuple2(0, 'A'),
			_Utils_Tuple2(1, 'B'),
			_Utils_Tuple2(2, 'C'),
			_Utils_Tuple2(3, 'D'),
			_Utils_Tuple2(4, 'E'),
			_Utils_Tuple2(5, 'F'),
			_Utils_Tuple2(6, 'G'),
			_Utils_Tuple2(7, 'H'),
			_Utils_Tuple2(8, 'I'),
			_Utils_Tuple2(9, 'J'),
			_Utils_Tuple2(10, 'K'),
			_Utils_Tuple2(11, 'L'),
			_Utils_Tuple2(12, 'M'),
			_Utils_Tuple2(13, 'N'),
			_Utils_Tuple2(14, 'O'),
			_Utils_Tuple2(15, 'P'),
			_Utils_Tuple2(16, 'Q'),
			_Utils_Tuple2(17, 'R'),
			_Utils_Tuple2(18, 'S'),
			_Utils_Tuple2(19, 'T'),
			_Utils_Tuple2(20, 'U'),
			_Utils_Tuple2(21, 'V'),
			_Utils_Tuple2(22, 'W'),
			_Utils_Tuple2(23, 'X'),
			_Utils_Tuple2(24, 'Y'),
			_Utils_Tuple2(25, 'Z'),
			_Utils_Tuple2(26, 'a'),
			_Utils_Tuple2(27, 'b'),
			_Utils_Tuple2(28, 'c'),
			_Utils_Tuple2(29, 'd'),
			_Utils_Tuple2(30, 'e'),
			_Utils_Tuple2(31, 'f'),
			_Utils_Tuple2(32, 'g'),
			_Utils_Tuple2(33, 'h'),
			_Utils_Tuple2(34, 'i'),
			_Utils_Tuple2(35, 'j'),
			_Utils_Tuple2(36, 'k'),
			_Utils_Tuple2(37, 'l'),
			_Utils_Tuple2(38, 'm'),
			_Utils_Tuple2(39, 'n'),
			_Utils_Tuple2(40, 'o'),
			_Utils_Tuple2(41, 'p'),
			_Utils_Tuple2(42, 'q'),
			_Utils_Tuple2(43, 'r'),
			_Utils_Tuple2(44, 's'),
			_Utils_Tuple2(45, 't'),
			_Utils_Tuple2(46, 'u'),
			_Utils_Tuple2(47, 'v'),
			_Utils_Tuple2(48, 'w'),
			_Utils_Tuple2(49, 'x'),
			_Utils_Tuple2(50, 'y'),
			_Utils_Tuple2(51, 'z'),
			_Utils_Tuple2(52, '0'),
			_Utils_Tuple2(53, '1'),
			_Utils_Tuple2(54, '2'),
			_Utils_Tuple2(55, '3'),
			_Utils_Tuple2(56, '4'),
			_Utils_Tuple2(57, '5'),
			_Utils_Tuple2(58, '6'),
			_Utils_Tuple2(59, '7'),
			_Utils_Tuple2(60, '8'),
			_Utils_Tuple2(61, '9'),
			_Utils_Tuple2(62, '+'),
			_Utils_Tuple2(63, '/')
		]));
var $chelovek0v$bbase64$Base64$Table$encode = function (code) {
	var _v0 = A2($elm$core$Dict$get, code, $chelovek0v$bbase64$Base64$Table$codeToCharMap);
	if (_v0.$ === 'Just') {
		var char_ = _v0.a;
		return char_;
	} else {
		return '';
	}
};
var $chelovek0v$bbase64$Base64$Shift$next = function (shift) {
	switch (shift.$) {
		case 'Shift0':
			return $chelovek0v$bbase64$Base64$Shift$Shift2;
		case 'Shift2':
			return $chelovek0v$bbase64$Base64$Shift$Shift4;
		case 'Shift4':
			return $chelovek0v$bbase64$Base64$Shift$Shift6;
		default:
			return $chelovek0v$bbase64$Base64$Shift$Shift2;
	}
};
var $chelovek0v$bbase64$Base64$Encode$sixtet = F2(
	function (octet, _v0) {
		var shift = _v0.a;
		var sixtet_ = _v0.b;
		var strAcc = _v0.c;
		switch (shift.$) {
			case 'Shift0':
				return A2($chelovek0v$bbase64$Base64$Shift$shiftRightZfBy, $chelovek0v$bbase64$Base64$Shift$Shift2, octet);
			case 'Shift2':
				return A2($chelovek0v$bbase64$Base64$Shift$shiftLeftBy, $chelovek0v$bbase64$Base64$Shift$Shift4, sixtet_) | A2($chelovek0v$bbase64$Base64$Shift$shiftRightZfBy, $chelovek0v$bbase64$Base64$Shift$Shift4, octet);
			case 'Shift4':
				return A2($chelovek0v$bbase64$Base64$Shift$shiftLeftBy, $chelovek0v$bbase64$Base64$Shift$Shift2, sixtet_) | A2($chelovek0v$bbase64$Base64$Shift$shiftRightZfBy, $chelovek0v$bbase64$Base64$Shift$Shift6, octet);
			default:
				return sixtet_;
		}
	});
var $chelovek0v$bbase64$Base64$Encode$encodeStep = F2(
	function (octet, encodeState) {
		var shift = encodeState.a;
		var strAcc = encodeState.c;
		var nextSixtet = function () {
			switch (shift.$) {
				case 'Shift0':
					return A2($chelovek0v$bbase64$Base64$Shift$and, $chelovek0v$bbase64$Base64$Shift$Shift2, octet);
				case 'Shift2':
					return A2($chelovek0v$bbase64$Base64$Shift$and, $chelovek0v$bbase64$Base64$Shift$Shift4, octet);
				case 'Shift4':
					return A2($chelovek0v$bbase64$Base64$Shift$and, $chelovek0v$bbase64$Base64$Shift$Shift6, octet);
				default:
					return A2($chelovek0v$bbase64$Base64$Shift$and, $chelovek0v$bbase64$Base64$Shift$Shift2, octet);
			}
		}();
		var currentSixtet = A2($chelovek0v$bbase64$Base64$Encode$sixtet, octet, encodeState);
		var base64Char = function () {
			if (shift.$ === 'Shift6') {
				return _Utils_ap(
					$chelovek0v$bbase64$Base64$Table$encode(currentSixtet),
					$chelovek0v$bbase64$Base64$Table$encode(
						A2($chelovek0v$bbase64$Base64$Shift$shiftRightZfBy, $chelovek0v$bbase64$Base64$Shift$Shift2, octet)));
			} else {
				return $chelovek0v$bbase64$Base64$Table$encode(currentSixtet);
			}
		}();
		return _Utils_Tuple3(
			$chelovek0v$bbase64$Base64$Shift$next(shift),
			nextSixtet,
			_Utils_ap(strAcc, base64Char));
	});
var $elm$bytes$Bytes$Decode$Decoder = function (a) {
	return {$: 'Decoder', a: a};
};
var $elm$bytes$Bytes$Decode$map = F2(
	function (func, _v0) {
		var decodeA = _v0.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v1 = A2(decodeA, bites, offset);
					var aOffset = _v1.a;
					var a = _v1.b;
					return _Utils_Tuple2(
						aOffset,
						func(a));
				}));
	});
var $elm$bytes$Bytes$Decode$succeed = function (a) {
	return $elm$bytes$Bytes$Decode$Decoder(
		F2(
			function (_v0, offset) {
				return _Utils_Tuple2(offset, a);
			}));
};
var $chelovek0v$bbase64$Base64$Encode$decodeStep = F2(
	function (octetDecoder, _v0) {
		var n = _v0.a;
		var encodeState = _v0.b;
		return (n <= 0) ? $elm$bytes$Bytes$Decode$succeed(
			$elm$bytes$Bytes$Decode$Done(encodeState)) : A2(
			$elm$bytes$Bytes$Decode$map,
			function (octet) {
				return $elm$bytes$Bytes$Decode$Loop(
					_Utils_Tuple2(
						n - 1,
						A2($chelovek0v$bbase64$Base64$Encode$encodeStep, octet, encodeState)));
			},
			octetDecoder);
	});
var $chelovek0v$bbase64$Base64$Encode$finalize = function (_v0) {
	var shift = _v0.a;
	var sixtet_ = _v0.b;
	var strAcc = _v0.c;
	switch (shift.$) {
		case 'Shift6':
			return _Utils_ap(
				strAcc,
				$chelovek0v$bbase64$Base64$Table$encode(sixtet_));
		case 'Shift4':
			return strAcc + ($chelovek0v$bbase64$Base64$Table$encode(
				A2($chelovek0v$bbase64$Base64$Shift$shiftLeftBy, $chelovek0v$bbase64$Base64$Shift$Shift2, sixtet_)) + '=');
		case 'Shift2':
			return strAcc + ($chelovek0v$bbase64$Base64$Table$encode(
				A2($chelovek0v$bbase64$Base64$Shift$shiftLeftBy, $chelovek0v$bbase64$Base64$Shift$Shift4, sixtet_)) + '==');
		default:
			return strAcc;
	}
};
var $chelovek0v$bbase64$Base64$Encode$initialEncodeState = _Utils_Tuple3($chelovek0v$bbase64$Base64$Shift$Shift0, 0, '');
var $elm$bytes$Bytes$Decode$loopHelp = F4(
	function (state, callback, bites, offset) {
		loopHelp:
		while (true) {
			var _v0 = callback(state);
			var decoder = _v0.a;
			var _v1 = A2(decoder, bites, offset);
			var newOffset = _v1.a;
			var step = _v1.b;
			if (step.$ === 'Loop') {
				var newState = step.a;
				var $temp$state = newState,
					$temp$callback = callback,
					$temp$bites = bites,
					$temp$offset = newOffset;
				state = $temp$state;
				callback = $temp$callback;
				bites = $temp$bites;
				offset = $temp$offset;
				continue loopHelp;
			} else {
				var result = step.a;
				return _Utils_Tuple2(newOffset, result);
			}
		}
	});
var $elm$bytes$Bytes$Decode$loop = F2(
	function (state, callback) {
		return $elm$bytes$Bytes$Decode$Decoder(
			A2($elm$bytes$Bytes$Decode$loopHelp, state, callback));
	});
var $elm$bytes$Bytes$Decode$unsignedInt8 = $elm$bytes$Bytes$Decode$Decoder(_Bytes_read_u8);
var $elm$bytes$Bytes$width = _Bytes_width;
var $chelovek0v$bbase64$Base64$Encode$tryEncode = function (input) {
	var decoderInitialState = _Utils_Tuple2(
		$elm$bytes$Bytes$width(input),
		$chelovek0v$bbase64$Base64$Encode$initialEncodeState);
	var base64Decoder = A2(
		$elm$bytes$Bytes$Decode$loop,
		decoderInitialState,
		$chelovek0v$bbase64$Base64$Encode$decodeStep($elm$bytes$Bytes$Decode$unsignedInt8));
	return A2(
		$elm$core$Maybe$map,
		$chelovek0v$bbase64$Base64$Encode$finalize,
		A2($elm$bytes$Bytes$Decode$decode, base64Decoder, input));
};
var $chelovek0v$bbase64$Base64$Encode$encode = function (encoder) {
	if (encoder.$ === 'StringEncoder') {
		var input = encoder.a;
		return A2(
			$elm$core$Maybe$withDefault,
			'',
			$chelovek0v$bbase64$Base64$Encode$tryEncode(
				$elm$bytes$Bytes$Encode$encode(
					$elm$bytes$Bytes$Encode$string(input))));
	} else {
		var input = encoder.a;
		return A2(
			$elm$core$Maybe$withDefault,
			'',
			$chelovek0v$bbase64$Base64$Encode$tryEncode(input));
	}
};
var $elm$core$Result$mapError = F2(
	function (f, result) {
		if (result.$ === 'Ok') {
			var v = result.a;
			return $elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return $elm$core$Result$Err(
				f(e));
		}
	});
var $author$project$Nats$Protocol$Error = function (a) {
	return {$: 'Error', a: a};
};
var $author$project$Nats$Protocol$MSG = F2(
	function (a, b) {
		return {$: 'MSG', a: a, b: b};
	});
var $author$project$Nats$Protocol$Operation = function (a) {
	return {$: 'Operation', a: a};
};
var $author$project$Nats$Protocol$Partial = function (a) {
	return {$: 'Partial', a: a};
};
var $author$project$Nats$Protocol$PartialOperation = function (a) {
	return {$: 'PartialOperation', a: a};
};
var $elm$bytes$Bytes$Decode$andThen = F2(
	function (callback, _v0) {
		var decodeA = _v0.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v1 = A2(decodeA, bites, offset);
					var newOffset = _v1.a;
					var a = _v1.b;
					var _v2 = callback(a);
					var decodeB = _v2.a;
					return A2(decodeB, bites, newOffset);
				}));
	});
var $elm$bytes$Bytes$Decode$bytes = function (n) {
	return $elm$bytes$Bytes$Decode$Decoder(
		_Bytes_read_bytes(n));
};
var $elm$bytes$Bytes$Encode$Bytes = function (a) {
	return {$: 'Bytes', a: a};
};
var $elm$bytes$Bytes$Encode$bytes = $elm$bytes$Bytes$Encode$Bytes;
var $author$project$Nats$Protocol$cr = '\u000D\n';
var $author$project$Nats$Protocol$stringBytes = function (str) {
	return $elm$bytes$Bytes$Encode$encode(
		$elm$bytes$Bytes$Encode$string(str));
};
var $author$project$Nats$Protocol$emptyBytes = $author$project$Nats$Protocol$stringBytes('');
var $elm$bytes$Bytes$Decode$fail = $elm$bytes$Bytes$Decode$Decoder(_Bytes_decodeFailure);
var $elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (maybeValue.$ === 'Just') {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$bytes$Bytes$Decode$string = function (n) {
	return $elm$bytes$Bytes$Decode$Decoder(
		_Bytes_read_string(n));
};
var $elm$core$String$foldr = _String_foldr;
var $elm$core$String$toList = function (string) {
	return A3($elm$core$String$foldr, $elm$core$List$cons, _List_Nil, string);
};
var $author$project$Nats$Protocol$findStringInBytes = function (s) {
	var stringLen = $elm$core$String$length(s);
	var charList = $elm$core$String$toList(s);
	var step = function (_v5) {
		var currentMatch = _v5.a;
		var index = _v5.b;
		return A2(
			$elm$bytes$Bytes$Decode$map,
			function (chars) {
				var _v0 = _Utils_Tuple2(
					$elm$core$String$toList(chars),
					currentMatch);
				if ((_v0.a.b && (!_v0.a.b.b)) && _v0.b.b) {
					if (!_v0.b.b.b) {
						var _v1 = _v0.a;
						var next = _v1.a;
						var _v2 = _v0.b;
						var expected = _v2.a;
						return _Utils_eq(next, expected) ? $elm$bytes$Bytes$Decode$Done(
							$elm$core$Maybe$Just((index - stringLen) + 1)) : $elm$bytes$Bytes$Decode$Loop(
							_Utils_Tuple2(charList, index + 1));
					} else {
						var _v3 = _v0.a;
						var next = _v3.a;
						var _v4 = _v0.b;
						var expected = _v4.a;
						var tail = _v4.b;
						return _Utils_eq(next, expected) ? $elm$bytes$Bytes$Decode$Loop(
							_Utils_Tuple2(tail, index + 1)) : $elm$bytes$Bytes$Decode$Loop(
							_Utils_Tuple2(charList, index + 1));
					}
				} else {
					return $elm$bytes$Bytes$Decode$Done($elm$core$Maybe$Nothing);
				}
			},
			$elm$bytes$Bytes$Decode$string(1));
	};
	return A2(
		$elm$core$Basics$composeR,
		$elm$bytes$Bytes$Decode$decode(
			A2(
				$elm$bytes$Bytes$Decode$loop,
				_Utils_Tuple2(charList, 0),
				step)),
		$elm$core$Maybe$andThen($elm$core$Basics$identity));
};
var $elm$bytes$Bytes$Decode$map2 = F3(
	function (func, _v0, _v1) {
		var decodeA = _v0.a;
		var decodeB = _v1.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v2 = A2(decodeA, bites, offset);
					var aOffset = _v2.a;
					var a = _v2.b;
					var _v3 = A2(decodeB, bites, aOffset);
					var bOffset = _v3.a;
					var b = _v3.b;
					return _Utils_Tuple2(
						bOffset,
						A2(func, a, b));
				}));
	});
var $author$project$Nats$Protocol$ERR = function (a) {
	return {$: 'ERR', a: a};
};
var $author$project$Nats$Protocol$INFO = function (a) {
	return {$: 'INFO', a: a};
};
var $author$project$Nats$Protocol$OK = {$: 'OK'};
var $author$project$Nats$Protocol$PING = {$: 'PING'};
var $author$project$Nats$Protocol$PONG = {$: 'PONG'};
var $author$project$Nats$Protocol$ServerInfo = F7(
	function (server_id, version, go, host, port_, auth_required, max_payload) {
		return {auth_required: auth_required, go: go, host: host, max_payload: max_payload, port_: port_, server_id: server_id, version: version};
	});
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom = $elm$json$Json$Decode$map2($elm$core$Basics$apR);
var $elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $elm$json$Json$Decode$field, decoder, fields);
	});
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $elm$json$Json$Decode$null = _Json_decodeNull;
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optionalDecoder = F3(
	function (path, valDecoder, fallback) {
		var nullOr = function (decoder) {
			return $elm$json$Json$Decode$oneOf(
				_List_fromArray(
					[
						decoder,
						$elm$json$Json$Decode$null(fallback)
					]));
		};
		var handleResult = function (input) {
			var _v0 = A2(
				$elm$json$Json$Decode$decodeValue,
				A2($elm$json$Json$Decode$at, path, $elm$json$Json$Decode$value),
				input);
			if (_v0.$ === 'Ok') {
				var rawValue = _v0.a;
				var _v1 = A2(
					$elm$json$Json$Decode$decodeValue,
					nullOr(valDecoder),
					rawValue);
				if (_v1.$ === 'Ok') {
					var finalResult = _v1.a;
					return $elm$json$Json$Decode$succeed(finalResult);
				} else {
					return A2(
						$elm$json$Json$Decode$at,
						path,
						nullOr(valDecoder));
				}
			} else {
				return $elm$json$Json$Decode$succeed(fallback);
			}
		};
		return A2($elm$json$Json$Decode$andThen, handleResult, $elm$json$Json$Decode$value);
	});
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional = F4(
	function (key, valDecoder, fallback, decoder) {
		return A2(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optionalDecoder,
				_List_fromArray(
					[key]),
				valDecoder,
				fallback),
			decoder);
	});
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required = F3(
	function (key, valDecoder, decoder) {
		return A2(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
			A2($elm$json$Json$Decode$field, key, valDecoder),
			decoder);
	});
var $elm$json$Json$Decode$string = _Json_decodeString;
var $author$project$Nats$Protocol$decodeServerInfo = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'max_payload',
	$elm$json$Json$Decode$int,
	A4(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
		'auth_required',
		$elm$json$Json$Decode$bool,
		true,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'port',
			$elm$json$Json$Decode$int,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'host',
				$elm$json$Json$Decode$string,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'go',
					$elm$json$Json$Decode$string,
					A3(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'version',
						$elm$json$Json$Decode$string,
						A3(
							$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'server_id',
							$elm$json$Json$Decode$string,
							$elm$json$Json$Decode$succeed($author$project$Nats$Protocol$ServerInfo))))))));
var $elm$json$Json$Decode$decodeString = _Json_runOnString;
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $elm$regex$Regex$findAtMost = _Regex_findAtMost;
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Nats$Protocol$messageRe = $elm$regex$Regex$fromString('^MSG ([a-zA-Z0-9._-]+) ([a-zA-Z0-9]+)( [a-zA-Z0-9._]+)? ([0-9]+)$');
var $author$project$Nats$Protocol$parseCommandMessage = function (str) {
	var matches = function () {
		var _v3 = $author$project$Nats$Protocol$messageRe;
		if (_v3.$ === 'Nothing') {
			return _List_Nil;
		} else {
			var re = _v3.a;
			return A3($elm$regex$Regex$findAtMost, 1, re, str);
		}
	}();
	var _v0 = $elm$core$List$head(matches);
	if (_v0.$ === 'Just') {
		var match = _v0.a;
		var args = A2(
			$elm$core$List$map,
			$elm$core$Maybe$withDefault(''),
			match.submatches);
		var replyTo = function () {
			var _v2 = A2(
				$elm$core$Maybe$withDefault,
				'',
				$elm$core$List$head(
					A2($elm$core$List$drop, 2, args)));
			if (_v2 === ' ') {
				return '';
			} else {
				var v = _v2;
				return v;
			}
		}();
		var sid = A2(
			$elm$core$Maybe$withDefault,
			'',
			$elm$core$List$head(
				A2($elm$core$List$drop, 1, args)));
		var size = A2(
			$elm$core$Maybe$withDefault,
			'',
			$elm$core$List$head(
				A2($elm$core$List$drop, 3, args)));
		var subject = A2(
			$elm$core$Maybe$withDefault,
			'',
			$elm$core$List$head(args));
		var _v1 = $elm$core$String$toInt(size);
		if (_v1.$ === 'Nothing') {
			return $elm$core$Result$Err('Invalid size: ' + size);
		} else {
			var value = _v1.a;
			return $elm$core$Result$Ok(
				{replyTo: replyTo, sid: sid, size: value, subject: subject});
		}
	} else {
		return $elm$core$Result$Err('Invalid MSG syntax: ' + str);
	}
};
var $author$project$Nats$Protocol$parseCommand = F2(
	function (empty, c) {
		switch (c) {
			case 'PING':
				return $elm$core$Result$Ok($author$project$Nats$Protocol$PING);
			case 'PONG':
				return $elm$core$Result$Ok($author$project$Nats$Protocol$PONG);
			case '+OK':
				return $elm$core$Result$Ok($author$project$Nats$Protocol$OK);
			default:
				if (A2($elm$core$String$startsWith, 'INFO ', c)) {
					var _v1 = A2(
						$elm$json$Json$Decode$decodeString,
						$author$project$Nats$Protocol$decodeServerInfo,
						A2($elm$core$String$dropLeft, 5, c));
					if (_v1.$ === 'Ok') {
						var info = _v1.a;
						return $elm$core$Result$Ok(
							$author$project$Nats$Protocol$INFO(info));
					} else {
						var err = _v1.a;
						return $elm$core$Result$Err(
							$elm$json$Json$Decode$errorToString(err));
					}
				} else {
					if (A2($elm$core$String$startsWith, '-ERR ', c)) {
						return $elm$core$Result$Ok(
							$author$project$Nats$Protocol$ERR(
								A2(
									$elm$core$String$dropRight,
									1,
									A2($elm$core$String$dropLeft, 5, c))));
					} else {
						if (A2($elm$core$String$startsWith, 'MSG', c)) {
							var _v2 = $author$project$Nats$Protocol$parseCommandMessage(c);
							if (_v2.$ === 'Ok') {
								var msg = _v2.a;
								return $elm$core$Result$Ok(
									A2(
										$author$project$Nats$Protocol$MSG,
										msg.sid,
										{data: empty, replyTo: msg.replyTo, size: msg.size, subject: msg.subject}));
							} else {
								var err = _v2.a;
								return $elm$core$Result$Err(err);
							}
						} else {
							return $elm$core$Result$Err('Invalid command \'' + (c + '\''));
						}
					}
				}
		}
	});
var $author$project$Nats$Protocol$parseBytes = F2(
	function (data, partial) {
		if (partial.$ === 'Just') {
			var msg = partial.a.a;
			var body = $elm$bytes$Bytes$Encode$encode(
				$elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							$elm$bytes$Bytes$Encode$bytes(msg.data),
							$elm$bytes$Bytes$Encode$bytes(data)
						])));
			var bodyWidth = $elm$bytes$Bytes$width(body);
			return _Utils_eq(bodyWidth, msg.size + 2) ? $author$project$Nats$Protocol$Operation(
				A2(
					$author$project$Nats$Protocol$MSG,
					msg.sid,
					{data: body, replyTo: msg.replyTo, size: msg.size, subject: msg.subject})) : ((_Utils_cmp(bodyWidth, msg.size + 2) > 0) ? $author$project$Nats$Protocol$Error('message payload is too big') : $author$project$Nats$Protocol$Partial(
				$author$project$Nats$Protocol$PartialOperation(
					_Utils_update(
						msg,
						{data: body}))));
		} else {
			var _v1 = A2($author$project$Nats$Protocol$findStringInBytes, $author$project$Nats$Protocol$cr, data);
			if (_v1.$ === 'Nothing') {
				return $author$project$Nats$Protocol$Error('Could not find CR separator');
			} else {
				var index = _v1.a;
				return A2(
					$elm$core$Maybe$withDefault,
					$author$project$Nats$Protocol$Error('could not decode input'),
					A2(
						$elm$bytes$Bytes$Decode$decode,
						A2(
							$elm$bytes$Bytes$Decode$andThen,
							function (s) {
								var _v2 = A2($author$project$Nats$Protocol$parseCommand, $author$project$Nats$Protocol$emptyBytes, s);
								if (_v2.$ === 'Ok') {
									if (_v2.a.$ === 'MSG') {
										var _v3 = _v2.a;
										var sid = _v3.a;
										var msg = _v3.b;
										var payloadWidth = $elm$bytes$Bytes$width(data) - (index + 2);
										return (_Utils_cmp(msg.size + 2, payloadWidth) < 0) ? $elm$bytes$Bytes$Decode$fail : (_Utils_eq(msg.size + 2, payloadWidth) ? A3(
											$elm$bytes$Bytes$Decode$map2,
											F2(
												function (_v4, payload) {
													return $author$project$Nats$Protocol$Operation(
														A2(
															$author$project$Nats$Protocol$MSG,
															sid,
															_Utils_update(
																msg,
																{data: payload})));
												}),
											$elm$bytes$Bytes$Decode$bytes(2),
											$elm$bytes$Bytes$Decode$bytes(msg.size)) : A3(
											$elm$bytes$Bytes$Decode$map2,
											F2(
												function (_v5, payload) {
													return $author$project$Nats$Protocol$Partial(
														$author$project$Nats$Protocol$PartialOperation(
															{data: payload, replyTo: msg.replyTo, sid: sid, size: msg.size, subject: msg.subject}));
												}),
											$elm$bytes$Bytes$Decode$bytes(2),
											$elm$bytes$Bytes$Decode$bytes(payloadWidth)));
									} else {
										var any = _v2.a;
										return $elm$bytes$Bytes$Decode$succeed(
											$author$project$Nats$Protocol$Operation(any));
									}
								} else {
									var err = _v2.a;
									return $elm$bytes$Bytes$Decode$succeed(
										$author$project$Nats$Protocol$Error(err));
								}
							},
							$elm$bytes$Bytes$Decode$string(index)),
						data));
			}
		}
	});
var $author$project$Nats$Protocol$crBytes = $author$project$Nats$Protocol$stringBytes($author$project$Nats$Protocol$cr);
var $elm$core$String$append = _String_append;
var $elm$json$Json$Encode$bool = _Json_wrap;
var $elm$json$Json$Encode$int = _Json_wrap;
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(_Utils_Tuple0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Nats$Protocol$encodeConnect = function (options) {
	return $elm$json$Json$Encode$object(
		_Utils_ap(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'verbose',
					$elm$json$Json$Encode$bool(options.verbose)),
					_Utils_Tuple2(
					'pedantic',
					$elm$json$Json$Encode$bool(options.pedantic)),
					_Utils_Tuple2(
					'lang',
					$elm$json$Json$Encode$string(options.lang)),
					_Utils_Tuple2(
					'version',
					$elm$json$Json$Encode$string(options.version)),
					_Utils_Tuple2(
					'protocol',
					$elm$json$Json$Encode$int(options.protocol))
				]),
			_Utils_ap(
				function () {
					var _v0 = options.auth_token;
					if (_v0.$ === 'Just') {
						var auth_token = _v0.a;
						return _List_fromArray(
							[
								_Utils_Tuple2(
								'auth_token',
								$elm$json$Json$Encode$string(auth_token))
							]);
					} else {
						return _List_Nil;
					}
				}(),
				_Utils_ap(
					function () {
						var _v1 = options.user;
						if (_v1.$ === 'Just') {
							var user = _v1.a;
							return _List_fromArray(
								[
									_Utils_Tuple2(
									'user',
									$elm$json$Json$Encode$string(user))
								]);
						} else {
							return _List_Nil;
						}
					}(),
					_Utils_ap(
						function () {
							var _v2 = options.pass;
							if (_v2.$ === 'Just') {
								var pass = _v2.a;
								return _List_fromArray(
									[
										_Utils_Tuple2(
										'pass',
										$elm$json$Json$Encode$string(pass))
									]);
							} else {
								return _List_Nil;
							}
						}(),
						function () {
							var _v3 = options.name;
							if (_v3.$ === 'Just') {
								var name = _v3.a;
								return _List_fromArray(
									[
										_Utils_Tuple2(
										'name',
										$elm$json$Json$Encode$string(name))
									]);
							} else {
								return _List_Nil;
							}
						}())))));
};
var $elm$core$Basics$neq = _Utils_notEqual;
var $elm$core$Basics$not = _Basics_not;
var $author$project$Nats$Protocol$opHeader = function (op) {
	switch (op.$) {
		case 'INFO':
			return '';
		case 'CONNECT':
			var options = op.a;
			return A2(
				$elm$core$String$append,
				'CONNECT ',
				A2(
					$elm$json$Json$Encode$encode,
					0,
					$author$project$Nats$Protocol$encodeConnect(options)));
		case 'MSG':
			var sid = op.a;
			var message = op.b;
			return '';
		case 'PING':
			return 'PING';
		case 'PONG':
			return 'PONG';
		case 'PUB':
			var message = op.a;
			return 'PUB ' + (message.subject + (((!$elm$core$String$isEmpty(message.replyTo)) ? (' ' + message.replyTo) : '') + (' ' + $elm$core$String$fromInt(message.size))));
		case 'SUB':
			var subject = op.a;
			var queueGroup = op.b;
			var sid = op.c;
			return 'SUB ' + (subject + (' ' + (((!$elm$core$String$isEmpty(queueGroup)) ? (queueGroup + ' ') : '') + sid)));
		case 'UNSUB':
			var sid = op.a;
			var maxMsgs = op.b;
			return 'UNSUB ' + (sid + ((!(!maxMsgs)) ? (' ' + $elm$core$String$fromInt(maxMsgs)) : ''));
		case 'OK':
			return 'OK';
		default:
			var err = op.a;
			return 'ERR \'' + (err + '\'');
	}
};
var $author$project$Nats$Protocol$toBytes = function (op) {
	return $elm$bytes$Bytes$Encode$encode(
		$elm$bytes$Bytes$Encode$sequence(
			_Utils_ap(
				_List_fromArray(
					[
						$elm$bytes$Bytes$Encode$string(
						$author$project$Nats$Protocol$opHeader(op)),
						$elm$bytes$Bytes$Encode$bytes($author$project$Nats$Protocol$crBytes)
					]),
				function () {
					if (op.$ === 'PUB') {
						var message = op.a;
						return _List_fromArray(
							[
								$elm$bytes$Bytes$Encode$bytes(message.data),
								$elm$bytes$Bytes$Encode$bytes($author$project$Nats$Protocol$crBytes)
							]);
					} else {
						return _List_Nil;
					}
				}())));
};
var $author$project$Nats$Config$bytes = F2(
	function (parentMsg, ports) {
		return {
			debug: false,
			fromPortMessage: A2(
				$elm$core$Basics$composeR,
				$chelovek0v$bbase64$Base64$Decode$decode($chelovek0v$bbase64$Base64$Decode$bytes),
				$elm$core$Result$mapError(
					function (e) {
						if (e.$ === 'ValidationError') {
							return 'Base64 validation error';
						} else {
							return 'Base64 invalid base sequence';
						}
					})),
			mode: 'binary',
			onError: $elm$core$Maybe$Nothing,
			parentMsg: parentMsg,
			parse: $author$project$Nats$Protocol$parseBytes,
			ports: ports,
			size: $elm$bytes$Bytes$width,
			toPortMessage: A2($elm$core$Basics$composeR, $chelovek0v$bbase64$Base64$Encode$bytes, $chelovek0v$bbase64$Base64$Encode$encode),
			write: $author$project$Nats$Protocol$toBytes
		};
	});
var $author$project$Main$natsClose = _Platform_outgoingPort('natsClose', $elm$json$Json$Encode$string);
var $author$project$Main$natsOnAck = _Platform_incomingPort(
	'natsOnAck',
	A2(
		$elm$json$Json$Decode$andThen,
		function (sid) {
			return A2(
				$elm$json$Json$Decode$andThen,
				function (ack) {
					return $elm$json$Json$Decode$succeed(
						{ack: ack, sid: sid});
				},
				A2($elm$json$Json$Decode$field, 'ack', $elm$json$Json$Decode$string));
		},
		A2($elm$json$Json$Decode$field, 'sid', $elm$json$Json$Decode$string)));
var $author$project$Main$natsOnClose = _Platform_incomingPort('natsOnClose', $elm$json$Json$Decode$string);
var $author$project$Main$natsOnError = _Platform_incomingPort(
	'natsOnError',
	A2(
		$elm$json$Json$Decode$andThen,
		function (sid) {
			return A2(
				$elm$json$Json$Decode$andThen,
				function (message) {
					return $elm$json$Json$Decode$succeed(
						{message: message, sid: sid});
				},
				A2($elm$json$Json$Decode$field, 'message', $elm$json$Json$Decode$string));
		},
		A2($elm$json$Json$Decode$field, 'sid', $elm$json$Json$Decode$string)));
var $author$project$Main$natsOnMessage = _Platform_incomingPort(
	'natsOnMessage',
	A2(
		$elm$json$Json$Decode$andThen,
		function (sid) {
			return A2(
				$elm$json$Json$Decode$andThen,
				function (message) {
					return A2(
						$elm$json$Json$Decode$andThen,
						function (ack) {
							return $elm$json$Json$Decode$succeed(
								{ack: ack, message: message, sid: sid});
						},
						A2(
							$elm$json$Json$Decode$field,
							'ack',
							$elm$json$Json$Decode$oneOf(
								_List_fromArray(
									[
										$elm$json$Json$Decode$null($elm$core$Maybe$Nothing),
										A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, $elm$json$Json$Decode$string)
									]))));
				},
				A2($elm$json$Json$Decode$field, 'message', $elm$json$Json$Decode$string));
		},
		A2($elm$json$Json$Decode$field, 'sid', $elm$json$Json$Decode$string)));
var $author$project$Main$natsOnOpen = _Platform_incomingPort('natsOnOpen', $elm$json$Json$Decode$string);
var $author$project$Main$natsOpen = _Platform_outgoingPort(
	'natsOpen',
	function ($) {
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'debug',
					$elm$json$Json$Encode$bool($.debug)),
					_Utils_Tuple2(
					'mode',
					$elm$json$Json$Encode$string($.mode)),
					_Utils_Tuple2(
					'sid',
					$elm$json$Json$Encode$string($.sid)),
					_Utils_Tuple2(
					'url',
					$elm$json$Json$Encode$string($.url))
				]));
	});
var $elm$core$Maybe$destruct = F3(
	function (_default, func, maybe) {
		if (maybe.$ === 'Just') {
			var a = maybe.a;
			return func(a);
		} else {
			return _default;
		}
	});
var $elm$json$Json$Encode$null = _Json_encodeNull;
var $author$project$Main$natsSend = _Platform_outgoingPort(
	'natsSend',
	function ($) {
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'ack',
					function ($) {
						return A3($elm$core$Maybe$destruct, $elm$json$Json$Encode$null, $elm$json$Json$Encode$string, $);
					}($.ack)),
					_Utils_Tuple2(
					'message',
					$elm$json$Json$Encode$string($.message)),
					_Utils_Tuple2(
					'sid',
					$elm$json$Json$Encode$string($.sid))
				]));
	});
var $author$project$Nats$Config$withDebug = F2(
	function (value, cfg) {
		return _Utils_update(
			cfg,
			{debug: value});
	});
var $author$project$Main$natsConfig = A2(
	$author$project$Nats$Config$withDebug,
	false,
	A2(
		$author$project$Nats$Config$bytes,
		$author$project$Main$NatsMsg,
		{close: $author$project$Main$natsClose, onAck: $author$project$Main$natsOnAck, onClose: $author$project$Main$natsOnClose, onError: $author$project$Main$natsOnError, onMessage: $author$project$Main$natsOnMessage, onOpen: $author$project$Main$natsOnOpen, open: $author$project$Main$natsOpen, send: $author$project$Main$natsSend}));
var $author$project$Nats$Internal$Types$OnAck = function (a) {
	return {$: 'OnAck', a: a};
};
var $author$project$Nats$Internal$Types$OnClose = function (a) {
	return {$: 'OnClose', a: a};
};
var $author$project$Nats$Internal$Types$OnError = function (a) {
	return {$: 'OnError', a: a};
};
var $author$project$Nats$Internal$Types$OnMessage = function (a) {
	return {$: 'OnMessage', a: a};
};
var $author$project$Nats$Internal$Types$OnOpen = function (a) {
	return {$: 'OnOpen', a: a};
};
var $author$project$Nats$Internal$Types$OnTime = function (a) {
	return {$: 'OnTime', a: a};
};
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $elm$time$Time$Every = F2(
	function (a, b) {
		return {$: 'Every', a: a, b: b};
	});
var $elm$time$Time$State = F2(
	function (taggers, processes) {
		return {processes: processes, taggers: taggers};
	});
var $elm$time$Time$init = $elm$core$Task$succeed(
	A2($elm$time$Time$State, $elm$core$Dict$empty, $elm$core$Dict$empty));
var $elm$time$Time$addMySub = F2(
	function (_v0, state) {
		var interval = _v0.a;
		var tagger = _v0.b;
		var _v1 = A2($elm$core$Dict$get, interval, state);
		if (_v1.$ === 'Nothing') {
			return A3(
				$elm$core$Dict$insert,
				interval,
				_List_fromArray(
					[tagger]),
				state);
		} else {
			var taggers = _v1.a;
			return A3(
				$elm$core$Dict$insert,
				interval,
				A2($elm$core$List$cons, tagger, taggers),
				state);
		}
	});
var $elm$core$Process$kill = _Scheduler_kill;
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _v0) {
				stepState:
				while (true) {
					var list = _v0.a;
					var result = _v0.b;
					if (!list.b) {
						return _Utils_Tuple2(
							list,
							A3(rightStep, rKey, rValue, result));
					} else {
						var _v2 = list.a;
						var lKey = _v2.a;
						var lValue = _v2.b;
						var rest = list.b;
						if (_Utils_cmp(lKey, rKey) < 0) {
							var $temp$rKey = rKey,
								$temp$rValue = rValue,
								$temp$_v0 = _Utils_Tuple2(
								rest,
								A3(leftStep, lKey, lValue, result));
							rKey = $temp$rKey;
							rValue = $temp$rValue;
							_v0 = $temp$_v0;
							continue stepState;
						} else {
							if (_Utils_cmp(lKey, rKey) > 0) {
								return _Utils_Tuple2(
									list,
									A3(rightStep, rKey, rValue, result));
							} else {
								return _Utils_Tuple2(
									rest,
									A4(bothStep, lKey, lValue, rValue, result));
							}
						}
					}
				}
			});
		var _v3 = A3(
			$elm$core$Dict$foldl,
			stepState,
			_Utils_Tuple2(
				$elm$core$Dict$toList(leftDict),
				initialResult),
			rightDict);
		var leftovers = _v3.a;
		var intermediateResult = _v3.b;
		return A3(
			$elm$core$List$foldl,
			F2(
				function (_v4, result) {
					var k = _v4.a;
					var v = _v4.b;
					return A3(leftStep, k, v, result);
				}),
			intermediateResult,
			leftovers);
	});
var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var $elm$time$Time$Name = function (a) {
	return {$: 'Name', a: a};
};
var $elm$time$Time$Offset = function (a) {
	return {$: 'Offset', a: a};
};
var $elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 'Zone', a: a, b: b};
	});
var $elm$time$Time$customZone = $elm$time$Time$Zone;
var $elm$time$Time$setInterval = _Time_setInterval;
var $elm$core$Process$spawn = _Scheduler_spawn;
var $elm$time$Time$spawnHelp = F3(
	function (router, intervals, processes) {
		if (!intervals.b) {
			return $elm$core$Task$succeed(processes);
		} else {
			var interval = intervals.a;
			var rest = intervals.b;
			var spawnTimer = $elm$core$Process$spawn(
				A2(
					$elm$time$Time$setInterval,
					interval,
					A2($elm$core$Platform$sendToSelf, router, interval)));
			var spawnRest = function (id) {
				return A3(
					$elm$time$Time$spawnHelp,
					router,
					rest,
					A3($elm$core$Dict$insert, interval, id, processes));
			};
			return A2($elm$core$Task$andThen, spawnRest, spawnTimer);
		}
	});
var $elm$time$Time$onEffects = F3(
	function (router, subs, _v0) {
		var processes = _v0.processes;
		var rightStep = F3(
			function (_v6, id, _v7) {
				var spawns = _v7.a;
				var existing = _v7.b;
				var kills = _v7.c;
				return _Utils_Tuple3(
					spawns,
					existing,
					A2(
						$elm$core$Task$andThen,
						function (_v5) {
							return kills;
						},
						$elm$core$Process$kill(id)));
			});
		var newTaggers = A3($elm$core$List$foldl, $elm$time$Time$addMySub, $elm$core$Dict$empty, subs);
		var leftStep = F3(
			function (interval, taggers, _v4) {
				var spawns = _v4.a;
				var existing = _v4.b;
				var kills = _v4.c;
				return _Utils_Tuple3(
					A2($elm$core$List$cons, interval, spawns),
					existing,
					kills);
			});
		var bothStep = F4(
			function (interval, taggers, id, _v3) {
				var spawns = _v3.a;
				var existing = _v3.b;
				var kills = _v3.c;
				return _Utils_Tuple3(
					spawns,
					A3($elm$core$Dict$insert, interval, id, existing),
					kills);
			});
		var _v1 = A6(
			$elm$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			newTaggers,
			processes,
			_Utils_Tuple3(
				_List_Nil,
				$elm$core$Dict$empty,
				$elm$core$Task$succeed(_Utils_Tuple0)));
		var spawnList = _v1.a;
		var existingDict = _v1.b;
		var killTask = _v1.c;
		return A2(
			$elm$core$Task$andThen,
			function (newProcesses) {
				return $elm$core$Task$succeed(
					A2($elm$time$Time$State, newTaggers, newProcesses));
			},
			A2(
				$elm$core$Task$andThen,
				function (_v2) {
					return A3($elm$time$Time$spawnHelp, router, spawnList, existingDict);
				},
				killTask));
	});
var $elm$time$Time$now = _Time_now($elm$time$Time$millisToPosix);
var $elm$time$Time$onSelfMsg = F3(
	function (router, interval, state) {
		var _v0 = A2($elm$core$Dict$get, interval, state.taggers);
		if (_v0.$ === 'Nothing') {
			return $elm$core$Task$succeed(state);
		} else {
			var taggers = _v0.a;
			var tellTaggers = function (time) {
				return $elm$core$Task$sequence(
					A2(
						$elm$core$List$map,
						function (tagger) {
							return A2(
								$elm$core$Platform$sendToApp,
								router,
								tagger(time));
						},
						taggers));
			};
			return A2(
				$elm$core$Task$andThen,
				function (_v1) {
					return $elm$core$Task$succeed(state);
				},
				A2($elm$core$Task$andThen, tellTaggers, $elm$time$Time$now));
		}
	});
var $elm$time$Time$subMap = F2(
	function (f, _v0) {
		var interval = _v0.a;
		var tagger = _v0.b;
		return A2(
			$elm$time$Time$Every,
			interval,
			A2($elm$core$Basics$composeL, f, tagger));
	});
_Platform_effectManagers['Time'] = _Platform_createManager($elm$time$Time$init, $elm$time$Time$onEffects, $elm$time$Time$onSelfMsg, 0, $elm$time$Time$subMap);
var $elm$time$Time$subscription = _Platform_leaf('Time');
var $elm$time$Time$every = F2(
	function (interval, tagger) {
		return $elm$time$Time$subscription(
			A2($elm$time$Time$Every, interval, tagger));
	});
var $elm$core$Platform$Sub$map = _Platform_map;
var $author$project$Nats$subscriptions = F2(
	function (cfg, _v0) {
		return A2(
			$elm$core$Platform$Sub$map,
			cfg.parentMsg,
			$elm$core$Platform$Sub$batch(
				_List_fromArray(
					[
						cfg.ports.onOpen($author$project$Nats$Internal$Types$OnOpen),
						cfg.ports.onClose($author$project$Nats$Internal$Types$OnClose),
						cfg.ports.onError($author$project$Nats$Internal$Types$OnError),
						cfg.ports.onMessage($author$project$Nats$Internal$Types$OnMessage),
						cfg.ports.onAck($author$project$Nats$Internal$Types$OnAck),
						A2($elm$time$Time$every, 1000, $author$project$Nats$Internal$Types$OnTime)
					])));
	});
var $author$project$Main$subscriptions = function (model) {
	return A2($author$project$Nats$subscriptions, $author$project$Main$natsConfig, model.nats);
};
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $author$project$Nats$doSend = F2(
	function (cfg, message) {
		return cfg.ports.send(message);
	});
var $author$project$Nats$Protocol$SUB = F3(
	function (a, b, c) {
		return {$: 'SUB', a: a, b: b, c: c};
	});
var $author$project$Nats$Protocol$UNSUB = F2(
	function (a, b) {
		return {$: 'UNSUB', a: a, b: b};
	});
var $elm$core$Dict$filter = F2(
	function (isGood, dict) {
		return A3(
			$elm$core$Dict$foldl,
			F3(
				function (k, v, d) {
					return A2(isGood, k, v) ? A3($elm$core$Dict$insert, k, v, d) : d;
				}),
			$elm$core$Dict$empty,
			dict);
	});
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (_v0.$ === 'Just') {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $author$project$Nats$Internal$SocketState$getSubscriptionByID = F2(
	function (id, state) {
		return $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				A2(
					$elm$core$Basics$composeR,
					function ($) {
						return $.id;
					},
					$elm$core$Basics$eq(id)),
				state.activeSubscriptions));
	});
var $author$project$Nats$Internal$SocketState$isRequest = function (sub) {
	var _v0 = sub.subType;
	if (_v0.$ === 'Req') {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Dict$values = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return A2($elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var $author$project$Nats$Internal$SocketState$finalizeSubscriptions = function (state) {
	var _v0 = state.status;
	if (_v0.$ === 'Connected') {
		var nextSubscriptions = $elm$core$Dict$values(state.nextSubscriptions);
		return _Utils_Tuple2(
			_Utils_update(
				state,
				{
					activeSubscriptions: nextSubscriptions,
					nextSubscriptions: A2(
						$elm$core$Dict$filter,
						function (_v1) {
							return $author$project$Nats$Internal$SocketState$isRequest;
						},
						state.nextSubscriptions)
				}),
			_Utils_ap(
				A2(
					$elm$core$List$filterMap,
					function (sub) {
						var _v2 = A2($author$project$Nats$Internal$SocketState$getSubscriptionByID, sub.id, state);
						if (_v2.$ === 'Nothing') {
							return $elm$core$Maybe$Just(
								A3($author$project$Nats$Protocol$SUB, sub.subject, sub.group, sub.id));
						} else {
							return $elm$core$Maybe$Nothing;
						}
					},
					nextSubscriptions),
				A2(
					$elm$core$List$filterMap,
					function (sub) {
						var _v3 = $elm$core$List$head(
							A2(
								$elm$core$List$filter,
								function (next) {
									return _Utils_eq(next.id, sub.id);
								},
								nextSubscriptions));
						if (_v3.$ === 'Nothing') {
							return $elm$core$Maybe$Just(
								A2($author$project$Nats$Protocol$UNSUB, sub.id, 0));
						} else {
							return $elm$core$Maybe$Nothing;
						}
					},
					state.activeSubscriptions)));
	} else {
		return _Utils_Tuple2(state, _List_Nil);
	}
};
var $author$project$Nats$Internal$SocketState$Sub = {$: 'Sub'};
var $author$project$Nats$Internal$SocketState$getSubscriptionBySubjectGroup = F2(
	function (_v0, state) {
		var subject = _v0.a;
		var group = _v0.b;
		return $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (sub) {
					return _Utils_eq(
						_Utils_Tuple2(sub.subject, sub.group),
						_Utils_Tuple2(subject, group));
				},
				state.activeSubscriptions));
	});
var $author$project$Nats$Internal$SocketState$nextID = function (state) {
	return state.lastSubID + 1;
};
var $author$project$Nats$Internal$SocketState$addSubscriptionHelper = F5(
	function (subType, subject, group, onMessage, state) {
		var _v0 = A2(
			$elm$core$Dict$get,
			_Utils_Tuple2(subject, group),
			state.nextSubscriptions);
		if (_v0.$ === 'Just') {
			var sub = _v0.a;
			return _Utils_update(
				state,
				{
					nextSubscriptions: A3(
						$elm$core$Dict$insert,
						_Utils_Tuple2(subject, group),
						_Utils_update(
							sub,
							{
								handlers: A2($elm$core$List$cons, onMessage, sub.handlers)
							}),
						state.nextSubscriptions)
				});
		} else {
			var _v1 = function () {
				var _v2 = A2(
					$author$project$Nats$Internal$SocketState$getSubscriptionBySubjectGroup,
					_Utils_Tuple2(subject, group),
					state);
				if (_v2.$ === 'Just') {
					var sub = _v2.a;
					return _Utils_Tuple2(sub.id, state.lastSubID);
				} else {
					return _Utils_Tuple2(
						$elm$core$String$fromInt(
							$author$project$Nats$Internal$SocketState$nextID(state)),
						$author$project$Nats$Internal$SocketState$nextID(state));
				}
			}();
			var subID = _v1.a;
			var lastSubID = _v1.b;
			return _Utils_update(
				state,
				{
					lastSubID: lastSubID,
					nextSubscriptions: A3(
						$elm$core$Dict$insert,
						_Utils_Tuple2(subject, group),
						{
							group: group,
							handlers: _List_fromArray(
								[onMessage]),
							id: subID,
							subType: subType,
							subject: subject
						},
						state.nextSubscriptions)
				});
		}
	});
var $author$project$Nats$Internal$SocketState$addSubscription = $author$project$Nats$Internal$SocketState$addSubscriptionHelper($author$project$Nats$Internal$SocketState$Sub);
var $author$project$Nats$Internal$SocketStateCollection$findByID = F2(
	function (sid, _v0) {
		var list = _v0.a;
		return $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (_v1) {
					var socket = _v1.socket;
					return _Utils_eq(socket.id, sid);
				},
				list));
	});
var $author$project$Nats$Socket$Undefined = {$: 'Undefined'};
var $author$project$Nats$Internal$SocketState$init = F3(
	function (options, onEvent, _v0) {
		var socket = _v0.a;
		return {activeSubscriptions: _List_Nil, connectOptions: options, lastSubID: 0, nextSubscriptions: $elm$core$Dict$empty, onEvent: onEvent, partialOperation: $elm$core$Maybe$Nothing, serverInfo: $elm$core$Maybe$Nothing, socket: socket, status: $author$project$Nats$Socket$Undefined};
	});
var $author$project$Nats$Internal$SocketStateCollection$internalRemove = function (sid) {
	return $elm$core$List$filter(
		function (_v0) {
			var socket = _v0.socket;
			return !_Utils_eq(socket.id, sid);
		});
};
var $author$project$Nats$Internal$SocketStateCollection$insert = F2(
	function (socket, _v0) {
		var list = _v0.a;
		return $author$project$Nats$Internal$SocketStateCollection$SocketStateCollection(
			A2(
				$elm$core$List$cons,
				socket,
				A2($author$project$Nats$Internal$SocketStateCollection$internalRemove, socket.socket.id, list)));
	});
var $author$project$Nats$logError = F2(
	function (cfg, err) {
		return A2(
			$elm$core$Maybe$withDefault,
			$elm$core$Platform$Cmd$none,
			A2(
				$elm$core$Maybe$map,
				function (onError) {
					return A2(
						$elm$core$Task$perform,
						$elm$core$Basics$identity,
						$elm$core$Task$succeed(
							onError(err)));
				},
				cfg.onError));
	});
var $elm$core$Platform$Cmd$map = _Platform_map;
var $author$project$Nats$Internal$SocketStateCollection$removeByID = F2(
	function (sid, _v0) {
		var list = _v0.a;
		return $author$project$Nats$Internal$SocketStateCollection$SocketStateCollection(
			A2($author$project$Nats$Internal$SocketStateCollection$internalRemove, sid, list));
	});
var $author$project$Nats$updateSocket = F4(
	function (_v0, sid, fn, oState) {
		var state = oState.a;
		var _v1 = A2($author$project$Nats$Internal$SocketStateCollection$findByID, sid, state.sockets);
		if (_v1.$ === 'Nothing') {
			return _Utils_Tuple3(oState, _List_Nil, $elm$core$Platform$Cmd$none);
		} else {
			var socket = _v1.a;
			var _v2 = fn(socket);
			if (_v2.a.$ === 'Nothing') {
				var _v3 = _v2.a;
				var msgs = _v2.b;
				var cmd = _v2.c;
				return _Utils_Tuple3(
					$author$project$Nats$State(
						_Utils_update(
							state,
							{
								sockets: A2($author$project$Nats$Internal$SocketStateCollection$removeByID, sid, state.sockets)
							})),
					msgs,
					cmd);
			} else {
				var newSocket = _v2.a.a;
				var msgs = _v2.b;
				var cmd = _v2.c;
				return _Utils_Tuple3(
					$author$project$Nats$State(
						_Utils_update(
							state,
							{
								sockets: A2($author$project$Nats$Internal$SocketStateCollection$insert, newSocket, state.sockets)
							})),
					msgs,
					cmd);
			}
		}
	});
var $author$project$Nats$handleSubHelper = F3(
	function (cfg, sub, oState) {
		var state = oState.a;
		if (sub.$ === 'Connect') {
			var options = sub.a;
			var socket = sub.b;
			var props = socket.a;
			var onEvent = sub.c;
			var _v1 = A2($author$project$Nats$Internal$SocketStateCollection$findByID, props.id, state.sockets);
			if (_v1.$ === 'Nothing') {
				return _Utils_Tuple2(
					$author$project$Nats$State(
						_Utils_update(
							state,
							{
								defaultSocket: function () {
									var _v2 = state.defaultSocket;
									if (_v2.$ === 'Nothing') {
										return $elm$core$Maybe$Just(props.id);
									} else {
										var id = _v2.a;
										return props._default ? $elm$core$Maybe$Just(props.id) : $elm$core$Maybe$Just(id);
									}
								}(),
								sockets: A2(
									$author$project$Nats$Internal$SocketStateCollection$insert,
									A3($author$project$Nats$Internal$SocketState$init, options, onEvent, socket),
									state.sockets)
							})),
					A2(
						$elm$core$Platform$Cmd$map,
						cfg.parentMsg,
						cfg.ports.open(
							{debug: props.debug || cfg.debug, mode: cfg.mode, sid: props.id, url: props.url})));
			} else {
				return _Utils_Tuple2(oState, $elm$core$Platform$Cmd$none);
			}
		} else {
			var sid = sub.a.sid;
			var subject = sub.a.subject;
			var group = sub.a.group;
			var onMessage = sub.a.onMessage;
			var _v3 = A2(
				$elm$core$Maybe$withDefault,
				A2($elm$core$Maybe$withDefault, '', state.defaultSocket),
				sid);
			if (_v3 === '') {
				return _Utils_Tuple2(
					oState,
					A2($author$project$Nats$logError, cfg, 'cannot subscribe: Could not determine the sid'));
			} else {
				var s = _v3;
				var _v4 = A4(
					$author$project$Nats$updateSocket,
					cfg,
					s,
					function (socket) {
						return _Utils_Tuple3(
							$elm$core$Maybe$Just(
								A4($author$project$Nats$Internal$SocketState$addSubscription, subject, group, onMessage, socket)),
							_List_Nil,
							$elm$core$Platform$Cmd$none);
					},
					oState);
				var newState = _v4.a;
				return _Utils_Tuple2(newState, $elm$core$Platform$Cmd$none);
			}
		}
	});
var $elm$core$Tuple$mapSecond = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			x,
			func(y));
	});
var $elm$core$Tuple$mapFirst = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			func(x),
			y);
	});
var $author$project$Nats$Internal$SocketStateCollection$mapWithEffect = F2(
	function (fn, _v0) {
		var list = _v0.a;
		return A2(
			$elm$core$Tuple$mapFirst,
			$author$project$Nats$Internal$SocketStateCollection$SocketStateCollection,
			A3(
				$elm$core$List$foldr,
				F2(
					function (socket, _v1) {
						var newList = _v1.a;
						var effectList = _v1.b;
						var _v2 = fn(socket);
						var newSocket = _v2.a;
						var effect = _v2.b;
						return _Utils_Tuple2(
							A2($elm$core$List$cons, newSocket, newList),
							A2($elm$core$List$cons, effect, effectList));
					}),
				_Utils_Tuple2(_List_Nil, _List_Nil),
				list));
	});
var $author$project$Nats$handleSub = F3(
	function (cfg, _v0, state) {
		var subList = _v0.a;
		var _v1 = A2(
			$elm$core$Tuple$mapSecond,
			$elm$core$Platform$Cmd$batch,
			A3(
				$elm$core$List$foldl,
				F2(
					function (innerSub, _v2) {
						var st = _v2.a;
						var cmdList = _v2.b;
						var _v3 = A3($author$project$Nats$handleSubHelper, cfg, innerSub, st);
						var newState = _v3.a;
						var newCmd = _v3.b;
						return _Utils_Tuple2(
							newState,
							A2($elm$core$List$cons, newCmd, cmdList));
					}),
				_Utils_Tuple2(state, _List_Nil),
				subList));
		var nState = _v1.a.a;
		var cmd = _v1.b;
		var _v4 = A2(
			$elm$core$Tuple$mapSecond,
			$elm$core$List$concat,
			A2(
				$author$project$Nats$Internal$SocketStateCollection$mapWithEffect,
				function (socket) {
					return A2(
						$elm$core$Tuple$mapSecond,
						$elm$core$List$map(
							function (op) {
								return A2(
									$elm$core$Platform$Cmd$map,
									cfg.parentMsg,
									A2(
										$author$project$Nats$doSend,
										cfg,
										{
											ack: function () {
												if (op.$ === 'CONNECT') {
													return $elm$core$Maybe$Just('CONNECT');
												} else {
													return $elm$core$Maybe$Nothing;
												}
											}(),
											message: cfg.toPortMessage(
												cfg.write(op)),
											sid: socket.socket.id
										}));
							}),
						$author$project$Nats$Internal$SocketState$finalizeSubscriptions(socket));
				},
				nState.sockets));
		var sockets = _v4.a;
		var opsCmds = _v4.b;
		return _Utils_Tuple2(
			$author$project$Nats$State(
				_Utils_update(
					nState,
					{sockets: sockets})),
			$elm$core$Platform$Cmd$batch(
				A2($elm$core$List$cons, cmd, opsCmds)));
	});
var $author$project$Nats$Protocol$PUB = function (a) {
	return {$: 'PUB', a: a};
};
var $author$project$Nats$Internal$SocketState$Req = function (a) {
	return {$: 'Req', a: a};
};
var $author$project$Nats$Internal$SocketState$addRequest = F3(
	function (cfg, req, state) {
		return _Utils_Tuple2(
			A5(
				$author$project$Nats$Internal$SocketState$addSubscriptionHelper,
				$author$project$Nats$Internal$SocketState$Req(
					{
						deadline: req.deadline,
						onMessage: function (m) {
							return _Utils_Tuple2(
								$elm$core$Maybe$Just(m),
								false);
						},
						onTimeout: A2($elm$core$Basics$composeR, $elm$core$Result$Err, req.onResponse)
					}),
				req.inbox,
				'',
				A2(
					$elm$core$Basics$composeR,
					function ($) {
						return $.data;
					},
					A2($elm$core$Basics$composeR, $elm$core$Result$Ok, req.onResponse)),
				state),
			_List_fromArray(
				[
					$author$project$Nats$Protocol$PUB(
					{
						data: req.message,
						replyTo: req.inbox,
						size: cfg.size(req.message),
						subject: req.subject
					})
				]));
	});
var $author$project$Nats$nextInbox = function (_v0) {
	var state = _v0.a;
	var _v1 = $author$project$Nats$Nuid$next(state.nuid);
	var postfix = _v1.a;
	var nuid = _v1.b;
	return _Utils_Tuple2(
		_Utils_ap(state.inboxPrefix, postfix),
		$author$project$Nats$State(
			_Utils_update(
				state,
				{nuid: nuid})));
};
var $author$project$Nats$toCmd = F3(
	function (cfg, effect, oState) {
		var state = oState.a;
		switch (effect.$) {
			case 'Pub':
				var sid = effect.a.sid;
				var subject = effect.a.subject;
				var replyTo = effect.a.replyTo;
				var message = effect.a.message;
				var _v1 = A2(
					$elm$core$Maybe$withDefault,
					A2($elm$core$Maybe$withDefault, '', state.defaultSocket),
					sid);
				if (_v1 === '') {
					return _Utils_Tuple2(
						oState,
						A2($author$project$Nats$logError, cfg, 'cannot publish message: Could not determine the sid'));
				} else {
					var s = _v1;
					return _Utils_Tuple2(
						oState,
						A2(
							$elm$core$Platform$Cmd$map,
							cfg.parentMsg,
							A2(
								$author$project$Nats$doSend,
								cfg,
								{
									ack: $elm$core$Maybe$Nothing,
									message: cfg.toPortMessage(
										cfg.write(
											$author$project$Nats$Protocol$PUB(
												{
													data: message,
													replyTo: A2($elm$core$Maybe$withDefault, '', replyTo),
													size: cfg.size(message),
													subject: subject
												}))),
									sid: s
								})));
				}
			case 'Request':
				var sid = effect.a.sid;
				var subject = effect.a.subject;
				var message = effect.a.message;
				var onResponse = effect.a.onResponse;
				var timeout = effect.a.timeout;
				var _v2 = A2(
					$elm$core$Maybe$withDefault,
					A2($elm$core$Maybe$withDefault, '', state.defaultSocket),
					sid);
				if (_v2 === '') {
					return _Utils_Tuple2(
						oState,
						A2($author$project$Nats$logError, cfg, 'cannot publish request: Could not determine the sid'));
				} else {
					var s = _v2;
					var _v3 = $author$project$Nats$nextInbox(oState);
					var inbox = _v3.a;
					var state1 = _v3.b;
					var _v4 = A4(
						$author$project$Nats$updateSocket,
						cfg,
						s,
						function (socket) {
							var _v5 = A3(
								$author$project$Nats$Internal$SocketState$addRequest,
								cfg,
								{
									deadline: state.time + (1000 * A2($elm$core$Maybe$withDefault, 5, timeout)),
									inbox: inbox,
									message: message,
									onResponse: onResponse,
									subject: subject
								},
								socket);
							var newSocket = _v5.a;
							var ops = _v5.b;
							return _Utils_Tuple3(
								$elm$core$Maybe$Just(newSocket),
								_List_Nil,
								$elm$core$Platform$Cmd$batch(
									A2(
										$elm$core$List$map,
										function (op) {
											return A2(
												$author$project$Nats$doSend,
												cfg,
												{
													ack: function () {
														if (op.$ === 'CONNECT') {
															return $elm$core$Maybe$Just('CONNECT');
														} else {
															return $elm$core$Maybe$Nothing;
														}
													}(),
													message: cfg.toPortMessage(
														cfg.write(op)),
													sid: s
												});
										},
										ops)));
						},
						state1);
					var nextState = _v4.a;
					var cmd = _v4.c;
					return _Utils_Tuple2(
						nextState,
						A2($elm$core$Platform$Cmd$map, cfg.parentMsg, cmd));
				}
			case 'BatchEffect':
				var list = effect.a;
				return A2(
					$elm$core$Tuple$mapSecond,
					$elm$core$Platform$Cmd$batch,
					A3(
						$elm$core$List$foldl,
						F2(
							function (eff, _v7) {
								var st = _v7.a;
								var cmd = _v7.b;
								var _v8 = A3($author$project$Nats$toCmd, cfg, eff, st);
								var newState = _v8.a;
								var newCmd = _v8.b;
								return _Utils_Tuple2(
									newState,
									A2($elm$core$List$cons, newCmd, cmd));
							}),
						_Utils_Tuple2(oState, _List_Nil),
						list));
			default:
				return _Utils_Tuple2(oState, $elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Nats$applyEffectAndSub = F4(
	function (cfg, effect, sub, state) {
		var _v0 = A3($author$project$Nats$toCmd, cfg, effect, state);
		var s1 = _v0.a;
		var cmd1 = _v0.b;
		var _v1 = A3($author$project$Nats$handleSub, cfg, sub, s1);
		var s2 = _v1.a;
		var cmd2 = _v1.b;
		return _Utils_Tuple2(
			s2,
			$elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[cmd1, cmd2])));
	});
var $author$project$Main$HandleRequest = function (a) {
	return {$: 'HandleRequest', a: a};
};
var $author$project$Main$OnSocketEvent = function (a) {
	return {$: 'OnSocketEvent', a: a};
};
var $author$project$Main$SubCompMsg = function (a) {
	return {$: 'SubCompMsg', a: a};
};
var $author$project$Nats$Internal$Sub$Sub = function (a) {
	return {$: 'Sub', a: a};
};
var $elm$core$List$sortBy = _List_sortBy;
var $author$project$Nats$Internal$Sub$sortPriority = function (sub) {
	if (sub.$ === 'Connect') {
		return 1;
	} else {
		return 2;
	}
};
var $author$project$Nats$Internal$Sub$sort = $elm$core$List$sortBy($author$project$Nats$Internal$Sub$sortPriority);
var $author$project$Nats$Internal$Sub$batch = A2(
	$elm$core$Basics$composeR,
	A2(
		$elm$core$List$foldl,
		function (_v0) {
			var l = _v0.a;
			return $elm$core$List$append(l);
		},
		_List_Nil),
	A2($elm$core$Basics$composeR, $author$project$Nats$Internal$Sub$sort, $author$project$Nats$Internal$Sub$Sub));
var $author$project$Nats$Sub$batch = $author$project$Nats$Internal$Sub$batch;
var $author$project$Nats$Internal$Sub$Connect = F3(
	function (a, b, c) {
		return {$: 'Connect', a: a, b: b, c: c};
	});
var $author$project$Nats$Internal$Sub$connect = F3(
	function (options, socket_, onEvent) {
		return $author$project$Nats$Internal$Sub$Sub(
			_List_fromArray(
				[
					A3($author$project$Nats$Internal$Sub$Connect, options, socket_, onEvent)
				]));
	});
var $author$project$Nats$connect = $author$project$Nats$Internal$Sub$connect;
var $author$project$Nats$Socket$connectOptions = F2(
	function (name, version) {
		return {
			auth_token: $elm$core$Maybe$Nothing,
			lang: 'elm',
			name: $elm$core$Maybe$Just(name),
			pass: $elm$core$Maybe$Nothing,
			pedantic: false,
			protocol: 0,
			user: $elm$core$Maybe$Nothing,
			verbose: false,
			version: version
		};
	});
var $author$project$Nats$Internal$Sub$Subscribe = function (a) {
	return {$: 'Subscribe', a: a};
};
var $author$project$Nats$groupSubscribe = F3(
	function (subject, group, onMessage) {
		return $author$project$Nats$Internal$Sub$Sub(
			_List_fromArray(
				[
					$author$project$Nats$Internal$Sub$Subscribe(
					{group: group, onMessage: onMessage, sid: $elm$core$Maybe$Nothing, subject: subject})
				]));
	});
var $author$project$Nats$Internal$Sub$map = F2(
	function (aToMsg, _v0) {
		var sub = _v0.a;
		return $author$project$Nats$Internal$Sub$Sub(
			A2(
				$elm$core$List$map,
				function (s) {
					if (s.$ === 'Connect') {
						var options = s.a;
						var sock = s.b;
						var onEvent = s.c;
						return A3(
							$author$project$Nats$Internal$Sub$Connect,
							options,
							sock,
							A2($elm$core$Basics$composeR, onEvent, aToMsg));
					} else {
						var sid = s.a.sid;
						var subject = s.a.subject;
						var group = s.a.group;
						var onMessage = s.a.onMessage;
						return $author$project$Nats$Internal$Sub$Subscribe(
							{
								group: group,
								onMessage: A2($elm$core$Basics$composeR, onMessage, aToMsg),
								sid: sid,
								subject: subject
							});
					}
				},
				sub));
	});
var $author$project$Nats$Sub$map = $author$project$Nats$Internal$Sub$map;
var $author$project$SubComp$Receive = F2(
	function (a, b) {
		return {$: 'Receive', a: a, b: b};
	});
var $author$project$SubComp$receive = F2(
	function (n, natsMessage) {
		return A2($author$project$SubComp$Receive, n, natsMessage.data);
	});
var $author$project$Nats$subscribe = function (subject) {
	return A2($author$project$Nats$groupSubscribe, subject, '');
};
var $author$project$SubComp$natsSubscriptions = function (model) {
	return $author$project$Nats$Sub$batch(
		A2(
			$elm$core$List$map,
			function (n) {
				return A2(
					$author$project$Nats$subscribe,
					'test.subject',
					$author$project$SubComp$receive(n));
			},
			A2($elm$core$List$range, 0, model.subCounter - 1)));
};
var $author$project$Nats$Socket$withUserPass = F3(
	function (user, pass, options) {
		return _Utils_update(
			options,
			{
				pass: $elm$core$Maybe$Just(pass),
				user: $elm$core$Maybe$Just(user)
			});
	});
var $author$project$Main$natsSubscriptions = function (model) {
	return $author$project$Nats$Sub$batch(
		_List_fromArray(
			[
				A2(
				$author$project$Nats$Sub$map,
				$author$project$Main$SubCompMsg,
				$author$project$SubComp$natsSubscriptions(model.subcomp)),
				A3($author$project$Nats$groupSubscribe, 'say.hello.to.me', 'server', $author$project$Main$HandleRequest),
				A3(
				$author$project$Nats$connect,
				A3(
					$author$project$Nats$Socket$withUserPass,
					'test',
					'test',
					A2($author$project$Nats$Socket$connectOptions, 'Demo', '0.1')),
				model.socket,
				$author$project$Main$OnSocketEvent)
			]));
};
var $author$project$Main$applyNatsEffect = F2(
	function (effect, model) {
		var _v0 = A4(
			$author$project$Nats$applyEffectAndSub,
			$author$project$Main$natsConfig,
			effect,
			$author$project$Main$natsSubscriptions(model),
			model.nats);
		var nats = _v0.a;
		var cmd = _v0.b;
		return _Utils_Tuple2(
			_Utils_update(
				model,
				{nats: nats}),
			cmd);
	});
var $author$project$Nats$Internal$Types$BatchEffect = function (a) {
	return {$: 'BatchEffect', a: a};
};
var $author$project$Nats$Internal$Types$NoEffect = {$: 'NoEffect'};
var $author$project$Nats$Internal$Types$Pub = function (a) {
	return {$: 'Pub', a: a};
};
var $author$project$Nats$Internal$Types$Request = function (a) {
	return {$: 'Request', a: a};
};
var $author$project$Nats$Effect$map = F2(
	function (fn, effect) {
		switch (effect.$) {
			case 'Pub':
				var pub = effect.a;
				return $author$project$Nats$Internal$Types$Pub(pub);
			case 'Request':
				var sid = effect.a.sid;
				var subject = effect.a.subject;
				var group = effect.a.group;
				var message = effect.a.message;
				var onResponse = effect.a.onResponse;
				var timeout = effect.a.timeout;
				return $author$project$Nats$Internal$Types$Request(
					{
						group: group,
						message: message,
						onResponse: A2($elm$core$Basics$composeR, onResponse, fn),
						sid: sid,
						subject: subject,
						timeout: timeout
					});
			case 'BatchEffect':
				var list = effect.a;
				return $author$project$Nats$Internal$Types$BatchEffect(
					A2(
						$elm$core$List$map,
						$author$project$Nats$Effect$map(fn),
						list));
			default:
				return $author$project$Nats$Internal$Types$NoEffect;
		}
	});
var $author$project$Nats$Effect$none = $author$project$Nats$Internal$Types$NoEffect;
var $author$project$Nats$publish = F2(
	function (subject, message) {
		return $author$project$Nats$Internal$Types$Pub(
			{message: message, replyTo: $elm$core$Maybe$Nothing, sid: $elm$core$Maybe$Nothing, subject: subject});
	});
var $author$project$Main$ReceiveResponse = function (a) {
	return {$: 'ReceiveResponse', a: a};
};
var $author$project$Main$RequestError = {$: 'RequestError'};
var $author$project$Main$receiveResponse = function (result) {
	if (result.$ === 'Ok') {
		var message = result.a;
		return $author$project$Main$ReceiveResponse(message);
	} else {
		return $author$project$Main$RequestError;
	}
};
var $author$project$Nats$groupRequest = F4(
	function (group, subject, message, onResponse) {
		return $author$project$Nats$Internal$Types$Request(
			{group: group, message: message, onResponse: onResponse, sid: $elm$core$Maybe$Nothing, subject: subject, timeout: $elm$core$Maybe$Nothing});
	});
var $author$project$Nats$request = $author$project$Nats$groupRequest('');
var $author$project$Nats$Socket$Error = function (a) {
	return {$: 'Error', a: a};
};
var $author$project$Nats$Socket$Opened = {$: 'Opened'};
var $author$project$Nats$Events$SocketError = function (a) {
	return {$: 'SocketError', a: a};
};
var $author$project$Nats$Socket$Connected = {$: 'Connected'};
var $author$project$Nats$Internal$SocketState$setStatus = F2(
	function (status, state) {
		return _Utils_update(
			state,
			{status: status});
	});
var $author$project$Nats$Internal$SocketState$ackCONNECT = $author$project$Nats$Internal$SocketState$setStatus($author$project$Nats$Socket$Connected);
var $author$project$Nats$Internal$SocketState$Closed = {$: 'Closed'};
var $author$project$Nats$Internal$SocketState$handleTimeouts = F2(
	function (time, state) {
		var _v0 = A3(
			$elm$core$Dict$foldl,
			F3(
				function (key, sub, _v1) {
					var d = _v1.a;
					var msg = _v1.b;
					var _v2 = sub.subType;
					if (_v2.$ === 'Req') {
						var deadline = _v2.a.deadline;
						var onTimeout = _v2.a.onTimeout;
						return (_Utils_cmp(deadline, time) < 0) ? _Utils_Tuple2(
							A3(
								$elm$core$Dict$insert,
								key,
								_Utils_update(
									sub,
									{subType: $author$project$Nats$Internal$SocketState$Closed}),
								d),
							A2(
								$elm$core$List$cons,
								onTimeout(
									$elm$time$Time$millisToPosix(time)),
								msg)) : _Utils_Tuple2(
							A3($elm$core$Dict$insert, key, sub, d),
							msg);
					} else {
						return _Utils_Tuple2(
							A3($elm$core$Dict$insert, key, sub, d),
							msg);
					}
				}),
			_Utils_Tuple2($elm$core$Dict$empty, _List_Nil),
			state.nextSubscriptions);
		var subs = _v0.a;
		var msgList = _v0.b;
		return _Utils_Tuple2(
			_Utils_update(
				state,
				{nextSubscriptions: subs}),
			msgList);
	});
var $author$project$Nats$Internal$SocketState$parse = F3(
	function (cfg, data, state) {
		var _v0 = A2(cfg.parse, data, state.partialOperation);
		switch (_v0.$) {
			case 'Operation':
				var op = _v0.a;
				return _Utils_Tuple2(
					_Utils_update(
						state,
						{partialOperation: $elm$core$Maybe$Nothing}),
					$elm$core$Maybe$Just(op));
			case 'Partial':
				var op = _v0.a;
				return _Utils_Tuple2(
					_Utils_update(
						state,
						{
							partialOperation: $elm$core$Maybe$Just(op)
						}),
					$elm$core$Maybe$Nothing);
			default:
				var err = _v0.a;
				return _Utils_Tuple2(
					_Utils_update(
						state,
						{
							partialOperation: $elm$core$Maybe$Nothing,
							status: $author$project$Nats$Socket$Error(err)
						}),
					$elm$core$Maybe$Nothing);
		}
	});
var $author$project$Nats$Protocol$CONNECT = function (a) {
	return {$: 'CONNECT', a: a};
};
var $author$project$Nats$Socket$Connecting = {$: 'Connecting'};
var $author$project$Nats$Events$SocketOpen = function (a) {
	return {$: 'SocketOpen', a: a};
};
var $author$project$Nats$Internal$SocketState$receiveOperation = F2(
	function (operation, state) {
		switch (operation.$) {
			case 'INFO':
				var serverInfo = operation.a;
				return _Utils_Tuple3(
					A2(
						$author$project$Nats$Internal$SocketState$setStatus,
						$author$project$Nats$Socket$Connecting,
						_Utils_update(
							state,
							{
								serverInfo: $elm$core$Maybe$Just(serverInfo)
							})),
					_List_fromArray(
						[
							state.onEvent(
							$author$project$Nats$Events$SocketOpen(serverInfo))
						]),
					_List_fromArray(
						[
							$author$project$Nats$Protocol$CONNECT(state.connectOptions)
						]));
			case 'PING':
				return _Utils_Tuple3(
					state,
					_List_Nil,
					_List_fromArray(
						[$author$project$Nats$Protocol$PONG]));
			case 'MSG':
				var id = operation.a;
				var message = operation.b;
				var _v1 = A2($author$project$Nats$Internal$SocketState$getSubscriptionByID, id, state);
				if (_v1.$ === 'Nothing') {
					return _Utils_Tuple3(state, _List_Nil, _List_Nil);
				} else {
					var sub = _v1.a;
					var _v2 = function () {
						var _v3 = sub.subType;
						switch (_v3.$) {
							case 'Req':
								var onMessage = _v3.a.onMessage;
								return onMessage(message);
							case 'Closed':
								return _Utils_Tuple2($elm$core$Maybe$Nothing, false);
							default:
								return _Utils_Tuple2(
									$elm$core$Maybe$Just(message),
									true);
						}
					}();
					var actualMessage = _v2.a;
					var _continue = _v2.b;
					var nextState = _continue ? state : _Utils_update(
						state,
						{
							nextSubscriptions: A3(
								$elm$core$Dict$insert,
								_Utils_Tuple2(sub.subject, sub.group),
								_Utils_update(
									sub,
									{subType: $author$project$Nats$Internal$SocketState$Closed}),
								state.nextSubscriptions)
						});
					return _Utils_Tuple3(
						nextState,
						function () {
							if (actualMessage.$ === 'Nothing') {
								return _List_Nil;
							} else {
								var msg = actualMessage.a;
								return A2(
									$elm$core$List$map,
									function (onMessage) {
										return onMessage(msg);
									},
									sub.handlers);
							}
						}(),
						_List_Nil);
				}
			default:
				return _Utils_Tuple3(state, _List_Nil, _List_Nil);
		}
	});
var $author$project$Nats$Internal$SocketState$receive = F3(
	function (cfg, data, state) {
		var _v0 = A3($author$project$Nats$Internal$SocketState$parse, cfg, data, state);
		var parseState = _v0.a;
		var maybeOperation = _v0.b;
		if (maybeOperation.$ === 'Nothing') {
			return _Utils_Tuple3(parseState, _List_Nil, _List_Nil);
		} else {
			var op = maybeOperation.a;
			return A2($author$project$Nats$Internal$SocketState$receiveOperation, op, parseState);
		}
	});
var $author$project$Nats$Internal$SocketStateCollection$update = F3(
	function (sid, fn, _v0) {
		var list = _v0.a;
		return $author$project$Nats$Internal$SocketStateCollection$SocketStateCollection(
			A2(
				$elm$core$List$map,
				function (socket) {
					return _Utils_eq(socket.socket.id, sid) ? fn(socket) : socket;
				},
				list));
	});
var $author$project$Nats$updateWithEffects = F3(
	function (cfg, msg, oState) {
		var state = oState.a;
		switch (msg.$) {
			case 'OnOpen':
				var sid = msg.a;
				return _Utils_Tuple3(
					$author$project$Nats$State(
						_Utils_update(
							state,
							{
								sockets: A3(
									$author$project$Nats$Internal$SocketStateCollection$update,
									sid,
									$author$project$Nats$Internal$SocketState$setStatus($author$project$Nats$Socket$Opened),
									state.sockets)
							})),
					_List_Nil,
					$elm$core$Platform$Cmd$none);
			case 'OnClose':
				var sid = msg.a;
				return A4(
					$author$project$Nats$updateSocket,
					cfg,
					sid,
					function (socket) {
						var _v1 = socket.status;
						if (_v1.$ === 'Closing') {
							return _Utils_Tuple3($elm$core$Maybe$Nothing, _List_Nil, $elm$core$Platform$Cmd$none);
						} else {
							return _Utils_Tuple3(
								$elm$core$Maybe$Just(
									A2(
										$author$project$Nats$Internal$SocketState$setStatus,
										$author$project$Nats$Socket$Error('socket closed'),
										socket)),
								_List_Nil,
								$elm$core$Platform$Cmd$none);
						}
					},
					oState);
			case 'OnError':
				var sid = msg.a.sid;
				var message = msg.a.message;
				return A4(
					$author$project$Nats$updateSocket,
					cfg,
					sid,
					function (socket) {
						return _Utils_Tuple3(
							$elm$core$Maybe$Just(
								A2(
									$author$project$Nats$Internal$SocketState$setStatus,
									$author$project$Nats$Socket$Error(message),
									socket)),
							_List_Nil,
							$elm$core$Platform$Cmd$none);
					},
					oState);
			case 'OnMessage':
				var sid = msg.a.sid;
				var message = msg.a.message;
				var _v2 = A2($author$project$Nats$Internal$SocketStateCollection$findByID, sid, state.sockets);
				if (_v2.$ === 'Nothing') {
					return _Utils_Tuple3(oState, _List_Nil, $elm$core$Platform$Cmd$none);
				} else {
					var socket = _v2.a;
					var _v3 = cfg.fromPortMessage(message);
					if (_v3.$ === 'Ok') {
						var data = _v3.a;
						var _v4 = A3($author$project$Nats$Internal$SocketState$receive, cfg, data, socket);
						var socketN = _v4.a;
						var msgs = _v4.b;
						var operations = _v4.c;
						return _Utils_Tuple3(
							$author$project$Nats$State(
								_Utils_update(
									state,
									{
										sockets: A2($author$project$Nats$Internal$SocketStateCollection$insert, socketN, state.sockets)
									})),
							msgs,
							$elm$core$Platform$Cmd$batch(
								A2(
									$elm$core$List$map,
									function (op) {
										return A2(
											$author$project$Nats$doSend,
											cfg,
											{
												ack: function () {
													if (op.$ === 'CONNECT') {
														return $elm$core$Maybe$Just('CONNECT');
													} else {
														return $elm$core$Maybe$Nothing;
													}
												}(),
												message: cfg.toPortMessage(
													cfg.write(op)),
												sid: sid
											});
									},
									operations)));
					} else {
						var err = _v3.a;
						return _Utils_Tuple3(
							oState,
							_List_fromArray(
								[
									socket.onEvent(
									$author$project$Nats$Events$SocketError(err))
								]),
							$elm$core$Platform$Cmd$none);
					}
				}
			case 'OnAck':
				var sid = msg.a.sid;
				var ack = msg.a.ack;
				return A4(
					$author$project$Nats$updateSocket,
					cfg,
					sid,
					function (socket) {
						return _Utils_Tuple3(
							$elm$core$Maybe$Just(
								$author$project$Nats$Internal$SocketState$ackCONNECT(socket)),
							_List_Nil,
							$elm$core$Platform$Cmd$none);
					},
					oState);
			default:
				var time = msg.a;
				var msTime = $elm$time$Time$posixToMillis(time);
				var _v6 = A2(
					$author$project$Nats$Internal$SocketStateCollection$mapWithEffect,
					$author$project$Nats$Internal$SocketState$handleTimeouts(msTime),
					state.sockets);
				var sockets = _v6.a;
				var msgs = _v6.b;
				return _Utils_Tuple3(
					$author$project$Nats$State(
						_Utils_update(
							state,
							{sockets: sockets, time: msTime})),
					$elm$core$List$concat(msgs),
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Nats$update = F3(
	function (cfg, msg, state) {
		var _v0 = A3($author$project$Nats$updateWithEffects, cfg, msg, state);
		var newState = _v0.a;
		var msgs = _v0.b;
		var cmds = _v0.c;
		return _Utils_Tuple2(
			newState,
			$elm$core$Platform$Cmd$batch(
				A2(
					$elm$core$List$cons,
					A2($elm$core$Platform$Cmd$map, cfg.parentMsg, cmds),
					A2(
						$elm$core$List$map,
						A2(
							$elm$core$Basics$composeR,
							$elm$core$Task$succeed,
							$elm$core$Task$perform($elm$core$Basics$identity)),
						msgs))));
	});
var $author$project$SubComp$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'Subscribe':
				return _Utils_Tuple3(
					_Utils_update(
						model,
						{subCounter: model.subCounter + 1}),
					$author$project$Nats$Effect$none,
					$elm$core$Platform$Cmd$none);
			case 'Unsubscribe':
				return _Utils_Tuple3(
					_Utils_update(
						model,
						{
							subCounter: (model.subCounter > 0) ? (model.subCounter - 1) : 0
						}),
					$author$project$Nats$Effect$none,
					$elm$core$Platform$Cmd$none);
			default:
				var n = msg.a;
				var data = msg.b;
				return _Utils_Tuple3(
					_Utils_update(
						model,
						{
							received: function () {
								var _v1 = A2(
									$elm$bytes$Bytes$Decode$decode,
									$elm$bytes$Bytes$Decode$string(
										$elm$bytes$Bytes$width(data)),
									data);
								if (_v1.$ === 'Just') {
									var s = _v1.a;
									return A2(
										$elm$core$List$cons,
										$elm$core$String$fromInt(n) + (': ' + s),
										model.received);
								} else {
									return A2($elm$core$List$cons, 'could not decode message', model.received);
								}
							}()
						}),
					$author$project$Nats$Effect$none,
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Main$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'NatsMsg':
				var natsMsg = msg.a;
				var _v1 = A3($author$project$Nats$update, $author$project$Main$natsConfig, natsMsg, model.nats);
				var nats = _v1.a;
				var natsCmd = _v1.b;
				return _Utils_Tuple3(
					_Utils_update(
						model,
						{nats: nats}),
					$author$project$Nats$Effect$none,
					natsCmd);
			case 'OnSocketEvent':
				if (msg.a.$ === 'SocketOpen') {
					var info = msg.a.a;
					return _Utils_Tuple3(
						_Utils_update(
							model,
							{
								serverInfo: $elm$core$Maybe$Just(info)
							}),
						$author$project$Nats$Effect$none,
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple3(model, $author$project$Nats$Effect$none, $elm$core$Platform$Cmd$none);
				}
			case 'SubCompMsg':
				var subcompMsg = msg.a;
				var _v2 = A2($author$project$SubComp$update, subcompMsg, model.subcomp);
				var subcomp = _v2.a;
				var subcompNatsEffect = _v2.b;
				var subcompCmd = _v2.c;
				return _Utils_Tuple3(
					_Utils_update(
						model,
						{subcomp: subcomp}),
					A2($author$project$Nats$Effect$map, $author$project$Main$SubCompMsg, subcompNatsEffect),
					A2($elm$core$Platform$Cmd$map, $author$project$Main$SubCompMsg, subcompCmd));
			case 'HandleRequest':
				var message = msg.a;
				return _Utils_Tuple3(
					model,
					A2(
						$author$project$Nats$publish,
						message.replyTo,
						$elm$bytes$Bytes$Encode$encode(
							$elm$bytes$Bytes$Encode$sequence(
								_List_fromArray(
									[
										$elm$bytes$Bytes$Encode$string('Hello '),
										$elm$bytes$Bytes$Encode$bytes(message.data),
										$elm$bytes$Bytes$Encode$string('!')
									])))),
					$elm$core$Platform$Cmd$none);
			case 'Publish':
				return _Utils_Tuple3(
					model,
					A2(
						$author$project$Nats$publish,
						'test.subject',
						$elm$bytes$Bytes$Encode$encode(
							$elm$bytes$Bytes$Encode$string('Hi'))),
					$elm$core$Platform$Cmd$none);
			case 'InputText':
				var text = msg.a;
				return _Utils_Tuple3(
					_Utils_update(
						model,
						{inputText: text}),
					$author$project$Nats$Effect$none,
					$elm$core$Platform$Cmd$none);
			case 'SendRequest':
				return _Utils_Tuple3(
					model,
					A3(
						$author$project$Nats$request,
						'say.hello.to.me',
						$elm$bytes$Bytes$Encode$encode(
							$elm$bytes$Bytes$Encode$string(model.inputText)),
						$author$project$Main$receiveResponse),
					$elm$core$Platform$Cmd$none);
			case 'RequestError':
				return _Utils_Tuple3(
					_Utils_update(
						model,
						{
							response: $elm$core$Maybe$Just('Sorry, timeout error... Try again later?')
						}),
					$author$project$Nats$Effect$none,
					$elm$core$Platform$Cmd$none);
			case 'ReceiveResponse':
				var response = msg.a;
				return _Utils_Tuple3(
					_Utils_update(
						model,
						{
							response: function () {
								var _v3 = A2(
									$elm$bytes$Bytes$Decode$decode,
									$elm$bytes$Bytes$Decode$string(
										$elm$bytes$Bytes$width(response)),
									response);
								if (_v3.$ === 'Just') {
									var s = _v3.a;
									return $elm$core$Maybe$Just(s);
								} else {
									return $elm$core$Maybe$Just('could not decode response');
								}
							}()
						}),
					$author$project$Nats$Effect$none,
					$elm$core$Platform$Cmd$none);
			case 'NoOp':
				return _Utils_Tuple3(model, $author$project$Nats$Effect$none, $elm$core$Platform$Cmd$none);
			default:
				return _Utils_Tuple3(model, $author$project$Nats$Effect$none, $elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Main$updateWrapper = F2(
	function (msg, model) {
		var _v0 = A2($author$project$Main$update, msg, model);
		var model1 = _v0.a;
		var natsEffect = _v0.b;
		var cmd = _v0.c;
		var _v1 = A2($author$project$Main$applyNatsEffect, natsEffect, model1);
		var model2 = _v1.a;
		var natsCmd = _v1.b;
		return _Utils_Tuple2(
			model2,
			$elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[cmd, natsCmd])));
	});
var $author$project$Main$InputText = function (a) {
	return {$: 'InputText', a: a};
};
var $author$project$Main$Publish = {$: 'Publish'};
var $author$project$Main$SendRequest = {$: 'SendRequest'};
var $elm$html$Html$a = _VirtualDom_node('a');
var $elm$html$Html$button = _VirtualDom_node('button');
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $elm$html$Html$div = _VirtualDom_node('div');
var $elm$html$Html$h4 = _VirtualDom_node('h4');
var $elm$html$Html$Attributes$href = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'href',
		_VirtualDom_noJavaScriptUri(url));
};
var $elm$html$Html$input = _VirtualDom_node('input');
var $elm$html$Html$li = _VirtualDom_node('li');
var $elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
var $elm$html$Html$map = $elm$virtual_dom$VirtualDom$map;
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 'Normal', a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $elm$html$Html$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$html$Html$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var $elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 'MayStopPropagation', a: a};
};
var $elm$html$Html$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var $elm$html$Html$Events$targetValue = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	$elm$json$Json$Decode$string);
var $elm$html$Html$Events$onInput = function (tagger) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'input',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysStop,
			A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetValue)));
};
var $elm$html$Html$p = _VirtualDom_node('p');
var $elm$html$Html$Attributes$placeholder = $elm$html$Html$Attributes$stringProperty('placeholder');
var $elm$html$Html$h1 = _VirtualDom_node('h1');
var $elm$html$Html$h3 = _VirtualDom_node('h3');
var $elm$core$Basics$modBy = _Basics_modBy;
var $author$project$Main$panel = function (body) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('panel panel-default')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('panel-body')
					]),
				body)
			]));
};
var $elm$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _v0) {
				var trues = _v0.a;
				var falses = _v0.b;
				return pred(x) ? _Utils_Tuple2(
					A2($elm$core$List$cons, x, trues),
					falses) : _Utils_Tuple2(
					trues,
					A2($elm$core$List$cons, x, falses));
			});
		return A3(
			$elm$core$List$foldr,
			step,
			_Utils_Tuple2(_List_Nil, _List_Nil),
			list);
	});
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $author$project$Main$scaffolding = function (boxes) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('container')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('header clearfix')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$h3,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('text-muted')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Elm NATS')
							]))
					])),
				function () {
				var _v0 = A2(
					$elm$core$List$partition,
					function (_v1) {
						var n = _v1.a;
						var box = _v1.b;
						return !A2($elm$core$Basics$modBy, 2, n);
					},
					A3(
						$elm$core$List$map2,
						F2(
							function (n, box) {
								return _Utils_Tuple2(
									n,
									$author$project$Main$panel(box));
							}),
						A2($elm$core$List$range, 0, 50),
						boxes));
				var col1 = _v0.a;
				var col2 = _v0.b;
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('row')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('col-sm-12')
								]),
							_List_fromArray(
								[
									$author$project$Main$panel(
									_List_fromArray(
										[
											A2(
											$elm$html$Html$h1,
											_List_Nil,
											_List_fromArray(
												[
													$elm$html$Html$text('Elm NATS demonstration mini-app')
												])),
											A2(
											$elm$html$Html$p,
											_List_Nil,
											_List_fromArray(
												[
													$elm$html$Html$text('This mini-app demonstration pub, sub and req/rep using Bytes messages')
												]))
										]))
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('col-sm-6')
								]),
							A2($elm$core$List$map, $elm$core$Tuple$second, col1)),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('col-sm-6')
								]),
							A2($elm$core$List$map, $elm$core$Tuple$second, col2))
						]));
			}()
			]));
};
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $elm$html$Html$ul = _VirtualDom_node('ul');
var $author$project$SubComp$Subscribe = {$: 'Subscribe'};
var $author$project$SubComp$Unsubscribe = {$: 'Unsubscribe'};
var $elm$core$List$singleton = function (value) {
	return _List_fromArray(
		[value]);
};
var $author$project$SubComp$view = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$h4,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text('Subscribe')
					])),
				A2(
				$elm$html$Html$p,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text('The Subscribe button add a new subscription to \'test.subject\'.')
					])),
				A2(
				$elm$html$Html$button,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('btn btn-default'),
						$elm$html$Html$Events$onClick($author$project$SubComp$Subscribe)
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Subscribe')
					])),
				A2(
				$elm$html$Html$button,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('btn btn-default'),
						$elm$html$Html$Events$onClick($author$project$SubComp$Unsubscribe)
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Unsubscribe')
					])),
				A2(
				$elm$html$Html$p,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text(
						'Current subscriptions: ' + $elm$core$String$fromInt(model.subCounter))
					])),
				A2(
				$elm$html$Html$p,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text('Here are the received messages, prefixed with a subscription id (most recent are on top):')
					])),
				A2(
				$elm$html$Html$ul,
				_List_Nil,
				A2(
					$elm$core$List$map,
					A2(
						$elm$core$Basics$composeR,
						$elm$html$Html$text,
						A2(
							$elm$core$Basics$composeR,
							$elm$core$List$singleton,
							$elm$html$Html$li(_List_Nil))),
					model.received))
			]));
};
var $author$project$Main$view = function (model) {
	var ready = function () {
		var _v2 = model.serverInfo;
		if (_v2.$ === 'Just') {
			return true;
		} else {
			return false;
		}
	}();
	return {
		body: _List_fromArray(
			[
				$author$project$Main$scaffolding(
				_List_fromArray(
					[
						_List_fromArray(
						[
							A2(
							$elm$html$Html$h4,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('Here is what we know about the NATS server')
								])),
							function () {
							var _v0 = model.serverInfo;
							if (_v0.$ === 'Just') {
								var info = _v0.a;
								return A2(
									$elm$html$Html$ul,
									_List_Nil,
									_List_fromArray(
										[
											A2(
											$elm$html$Html$li,
											_List_Nil,
											_List_fromArray(
												[
													$elm$html$Html$text('Server ID: ' + info.server_id)
												])),
											A2(
											$elm$html$Html$li,
											_List_Nil,
											_List_fromArray(
												[
													$elm$html$Html$text('Version: ' + info.version)
												])),
											A2(
											$elm$html$Html$li,
											_List_Nil,
											_List_fromArray(
												[
													$elm$html$Html$text('Go version: ' + info.go)
												]))
										]));
							} else {
								return A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('alert alert-warning')
										]),
									_List_fromArray(
										[
											$elm$html$Html$text('Problem: No connection established (yet?). This app need a running '),
											A2(
											$elm$html$Html$a,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$href('https://github.com/nats-io/gnatsd/')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('gnatsd')
												])),
											$elm$html$Html$text(' and a running '),
											A2(
											$elm$html$Html$a,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$href('https://github.com/orus-io/nats-websocket-gw')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('nats-websocket-gw')
												])),
											$elm$html$Html$text(' --no-origin-check')
										]));
							}
						}()
						]),
						_List_fromArray(
						[
							A2(
							$elm$html$Html$h4,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('Publish')
								])),
							A2(
							$elm$html$Html$p,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('The Publish button sends \'Hi\' on \'test.subject\'.')
								])),
							A2(
							$elm$html$Html$button,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('btn btn-primary'),
									$elm$html$Html$Events$onClick($author$project$Main$Publish)
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Publish')
								]))
						]),
						_List_fromArray(
						[
							A2(
							$elm$html$Html$h4,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('A req/rep demo')
								])),
							A2(
							$elm$html$Html$input,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('form-control'),
									$elm$html$Html$Attributes$type_('text'),
									$elm$html$Html$Events$onInput($author$project$Main$InputText),
									$elm$html$Html$Attributes$placeholder('Your name')
								]),
							_List_Nil),
							A2(
							$elm$html$Html$button,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('btn btn-primary'),
									$elm$html$Html$Events$onClick($author$project$Main$SendRequest)
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Say hello !')
								])),
							function () {
							var _v1 = model.response;
							if (_v1.$ === 'Just') {
								var response = _v1.a;
								return $elm$html$Html$text(response);
							} else {
								return $elm$html$Html$text('');
							}
						}()
						]),
						_List_fromArray(
						[
							A2(
							$elm$html$Html$map,
							$author$project$Main$SubCompMsg,
							$author$project$SubComp$view(model.subcomp))
						])
					]))
			]),
		title: 'Elm Nats Demo'
	};
};
var $author$project$Main$main = $elm$browser$Browser$document(
	{init: $author$project$Main$init, subscriptions: $author$project$Main$subscriptions, update: $author$project$Main$updateWrapper, view: $author$project$Main$view});
_Platform_export({'Main':{'init':$author$project$Main$main(
	A2(
		$elm$json$Json$Decode$andThen,
		function (now) {
			return $elm$json$Json$Decode$succeed(
				{now: now});
		},
		A2($elm$json$Json$Decode$field, 'now', $elm$json$Json$Decode$int)))(0)}});}(this));