/**
   D code for contract tests verifying creation of PythonClass instances.
 */
module contract.pyclass;


import python.c;
import autowrap.pynih.python.cooked;
import autowrap.pynih.python.type;


extern(C):


package PyObject* pyclass_int_double_struct(PyObject* self, PyObject *args) {

    if(PyTuple_Size(args) != 2) {
        PyErr_SetString(PyExc_TypeError, &"Wrong number of arguments"[0]);
        return null;
    }

    auto arg0 = PyTuple_GetItem(args, 0);
    if(arg0 is null) {
        PyErr_SetString(PyExc_TypeError, &"Could not get first argument"[0]);
        return null;
    }

    auto arg1 = PyTuple_GetItem(args, 1);
    if(arg1 is null) {
        PyErr_SetString(PyExc_TypeError, &"Could not get first argument"[0]);
        return null;
    }

    static struct SimpleStruct {
        int i;
        double d;
    }

    auto darg0 = cast(int) PyLong_AsLong(arg0);
    auto darg1 = PyFloat_AsDouble(arg1);
    auto struct_ = SimpleStruct(darg0, darg1);

    return pythonClass(struct_);
}


package PyObject* pyclass_string_list_struct(PyObject* self, PyObject *args) {
    if(PyTuple_Size(args) != 1) {
        PyErr_SetString(PyExc_TypeError, &"Wrong number of arguments"[0]);
        return null;
    }

    auto arg = PyTuple_GetItem(args, 0);
    if(arg is null) {
        PyErr_SetString(PyExc_TypeError, &"Could not get first argument"[0]);
        return null;
    }

    if(!PyList_Check(arg)) {
        PyErr_SetString(PyExc_TypeError, &"Argument not a list"[0]);
        return null;
    }

    char[][] strings;

    foreach(i; 0 .. PyList_Size(arg)) {

        auto item = PyList_GetItem(arg, i);
        assert(PyUnicode_Check(item));

        if(!PyUnicode_Check(item)) {
            PyErr_SetString(PyExc_TypeError, &"All arguments must be strings"[0]);
            return null;
        }

        auto unicode = PyUnicode_AsUTF8String(item);
        if(!unicode) {
            PyErr_SetString(PyExc_TypeError, &"Could not decode UTF8"[0]);
            return null;
        }

        const length = PyUnicode_GetLength(item);
        auto ptr = PyBytes_AsString(unicode);
        auto str = ptr is null ? null : ptr[0 .. length];

        strings ~= str;
    }

    static struct StringsStruct {
        string[] strings;
    }

    return pythonClass(StringsStruct(cast(string[]) strings));
}


package PyObject* pyclass_twice_struct(PyObject* self, PyObject *args) {
    if(PyTuple_Size(args) != 1) {
        PyErr_SetString(PyExc_TypeError, &"Wrong number of arguments"[0]);
        return null;
    }

    auto arg = PyTuple_GetItem(args, 0);
    if(arg is null) {
        PyErr_SetString(PyExc_TypeError, &"Could not get first argument"[0]);
        return null;
    }

    const darg = cast(int) PyLong_AsLong(arg);

    static struct TwiceStruct {
        int i;
        int twice() @safe @nogc pure nothrow const {
            return i * 2;
        }
    }

    return pythonClass(TwiceStruct(darg));
}


package PyObject* pyclass_thrice_struct(PyObject* self, PyObject *args) {
    if(PyTuple_Size(args) != 1) {
        PyErr_SetString(PyExc_TypeError, &"Wrong number of arguments"[0]);
        return null;
    }

    auto arg = PyTuple_GetItem(args, 0);
    if(arg is null) {
        PyErr_SetString(PyExc_TypeError, &"Could not get first argument"[0]);
        return null;
    }

    const darg = PyFloat_AsDouble(arg);

    static struct ThriceStruct {
        double d;

        double thrice() @safe @nogc pure nothrow const {
            return d * 3;
        }

        double quadruple() @safe @nogc pure nothrow const {
            return d * 4;
        }
    }

    return pythonClass(ThriceStruct(darg));
}


package PyObject* pyclass_void_struct(PyObject* self, PyObject *args) {

    static struct VoidStruct {
        int i = 42;

        void setValue(int i) {
            this.i = i;
        }
    }

    return pythonClass(VoidStruct());
}
