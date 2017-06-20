program test_nonexistent_key

    use confort
    use iso_fortran_env
    use iso_c_binding
    use tests_common
#   include <macros>

    type(config) :: cfg
    character(len=150) :: buf
    character(len=*), parameter :: fn = "test.cfg"
    character(len=*), parameter :: key_wrong = "thereisnouschkey"
    character(len=*), parameter :: key_ok = "key1"
    character(len=*), parameter :: value_ok = "value1"
    character(len=*), parameter :: def = "domyslna"

    call mincf_read_file(cfg, fn)

    if (ftest(cfg % err() .eq. MINCF_OK)) then

        call mincf_get(cfg, key_ok)
        call cfg % print_error(__FILE__,__LINE__)
        call test( mincf_get_errno(cfg) .eq. MINCF_OK )
        call test( mincf_exists(cfg,key_ok) )
        call mincf_get(cfg, key_wrong)
        call cfg % print_error(__FILE__,__LINE__)

        call test( mincf_get_errno(cfg) .ne. MINCF_OK )
        call test( iand(mincf_get_errno(cfg), MINCF_ERROR) .eq. 0 )
        call test( iand(mincf_get_errno(cfg), MINCF_NOT_FOUND) .ne. 0 )
        call test( .not. mincf_exists(cfg,key_wrong) )

        call mincf_get(cfg, key_wrong, buf)
        call cfg % print_error(__FILE__,__LINE__)
        call test(iand(mincf_get_errno(cfg), MINCF_NOT_FOUND) .ne. 0)

        call mincf_get(cfg, key_ok, buf, def)
        call cfg % print_error(__FILE__,__LINE__)
        call test(iand(mincf_get_errno(cfg), MINCF_NOT_FOUND) .eq. 0)
        call test(buf .eq. value_ok)

        call mincf_get(cfg, key_wrong, buf, def)
        call cfg % print_error(__FILE__,__LINE__)
        call test(iand(mincf_get_errno(cfg), MINCF_NOT_FOUND) .eq. 0)
        call test(buf .eq. def)

        call mincf_get(cfg, "test_overwrite_1", buf)
        call cfg % print_error(__FILE__,__LINE__)
        call test(mincf_get_errno(cfg) .eq. MINCF_OK)
        call mincf_get(cfg, "test_overwrite_2", buf)
        call cfg % print_error(__FILE__,__LINE__)
        if ( ftest(mincf_get_errno(cfg) .eq. MINCF_OK) ) then
            call test(buf .eq. 'A very short comment.')
            write(6, "('buffer content: ',A)") buf
        end if


        call mincf_free(cfg)

    end if

end program
