program test

    use miniconf
    use iso_fortran_env
    use iso_c_binding

    integer :: failure

    call test_nonexistent_file(failure)
    call write_result('test_nonexistent_file',failure)

    call test_nonexistent_key(failure)
    call write_result('test_nonexistent_key',failure)

    call test_get_existing_key(failure)
    call write_result('test_get_existing_key',failure)

    ! call test_get_existing_keydef(failure)
    ! call write_result('test_get_existing_keydef',failure)


contains

    subroutine write_result(test,failure)
        character(len=*), intent(in) :: test
        character(len=12) :: str
        integer, intent(in) :: failure
        integer, save :: i = 1

        if (failure .eq. 0) then
            str = 'OK'
        else
            str='FAILED!'
        endif

        write (output_unit,'(I2,A30,A8)') i, test, trim(str)
        i = i + 1
    end subroutine


    subroutine test_nonexistent_file(failure)
        integer, intent(inout) :: failure
        integer(c_int) :: errno
        type(miniconf_c) :: cfg
        character(len=*), parameter :: fn = "Tegoplikuniema"
        failure = 0

        call mincf_read_file(cfg, fn // char(0), errno)

        if (errno .eq. 0) then
            failure = 1
            call mincf_free(cfg)
        end if
    end subroutine


    subroutine test_nonexistent_key(failure)
        integer, intent(inout) :: failure
        integer(c_int) :: errno
        type(miniconf_c) :: cfg
        character(len=150) :: buf
        character(len=*), parameter :: fn = "test.cfg"
        failure = 0

        call mincf_read_file(cfg, fn // char(0), errno)

        if (errno .ne. MINCF_OK) then
            failure = 1
            return
        end if

        call mincf_get(cfg, &
                & "blablablablabla" // char(0), &
                & buf, len(buf,kind=c_size_t), errno)

        if ( errno .ne. MINCF_NOT_FOUND )  &
            & failure = 1

        call mincf_free(cfg)
    end subroutine


    subroutine test_get_existing_key(failure)

        integer, intent(inout) :: failure
        integer(c_int) :: errno
        type(miniconf_c) :: cfg
        character(len=*), parameter :: fn = "test.cfg"
        failure = 0

        call mincf_read_file(cfg, fn // char(0), errno)

        if (errno .ne. MINCF_OK) then
            failure = 1
            return
        end if

        try : block

            character(len=150) :: buf

            call mincf_get(cfg, "key1" // char(0), &
                    & buf, len(buf,kind=c_size_t), errno)

            if ( errno .ne. MINCF_OK ) then
                failure = 1
                exit try
            end if

            if ( buf .ne. "value1" ) &
                & failure = 1

        end block try

        call mincf_free(cfg)


    end subroutine


    ! subroutine test_get_existing_keydef(failure)
    !     integer, intent(inout) :: failure
    !
    !     failure = 0
    !
    ! end subroutine



end program test
