submodule(miniconf) miniconf_procedures

    use iso_c_binding
    use iso_fortran_env

contains

    subroutine mincf_read_file(cfg,fn,errno)
        type(miniconf_c), intent(inout) :: cfg
        character(len=*), intent(in) :: fn
        integer, intent(out) :: errno

        call c_mincf_read_file(cfg, fn, len(fn,c_size_t), errno)
    end subroutine

    subroutine mincf_get_or_stop(cfg,key,buf)
        type(miniconf_c), intent(out) :: cfg
        character(len=*), intent(in) :: key
        character(len=*), intent(out) :: buf
        integer :: errno

        call c_mincf_get(cfg, &
                & key, len(key,c_size_t), &
                & buf, len(buf,c_size_t), &
                & errno)

        if ( mincf_failed(errno) ) then
            write (error_unit,"('miniconf: entry ""',A,'"" not found.')") key
            call mincf_free(cfg)
            error stop "runtime error"
        end if
    end subroutine

    subroutine mincf_get_or_error(cfg,key,buf,errno)
        type(miniconf_c), intent(out) :: cfg
        character(len=*), intent(in) :: key
        character(len=*), intent(out) :: buf
        integer, intent(out) :: errno

        call c_mincf_get(cfg, &
                & key, len(key,c_size_t), &
                & buf, len(buf,c_size_t), &
                & errno)
    end subroutine

    subroutine mincf_get_exists(cfg,key,errno)
        type(miniconf_c), intent(out) :: cfg
        character(len=*), intent(in) :: key
        integer, intent(out) :: errno

        call c_mincf_get_exists(cfg, key, len(key,c_size_t), errno)
    end subroutine

    logical function mincf_exists(cfg,key)
        type(miniconf_c), intent(out) :: cfg
        character(len=*), intent(in) :: key
        integer :: errno

        call c_mincf_get_exists(cfg, key, len(key,c_size_t), errno)

        mincf_exists = ( errno .eq. MINCF_OK )
    end function

    subroutine mincf_get_default(cfg,key,buf,defvalue,errno)
        type(miniconf_c), intent(out) :: cfg
        character(len=*), intent(in) :: key, defvalue
        character(len=*), intent(out) :: buf
        integer, intent(out) :: errno

        call c_mincf_get_default(cfg, &
                & key, len(key,c_size_t), &
                & buf, len(buf,c_size_t), &
                & defvalue, len(defvalue,c_size_t), &
                & errno)
    end subroutine

    module subroutine mincf_get_yolo(cfg,key,buf,defvalue)
        type(miniconf_c), intent(out) :: cfg
        character(len=*), intent(in) :: key, defvalue
        character(len=*), intent(out) :: buf
        integer :: errno

        call c_mincf_get_default(cfg, &
                & key, len(key,c_size_t), &
                & buf, len(buf,c_size_t), &
                & defvalue, len(defvalue,c_size_t), &
                & errno)
    end subroutine

    logical function mincf_failed(errno)
        integer, intent(in) :: errno
        mincf_failed = iand(errno,MINCF_ERROR) .ne. 0
    end function

    logical function mincf_this_error(errno,errflag)
        integer, intent(in) :: errno,errflag
        mincf_this_error = iand(errno,errflag) .ne. 0
    end function


end submodule
