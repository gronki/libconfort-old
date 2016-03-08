
PREFIX=/usr/local
INCLUDEDIR=$(PREFIX)/include/miniconf
LIBDIR=$(PREFIX)/lib
LIBNAME=libminiconf.so
CC=gcc
F90=gfortran

all: $(LIBNAME) libminiconf.a


$(LIBNAME): miniconf.o miniconf.mod
	$(CC) -shared miniconf.o -o $(LIBNAME)

libminiconf.a: miniconf.o miniconf.mod
	ar rcs $@ miniconf.o

miniconf.o: miniconf.c
	$(CC) -O3 -fPIC  -c $<

miniconf.mod: miniconf_fort.f90
	$(F90) -O3  -fPIC  -c $<

clean:
	rm -f *.o *.mod *.a *.so* *.dll*


install: $(LIBNAME) libminiconf.a
	install -dvZ $(INCLUDEDIR)
	install -pvZ miniconf.h $(INCLUDEDIR)
	install -pvZ miniconf.mod $(INCLUDEDIR)
	install -pvZ miniconf_fort.f90 $(INCLUDEDIR)

	install -dvZ $(LIBDIR)
	install -pvZ $(LIBNAME) $(LIBDIR)
	install -pvZ libminiconf.a $(LIBDIR)

	install -dvZ $(PREFIX)/lib/pkgconfig/
	install -pvZ miniconf.pc $(PREFIX)/lib/pkgconfig/
