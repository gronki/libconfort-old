VERSION			= 170102

prefix 	 	 	= /usr/local
exec_prefix	 	= $(prefix)
bindir		 	= $(exec_prefix)/bin
datadir	 	 	= $(prefix)/share
includedir 	 	= $(prefix)/include
libdir 	 	 	= $(exec_prefix)/lib
fmoddir			= $(libdir)/finclude
docdir 	 	 	= $(datadir)/doc
licensedir 	 	= $(datadir)/licenses

INCLUDE	 	 	= -I.

CC  	 	 	:= cc
CFLAGS 	 	 	?= -g -Wall -O3 -march=native
FC 		 	 	:= f95
FFLAGS	 	 	?= -g -Wall -O3 -march=native -fbacktrace -std=f2008

COMPILE.C    	= $(CC) $(INCLUDE) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
COMPILE.F    	= $(FC) $(INCLUDE) $(FFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
LINK.C    	 	= $(CC) $(INCLUDE) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)
LINK.F    	 	= $(FC) $(INCLUDE) $(FFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)

OBJECTS = c_routines.o f_routines.o core.o miniconf_procedures.o miniconf.o

override CPPFLAGS += "-DVERSION=\"$(VERSION)\""

all: libminiconf.so libminiconf.a miniconf.pc

libminiconf.so: $(OBJECTS)
	$(LINK.F) $(LDLIBS) -shared $^ -o $@

libminiconf.a: $(OBJECTS)
	ar rcs $@ $^

miniconf_procedures.o: miniconf.o

%.o: %.c
	$(COMPILE.C) -fPIC $< -o $@
%.o: %.F90
	$(COMPILE.F) -fPIC $< -o $@
%.o: %.mod

.INTERMEDIATE: $(OBJECTS)

installdirs:
	install -d $(DESTDIR)$(includedir)
	install -d $(DESTDIR)$(fmoddir)
	install -d $(DESTDIR)$(libdir)/pkgconfig

install: installdirs all
	install -m 644 miniconf.h $(DESTDIR)$(includedir)
	install -m 644 miniconf.mod $(DESTDIR)$(fmoddir)
	install -p libminiconf.so $(DESTDIR)$(libdir)
	install -m 644 libminiconf.a $(DESTDIR)$(libdir)
	install -m 644 miniconf.pc $(DESTDIR)$(libdir)/pkgconfig/
	install -m 644 LICENSE $(DESTDIR)$(licensedir)/miniconf/

docs: README.pdf

README.pdf: README.md
	pandoc -s -f markdown_github -t latex $< -o $@

miniconf.pc:
	echo "Name: miniconf" > miniconf.pc
	echo "Description: A minimalistic utility for reading configuration files. Easy to use Fortran 2008 bindings are included. Compatible with GCC and Intel compilers."  >> miniconf.pc
	echo "Version: $(VERSION)"  >> miniconf.pc
	echo "Libs: -L$(libdir) -lminiconf" >> miniconf.pc
	echo "Cflags: -I$(includedir) -I$(fmoddir)" >> miniconf.pc

clean:
	rm -f *.o *.mod *.smod *.f90 *.a *.so *.dll miniconf.pc
	$(MAKE) -C 'test' clean

distclean: clean
	rm -f *.tar.xz

dist: distclean
	tar cvf libminiconf-$(VERSION).tar -C .. \
			--exclude='libminiconf/.git' \
			--exclude='libminiconf/*.tar' \
			--transform="s/^libminiconf/libminiconf-$(VERSION)/" \
			libminiconf
	xz -f libminiconf-$(VERSION).tar
