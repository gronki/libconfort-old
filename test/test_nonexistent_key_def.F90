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
    character(len=*), parameter :: def = "domyslna"

    call mincf_read_file(cfg, fn, len(fn,c_size_t), errno)

    call test(errno .eq. MINCF_OK)

    call mincf_get_default(cfg, &
            & key, len(key,c_size_t), &
            & buf, len(buf,c_size_t), &
            & def, len(def,c_size_t), &
            & errno)

    call test(iand(errno,MINCF_NOT_FOUND) .eq. 0)
    call test(buf .eq. def)

    call mincf_free(cfg)

end program
