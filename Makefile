VERSION			= 170112

prefix 	 	 	= /usr/local
exec_prefix	 	= $(prefix)
bindir		 	= $(exec_prefix)/bin
datadir	 	 	= $(prefix)/share
includedir 	 	= $(prefix)/include
libdir 	 	 	= $(exec_prefix)/lib
fmoddir			= $(libdir)/finclude
docdir 	 	 	= $(datadir)/doc
licensedir 	 	= $(datadir)/licenses

INCLUDE	 	 	= -I. -Isrc

CC  	 	 	:= cc
CFLAGS 	 	 	?= -g -Wall -O3 -march=native
FC 		 	 	:= f95
FFLAGS	 	 	?= -g -Wall -O3 -march=native -fbacktrace -std=f2008

COMPILE.C    	= $(CC) $(INCLUDE) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
COMPILE.F    	= $(FC) $(INCLUDE) $(FFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
LINK.C    	 	= $(CC) $(INCLUDE) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)
LINK.F    	 	= $(FC) $(INCLUDE) $(FFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)

OBJECTS = c_routines.o f_routines.o core.o procedural.o confort.o

VPATH = src

all: libconfort.so libconfort.a confort.pc

libconfort.so: $(OBJECTS)
	$(LINK.F) $(LDLIBS) -shared $^ -o $@

libconfort.a: $(OBJECTS)
	ar rcs $@ $^

procedural.o: confort.o

%.o: %.c
	$(COMPILE.C) -fPIC $< -o $@
%.o: %.F90
	$(COMPILE.F) -fPIC $< -o $@
%.o: %.mod

.INTERMEDIATE: $(OBJECTS)

installdirs:
	install -d $(DESTDIR)$(includedir)
	install -d $(DESTDIR)$(fmoddir)
	install -d $(DESTDIR)$(licensedir)/confort
	install -d $(DESTDIR)$(docdir)/confort
	install -d $(DESTDIR)$(libdir)/pkgconfig

install: installdirs all
	install -m 644 src/confort.h $(DESTDIR)$(includedir)
	install -m 644 confort.mod $(DESTDIR)$(fmoddir)
	install -p libconfort.so $(DESTDIR)$(libdir)
	install -m 644 libconfort.a $(DESTDIR)$(libdir)
	install -m 644 confort.pc $(DESTDIR)$(libdir)/pkgconfig/
	install -m 644 LICENSE $(DESTDIR)$(licensedir)/confort/
	cp -rv doc/* $(DESTDIR)$(docdir)/confort/

docs: doc/README.pdf

doc/README.pdf: README.md
	pandoc -s -f markdown_github -t latex $< -o $@

confort.pc:
	echo "Name: confort" > confort.pc
	echo "Description: A minimalistic utility for reading configuration files. Easy to use Fortran 2008 bindings are included. Compatible with GCC and Intel compilers."  >> confort.pc
	echo "Version: $(VERSION)"  >> confort.pc
	echo "Libs: -L$(libdir) -lconfort" >> confort.pc
	echo "Cflags: -I$(includedir) -I$(fmoddir)" >> confort.pc

clean:
	rm -f *.o *.mod *.smod *.f90 *.a *.so *.dll confort.pc
	$(MAKE) -C 'test' clean

dist: clean
	tar cvf libconfort-$(VERSION).tar -C .. \
			--exclude='libconfort/.git' \
			--exclude='libconfort/*.tar' \
			--exclude='libconfort/*.tar.gz' \
			--transform="s/^libconfort/libconfort-$(VERSION)/" \
			libconfort
	gzip -f libconfort-$(VERSION).tar
