VERSION			= 170619

prefix 	 	 	= /usr/local
exec_prefix	 	= $(prefix)
bindir		 	= $(exec_prefix)/bin
datadir	 	 	= $(prefix)/share
includedir 	 	= $(prefix)/include
libdir 	 	 	= $(exec_prefix)/lib
fmoddir			= $(libdir)/gfortran/modules
docdir 	 	 	= $(datadir)/doc
licensedir 	 	= $(datadir)/licenses

INCLUDE	 	 	= -I. -Isrc

CC  	 	 	:= cc
CFLAGS 	 	 	?= -g -Wall -O2
FC 		 	 	:= f95
FFLAGS	 	 	?= $(CFLAGS) -fimplicit-none -Wpedantic
FPP				?= $(FC) -E

OBJECTS = c_routines.o f_routines.o core.o confort.o

VPATH = src

all: libconfort.so libconfort.a

libconfort.so: $(OBJECTS)
	$(FC) $(LDFLAGS) -shared $^ $(LDLIBS) -o $@

libconfort.a: $(OBJECTS)
	$(AR) rcs $@ $^

%.o: %.c
	$(CC) -fPIC $(INCLUDE) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
%.o: %.f90
	$(FC) -fPIC $(INCLUDE) $(FFLAGS) -c $< -o $@
%.f90: %.F90
	$(FPP) $(INCLUDE) $(CPPFLAGS) $< -o $@
%.o: %.mod

.INTERMEDIATE: $(OBJECTS)

installdirs:
	install -d $(DESTDIR)$(includedir)
	install -d $(DESTDIR)$(fmoddir)
	install -d $(DESTDIR)$(licensedir)/confort
	install -d $(DESTDIR)$(docdir)/confort
	install -d $(DESTDIR)$(libdir)/pkgconfig

install: installdirs all
	# headers
	install -m 644 src/confort.h $(DESTDIR)$(includedir)
	install -m 644 confort.mod $(DESTDIR)$(fmoddir)
	# libraries
	install libconfort.so $(DESTDIR)$(libdir)
	install -m 644 libconfort.a $(DESTDIR)$(libdir)
	# pkg config
	@echo "Name: confort" | tee $(DESTDIR)$(libdir)/pkgconfig/confort.pc
	@echo "Description: A minimalistic utility for reading configuration files. \
	Easy to use Fortran 2008 bindings are included. Compatible with GCC \
	and Intel compilers." | tee -a $(DESTDIR)$(libdir)/pkgconfig/confort.pc
	@echo "Version: $(VERSION)" | tee -a $(DESTDIR)$(libdir)/pkgconfig/confort.pc
	@echo "Libs: -L$(libdir) -lconfort" | tee -a $(DESTDIR)$(libdir)/pkgconfig/confort.pc
	@echo "Cflags: -I$(includedir) -I$(fmoddir)" | tee -a $(DESTDIR)$(libdir)/pkgconfig/confort.pc
	# docs
	install -m 644 LICENSE $(DESTDIR)$(licensedir)/confort/
	install -m 644 README.html $(DESTDIR)$(docdir)/confort/

docs: README.html

%.html: %.md
	pandoc -s -f markdown_github -t html5 $< -o $@

clean:
	$(RM) *.o *.smod *.f90 *.dll confort.pc
	$(MAKE) -C 'test' clean

distclean: clean
	rm -rfv libconfort.a confort.mod libconfort.so

dist: distclean
	tar cvf libconfort-$(VERSION).tar -C .. \
			--exclude='libconfort/.git' \
			--exclude='libconfort/*.tar' \
			--exclude='libconfort/*.tar.gz' \
			--transform="s/^libconfort/libconfort-$(VERSION)/" \
			libconfort
	gzip -f libconfort-$(VERSION).tar
