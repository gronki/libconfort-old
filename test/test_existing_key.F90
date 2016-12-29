program test_existing_key

    use miniconf
    use iso_fortran_env
    use iso_c_binding
    use tests_common
#   include <macros>

    integer(c_int) :: errno
    type(miniconf_c) :: cfg
    character(len=*), parameter :: fn = "test.cfg"
    character(len=*), parameter :: key = "key1"
    character(len=150) :: buf

    call mincf_read_file(cfg, fn, len(fn,c_size_t), errno)

    if ( ftest(errno .eq. MINCF_OK) ) then

        call mincf_get(cfg, key, len(key,c_size_t), &
                & buf, len(buf,c_size_t), errno)

        call test(errno .eq. MINCF_OK)
        call test(buf .eq. 'value1')

    end if

    call mincf_free(cfg)

end program
