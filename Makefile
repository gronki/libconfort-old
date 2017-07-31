VERSION = 170731

prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
datadir = $(prefix)/share
includedir = $(prefix)/include
libdir = $(exec_prefix)/lib
fmoddir = $(libdir)/gfortran/modules

INCLUDE = -I. -Isrc

CC = gcc
FC = gfortran
CFLAGS = -g -Wall -O2
FFLAGS = -g -Wall -O2 -pedantic -fimplicit-none -fbacktrace

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
%.o: %.F90
	$(FC) -fPIC $(INCLUDE) $(CPPFLAGS) $(FFLAGS) -c $< -o $@

installdirs:
	install -d $(DESTDIR)$(includedir)
	install -d $(DESTDIR)$(fmoddir)
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

clean:
	$(RM) *.o *.smod 
	$(MAKE) -C 'test' clean

distclean: clean
	$(RM) -rv libconfort.a confort.mod libconfort.so

