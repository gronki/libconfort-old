VERSION=4.51

prefix=/usr/local
includedir=$(prefix)/include
exec_prefix=$(prefix)
libdir=$(exec_prefix)/lib
bindir=$(exec_prefix)/bin

CC := gcc
FC := gfortran

override ALL_CFLAGS = -I.
override ALL_FCFLAGS = -I.

# C compilers
ifeq ($(CC),gcc)
CFLAGS = -O2 -ftree-vectorize -finline-functions -funroll-loops -Wall
endif
ifeq ($(CC),icc)
CFLAGS = -O2 -unroll -Wall
endif

# Fortran compilers
ifeq ($(FC),gfortran)
override ALL_FCFLAGS += -std=f2008 -fimplicit-none
FCFLAGS = -O2 -ftree-vectorize -finline-functions -funroll-loops -Wall
endif
ifeq ($(FC),ifort)
override ALL_FCFLAGS += -implicitnone
FCFLAGS = -O2 -unroll -warn all
endif

override ALL_CFLAGS += $(CFLAGS)
override ALL_FCFLAGS += $(FCFLAGS)

all: libminiconf.so libminiconf.a miniconf.pc

libminiconf.so: miniconf.o miniconf_fort.o
	$(FC) $(ALL_FCFLAGS) -shared $^ -o $@

libminiconf.a: miniconf.o miniconf_fort.o
	ar rcs $@ $^

miniconf.o: miniconf.c
	$(CC) $(ALL_CFLAGS) -fPIC -c -o $@ $<

miniconf_fort.o: miniconf.F90
	$(FC) $(ALL_FCFLAGS) -fPIC -c -o $@ $<

clean:
	rm -f *.o
	$(MAKE) -C 'test' clean

distclean: clean
	rm -f *.mod *.a *.so *.dll miniconf.pc
	$(MAKE) -C 'test' distclean

installdirs:
	install -d $(DESTDIR)$(includedir)/miniconf
	install -d $(DESTDIR)$(libdir)/pkgconfig

install: installdirs all
	install -m 644 -p miniconf.h $(DESTDIR)$(includedir)/miniconf
	install -m 644 -p miniconf.mod $(DESTDIR)$(includedir)/miniconf
	install -p libminiconf.so $(DESTDIR)$(libdir)
	install -m 644 -p libminiconf.a $(DESTDIR)$(libdir)
	install -m 644 -p miniconf.pc $(DESTDIR)$(libdir)/pkgconfig

dist: distclean
	mkdir -p dist
	tar cf dist/libminiconf-$(VERSION).tar ../libminiconf \
			--exclude='.git' --exclude='.gitmodules' \
			--exclude='libminiconf/dist' \
			--exclude='libminiconf/rpmbuild'
	xz -f dist/libminiconf-$(VERSION).tar

rpm: dist libminiconf.spec
	mkdir -p rpmbuild/SOURCES rpmbuild/SPECS rpmbuild/RPMS \
				rpmbuild/SRPMS rpmbuild/BUILD
	cp dist/libminiconf-$(VERSION).tar.xz rpmbuild/SOURCES/
	cp libminiconf.spec rpmbuild/SPECS
	cd rpmbuild/SPECS && rpmbuild \
			--define "_topdir $(CURDIR)/rpmbuild" \
			--define "_version $(VERSION)" \
			-ba libminiconf.spec

miniconf.pc:
	echo "Name: miniconf" > miniconf.pc
	echo "Description: A minimalistic utility for reading configuration files. Easy to use Fortran 2008 bindings are included. Compatible with GCC and Intel compilers."  >> miniconf.pc
	echo "Version: $(VERSION)"  >> miniconf.pc
	echo "Libs: -L$(libdir) -lminiconf" >> miniconf.pc
	echo "Cflags: -I$(includedir)/miniconf" >> miniconf.pc

.PHONY:	miniconf.pc
