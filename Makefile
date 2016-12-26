VERSION				= 161226

prefix 	 	 		= /usr/local
exec_prefix	 		= $(prefix)
bindir		 		= $(exec_prefix)/bin
datadir	 	 		= $(prefix)/share
includedir 	 		= $(prefix)/include
libdir 	 	 		= $(exec_prefix)/lib
docdir 	 	 		= $(datadir)/doc

OBJECTS	 	 		= core.o c_routines.o f_routines.o miniconf.o

INCLUDE	 	 		= -I.

CC  	 	 		?= cc
FC 		 	 		:= $(if $(filter $(FC),f77),f95,$(FC))

# GNU Fortran (gfortran/f95)
FFLAGS_f95			:= -std=f2008 -fimplicit-none
FFLAGS_f95_extra	:= -Wall -O2 -mieee-fp

# Intel Fortran (ifort)
FFLAGS_ifort		:= -std08 -implicitnone
FFLAGS_ifort_extra 	:= -warn all -O2 -mieee-fp

CFLAGS 	 	 		?= -Wall -O2 -mieee-fp
FFLAGS	 	 		?= $(FFLAGS_$(FC)_extra)
FFLAGS 		 		+= $(FFLAGS_$(FC))

COMPILE.C 	 		= $(CC) $(INCLUDE) $(CPPFLAGS) -g $(CFLAGS) -fPIC -c
COMPILE.F    		= $(FC) $(INCLUDE) $(CPPFLAGS) -g $(FFLAGS) -fPIC -c
LINK.C 	 	 		= $(CC) $(INCLUDE) $(CPPFLAGS) -g $(CFLAGS) $(LDFLAGS)
LINK.F    	 		= $(FC) $(INCLUDE) $(CPPFLAGS) -g $(FFLAGS) $(LDFLAGS)
LINK       			= $(LD) --build-id $(LDFLAGS)

all: libminiconf.so libminiconf.a miniconf.pc

libminiconf.so: $(OBJECTS)
	$(LINK.F) $(LDLIBS) -shared $^ -o $@

libminiconf.a: $(OBJECTS)
	ar rcs $@ $^

%.o: %.c
	$(COMPILE.C) $< -o $@

%.o: %.F90
	$(COMPILE.F) $< -o $@

.INTERMEDIATE: $(OBJECTS)

clean:
	rm -f *.o
	$(MAKE) -C 'test' clean
	rm -f *.mod *.a *.so *.dll miniconf.pc

distclean: clean

dist: distclean
	tar cvf libminiconf-$(VERSION).tar -C .. \
			--exclude='libminiconf/.git' \
			--exclude='libminiconf/*.tar' \
			--transform="s/^libminiconf/libminiconf-$(VERSION)/" \
			libminiconf
	xz -f libminiconf-$(VERSION).tar

installdirs:
	install -d $(DESTDIR)$(includedir)/miniconf
	install -d $(DESTDIR)$(libdir)/pkgconfig

install: installdirs all
	install -m 644 -p miniconf.h $(DESTDIR)$(includedir)/miniconf
	install -m 644 -p miniconf.mod $(DESTDIR)$(includedir)/miniconf
	install -p libminiconf.so $(DESTDIR)$(libdir)
	install -m 644 -p libminiconf.a $(DESTDIR)$(libdir)
	install -m 644 -p miniconf.pc $(DESTDIR)$(libdir)/pkgconfig

miniconf.pc:
	echo "Name: miniconf" > miniconf.pc
	echo "Description: A minimalistic utility for reading configuration files. Easy to use Fortran 2008 bindings are included. Compatible with GCC and Intel compilers."  >> miniconf.pc
	echo "Version: $(VERSION)"  >> miniconf.pc
	echo "Libs: -L$(libdir) -lminiconf" >> miniconf.pc
	echo "Cflags: -I$(includedir)/miniconf" >> miniconf.pc

.PHONY:	miniconf.pc
