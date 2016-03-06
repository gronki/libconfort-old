
INCLUDEDIR=/usr/local/include
LIBDIR=/usr/local/lib

all: libminiconf.so.1 libminiconf.a


libminiconf.so.1: miniconf.o miniconf_fort.o
	gcc -shared $^ -o libminiconf.so.1

libminiconf.a: miniconf.o miniconf_fort.o
	ar rcs $@ $^

miniconf.o: miniconf.c
	gcc -O3 -fPIC  -c $<

miniconf_fort.o: miniconf_fort.f90
	gfortran -O3  -fPIC  -c $<

clean:
	rm -f *.o *.mod

install: libminiconf.so.1 libminiconf.a
	install -dvZ $(INCLUDEDIR)
	install -pvZ miniconf.h $(INCLUDEDIR)
	install -pvZ miniconf_fort.mod $(INCLUDEDIR)
	install -dvZ $(LIBDIR)
	install -pvZ libminiconf.so.1 $(LIBDIR)
	install -pvZ libminiconf.a $(LIBDIR)
	ln -sfr $(LIBDIR)/libminiconf.so.1 $(LIBDIR)/libminiconf.so
