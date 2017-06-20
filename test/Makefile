FSOURCES 	 = $(wildcard test_*.F90)
CSOURCES 	 = $(wildcard test_*.c)
TESTS		 = $(FSOURCES:.F90=_F90) $(CSOURCES:.c=_c)
PROGS 	  	 = $(addprefix bin/,$(TESTS))
CERTS 	  	 = $(addprefix out/,$(TESTS))

INCLUDE	 	 = -I. -I.. -I../src

CC  	 	 := cc
FC 		 	 := f95
FPP			 := $(FC) -E

CFLAGS 	 	 := -Og -Wall -mieee-fp -g
FFLAGS	 	 := $(CFLAGS) -std=f2008
FFLAGS 		 += -fbackslash -fcheck=all -fbacktrace -ffree-line-length-none
CPPFLAGS	 := -D__CONFORT_DEBUG

################################################

all: $(CERTS)

out/%: bin/%
	mkdir -p out
	bash runtest.sh $(subst out/,,$@)

bin/%_F90: common.o %.f90 ../libconfort.a
	mkdir -p bin
	$(FC) $(INCLUDE) $(FFLAGS) $(LDFLAGS) -L.. $^ -o $@
bin/%_c: common_c.o %.c ../libconfort.a
	mkdir -p bin
	$(CC) $(INCLUDE) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -L.. $^ -o $@

%.o: %.c
	$(CC)  $(INCLUDE) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
%.o: %.f90
	$(FC)  $(INCLUDE) $(FFLAGS) -c $< -o $@
%.f90: %.F90
	$(FPP) $(INCLUDE) $(CPPFLAGS) $< -o $@
%.o: %.mod

../libconfort.a: $(wildcard ../src/*.F90) $(wildcard ../src/*.c) $(wildcard ../src/*.h)
	$(MAKE) -C .. CC="$(CC)" FC="$(FC)" CFLAGS="$(CFLAGS)" FFLAGS="$(FFLAGS)" CPPFLAGS="$(CPPFLAGS)"

clean:
	rm -rfv *.o *.mod *.pass *.fail bin out

distclean: clean

.SECONDARY: $(PROGS)
