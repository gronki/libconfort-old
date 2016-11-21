CC := gcc
FC := gfortran

override ALL_CFLAGS = -I..
override ALL_FCFLAGS = -I..

CFLAGS= -Og -g
FCFLAGS= -Og -g

# Fortran compilers
ifeq ($(FC),gfortran)
override ALL_FCFLAGS += -std=f2008 -fimplicit-none
endif
ifeq ($(FC),ifort)
override ALL_FCFLAGS += -implicitnone
endif

override ALL_CFLAGS += $(CFLAGS)
override ALL_FCFLAGS += $(FCFLAGS)

all: bin/test_f bin/test_c

bin/test_f: test_f.f90 ../libminiconf.a
	mkdir -p bin
	$(FC) $(ALL_FCFLAGS) -o $@ $^

bin/test_c: test_c.c ../libminiconf.a
	mkdir -p bin
	$(CC) $(ALL_CFLAGS) -o $@ $^

../libminiconf.a: ../miniconf.F90 ../miniconf.c ../miniconf.h
	$(MAKE) -C .. CFLAGS="$(CFLAGS)" FCFLAGS="$(FCFLAGS)"

clean:
	rm -f *.o *.mod

distclean: clean
	rm -rf bin
