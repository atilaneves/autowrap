import autowrap;

enum str = wrapDlang!(
    LibraryName("std_zip"),
    Modules(
        Yes.alwaysExport,
        "std.zip",
        )
    );

// pragma(msg, str);
mixin(str);

version(Have_autowrap_pynih):

import python.raw;


pragma(mangle, "_D6python4type__T13PythonCompareTS3std8typecons__T10RebindableTyCQBf8datetime8timezone8TimeZoneZQBuZ7_py_cmpUNbPSQEh3raw7_objectQriZQv")
private PyObject* hack0(PyObject*, PyObject*, int) { assert(0); }
