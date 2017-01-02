program test_nonexistent_key

    use miniconf
    use iso_fortran_env
    use iso_c_binding
    use tests_common
#   include <macros>

    integer(c_int) :: errno
    type(miniconf_c) :: cfg
    character(len=150) :: buf
    character(len=*), parameter :: fn = "test.cfg"
    character(len=*), parameter :: key = "sajiifwcrhcri"

    call mincf_read_file(cfg, fn, errno)

    call test(errno .eq. MINCF_OK)

    call mincf_get(cfg, key, buf, errno)

    call test(iand(errno,MINCF_NOT_FOUND) .ne. 0)

    call mincf_free(cfg)

end program
