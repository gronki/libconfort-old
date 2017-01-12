FSOURCES 	 = $(wildcard test_*.F90)
CSOURCES 	 = $(wildcard test_*.c)
TESTS		 = $(FSOURCES:.F90=_F90) $(CSOURCES:.c=_c)
PROGS 	  	 = $(addprefix bin/,$(TESTS))
CERTS 	  	 = $(addprefix out/,$(TESTS))

INCLUDE	 	 = -I. -I..

CC  	 	 := cc
FC 		 	 := f95
CPP			 := cpp -nostdinc

CFLAGS 	 	 := -Og -Wall -mieee-fp
FFLAGS	 	 := $(CFLAGS) -std=f2008 -fimplicit-none
FFLAGS 		 += -fbackslash -fcheck=all -fbacktrace

COMPILE.C 	 = $(CC) $(INCLUDE) $(CPPFLAGS) -g $(CFLAGS) -c
COMPILE.F    = $(FC) $(INCLUDE) $(CPPFLAGS) -g $(FFLAGS) -c
LINK.C 	 	 = $(CC) $(INCLUDE) $(CPPFLAGS) -g $(CFLAGS) $(LDFLAGS)
LINK.F    	 = $(FC) $(INCLUDE) $(CPPFLAGS) -g $(FFLAGS) $(LDFLAGS)
LINK.O       = $(LD) --build-id $(LDFLAGS)

################################################

all: $(CERTS)

out/%: bin/%
	mkdir -p out
	bash runtest.sh $(subst out/,,$@)

bin/%_F90: common.o %.f90 ../libconfort.a
	mkdir -p bin
	$(LINK.F) -L.. $^ -o $@
bin/%_c: common_c.o %.c ../libconfort.a
	mkdir -p bin
	$(LINK.C) -L.. $^ -o $@

%.o: %.c
	$(COMPILE.C) $< -o $@
%.o: %.f90
	$(COMPILE.F) $< -o $@
%.f90: %.F90
	$(CPP) $(INCLUDE) $(CPPFLAGS) $< -o $@
%.o: %.mod

../libconfort.a: $(wildcard ../*.F90) $(wildcard ../*.c) $(wildcard ../*.h)
	$(MAKE) -C .. CC=$(CC) FC=$(FC)

clean:
	rm -rfv *.o *.mod *.pass *.fail bin out

distclean: clean

.SECONDARY: $(PROGS)
