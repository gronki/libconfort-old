program test1

    use miniconf
    use iso_c_binding

    implicit none

    type(c_ptr) :: cfg

    character(len=2048) :: buf_key,buf_val,buf_def

    integer :: i

    call  mincf_readf(cfg,'test2.cfg')
    if ( .not.c_associated(cfg) ) then
        write(0,*) 'error reading config'
        stop -1
    end if

    do i = 1,7
        write(buf_key,'(A,I0)') 'key', i
        write(buf_def,'(A,I0,A)') 'Default #', i, ' :)'

        if ( mincf_get(cfg,trim(buf_key),trim(buf_def),buf_val) .eq. MINCF_NOT_FOUND ) then
            write (0,'(A,A,A)') 'value ', trim(buf_key), ' not found!'
        end if

        write (6,'(A,A,A,A)') 'I have got: ''', trim(buf_val), ''' ... '

    end do




    call mincf_free(cfg)




end program test1
