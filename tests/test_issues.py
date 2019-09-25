import os

is_pyd = os.environ.get('PYD')
is_pynih = os.environ.get('PYNIH')


def test_issue_39():
    from issues import StaticMemberFunctions
    s = StaticMemberFunctions()
    assert s.add(1, 2) == 3
    assert s.add(2, 3) == 5
    assert StaticMemberFunctions.add(3, 4) == 7


def test_issue_40_c():
    from issues import c_add
    assert c_add(2, 3) == 5


def test_issue_40_cpp():
    from issues import cpp_add
    assert cpp_add(2, 3) == 5


def test_issue_42_takes_in():
    from issues import IssueString, takes_in_string
    import pytest

    if is_pyd:
        # pyd can't convert to const
        with pytest.raises(RuntimeError):
            takes_in_string(IssueString())


def test_issue_42_takes_scope():
    from issues import IssueString, takes_scope_string
    takes_scope_string(IssueString())


def test_issue_42_takes_ref():
    from issues import IssueString, takes_ref_string
    takes_ref_string(IssueString())


def test_issue_42_takes_ref_const():
    from issues import IssueString, takes_ref_const_string
    import pytest

    if is_pyd:
        # pyd can't convert to const
        with pytest.raises(RuntimeError):
            takes_ref_const_string(IssueString())


def test_issue_42_returns_ref_const():
    from issues import returns_ref_const_string
    import pytest

    if is_pyd:
        # pyd can't convert from const(issues.IssueString*)
        with pytest.raises(RuntimeError):
            s = returns_ref_const_string()
            assert s.value == 'quux'


def test_issue_42_returns_const():
    from issues import returns_const_string
    import pytest

    if is_pyd:
        # pyd can't convert from const(issues.IssueString*)
        with pytest.raises(RuntimeError):
            returns_const_string()
    else:
        assert returns_const_string().value == 'toto'


def test_issue_44():
    import pytest

    if is_pynih:
        with pytest.raises(ImportError):
            from issues import string_ptr
    else:
        from issues import string_ptr
        assert string_ptr('foo').value == 'foo'
        assert string_ptr('bar').value == 'bar'


def test_issue_47():
    from issues import uncopiable_ptr
    import pytest

    if is_pyd:
        with pytest.raises(RuntimeError):
            assert uncopiable_ptr(33.3).x == 33.3
            assert uncopiable_ptr(44.4).x == 44.4
    else:
        assert uncopiable_ptr(33.3).x == 33.3
        assert uncopiable_ptr(44.4).x == 44.4


def test_issue_50():
    from issues import String, takes_string
    takes_string(String())


def test_issue_54():
    from issues import Issue54
    import pytest

    c = Issue54(10)
    if is_pyd:
        # FIXME
        with pytest.raises(AttributeError):
            assert c.i == 10
    else:
        assert c.i == 10


def test_issue_133():
    from issues import issue133
    import pytest

    res = issue133()
    assert res.times4(1) == 4
    assert res.times4(2) == 8
    assert res.times4(3) == 12

    # oops should not be accessible since it's private
    with pytest.raises(AttributeError):
        o = res.oops
        assert o == 42
