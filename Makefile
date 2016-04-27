
prefix=/usr/local
includedir=$(prefix)/include
exec_prefix=$(prefix)
libdir=$(exec_prefix)/lib
bindir=$(exec_prefix)/bin
release=1

CFLAGS=-O2 -g -Wall
FFLAGS=-O2 -g -Wall

all: libminiconf.so.$(release) libminiconf.a miniconf.mod


libminiconf.so.$(release): miniconf.o
	cc -shared $^ -o $@

libminiconf.a: miniconf.o
	ar rcs $@ $^

miniconf.o: miniconf.c
	cc $(CFLAGS) -fPIC  -c $<

miniconf.mod: miniconf_fort.f90
	f95 $(FFLAGS) -fPIC -c $<

clean:
	rm -f *.o

distclean: clean
	rm -f *.mod *.a *.so.* *.dll

installdirs:
	install -dvZ $(DESTDIR)$(includedir)
	install -dvZ $(DESTDIR)$(libdir)
	install -dvZ $(DESTDIR)$(libdir)/pkgconfig

install: installdirs all
	install -m 644 -pvZ miniconf.h $(DESTDIR)$(includedir)
	install -m 644 -pvZ miniconf.mod $(DESTDIR)$(includedir)
	install -pvZ libminiconf.so.$(release) $(DESTDIR)$(libdir)
	install -m 644 -pvZ libminiconf.a $(DESTDIR)$(libdir)
	install -m 644 -pvZ miniconf.pc $(DESTDIR)$(libdir)/pkgconfig
