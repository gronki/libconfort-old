submodule(miniconf) miniconf_procedures

    use iso_c_binding
    use iso_fortran_env

contains

    module subroutine mincf_read_stdin(cfg,errno)
        type(miniconf_c), intent(inout) :: cfg
        integer, intent(inout), optional :: errno
        integer :: errno_local

        if ( present(errno) ) then
            call c_mincf_read_stdin(cfg,errno)
        else
            call c_mincf_read_stdin(cfg,errno_local)
            if ( mincf_check_error(errno_local) ) then
                call mincf_free(cfg)
                error stop "miniconf: fatal error while reading the configuration"
            end if
        end if
    end subroutine

    module subroutine mincf_read_file(cfg,fn,errno)
        type(miniconf_c), intent(inout) :: cfg
        character(len=*), intent(in) :: fn
        integer, intent(inout), optional :: errno
        integer :: errno_local

        if ( present(errno) ) then
            call c_mincf_read_file(cfg, fn, len(fn,c_size_t), errno)
        else
            call c_mincf_read_file(cfg, fn, len(fn,c_size_t), errno_local)
            if ( mincf_check_error(errno_local) ) then
                call mincf_free(cfg)
                error stop "miniconf: fatal error while reading the configuration"
            end if
        end if

    end subroutine

    module subroutine mincf_get_or_error(cfg,key,buf,errno)
        type(miniconf_c), intent(out) :: cfg
        character(len=*), intent(in) :: key
        character(len=*), intent(out) :: buf
        integer, intent(inout), optional :: errno
        integer :: errno_local

        if ( present(errno) ) then
            call c_mincf_get(cfg, &
                    & key, len(key,c_size_t), &
                    & buf, len(buf,c_size_t), &
                    & errno)
        else
            call c_mincf_get(cfg, &
                    & key, len(key,c_size_t), &
                    & buf, len(buf,c_size_t), &
                    & errno_local)
            if ( mincf_check_error(errno_local) ) then
                call mincf_free(cfg)
                error stop "miniconf: fatal error while reading the configuration"
            end if
        end if

    end subroutine

    module subroutine mincf_get_exists(cfg,key,errno)
        type(miniconf_c), intent(out) :: cfg
        character(len=*), intent(in) :: key
        integer, intent(out) :: errno

        call c_mincf_get_exists(cfg, key, len(key,c_size_t), errno)
    end subroutine

    module logical function mincf_exists(cfg,key)
        type(miniconf_c), intent(out) :: cfg
        character(len=*), intent(in) :: key
        integer :: errno

        call c_mincf_get_exists(cfg, key, len(key,c_size_t), errno)

        mincf_exists = ( errno .eq. MINCF_OK )
    end function

    module subroutine mincf_get_default(cfg,key,buf,defvalue,errno)
        type(miniconf_c), intent(out) :: cfg
        character(len=*), intent(in) :: key, defvalue
        character(len=*), intent(out) :: buf
        integer, intent(inout), optional :: errno
        integer :: errno_local

        call c_mincf_get_default(cfg, &
                & key, len(key,c_size_t), &
                & buf, len(buf,c_size_t), &
                & defvalue, len(defvalue,c_size_t), &
                & errno_local)

        if ( present(errno) ) then
            errno = errno_local
        end if
    end subroutine

    module logical function mincf_failed(errno)
        integer, intent(in) :: errno
        mincf_failed = iand(errno,MINCF_ERROR) .ne. 0
    end function

    module logical function mincf_this_error(errno,errflag)
        integer, intent(in) :: errno,errflag
        mincf_this_error = iand(errno,errflag) .ne. 0
    end function

    module subroutine mincf_print_error(errno,file,line)
        integer, intent(in) :: errno
        character(len=*), intent(in), optional :: file
        integer, intent(in), optional :: line

        character(len=128) :: prefix = "miniconf"

        if ( present(file) .and. present(line) ) then
            write (prefix,"(A,' line ',I0)") file,line
        end if

        if ( iand(errno,MINCF_ERROR) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"There was an error."
        if ( iand(errno,MINCF_NOT_FOUND) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"The entry was not found."
        if ( iand(errno,MINCF_FILE_NOT_FOUND) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"File not found."
        if ( iand(errno,MINCF_SYNTAX_ERROR) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"Syntax error in configuration file."
        if ( iand(errno,MINCF_ARGUMENT_ERROR) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"Incorrect argument."
        if ( iand(errno,MINCF_MEMORY_ERROR) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"Memory error"
    end subroutine


end submodule
