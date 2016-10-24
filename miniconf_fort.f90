
!  *************** M I N I C O N F ***************
!     This small library allows to read a simple
!     configuration file. Data can be read from
!     any FILE* handle (for example stdin).
!     Dominik Gronkiewicz 2016  gronki@gmail.com
!     GNU GPL 2 license.
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



module miniconf

    use iso_c_binding

    type :: mini_conf
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



    interface

        subroutine mincf_read_file(cfg,file,errno) &
                & bind(C,name='fort_mincf_read_file')
            use iso_c_binding
            import :: miniconf_c
            type(miniconf_c), intent(inout) :: cfg
            character(kind=c_char, len=1), intent(in) :: file(*)
            integer(c_int), intent(out) :: errno
        end subroutine

        subroutine mincf_read_stdin(cfg,errno) &
                & bind(C,name='fort_mincf_read_stdin')
            use iso_c_binding
            import :: miniconf_c
            type(miniconf_c), intent(inout) :: cfg
            integer(c_int), intent(out) :: errno
        end subroutine



        !> Deallocates the memory reserved for config.
        !! WARNING: without this you get a memory leak!
        !! @param conf    Pointer to miniconf structure.
        subroutine mincf_free(cfg) &
                & bind(C,name='mincf_free')
            use iso_c_binding
            import :: miniconf_c
            type(miniconf_c), intent(inout) :: cfg
        end subroutine


        function c_strlen(s) &
            & result(length) &
            & bind(C,name='strlen')
            use iso_c_binding
            character(c_char), intent(in) :: s(*)
            integer(c_size_t) :: length
        end function
        subroutine mincf_get(cfg,key,buf,sz,errno) &
                & bind(C,name='fort_mincf_get')
            use iso_c_binding
            import :: miniconf_c
            type(miniconf_c), intent(inout) :: cfg
            character(kind=c_char, len=1), intent(in) :: key(*)
            integer(c_size_t), intent(in), value :: sz
            character(kind=c_char), intent(inout) :: buf(*)
            integer(c_int), intent(out) :: errno
        end subroutine
        subroutine mincf_get_default(cfg,key,buf,sz,defvalue,errno) &
                & bind(C,name='fort_mincf_get_default')
            use iso_c_binding
            import :: miniconf_c
            type(miniconf_c), intent(inout) :: cfg
            character(kind=c_char, len=1), intent(in) :: key(*), defvalue(*)
            integer(c_size_t), intent(in), value :: sz
            character(kind=c_char), intent(inout) :: buf(*)
            integer(c_int), intent(out) :: errno
        end subroutine
        subroutine cstr_import(buf,sz) &
                & bind(C,name='cstr_import')
            use iso_c_binding
            character(kind=c_char), intent(inout) :: buf(*)
            integer(c_size_t), intent(in), value :: sz
        end subroutine

    end interface

end module
