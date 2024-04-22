module ut.pynih.python.object_;


import unit_threaded;
import autowrap.pynih.python.object_;
import autowrap.pynih.python.conv;
import autowrap.pynih.python.exception;


@("lt")
unittest {
    const three = PythonObject(3);
    const five = PythonObject(5);

    (three < five).should == true;
    (three < three).should == false;
    (five < three).should == false;

    (three < PythonObject("foo"))
        .shouldThrowWithMessage!PythonException(
            "TypeError: '<' not supported between instances of 'int' and 'str'");
}


@("le")
unittest {
    const three = PythonObject(3);
    const five = PythonObject(5);

    (three <= five).should == true;
    (three <= three).should == true;
    (five <= three).should == false;

    (three <= PythonObject("foo"))
        .shouldThrowWithMessage!PythonException(
            "TypeError: '<' not supported between instances of 'int' and 'str'");
}


@("eq")
unittest {
    const three = PythonObject(3);
    const five = PythonObject(5);

    (three == three).should == true;
    (three == five).should == false;
    (five == three).should == false;

    (three == PythonObject("foo")).should == false;
}



@("gt")
unittest {
    const three = PythonObject(3);
    const five = PythonObject(5);

    (three > five).should == false;
    (three > three).should == false;
    (five > three).should == true;

    (three < PythonObject("foo"))
        .shouldThrowWithMessage!PythonException(
            "TypeError: '<' not supported between instances of 'int' and 'str'");
}


@("ge")
unittest {
    const three = PythonObject(3);
    const five = PythonObject(5);

    (three >= five).should == false;
    (three >= three).should == true;
    (five >= three).should == true;

    (three <= PythonObject("foo"))
        .shouldThrowWithMessage!PythonException(
            "TypeError: '<' not supported between instances of 'int' and 'str'");
}


@("str")
unittest {
    PythonObject(3).str.toString.should == "3";
    PythonObject("foo").str.toString.should == "foo";
    PythonObject([1: 2]).str.toString.should == "{1: 2}";
}


@("repr")
unittest {
    PythonObject(3).repr.toString.should == "3";
    PythonObject("foo").repr.toString.should == "'foo'";
    PythonObject([1: 2]).repr.toString.should == "{1: 2}";
}


@("toString")
unittest {
    PythonObject(3).toString.should == "3";
    PythonObject("foo").toString.should == "foo";
    PythonObject([1: 2]).toString.should == "{1: 2}";
}


@("bytes")
unittest {
    int[] ints = ['f', 'o', 'o'];
    PythonObject(ints).bytes.toString.should == "b'foo'";
    PythonObject("oops").bytes
        .shouldThrowWithMessage!PythonException(
            "TypeError: cannot convert 'str' object to bytes"
            );
}


@("hash")
unittest {
    PythonObject(42).hash.should == 42;
    PythonObject(77).hash.should == 77;
    PythonObject(3.3).hash.should == 691752902764107779;
}


@("type")
unittest {
    PythonObject(42).type.toString.should == "<class 'int'>";
    PythonObject("foo").type.toString.should == "<class 'str'>";
    PythonObject([1: 2]).type.toString.should == "<class 'dict'>";
}

@("dir")
unittest {
    const dir = PythonObject(42).dir.to!(string[]);
    "real".should.be in dir;
    "imag".should.be in dir;
}


@("len")
unittest {
    PythonObject(42).len.shouldThrowWithMessage!PythonException(
        "TypeError: object of type 'int' has no len()"
    );

    PythonObject("foo").len.should == 3;
    PythonObject([1, 2]).len.should == 2;
    PythonObject([1: 2]).len.should == 1;
}

@("not")
unittest {
    PythonObject(false).not.should == true;
    PythonObject(true).not.should == false;
    PythonObject(0).not.should == true;
    PythonObject(1).not.should == false;
}


@("hasattr")
unittest {
    PythonObject(42).hasattr("real").should == true;
    PythonObject(42).hasattr("foo").should == false;

    PythonObject(42).hasattr(PythonObject("real")).should == true;
    PythonObject(42).hasattr(PythonObject("foo")).should == false;
    PythonObject(42).hasattr(PythonObject(42)).should == false;
}


@("getattr")
unittest {
    PythonObject(42).getattr("real").to!int.should == 42;
    PythonObject(42).getattr("imag").to!int.should == 0;
    PythonObject(42).getattr("foo").shouldThrowWithMessage!PythonException(
        "AttributeError: 'int' object has no attribute 'foo'");

    PythonObject(42).getattr(PythonObject("real")).to!int.should == 42;
    PythonObject(42).getattr(PythonObject("imag")).to!int.should == 0;

    PythonObject(42).getattr(PythonObject("foo")).shouldThrowWithMessage!PythonException(
        "AttributeError: 'int' object has no attribute 'foo'");
    PythonObject(42).getattr(PythonObject(42)).shouldThrowWithMessage!PythonException(
        "TypeError: attribute name must be string, not 'int'");
}


@("setattr")
unittest {
    import python.c: PyRun_StringFlags, Py_file_input, Py_eval_input, PyCompilerFlags, PyDict_New;
    import std.array: join;
    import std.string: toStringz;

    static linesToCode(in string[] lines) {
        return lines.join("\n").toStringz;
    }

    const define = linesToCode(
        [
            `class Foo(object):`,
            `    pass`,
            ``,
        ]
    );

    PyCompilerFlags flags;
    auto globals = PyDict_New;
    auto locals = PyDict_New;

    auto defRes = PyRun_StringFlags(
        define,
        Py_file_input,
        globals,
        locals,
        &flags,
    );

    if(defRes is null) throw new PythonException("oops");

    auto evalRes = PyRun_StringFlags(
        `Foo()`,
        Py_eval_input,
        globals,
        locals,
        &flags,
    );

    if(evalRes is null) throw new PythonException("oops");
    auto foo = PythonObject(evalRes);
    "Foo object".should.be in foo.toString;

    foo.hasattr("a1").should == false;
    foo.setattr("a1", "bar");
    foo.hasattr("a1").should == true;
    foo.getattr("a1").to!string.should == "bar";
    foo.setattr("a1", PythonObject("baz"));
    foo.getattr("a1").to!string.should == "baz";

    foo.hasattr("a2").should == false;
    foo.setattr(PythonObject("a2"), "quux");
    foo.hasattr("a2").should == true;
    foo.getattr("a2").to!string.should == "quux";
    foo.setattr(PythonObject("a2"), PythonObject("toto"));
    foo.hasattr("a2").should == true;
    foo.getattr("a2").to!string.should == "toto";
    foo.setattr(PythonObject(42), "oops").shouldThrowWithMessage!PythonException(
        "TypeError: attribute name must be string, not 'int'");
}


@("delattr")
unittest {
    import python.c: PyRun_StringFlags, Py_file_input, Py_eval_input, PyCompilerFlags, PyDict_New;
    import std.array: join;
    import std.string: toStringz;
    import std.regex: matchFirst, regex;

    static linesToCode(in string[] lines) {
        return lines.join("\n").toStringz;
    }

    const define = linesToCode(
        [
            `class Foo(object):`,
            `    pass`,
            ``,
        ]
    );

    PyCompilerFlags flags;
    auto globals = PyDict_New;
    auto locals = PyDict_New;

    auto defRes = PyRun_StringFlags(
        define,
        Py_file_input,
        globals,
        locals,
        &flags,
    );

    if(defRes is null) throw new PythonException("oops");

    auto evalRes = PyRun_StringFlags(
        `Foo()`,
        Py_eval_input,
        globals,
        locals,
        &flags,
    );

    if(evalRes is null) throw new PythonException("oops");
    auto foo = PythonObject(evalRes);
    "Foo object".should.be in foo.toString;

    {
	    auto r = regex(r"^AttributeError: ('Foo' object has no attribute ')?oops(')?$");
	    foo.delattr("oops").shouldThrow!PythonException.msg.matchFirst(r).shouldNotBeEmpty;
    }
    {
	    auto r = regex(r"^AttributeError: ('Foo' object has no attribute ')?oopsie(')?$");
	    foo.delattr("oopsie").shouldThrow!PythonException.msg.matchFirst(r).shouldNotBeEmpty;
    }

    foo.setattr("key", "val");
    foo.hasattr("key").should == true;
    foo.delattr("key");
    foo.hasattr("key").should == false;

    foo.setattr(PythonObject("key"), "value");
    foo.hasattr("key").should == true;
    foo.delattr(PythonObject("key"));
    foo.hasattr("key").should == false;
}


@("opDispatch")
unittest {
    import python.c: PyRun_StringFlags, Py_file_input, Py_eval_input, PyCompilerFlags,
        PyDict_New;
    import std.array: join;
    import std.string: toStringz;
    import std.typecons: tuple;

    static linesToCode(in string[] lines) {
        return lines.join("\n").toStringz;
    }

    const define = linesToCode(
        [
            `class Foo(object):`,
            `    def __init__(self, i):`,
            `        self.i = i`,
            `    def meth(self, a, b, c='foo', d='bar'):`,
            `        return f"{self.i}_{a}_{b}_{c}_{d}"`,
            ``,
        ]
    );

    PyCompilerFlags flags;
    auto globals = PyDict_New;
    auto locals = PyDict_New;

    auto defRes = PyRun_StringFlags(
        define,
        Py_file_input,
        globals,
        locals,
        &flags,
    );

    if(defRes is null) throw new PythonException("oops");

    auto evalRes = PyRun_StringFlags(
        `Foo(7)`,
        Py_eval_input,
        globals,
        locals,
        &flags,
    );

    if(evalRes is null) throw new PythonException("oops");
    auto foo = PythonObject(evalRes);
    "Foo object".should.be in foo.toString;

    foo.meth(1, 2).to!string.should == "7_1_2_foo_bar";
    foo.meth(3, 4).to!string.should == "7_3_4_foo_bar";
    foo.meth(1, 2, 0).to!string.should == "7_1_2_0_bar";
    foo.meth(3, 4, 5, 6).to!string.should == "7_3_4_5_6";

    foo.meth(PythonObject(tuple(1, 2))).to!string.should == "7_1_2_foo_bar";
    foo.meth(PythonObject(tuple(1, 2)), PythonObject(["c": 5, "d": 6]))
        .to!string.should == "7_1_2_5_6";
    {
        import std.string : replace;
        auto ex = foo.meth(PythonObject(tuple(1, 2)), PythonObject(["oops": 6]))
            .shouldThrow!PythonException;
        ex.msg.replace("Foo.meth", "meth").should == "TypeError: meth() got an unexpected keyword argument 'oops'";
    }

    foo.meth(PythonObject([1, 2])).shouldThrowWithMessage!PythonException(
        "TypeError: argument list must be a tuple");

    foo.i.to!int.should == 7;
    foo.i(1, 2).shouldThrowWithMessage!PythonException(
        "`i` is not a callable");
    foo.nope.shouldThrowWithMessage!PythonException(
        "AttributeError: 'Foo' object has no attribute 'nope'");
}


@("opIndex")
unittest {
    PythonObject([1, 2, 3])[1].to!int.should == 2;
    PythonObject([1, 2, 3])[2].to!int.should == 3;
    PythonObject([1, 2, 3])[PythonObject(2)].to!int.should == 3;
    PythonObject([1: 2, 3: 4])[1].shouldThrowWithMessage!PythonException(
        "TypeError: dict is not a sequence");

    PythonObject(["foo": 1, "bar": 2])["foo"].to!int.should == 1;
    PythonObject(["foo": 1, "bar": 2])[PythonObject("bar")].to!int.should == 2;
    PythonObject([1, 2, 3])["oops"].shouldThrowWithMessage!PythonException(
        "TypeError: list indices must be integers or slices, not str");


    auto lst = PythonObject([1, 2, 3]);
    lst[1] = 42;
    lst[1].to!int.should == 42;
    lst[PythonObject(2)] = 9;
    lst[2].to!int.should == 9;

    auto dict = PythonObject(["foo": 1, "bar": 2]);
    dict["bar"] = 42;
    dict["bar"].to!int.should == 42;
    dict[PythonObject("foo")] = 77;
    dict["foo"].to!int.should == 77;
}


@("del")
unittest {
    auto lst = PythonObject([1, 2, 3, 4, 5]);
    lst.del(1);
    lst.to!(int[]).should == [1, 3, 4, 5];
    lst.del(0, 2);
    lst.to!(int[]).should == [4, 5];
    lst.del();
    int[] empty;
    lst.to!(int[]).should == empty;

    auto dict = PythonObject(["foo": 1, "bar": 2, "baz": 3]);
    dict.del("foo");
    dict.to!(int[string]).should == ["bar": 2, "baz": 3];
    dict.del(PythonObject("bar"));
    dict.to!(int[string]).should == ["baz": 3];
}


@("inheritance")
unittest {
    import python.c: PyRun_StringFlags, Py_file_input, Py_eval_input, PyCompilerFlags,
        PyDict_New;
    import std.array: join;
    import std.string: toStringz;
    import std.typecons: tuple;

    static linesToCode(in string[] lines) {
        return lines.join("\n").toStringz;
    }

    const define = linesToCode(
        [
            `class Foo(object):`,
            `    pass`,
            `class Bar(object):`,
            `    pass`,
            `class BabyFoo(Foo):`,
            `    pass`,
            ``
        ]
    );

    PyCompilerFlags flags;
    auto globals = PyDict_New;
    auto locals = PyDict_New;

    auto defRes = PyRun_StringFlags(
        define,
        Py_file_input,
        globals,
        locals,
        &flags,
    );

    if(defRes is null) throw new PythonException("oops");

    auto instRes = PyRun_StringFlags(
        `Foo()`,
        Py_eval_input,
        globals,
        locals,
        &flags,
    );
    if(instRes is null) throw new PythonException("oops");

    auto FooRes = PyRun_StringFlags(
        `Foo`,
        Py_eval_input,
        globals,
        locals,
        &flags,
    );
    if(FooRes is null) throw new PythonException("oops");

    auto BarRes = PyRun_StringFlags(
        `Bar`,
        Py_eval_input,
        globals,
        locals,
        &flags,
    );
    if(BarRes is null) throw new PythonException("oops");

    auto BabyFooRes = PyRun_StringFlags(
        `BabyFoo`,
        Py_eval_input,
        globals,
        locals,
        &flags,
    );
    if(BabyFooRes is null) throw new PythonException("oops");

    const foo = PythonObject(instRes);
    const Foo = PythonObject(FooRes);
    const Bar = PythonObject(BarRes);

    foo.isInstance(Foo).should == true;
    foo.isInstance(Bar).should == false;

    const BabyFoo = PythonObject(BabyFooRes);
    BabyFoo.isSubClass(Foo).should == true;
    BabyFoo.isSubClass(BabyFoo).should == true;
    BabyFoo.isSubClass(Bar).should == false;

}


@("slice")
unittest {
    PythonObject([1, 2, 3, 4, 5])[1..3].to!(int[]).should == [2, 3];
    PythonObject([1, 2, 3, 4, 5])[].to!(int[]).should == [1, 2, 3, 4, 5];

    auto lst = PythonObject([1, 2, 3, 4, 5]);
    lst[1..3] = PythonObject([42]);
    lst.to!(int[]).should == [1, 42, 4, 5];

    lst[] = PythonObject([77]);
    lst.to!(int[]).should == [77];

    (lst[1..3] = PythonObject(-1)).shouldThrowWithMessage!PythonException(
        "TypeError: can only assign an iterable");
    PythonObject(1)[1..2].shouldThrowWithMessage!PythonException(
        "TypeError: 'int' object is unsliceable");
}


@("range")
unittest {
    import std.array: array;
    import std.algorithm: map;

    PythonObject([1, 2, 3])
        .range
        .map!(x => x.to!int * 2)
        .should == [2, 4, 6];
}

@("opBinary.+")
unittest {
    (PythonObject(2) + PythonObject(3)).to!int.should == 5;
}


@("opBinary.-")
unittest {
    (PythonObject(5) - PythonObject(3)).to!int.should == 2;
}

@("opBinary.*.int")
unittest {
    (PythonObject(2) * PythonObject(3)).to!int.should == 6;
}


@("opBinary./")
unittest {
    (PythonObject(5) / PythonObject(2)).to!double.should == 2.5;
}


@("opBinary.%")
unittest {
    (PythonObject(5) % PythonObject(2)).to!int.should == 1;
    (PythonObject(4) % PythonObject(2)).to!int.should == 0;
}

@("opBinary.^^")
unittest {
    (PythonObject(2) ^^ PythonObject(3)).to!int.should == 8;
}


@("opBinary.<<")
unittest {
    (PythonObject(2) << PythonObject(4)).to!int.should == 32;
}


@("opBinary.>>")
unittest {
    (PythonObject(32) >> PythonObject(4)).to!int.should == 2;
}


@("opBinary.&")
unittest {
    (PythonObject(0) & PythonObject(0)).to!int.should == 0;
    (PythonObject(0) & PythonObject(1)).to!int.should == 0;
    (PythonObject(1) & PythonObject(0)).to!int.should == 0;
    (PythonObject(1) & PythonObject(1)).to!int.should == 1;
}

@("opBinary.|")
unittest {
    (PythonObject(0) | PythonObject(0)).to!int.should == 0;
    (PythonObject(0) | PythonObject(1)).to!int.should == 1;
    (PythonObject(1) | PythonObject(0)).to!int.should == 1;
    (PythonObject(1) | PythonObject(1)).to!int.should == 1;
}

@("opBinary.^")
unittest {
    (PythonObject(0) ^ PythonObject(0)).to!int.should == 0;
    (PythonObject(0) ^ PythonObject(1)).to!int.should == 1;
    (PythonObject(1) ^ PythonObject(0)).to!int.should == 1;
    (PythonObject(1) ^ PythonObject(1)).to!int.should == 0;
}

@("opBinary.~")
unittest {
    (PythonObject([1, 2, 3]) ~ PythonObject([4, 5])).to!(int[]).should == [1, 2, 3, 4, 5];
}

@("opBinary.*.seq")
unittest {
    (PythonObject([1]) * 3).to!(int[]).should == [1, 1, 1];
}

@("opUnary.+")
unittest {
    (+PythonObject( 3)).to!int.should ==  3;
    (+PythonObject(-3)).to!int.should == -3;
}


@("opUnary.-")
unittest {
    (-PythonObject( 3)).to!int.should == -3;
    (-PythonObject(-3)).to!int.should ==  3;
}


@("opUnary.~")
unittest {
    (~PythonObject(0xf)).to!int.should == 0xfffffff0;
}


@("pyd.dict")
unittest {
    PythonObject(42).keys.shouldThrowWithMessage!PythonException(
        "AttributeError: 'int' object has no attribute 'keys'");

    PythonObject(42).values.shouldThrowWithMessage!PythonException(
        "AttributeError: 'int' object has no attribute 'values'");

    PythonObject(42).items.shouldThrowWithMessage!PythonException(
        "AttributeError: 'int' object has no attribute 'items'");

    auto g = PythonObject(["a": "b"]);
    g.keys.to!(string[]).should == ["a"];
    g.values.to!(string[]).should == ["b"];
    auto items = g.items;
    items[0][0].to!string.should == "a";
    items[0][1].to!string.should == "b";

    g["a"].to!string.should == "b";
    g["b"] = "c";
    g.keys.to!(string[]).should ~ ["a", "b"];
    g.values.to!(string[]).should ~ ["b", "c"];
    g["c"] = PythonObject("d");
    g.keys.to!(string[]).should ~ ["a", "b", "c"];
    g.values.to!(string[]).should ~ ["b", "c", "d"];
    g.del("b");
    g.keys.to!(string[]).should ~ ["a", "c"];
    g.values.to!(string[]).should ~ ["b", "d"];

    auto g2 = g.copy;
    g.keys.to!(string[]).should == g2.keys.to!(string[]);
    g2.del("c");
    g.keys.to!(string[]).should == ["a", "c"];
    g2.keys.to!(string[]).should == ["a"];
}


@("pyd.dict.merge.noovverride")
unittest {
    auto dict = PythonObject(["a": "1", "b": "2"]);
    dict.merge(PythonObject(["x": "1", "y": "2", "a": "3"]));
    dict.to!(string[string]).should == ["a": "3", "b": "2", "x": "1", "y": "2"];
}


@("pyd.dict.merge.override")
unittest {
    auto dict = PythonObject(["a": "1", "b": "2"]);
    dict.merge(PythonObject(["x": "1", "y": "2", "a": "3"]), false);
    dict.to!(string[string]).should == ["a": "1", "b": "2", "x": "1", "y": "2"];
}


@("pyd.dict.in")
unittest {
    auto dict = PythonObject(["a": "1", "b": "2"]);
    assert("a" in dict);
    assert("z" !in dict);
    assert(PythonObject("a") in dict);
    assert(PythonObject("z") !in dict);
}
