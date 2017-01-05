VERSION				= 170102

prefix 	 	 		= /usr/local
exec_prefix	 		= $(prefix)
bindir		 		= $(exec_prefix)/bin
datadir	 	 		= $(prefix)/share
includedir 	 		= $(prefix)/include
libdir 	 	 		= $(exec_prefix)/lib
fmoddir				= $(libdir)/gfortran/modules
docdir 	 	 		= $(datadir)/doc

OBJECTS	 	 		= core.o c_routines.o f_routines.o miniconf_procedures.o miniconf.o

INCLUDE	 	 		= -I.

CC  	 	 		?= cc
FC 		 	 		:= $(if $(filter $(FC),f77),f95,$(FC))
FPP					:= cpp -traditional -nostdinc

FFLAGS_f95			:= -g -Wall -std=f2008 -fimplicit-none -fbacktrace
FFLAGS_gfortran		:= $(FFLAGS_f95)
FFLAGS_ifort		:= -g -warn all -std08 -implicitnone
FFLAGS_pgf95		:= -gopt -Minform=warn -Mdclchk

CFLAGS 	 	 		?= -Wall -O2
FFLAGS	 	 		?= -O2
override FFLAGS		+= $(FFLAGS_$(FC))

COMPILE.C 	 		= $(CC) $(INCLUDE) $(CPPFLAGS) $(CFLAGS) -c
COMPILE.F    		= $(FC) $(INCLUDE) $(CPPFLAGS) $(FFLAGS) -c
COMPILE.f    		= $(FC) $(INCLUDE) $(FFLAGS) -c
LINK.C 	 	 		= $(CC) $(INCLUDE) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS)
LINK.F    	 		= $(FC) $(INCLUDE) $(CPPFLAGS) $(FFLAGS) $(LDFLAGS)
LINK.f    	 		= $(FC) $(INCLUDE) $(FFLAGS) $(LDFLAGS)
LINK       			= $(LD) --build-id $(LDFLAGS)
PREPROCESS.F		= $(FPP) $(INCLUDE) $(CPPFLAGS)

override CPPFLAGS	+= "-DVERSION=\"$(VERSION)\""

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

.INTERMEDIATE: $(OBJECTS) $(OBJECTS:.o=.mod) $(OBJECTS:.o=.smod)

clean:
	rm -f *.o
	$(MAKE) -C 'test' clean
	rm -f *.mod *.smod *.f90 *.a *.so *.dll miniconf.pc

distclean: clean
	find -name 'libminiconf-*' -type d -print0 | xargs -0 rm -rfv
	find -name '*.log' -delete
	find -name '*.tar.xz' -delete
	find -name '*.rpm' -delete
	rm -rfv i686 x86_64

dist: distclean
	tar cvf libminiconf-$(VERSION).tar -C .. \
			--exclude='libminiconf/.git' \
			--exclude='libminiconf/*.tar' \
			--exclude='libminiconf/*.spec' \
			--transform="s/^libminiconf/libminiconf-$(VERSION)/" \
			libminiconf
	xz -f libminiconf-$(VERSION).tar

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
