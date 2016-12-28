FSOURCES 	 = $(wildcard test_*.F90)
CSOURCES 	 = $(wildcard test_*.c)
TESTS		 = $(FSOURCES:.F90=) $(CSOURCES:.c=)
PROGS 	  	 = $(addprefix bin/,$(TESTS))
CERTS 	  	 = $(addprefix out/,$(TESTS))

INCLUDE	 	 = -I. -I..

CC  	 	 := cc
FC 		 	 := f95

CFLAGS 	 	 := -Og -Wall -mieee-fp
FFLAGS	 	 := $(CFLAGS) -std=f2008 -fimplicit-none -fcheck=all

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

bin/%: common.o %.F90 ../libminiconf.a
	mkdir -p bin
	$(LINK.F) -L.. $^ -o $@
bin/%: %.c ../libminiconf.a
	mkdir -p bin
	$(LINK.C) -L.. $^ -o $@

%.o: %.F90
	$(COMPILE.F) $< -o $@

../libminiconf.a: $(wildcard ../*.F90) $(wildcard ../*.c) $(wildcard ../*.h)
	$(MAKE) -B -C .. CC=$(CC) FC=$(FC) $@

clean:
	rm -rfv *.o *.mod *.pass *.fail bin out

distclean: clean

.SECONDARY: $(PROGS)
