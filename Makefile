VERSION				= 170102

prefix 	 	 	= /usr/local
exec_prefix	 	= $(prefix)
bindir		 	= $(exec_prefix)/bin
datadir	 	 	= $(prefix)/share
includedir 	 	= $(prefix)/include
libdir 	 	 	= $(exec_prefix)/lib
fmoddir			= $(libdir)/gfortran/modules
docdir 	 	 	= $(datadir)/doc

INCLUDE	 	 	= -I.

CC  	 	 	:= cc  -g -Wall
FC 		 	 	:= f95 -g -Wall
FPP				:= cpp -traditional -nostdinc

CFLAGS 	 	 	?= -O3 -march=native
FFLAGS	 	 	?= -O3 -march=native -fbacktrace

COMPILE.C 	 	= $(CC) $(INCLUDE) $(CPPFLAGS) $(CFLAGS) -c
COMPILE.F    	= $(FC) $(INCLUDE) $(CPPFLAGS) $(FFLAGS) -c
COMPILE.f    	= $(FC) $(INCLUDE) -fpreprocessed $(FFLAGS) -c
LINK.C 	 	 	= $(CC) $(INCLUDE) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS)
LINK.F    	 	= $(FC) $(INCLUDE) $(CPPFLAGS) $(FFLAGS) $(LDFLAGS)
LINK.f    	 	= $(FC) $(INCLUDE) -fpreprocessed $(FFLAGS) $(LDFLAGS)
LINK       		= $(LD) --build-id $(LDFLAGS)
PREPROCESS.F	= $(FPP) $(INCLUDE) $(CPPFLAGS)

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
%.o: %.f90
	$(COMPILE.f) -fPIC $< -o $@
%.f90: %.F90
	$(PREPROCESS.F) $< -o $@
%.o: %.mod

.INTERMEDIATE: $(OBJECTS)

installdirs:
	install -d $(DESTDIR)$(includedir)
	install -d $(DESTDIR)$(fmoddir)
	install -d $(DESTDIR)$(libdir)/pkgconfig

install: installdirs all
	install -m 644 -p miniconf.h $(DESTDIR)$(includedir)
	install -m 644 -p miniconf.mod $(DESTDIR)$(fmoddir)
	install -p libminiconf.so $(DESTDIR)$(libdir)
	install -m 644 -p libminiconf.a $(DESTDIR)$(libdir)
	install -m 644 -p miniconf.pc $(DESTDIR)$(libdir)/pkgconfig

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
