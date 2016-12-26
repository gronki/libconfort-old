INCLUDE	 	= -I. -I..

CC			?= cc
FC			:= $(if $(filter $(FC),f77),f95,$(FC))

CFLAGS		?= -Og -Wall
FFLAGS		?= -Og -Wall
FFLAGS		+= -fimplicit-none -std=f2008

COMPILE.C 	 		= $(CC) $(INCLUDE) $(CPPFLAGS) -g $(CFLAGS) -fPIC -c
COMPILE.F    		= $(FC) $(INCLUDE) $(CPPFLAGS) -g $(FFLAGS) -fPIC -c
LINK.C 	 	 		= $(CC) $(INCLUDE) $(CPPFLAGS) -g $(CFLAGS) $(LDFLAGS)
LINK.F    	 		= $(FC) $(INCLUDE) $(CPPFLAGS) -g $(FFLAGS) $(LDFLAGS)
LINK       			= $(LD) --build-id $(LDFLAGS)

all: bin/test_f bin/test_c

bin/test_f: test_f.f90 ../libminiconf.a
	mkdir -p bin
	$(LINK.F) $^ -o $@

bin/test_c: test_c.c ../libminiconf.a
	mkdir -p bin
	$(LINK.C) $^ -o $@

../libminiconf.a:
	$(MAKE) -C ..

clean:
	rm -f *.o *.mod
	rm -rf bin

distclean: clean
