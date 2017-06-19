# ifndef __FORTRAN_FEATURES_CHECK__
# define __FORTRAN_FEATURES_CHECK__

#   if __GNUC__ && (100*__GNUC__+__GNUC_MINOR__) < 600
#       define __NO_SUBMODULES 1
#   endif

# endif
