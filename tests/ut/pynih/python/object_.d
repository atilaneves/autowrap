module pynih.python.object_;

import unit_threaded;
import python.object_;
import python.conv;


@("lt")
unittest {
    const three = PythonObject(3);
    const five = PythonObject(5);

    (three < five).should == true;
    (five < three).should == false;

    (three < PythonObject("foo")).shouldThrowWithMessage("Error comparing Python objects");
}
