#!/bin/bash

TESTNAME=$1

mkdir -p out

colorize() {
    sed "s/\(PASSED\)/$(tput setaf 2; tput bold)\1$(tput sgr0)/g; s/\(FAILED\)/$(tput setaf 1; tput bold)\1$(tput sgr0)/g"
}

if bin/$TESTNAME | tee out/$TESTNAME | grep FAILED > /dev/null
then
    cat out/$TESTNAME | colorize
    rm -f $TESTNAME.pass
    ln -sfv out/$TESTNAME $TESTNAME.fail
else
    cat out/$TESTNAME | colorize
    rm -f $TESTNAME.fail
    ln -sfv out/$TESTNAME $TESTNAME.pass
fi
