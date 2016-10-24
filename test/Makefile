
CC := gcc
FC := gfortran

OFLAGS = -O0
MFLAGS =
CFLAGS = $(MFLAGS) $(OFLAGS)
FCFLAGS = $(MFLAGS) $(OFLAGS)
CFLAGS += -g
CFLAGS += -std=c99
FCFLAGS += -g
FCFLAGS += -cpp

ifeq ($(FC),gfortran)
FCFLAGS += -Wall -std=f2008 -fimplicit-none
FCFLAGS += -fbacktrace
endif
ifeq ($(CC),gcc)
CFLAGS += -Wall
endif
ifeq ($(FC),ifort)
FCFLAGS += -traceback -check -fpe0
endif
ifeq ($(CC),icc)
CFLAGS += -traceback
endif

all: bin/test_f bin/test_c

bin/test_f: test_f.f90 ../libminiconf.a
	mkdir -p bin
	$(FC) $(FCFLAGS) -o $@ -I.. $^

bin/test_c: test_c.c ../libminiconf.a
	mkdir -p bin
	$(CC) $(CFLAGS) -o $@ -I.. $^

../libminiconf.a: ../miniconf_fort.f90 ../miniconf.c ../miniconf.h
	$(MAKE) -C .. CFLAGS="$(CFLAGS)" FCFLAGS="$(FCFLAG)" OFLAGS="$(OFLAGS)" MFLAGS="$(MFLAGS)"

clean:
	rm -f *.o *.mod
	$(MAKE) -C .. clean

distclean: clean
	rm -rf bin
	$(MAKE) -C .. distclean
