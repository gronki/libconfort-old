program test_nonexistent_file

    use confort
    use iso_fortran_env
    use iso_c_binding
    use tests_common
#   include <macros>

    type(config) :: cfg
    character(len=*), parameter :: fn = "Tegoplikuniema"

    call mincf_read_file(cfg, fn)

    call test(cfg % err() .ne. 0)

    call mincf_free(cfg)

end program
