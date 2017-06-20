! /******************* C O N F O R T *******************
!     (c) 2017 Dominik Gronkiewicz <gronki@gmail.com>
!     Distributed under MIT License.
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
! ******************************************************/

module confort

    use iso_c_binding

    integer, parameter :: MINCF_OK =                0
    integer, parameter :: MINCF_ERROR =             1
    integer, parameter :: MINCF_ARGUMENT_ERROR =    ishft(1,1)
    integer, parameter :: MINCF_MEMORY_ERROR =      ishft(1,2)
    integer, parameter :: MINCF_FILE_NOT_FOUND =    ishft(1,3)
    integer, parameter :: MINCF_SYNTAX_ERROR =      ishft(1,4)
    integer, parameter :: MINCF_NOT_FOUND =         ishft(1,5)

    type, bind(C) :: confort_c
        type(c_ptr) :: buffer = c_null_ptr
        integer(c_size_t) :: buffer_sz = 0
        integer(c_size_t) :: n_records = 0
        integer(c_size_t) :: records_sz = 0
        type(c_ptr) :: records = c_null_ptr
    end type

    type :: config
        integer, private :: errno = MINCF_OK
        type(confort_c), private :: data_struct
    contains
        procedure :: read       =>  mincf_read_stdin,   &
                                    mincf_read_file
        procedure :: failed     =>  mincf_any_error,    &
                                    mincf_this_error
        procedure :: get        =>  mincf_get_or_error, &
                                    mincf_get_exists,   &
                                    mincf_get_default
        procedure :: contains   =>  mincf_exists
        procedure :: not_found  =>  mincf_key_not_found
        procedure :: err        =>  mincf_get_errno
        procedure :: print_error => mincf_print_error
        final     :: mincf_free
    end type

    !// read the config

    interface mincf_read

        module procedure :: mincf_read_stdin
        module procedure :: mincf_read_file

    end interface

    !// get entry -- subroutine style

    interface mincf_get

        module procedure :: mincf_get_or_error
        module procedure :: mincf_get_exists
        module procedure :: mincf_get_default

    end interface

    !// error checking

    interface mincf_failed

        module procedure :: mincf_any_error
        module procedure :: mincf_this_error

    end interface


contains

!------------------------------ MINCF_GET_ERRNO -------------------------------!
!                  returns error number of the last operation                  !
!----------------------------------- inputs -----------------------------------!
!                              cfg: config class                               !
!---------------------------------- returns -----------------------------------!
!                                 error number                                 !
!------------------------------------------------------------------------------!

    function mincf_get_errno(cfg) result(errno)
        class(config) :: cfg
        integer :: errno

        errno = cfg % errno

#       if __CONFORT_DEBUG
        write (0,'(A,":",I0,":",A,Z0)') __FILE__, __LINE__,  "mincf_get_errno: ", errno
#       endif
    end function

!-------------------------------- mincf_any_error --------------------------------!
!                        checks if any failure occured                         !
!----------------------------------- inputs -----------------------------------!
!                              errno: error code                               !
!---------------------------------- returns -----------------------------------!
!                         true if any failure occured                          !
!------------------------------------------------------------------------------!

    function mincf_any_error(cfg)
        class(config) :: cfg
        logical :: mincf_any_error
        mincf_any_error = iand(cfg % errno, MINCF_ERROR) .ne. 0
    end function

!---------------------------- MINCF_KEY_NOT_FOUND -----------------------------!
!                Tests whether NOT FOUND error was encountered.                !
!----------------------------------- inputs -----------------------------------!
!                              cfg: config class                               !
!---------------------------------- returns -----------------------------------!
!                       whether NOT FOUND error occured                        !
!------------------------------------------------------------------------------!

    function mincf_key_not_found(cfg) result(test)
        class(config) :: cfg
        logical :: test
        test = iand(cfg % errno, MINCF_NOT_FOUND) .ne. 0
    end function

!------------------------------ MINCF_THIS_ERROR ------------------------------!
!          check if a given error has occured based on the error code          !
!----------------------------------- inputs -----------------------------------!
!                              errno: error code                               !
!                       errflag: error to be checked for                       !
!---------------------------------- returns -----------------------------------!
!                        true if the error has occured                         !
!------------------------------------------------------------------------------!

    logical function mincf_this_error(cfg,errflag)
        class(config) :: cfg
        integer, intent(in) :: errflag
        mincf_this_error = iand(cfg % errno, errflag) .ne. 0
    end function

!------------------------------ MINCF_READ_STDIN ------------------------------!
!                 reads the configuration from standard input                  !
!----------------------------------- INPUT ------------------------------------!
!                          cfg -> configuration class                          !
!------------------------------------------------------------------------------!

    subroutine mincf_read_stdin(cfg)
        class(config) :: cfg

        interface
            subroutine c_mincf_read_stdin(cfg,errno) &
                    & bind(C,name='fort_mincf_read_stdin')
                use iso_c_binding
                import :: confort_c
                type(confort_c), intent(inout) :: cfg
                integer(c_int), intent(out) :: errno
            end subroutine
        end interface

        call c_mincf_read_stdin(cfg % data_struct, cfg % errno)

    end subroutine

!------------------------------ MINCF_READ_FILE -------------------------------!
!                reads the configuration from a given file name                !
!----------------------------------- INPUT ------------------------------------!
!                          cfg -> configuration class                          !
!                           fn -> filename                                     !
!------------------------------------------------------------------------------!

    subroutine mincf_read_file(cfg,fn)
        class(config) :: cfg
        character(len=*), intent(in) :: fn

        interface
            subroutine c_mincf_read_file(cfg,fn,sz,errno) &
                    & bind(C,name='fort_mincf_read_file')
                use iso_c_binding
                import :: confort_c
                type(confort_c), intent(inout) :: cfg
                integer(c_size_t), intent(in), value :: sz
                character(c_char), intent(in) :: fn(sz)
                integer(c_int), intent(out) :: errno
            end subroutine
        end interface

        call c_mincf_read_file(cfg % data_struct, fn, len(fn,c_size_t),     &
            cfg % errno)

    end subroutine

!------------------------------ MINCF_GET_EXISTS ------------------------------!
!            Check for existence of a given key in the dictionary.             !
!----------------------------------- inputs -----------------------------------!
!                        cfg: configuration file class                         !
!                         key: key to be searched for                          !
!---------------------------------- outputs -----------------------------------!
!         errno: error number, see error number table for more details         !
!------------------------------------------------------------------------------!

    subroutine mincf_get_exists(cfg,key)
        class(config) :: cfg
        character(len=*), intent(in) :: key

        interface
            subroutine c_mincf_get_exists(cfg,key,key_sz,errno) &
                    & bind(C,name='fort_mincf_get_exists')
                use iso_c_binding
                import confort_c
                type(confort_c), intent(out) :: cfg
                integer(c_size_t), intent(in), value :: key_sz
                character(c_char), intent(in) :: key(key_sz)
                integer(c_int), intent(out) :: errno
            end subroutine
        end interface

        call c_mincf_get_exists(cfg % data_struct, key, len(key,c_size_t),  &
                cfg % errno)
    end subroutine

!-------------------------------- MINCF_EXISTS --------------------------------!
!            Check for existence of a given key in the dictionary.             !
!----------------------------------- inputs -----------------------------------!
!                        cfg: configuration file class                         !
!                         key: key to be searched for                          !
!---------------------------------- returns -----------------------------------!
!                     true if key exists, false otherwise                      !
!------------------------------------------------------------------------------!

    function mincf_exists(cfg,key) result(key_exists)
        class(config) :: cfg
        character(len=*), intent(in) :: key
        integer :: errno
        logical :: key_exists

        interface
            subroutine c_mincf_get_exists(cfg,key,key_sz,errno) &
                    & bind(C,name='fort_mincf_get_exists')
                use iso_c_binding
                import confort_c
                type(confort_c), intent(out) :: cfg
                integer(c_size_t), intent(in), value :: key_sz
                character(c_char), intent(in) :: key(key_sz)
                integer(c_int), intent(out) :: errno
            end subroutine
        end interface

        call c_mincf_get_exists(cfg % data_struct, key, len(key,c_size_t), errno)

        key_exists = ( errno .eq. MINCF_OK )
    end function

!----------------------------- MINCF_GET_OR_ERROR -----------------------------!
!     Attempts to get the value associated with a given key. If no such key    !
!                         exists, an error flag is set.                        !
!----------------------------------- inputs -----------------------------------!
!                              cfg: config class                               !
!                         key: key to be searched for                          !
!---------------------------------- outputs -----------------------------------!
!                       buf: buffer to place the result                        !
!------------------------------------------------------------------------------!

    subroutine mincf_get_or_error(cfg,key,buf)
        class(config) :: cfg
        character(len=*), intent(in) :: key
        character(len=*), intent(out) :: buf
        integer :: errno_local

        interface
            subroutine c_mincf_get(cfg,key,key_sz,buf,sz,errno) &
                    & bind(C,name='fort_mincf_get')
                use iso_c_binding
                import confort_c
                type(confort_c), intent(out) :: cfg
                integer(c_size_t), intent(in), value :: key_sz
                character(c_char), intent(in) :: key(key_sz)
                integer(c_size_t), intent(in), value :: sz
                character(c_char), intent(inout) :: buf(sz)
                integer(c_int), intent(out) :: errno
            end subroutine
        end interface

        call c_mincf_get(cfg % data_struct, &
            & key, len(key,c_size_t), &
            & buf, len(buf,c_size_t), &
            & cfg % errno)

#       if __CONFORT_DEBUG
        write (0,'(A,":",I0,":",A,A)') __FILE__, __LINE__,  "key:   ", key
        write (0,'(A,":",I0,":",A,Z0)') __FILE__, __LINE__, "errno: ", cfg % errno
#       endif

    end subroutine

!----------------------------- MINCF_GET_DEFAULT ------------------------------!
!    Attempts to get the value associated with a given key. If no such key     !
!           exists, the given default value is copied to the buffer.           !
!----------------------------------- inputs -----------------------------------!
!                              cfg: config class                               !
!                         key: key to be searched for                          !
!                           defvalue: default value                            !
!---------------------------------- outputs -----------------------------------!
!                       buf: buffer to place the results                       !
!------------------------------------------------------------------------------!

    subroutine mincf_get_default(cfg,key,buf,defvalue)
        class(config) :: cfg
        character(len=*), intent(in) :: key, defvalue
        character(len=*), intent(out) :: buf

        interface
            subroutine c_mincf_get_default(cfg, &
                    key, key_sz, &
                    buf, sz, &
                    defvalue, defvalue_sz, &
                    errno)   bind(C,name='fort_mincf_get_default')
                use iso_c_binding
                import confort_c
                type(confort_c), intent(out) :: cfg
                integer(c_size_t), intent(in), value :: key_sz, defvalue_sz
                character(c_char), intent(in) :: key(key_sz), defvalue(defvalue_sz)
                integer(c_size_t), intent(in), value :: sz
                character(c_char), intent(inout) :: buf(sz)
                integer(c_int), intent(out) :: errno
            end subroutine
        end interface

        call c_mincf_get_default(cfg % data_struct, &
                & key, len(key,c_size_t), &
                & buf, len(buf,c_size_t), &
                & defvalue, len(defvalue,c_size_t), &
                & cfg % errno)

    end subroutine

!----------------------------- MINCF_PRINT_ERROR ------------------------------!
! checks the error code and prints an appropriate message to the error output  !
!----------------------------------- INPUTS -----------------------------------!
!                           cfg: configuration class                           !
!               file (optional): __FILE__ preprocessor directive               !
!               line (optional): __LINE__ preprocessor directive               !
!------------------------------------------------------------------------------!

    subroutine mincf_print_error(cfg,file,line)
        class(config) :: cfg
        character(len=*), intent(in), optional :: file
        integer, intent(in), optional :: line

        character(len=128) :: prefix = "confort"

        if ( present(file) .and. present(line) ) then
            write (prefix,"(A,' line ',I0)") file,line
        end if

        if ( iand(cfg % errno,MINCF_ERROR) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"There was an error."
        if ( iand(cfg % errno,MINCF_NOT_FOUND) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"The entry was not found."
        if ( iand(cfg % errno,MINCF_FILE_NOT_FOUND) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"File not found."
        if ( iand(cfg % errno,MINCF_SYNTAX_ERROR) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"Syntax error in configuration file."
        if ( iand(cfg % errno,MINCF_ARGUMENT_ERROR) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"Incorrect argument."
        if ( iand(cfg % errno,MINCF_MEMORY_ERROR) .ne. 0 ) &
            & write (0,"(A,': ',A)") trim(prefix),"Memory error"
    end subroutine

!--------------------------------- MINCF_FREE ---------------------------------!
!                         destructor for config class                          !
!----------------------------------- inputs -----------------------------------!
!                              cfg: config class                               !
!------------------------------------------------------------------------------!

    subroutine mincf_free(cfg)
        type(config) :: cfg

        interface
            subroutine c_mincf_free(cfg) bind(C, name='mincf_free')
                import :: confort_c
                type(confort_c), intent(inout) :: cfg
            end subroutine
        end interface

        call c_mincf_free(cfg % data_struct)

#       if __CONFORT_DEBUG
        write (0,*) 'destructor'
#       endif

    end subroutine mincf_free

end module
