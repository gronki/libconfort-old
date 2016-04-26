
prefix=/usr/local
includedir=$(prefix)/include/miniconf
exec_prefix=$(prefix)
libdir=$(exec_prefix)/lib
bindir=$(exec_prefix)/bin

CC=cc
FC=f95

all: libminiconf.so libminiconf.a


libminiconf.so: miniconf.o miniconf.mod
	$(CC) -shared miniconf.o -o libminiconf.so

libminiconf.a: miniconf.o miniconf.mod
	ar rcs $@ miniconf.o

miniconf.o: miniconf.c
	$(CC) -O2 -g -fPIC  -c $<

miniconf.mod: miniconf_fort.f90
	$(FC) -O2 -g  -fPIC  -c $<

clean:
	rm -f *.o

distclean: clean
	rm -f *.mod *.a *.so.* *.dll

installdirs: $(DESTDIR)$(includedir) $(DESTDIR)$(libdir) $(DESTDIR)$(libdir)/pkgconfig
	install -dvZ $(DESTDIR)$(includedir)
	install -dvZ $(DESTDIR)$(libdir)
	install -dvZ $(DESTDIR)$(libdir)/pkgconfig

install: installdirs libminiconf.so libminiconf.a
	install -pvZ miniconf.h $(DESTDIR)$(includedir)
	install -pvZ miniconf.mod $(DESTDIR)$(includedir)
	install -pvZ libminiconf.so $(DESTDIR)$(libdir)
	install -pvZ libminiconf.a $(DESTDIR)$(libdir)
	install -pvZ miniconf.pc $(DESTDIR)$(libdir)/pkgconfig
