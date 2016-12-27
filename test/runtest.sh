#!/bin/bash

TESTNAME=$1

mkdir -p out

echo " ================================================"
echo "        test name: $TESTNAME"

if bin/$TESTNAME | tee out/$TESTNAME | grep FAILED
then
    echo " FAILED FAILED FAILED FAILED FAILED FAILED FAILED"
    rm -f $TESTNAME.pass
    ln -sfv out/$TESTNAME $TESTNAME.fail
else
    echo " PASSED PASSED PASSED PASSED PASSED PASSED PASSED"
    rm -f $TESTNAME.fail
    ln -sfv out/$TESTNAME $TESTNAME.pass
fi
