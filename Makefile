# Makefile to drive the tests

export PYTHON_LIB_DIR ?= /usr/lib
DUB_CONFIGURATION ?= python37

.PHONY: clean test test_python test_cs test_simple_pyd test_simple_pynih test_simple_cs test_pyd_pyd test_issues_pyd test_issues_pynih test_numpy examples/simple/lib/pyd/libsimple.so examples/simple/lib/pynih/libsimple.so examples/issues/lib/pyd/libissues.so examples/issues/lib/pynih/libissues.so examples/numpy/libnumpy.so examples/pyd/lib/pyd/libpydtests.so examples/pyd/lib/pynih/libpydtests.so

all: test
test: test_python test_cs
test_python: test_simple_pyd test_simple_pynih test_pyd_pyd test_pyd_pynih test_issues test_numpy
test_issues: test_issues_pyd test_issues_pynih
test_cs: test_simple_cs

clean:
	@cd csharp && dub clean -q
	@cd excel && dub clean -q
	@cd pynih && dub clean -q
	@cd python && dub clean -q
	@cd reflection && dub clean -q
	@cd examples/issues && dub clean -q
	@cd examples/numpy && dub clean -q
	@cd examples/pyd && dub clean -q
	@cd examples/simple && dub clean -q
	@rm -f examples/*/*.so examples/pyd/lib/pyd/*.so examples/simple/lib/*/*.so examples/simple/simple examples/simple/Simple.cs
	@rm -rf tests/*/bin tests/*/obj

test_simple_pyd: tests/test_simple.py examples/simple/lib/pyd/simple.so
	PYTHONPATH=$(PWD)/examples/simple/lib/pyd pytest -s -vv $<

examples/simple/lib/pyd/simple.so: examples/simple/lib/pyd/libsimple.so
	@cp $^ $@

examples/simple/lib/pyd/libsimple.so:
	@cd examples/simple && dub build -q -c $(DUB_CONFIGURATION)

example/simple/dub.selections.json:
	@cd examples/simple && dub upgrade -q

test_simple_pynih_only: tests/test_simple_pynih_only.py examples/simple/lib/pynih/simple.so pynih/source/python/raw.d
	PYTHONPATH=$(PWD)/examples/simple/lib/pynih pytest -s -vv $<

test_simple_pynih: tests/test_simple.py examples/simple/lib/pynih/simple.so pynih/source/python/raw.d
	PYTHONPATH=$(PWD)/examples/simple/lib/pynih pytest -s -vv $<

test_simple_cs: examples/simple/lib/csharp/libsimple.x64.so examples/simple/Simple.cs
	@cd tests/test_simple_cs && \
	dotnet build test_simple_cs.csproj && \
	dotnet test test_simple_cs.csproj

examples/simple/lib/csharp/libsimple.x64.so: examples/simple/lib/csharp/libsimple.so
	@cp $^ $@

examples/simple/lib/csharp/libsimple.so: examples/simple/dub.sdl examples/simple/dub.selections.json
	@cd examples/simple && dub build -q -c csharp

examples/simple/Simple.cs: examples/simple/lib/csharp/libsimple.so
	@cd examples/simple && dub run -q -c emitCSharp

pynih/source/python/raw.d: pynih/Makefile pynih/source/python/raw.dpp
	make -C pynih source/python/raw.d

examples/simple/lib/pynih/simple.so: examples/simple/lib/pynih/libsimple.so
	@cp $^ $@

examples/simple/lib/pynih/libsimple.so:
	@cd examples/simple && dub build -q -c pynih

test_issues_pyd: tests/test_issues.py examples/issues/lib/pyd/issues.so
	PYTHONPATH=$(PWD)/examples/issues/lib/pyd PYD=1 pytest -s -vv $<

examples/issues/lib/pyd/issues.so: examples/issues/lib/pyd/libissues.so
	@cp $^ $@

examples/issues/lib/pyd/libissues.so:
	@cd examples/issues && dub build -q -c $(DUB_CONFIGURATION)

test_issues_pynih: tests/test_issues.py examples/issues/lib/pynih/issues.so
	PYTHONPATH=$(PWD)/examples/issues/lib/pynih PYNIH=1 pytest -s -vv $<

examples/issues/lib/pynih/issues.so: examples/issues/lib/pynih/libissues.so
	@cp $^ $@

examples/issues/lib/pynih/libissues.so:
	@cd examples/issues && dub build -q -c pynih


examples/issues/dub.selections.json:
	@cd examples/issues && dub upgrade -q

test_pyd_pyd: tests/test_pyd.py examples/pyd/lib/pyd/pyd.so
	PYTHONPATH=$(PWD)/examples/pyd/lib/pyd PYD=1 pytest -s -vv $<

examples/pyd/lib/pyd/pyd.so: examples/pyd/lib/pyd/libpydtests.so
	@cp $^ $@

examples/pyd/lib/pyd/libpydtests.so:
	@cd examples/pyd && dub build -q -c $(DUB_CONFIGURATION)

test_pyd_pynih: tests/test_pyd.py examples/pyd/lib/pynih/pyd.so
	PYTHONPATH=$(PWD)/examples/pyd/lib/pynih PYNIH=1 pytest -s -vv $<

examples/pyd/lib/pynih/pyd.so: examples/pyd/lib/pynih/libpydtests.so
	@cp $^ $@

examples/pyd/lib/pynih/libpydtests.so:
	@cd examples/pyd && dub build -q -c pynih

test_numpy: tests/test_numpy.py examples/numpy/numpytests.so
	PYTHONPATH=$(PWD)/examples/numpy pytest -s -vv $<

examples/numpy/numpytests.so: examples/numpy/libnumpy.so
	@cp $^ $@

examples/numpy/libnumpy.so:
	@cd examples/numpy && dub build -q -c $(DUB_CONFIGURATION)

examples/numpy/dub.selections.json:
	@cd examples/numpy && dub upgrade -q
