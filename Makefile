
prefix=/usr/local
includedir=$(prefix)/include
exec_prefix=$(prefix)
libdir=$(exec_prefix)/lib
bindir=$(exec_prefix)/bin
release=2

CC := gcc
FC := gfortran

CFLAGS = -O2 -g
FCFLAGS = -O2 -g

override ALL_CFLAGS = $(INCL)
override ALL_FCFLAGS = $(INCL) -cpp

ifeq ($(FC),gfortran)
override ALL_FCFLAGS += -Wall -std=f2008 -fimplicit-none
FCFLAGS += -fbacktrace
endif
ifeq ($(CC),gcc)
override ALL_CFLAGS += -Wall
endif
ifeq ($(FC),ifort)
override ALL_FCFLAGS += -warn all -implicitnone
FCFLAGS += -traceback -xHost
endif
ifeq ($(CC),icc)
CFLAGS += -traceback -xHost
endif

override ALL_CFLAGS += $(CFLAGS)
override ALL_FCFLAGS += $(FCFLAGS)


all: libminiconf.so.$(release) libminiconf.a


libminiconf.so.$(release): miniconf.o miniconf_fort.o
	$(FC) $(ALL_FCFLAGS) -shared $^ -o $@

libminiconf.a: miniconf.o miniconf_fort.o
	ar rcs $@ $^

miniconf.o: miniconf.c
	$(CC) $(ALL_CFLAGS) -fPIC  -c $<

miniconf_fort.o: miniconf_fort.f90
	$(FC) $(ALL_FCFLAGS) -fPIC -c $<

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
