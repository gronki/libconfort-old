!  /************** M I N I C O N F ***************
!    This small library allows to read a simple
!     configuration file. Data can be read from
!     any FILE* handle (for example stdin).
!     Dominik Gronkiewicz 2016  gronki@gmail.com
!     MIT license.
!
!     Example file:
!     --------------------------
!     key1 value1
!
!     # comment
!     key2 value2 value3   #  another comment
!
!     key3 "very long # text
!     with newline"
!
!     key4   5.0
!     key5   6.0  7.5  # hoorayy it's the end
!     --------------------------
!
! ************************************************/


module miniconf

    use iso_c_binding

    type :: miniconf_t
        type(c_ptr) :: r
    end type

    type, bind(C) :: miniconf_c
        type(c_ptr) :: buffer
        integer(c_size_t) ::  buffer_sz
        integer(c_size_t) :: n_records
        integer(c_size_t) :: records_sz
        type(c_ptr) :: records
    end type

    integer, parameter :: MINCF_OK =                0
    integer, parameter :: MINCF_ERROR =             1
    integer, parameter :: MINCF_ARGUMENT_ERROR =    ishft(1,1)
    integer, parameter :: MINCF_MEMORY_ERROR =      ishft(1,2)
    integer, parameter :: MINCF_FILE_NOT_FOUND =    ishft(1,3)
    integer, parameter :: MINCF_SYNTAX_ERROR =      ishft(1,4)
    integer, parameter :: MINCF_NOT_FOUND =         ishft(1,5)

    !// read the config

    interface mincf_read

        module subroutine mincf_read_file(cfg,fn,errno)
            type(miniconf_c), intent(inout) :: cfg
            character(len=*), intent(in) :: fn
            integer, intent(out) :: errno
        end subroutine

        subroutine mincf_read_stdin(cfg,errno) &
                & bind(C,name='fort_mincf_read_stdin')
            use iso_c_binding
            import :: miniconf_c
            type(miniconf_c), intent(inout) :: cfg
            integer(c_int), intent(out) :: errno
        end subroutine

    end interface

    !// get entry -- subroutine style

    interface mincf_get
        module subroutine mincf_get_or_error(cfg,key,buf,errno)
            type(miniconf_c), intent(out) :: cfg
            character(len=*), intent(in) :: key
            character(len=*), intent(out) :: buf
            integer, intent(out) :: errno
        end subroutine

        module subroutine mincf_get_exists(cfg,key,errno)
            type(miniconf_c), intent(out) :: cfg
            character(len=*), intent(in) :: key
            integer, intent(out) :: errno
        end subroutine

        module subroutine mincf_get_default(cfg,key,buf,defvalue,errno)
            type(miniconf_c), intent(out) :: cfg
            character(len=*), intent(in) :: key, defvalue
            character(len=*), intent(out) :: buf
            integer, intent(out) :: errno
        end subroutine

        module subroutine mincf_get_yolo(cfg,key,buf,defvalue)
            type(miniconf_c), intent(out) :: cfg
            character(len=*), intent(in) :: key, defvalue
            character(len=*), intent(out) :: buf
        end subroutine
    end interface

    !// error checking

    interface mincf_check_error

        module logical function mincf_had_error(errno)
            integer, intent(in) :: errno
        end function

        module logical function mincf_this_error(errno,errflag)
            integer, intent(in) :: errno,errflag
        end function

    end interface

    !// Other procedures

    interface

        module logical function mincf_exists(cfg,key)
            type(miniconf_c), intent(out) :: cfg
            character(len=*), intent(in) :: key
        end function

        subroutine mincf_free(cfg) &
                & bind(C,name='mincf_free')
            use iso_c_binding
            import :: miniconf_c
            type(miniconf_c), intent(inout) :: cfg
        end subroutine

    end interface

    !// C binding interfaces

    interface

        subroutine c_mincf_read_file(cfg,fn,sz,errno) &
                & bind(C,name='fort_mincf_read_file')
            use iso_c_binding
            import :: miniconf_c
            type(miniconf_c), intent(inout) :: cfg
            integer(c_size_t), intent(in), value :: sz
            character(c_char), intent(in) :: fn(sz)
            integer(c_int), intent(out) :: errno
        end subroutine

        subroutine c_mincf_get(cfg,key,key_sz,buf,sz,errno) &
                & bind(C,name='fort_mincf_get')
            use iso_c_binding
            import miniconf_c
            type(miniconf_c), intent(out) :: cfg
            integer(c_size_t), intent(in), value :: key_sz
            character(c_char), intent(in) :: key(key_sz)
            integer(c_size_t), intent(in), value :: sz
            character(c_char), intent(inout) :: buf(sz)
            integer(c_int), intent(out) :: errno
        end subroutine

        subroutine c_mincf_get_exists(cfg,key,key_sz,errno) &
                & bind(C,name='fort_mincf_get_exists')
            use iso_c_binding
            import miniconf_c
            type(miniconf_c), intent(out) :: cfg
            integer(c_size_t), intent(in), value :: key_sz
            character(c_char), intent(in) :: key(key_sz)
            integer(c_int), intent(out) :: errno
        end subroutine

        subroutine c_mincf_get_default(cfg,key,key_sz,buf,sz,defvalue,defvalue_sz,errno) &
                & bind(C,name='fort_mincf_get_default')
            use iso_c_binding
            import miniconf_c
            type(miniconf_c), intent(out) :: cfg
            integer(c_size_t), intent(in), value :: key_sz, defvalue_sz
            character(c_char), intent(in) :: key(key_sz), defvalue(defvalue_sz)
            integer(c_size_t), intent(in), value :: sz
            character(c_char), intent(inout) :: buf(sz)
            integer(c_int), intent(out) :: errno
        end subroutine

    end interface

end module
