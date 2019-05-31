# Makefile to drive the tests

DUB_CONFIGURATION ?= python37

.PHONY: test test_simple_pyd test_simple_pynih test_issues test_pyd test_numpy examples/simple/lib/pyd/libsimple.so examples/simple/lib/pynih/libsimple.so examples/issues/libissues.so examples/pyd/libpydtests.so examples/numpy/libnumpy.so

all: test
test: test_simple_pyd test_issues test_pyd test_numpy test_simple_pynih

test_simple_pyd: tests/test_simple.py examples/simple/lib/pyd/simple.so
	PYTHONPATH=$(PWD)/examples/simple/lib/pyd pytest -s -vv tests/test_simple.py

examples/simple/lib/pyd/simple.so: examples/simple/lib/pyd/libsimple.so
	@cp $^ $@

examples/simple/lib/pyd/libsimple.so: examples/simple/dub.sdl examples/simple/dub.selections.json
	@cd examples/simple && dub build -q -c $(DUB_CONFIGURATION)

example/simple/dub.selections.json:
	@cd examples/simple && dub upgrade -q

test_simple_pynih: tests/test_simple.py examples/simple/lib/pynih/simple.so
	PYTHONPATH=$(PWD)/examples/simple/lib/pynih pytest -s -vv tests/test_simple.py

examples/simple/lib/pynih/simple.so: examples/simple/lib/pynih/libsimple.so
	@cp $^ $@

examples/simple/lib/pynih/libsimple.so: examples/simple/dub.sdl examples/simple/dub.selections.json
	@cd examples/simple && dub build -q -c pynih

examples/simple/dub.selections.json:
	@cd examples/simple && dub upgrade -q


test_issues: tests/test_issues.py examples/issues/issues.so
	PYTHONPATH=$(PWD)/examples/issues pytest -s -vv tests/test_issues.py

examples/issues/issues.so: examples/issues/libissues.so
	@cp $^ $@

examples/issues/libissues.so: examples/issues/dub.sdl examples/issues/dub.selections.json
	@cd examples/issues && dub build -q -c $(DUB_CONFIGURATION)

example/issues/dub.selections.json:
	@cd examples/issues && dub upgrade -q

test_pyd: tests/test_pyd.py examples/pyd/pyd.so
	PYTHONPATH=$(PWD)/examples/pyd pytest -s -vv tests/test_pyd.py

examples/pyd/pyd.so: examples/pyd/libpydtests.so
	@cp $^ $@

examples/pyd/libpydtests.so: examples/pyd/dub.sdl examples/pyd/dub.selections.json
	@cd examples/pyd && dub build -q -c $(DUB_CONFIGURATION)

example/pyd/dub.selections.json:
	@cd examples/pyd && dub upgrade -q

test_numpy: tests/test_numpy.py examples/numpy/numpytests.so
	PYTHONPATH=$(PWD)/examples/numpy pytest -s -vv tests/test_numpy.py

examples/numpy/numpytests.so: examples/numpy/libnumpy.so
	@cp $^ $@

examples/numpy/libnumpy.so: examples/numpy/dub.sdl examples/numpy/dub.selections.json
	@cd examples/numpy && dub build -q -c $(DUB_CONFIGURATION)

example/numpy/dub.selections.json:
	@cd examples/numpy && dub upgrade -q
