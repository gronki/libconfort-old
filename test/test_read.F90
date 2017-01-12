program test_nonexistent_file

    use confort
    use iso_fortran_env
    use iso_c_binding
    use tests_common
#   include <macros>

    integer(c_int) :: errno
    type(confort_c) :: cfg
    character(len=*), parameter :: fn = "Tegoplikuniema"

    call mincf_read_file(cfg, fn, errno)

    call test(errno .ne. 0)

    call mincf_free(cfg)

end program
