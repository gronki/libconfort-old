
INCLUDEDIR=/usr/local/include
LIBDIR=/usr/local/lib
LIBNAME=libminiconf.so
CC=gcc
F90=gfortran

all: $(LIBNAME).1 libminiconf.a


$(LIBNAME).1: miniconf.o miniconf.mod
	$(CC) -shared miniconf.o -o $(LIBNAME).1

libminiconf.a: miniconf.o miniconf.mod
	ar rcs $@ miniconf.o

miniconf.o: miniconf.c
	$(CC) -O3 -fPIC  -c $<

miniconf.mod: miniconf_fort.f90
	$(F90) -O3  -fPIC  -c $<

clean:
	rm -f *.o *.mod *.a *.so* *.dll*

install: $(LIBNAME).1 libminiconf.a
	install -dvZ $(INCLUDEDIR)
	install -pvZ miniconf.h $(INCLUDEDIR)
	install -pvZ miniconf.mod $(INCLUDEDIR)
	install -pvZ miniconf_fort.f90 $(INCLUDEDIR)
	install -dvZ $(LIBDIR)
	install -pvZ $(LIBNAME).1 $(LIBDIR)
	install -pvZ libminiconf.a $(LIBDIR)
	ln -sfr $(LIBDIR)/$(LIBNAME).1 $(LIBDIR)/$(LIBNAME)
