
INCLUDEDIR=/usr/local/include
LIBDIR=/usr/local/lib

all: libminiconf.so.1 libminiconf.a


libminiconf.so.1: miniconf.o miniconf.mod
	gcc -shared miniconf.o -o libminiconf.so.1

libminiconf.a: miniconf.o miniconf.mod
	ar rcs $@ miniconf.o

miniconf.o: miniconf.c
	gcc -O3 -fPIC  -c $<

miniconf.mod: miniconf_fort.f90
	gfortran -O3  -fPIC  -c $<

clean:
	rm -f *.o *.mod *.a *.so*

install: libminiconf.so.1 libminiconf.a
	install -dvZ $(INCLUDEDIR)
	install -pvZ miniconf.h $(INCLUDEDIR)
	install -pvZ miniconf.mod $(INCLUDEDIR)
	install -dvZ $(LIBDIR)
	install -pvZ libminiconf.so.1 $(LIBDIR)
	install -pvZ libminiconf.a $(LIBDIR)
	ln -sfr $(LIBDIR)/libminiconf.so.1 $(LIBDIR)/libminiconf.so
