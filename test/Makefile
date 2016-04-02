
TESTSC=$(addprefix bin/,$(basename $(wildcard test*.c)))
TESTSF=$(addprefix bin/,$(basename $(wildcard test*.f90)))

$(TESTSF): bin/%: %.f90 ../libminiconf.a
	mkdir -p bin
	f95 -g -o $@ -I.. $^

$(TESTSC): bin/%: %.c ../libminiconf.a
	mkdir -p bin
	cc -g -o $@ -I.. $^

../libminiconf.a: ../miniconf_fort.f90 ../miniconf.c ../miniconf.h
	cd ..; make libminiconf.a

clean:
	rm *.o *.mod

erase: clean
