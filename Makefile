
prefix=/usr/local
includedir=$(prefix)/include
exec_prefix=$(prefix)
libdir=$(exec_prefix)/lib
bindir=$(exec_prefix)/bin
release=2

CC := gcc
FC := gfortran

OFLAGS = -O2
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
FCFLAGS += -traceback
endif
ifeq ($(CC),icc)
CFLAGS += -traceback
endif

################################################


build: libminiconf.so.$(release) libminiconf.a


libminiconf.so.$(release): miniconf.o miniconf_fort.o
	$(FC) $(FCFLAGS) -shared $^ -o $@

libminiconf.a: miniconf.o miniconf_fort.o
	ar rcs $@ $^

miniconf.o: miniconf.c
	$(CC) $(CFLAGS) -fPIC  -c $<

miniconf_fort.o: miniconf_fort.f90
	$(FC) $(FCFLAGS) -fPIC -c $<

clean:
	rm -f *.o

distclean: clean
	rm -f *.mod *.a *.so.* *.dll

installdirs:
	install -dvZ $(DESTDIR)$(includedir)/miniconf
	install -dvZ $(DESTDIR)$(libdir)
	install -dvZ $(DESTDIR)$(libdir)/pkgconfig

install: installdirs all
	install -m 644 -pvZ miniconf.h $(DESTDIR)$(includedir)/miniconf
	install -m 644 -pvZ miniconf.mod $(DESTDIR)$(includedir)/miniconf
	install -pvZ libminiconf.so.$(release) $(DESTDIR)$(libdir)
	install -m 644 -pvZ libminiconf.a $(DESTDIR)$(libdir)
	install -m 644 -pvZ miniconf.pc $(DESTDIR)$(libdir)/pkgconfig
