
prefix=/usr/local
includedir=$(prefix)/include/miniconf
exec_prefix=$(prefix)
libdir=$(exec_prefix)/lib
bindir=$(exec_prefix)/bin
release=1

CC=cc
FC=f95

all: libminiconf.so.$(release) libminiconf.a miniconf.mod


libminiconf.so.$(release): miniconf.o
	$(CC) -shared $^ -o $@

libminiconf.a: miniconf.o
	ar rcs $@ $^

miniconf.o: miniconf.c
	$(CC) -O2 -g -fPIC  -c $<

miniconf.mod: miniconf_fort.f90
	$(FC) -O2 -g  -fPIC  -c $<

clean:
	rm -f *.o

distclean: clean
	rm -f *.mod *.a *.so.* *.dll

installdirs:
	install -dvZ $(DESTDIR)$(includedir)
	install -dvZ $(DESTDIR)$(libdir)
	install -dvZ $(DESTDIR)$(libdir)/pkgconfig

$(DESTDIR)$(includedir) $(DESTDIR)$(libdir) $(DESTDIR)$(libdir)/pkgconfig:
	install -dvZ $@

install: installdirs libminiconf.so.$(release) libminiconf.a
	install -pvZ miniconf.h $(DESTDIR)$(includedir)
	install -pvZ miniconf.mod $(DESTDIR)$(includedir)
	install -pvZ libminiconf.so.$(release) $(DESTDIR)$(libdir)
	ln -srf $(DESTDIR)$(libdir)/libminiconf.so.$(release) $(DESTDIR)$(libdir)/libminiconf.so
	install -pvZ libminiconf.a $(DESTDIR)$(libdir)
	install -pvZ miniconf.pc $(DESTDIR)$(libdir)/pkgconfig
