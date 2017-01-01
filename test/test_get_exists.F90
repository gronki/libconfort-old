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
    character(len=*), parameter :: key_ok = "key1"
    character(len=*), parameter :: key_wrong = "sajiifwcrhcri"

    call mincf_read_file(cfg, fn, len(fn,c_size_t), errno)

    if ( ftest(errno .eq. MINCF_OK) ) then

        call mincf_get_exists(cfg, &
                & key_ok, len(key_ok,c_size_t), errno)

        call test( errno .eq. MINCF_OK )

        call mincf_get_exists(cfg, &
            & key_wrong, len(key_wrong,c_size_t), errno)

        call test( errno .ne. MINCF_OK )
        call test( iand(errno, MINCF_ERROR) .eq. 0 )
        call test( iand(errno, MINCF_NOT_FOUND) .ne. 0 )

        call mincf_free(cfg)

    end if

end program
