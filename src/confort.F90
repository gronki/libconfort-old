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
  implicit none

  type, bind(C) :: config
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

  ! read the config

  interface mincf_read
    module procedure :: mincf_read_stdin
    module procedure :: mincf_read_file
  end interface

  ! get entry

  interface mincf_get
    module procedure :: mincf_get_or_error
    module procedure :: mincf_get_default
  end interface

  ! Other procedures

  interface
    subroutine mincf_free(cfg) &
      & bind(C,name='mincf_free')
      use iso_c_binding
      import :: config
      type(config), intent(inout) :: cfg
    end subroutine
  end interface

contains

  subroutine mincf_read_stdin(cfg,errno)

    interface
      subroutine c_mincf_read_stdin(cfg,errno) &
        & bind(C,name='fort_mincf_read_stdin')
        use iso_c_binding
        import :: config
        type(config), intent(inout) :: cfg
        integer(c_int), intent(out) :: errno
      end subroutine
    end interface

    type(config), intent(inout) :: cfg
    integer, intent(inout), optional :: errno
    integer :: errno_local

    if ( present(errno) ) then
      call c_mincf_read_stdin(cfg,errno)
    else
      call c_mincf_read_stdin(cfg,errno_local)
      if ( errno_local .ne. 0 ) then
        call mincf_free(cfg)
        error stop "confort: fatal error while reading the configuration"
      end if
    end if
  end subroutine

  subroutine mincf_read_file(cfg,fn,errno)

    interface
      subroutine c_mincf_read_file(cfg,fn,sz,errno) &
        & bind(C,name='fort_mincf_read_file')
        use iso_c_binding
        import :: config
        type(config), intent(inout) :: cfg
        integer(c_size_t), intent(in), value :: sz
        character(c_char), intent(in) :: fn(sz)
        integer(c_int), intent(out) :: errno
      end subroutine
    end interface

    type(config), intent(inout) :: cfg
    character(len=*), intent(in) :: fn
    integer, intent(inout), optional :: errno
    integer :: errno_local

    if ( present(errno) ) then
      call c_mincf_read_file(cfg, fn, len(fn,c_size_t), errno)
    else
      call c_mincf_read_file(cfg, fn, len(fn,c_size_t), errno_local)
      if ( errno_local .ne. 0 ) then
        call mincf_free(cfg)
        error stop "confort: fatal error while reading the configuration"
      end if
    end if

  end subroutine

  subroutine mincf_get_or_error(cfg,key,buf,errno)

    interface
      subroutine c_mincf_get(cfg,key,key_sz,buf,sz,errno) &
        & bind(C,name='fort_mincf_get')
        use iso_c_binding
        import config
        type(config), intent(out) :: cfg
        integer(c_size_t), intent(in), value :: key_sz
        character(c_char), intent(in) :: key(key_sz)
        integer(c_size_t), intent(in), value :: sz
        character(c_char), intent(inout) :: buf(sz)
        integer(c_int), intent(out) :: errno
      end subroutine
    end interface

    type(config), intent(out) :: cfg
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
      if ( errno_local .ne. 0 ) then
        call mincf_free(cfg)
        error stop "confort: fatal error while reading the configuration"
      end if
    end if

  end subroutine

  logical function mincf_exists(cfg,key)
    interface
      subroutine c_mincf_get_exists(cfg,key,key_sz,errno) &
        & bind(C,name='fort_mincf_get_exists')
        use iso_c_binding
        import config
        type(config), intent(out) :: cfg
        integer(c_size_t), intent(in), value :: key_sz
        character(c_char), intent(in) :: key(key_sz)
        integer(c_int), intent(out) :: errno
      end subroutine
    end interface
    type(config), intent(out) :: cfg
    character(len=*), intent(in) :: key
    integer :: errno

    call c_mincf_get_exists(cfg, key, len(key,c_size_t), errno)

    mincf_exists = ( errno .eq. MINCF_OK )
  end function

  subroutine mincf_get_default(cfg,key,buf,defvalue,errno)
    interface
      subroutine c_mincf_get_default(cfg,key,key_sz,buf,sz,defvalue,defvalue_sz,errno) &
        & bind(C,name='fort_mincf_get_default')
        use iso_c_binding
        import config
        type(config), intent(out) :: cfg
        integer(c_size_t), intent(in), value :: key_sz, defvalue_sz
        character(c_char), intent(in) :: key(key_sz), defvalue(defvalue_sz)
        integer(c_size_t), intent(in), value :: sz
        character(c_char), intent(inout) :: buf(sz)
        integer(c_int), intent(out) :: errno
      end subroutine
    end interface
    type(config), intent(out) :: cfg
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


  subroutine mincf_print_error(errno,file,line)
    integer, intent(in) :: errno
    character(len=*), intent(in), optional :: file
    integer, intent(in), optional :: line

    character(len=128) :: prefix = "confort"

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

end module
