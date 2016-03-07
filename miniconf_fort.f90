
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

    implicit none

    !> Value indicating that key has not been found.
    integer, parameter :: MINCF_NOT_FOUND = -1

    ! type MINCF_CONF
    !     type(c_ptr) :: r
    ! end type

    interface
        !>  Reads the configuration from file.
        !!  @param fn String containing the filename.
        !! @return  Pointer to miniconf structure, containing the configuration or
        !! C_NULL_PTR in case of failure.
        !! @see mincf_free
        function mincf_readf(fn) result(r)
            import
            character (len=*) :: fn
            type(c_ptr) :: r
        end function

        !> Reads the configuration information from standard input. Particularly
        !! useful when creating bash scripts since the configuration can be derived
        !! to program directly using pipe.
        !! @return  Pointer to miniconf structure, containing the configuration or
        !! C_NULL_PTR in case of failure.
        !! @see mincf_free
        function mincf_read() result(r)
            import
            type(c_ptr) :: r
        end function

        !> Gets the value of key "key" from config "conf".
        !! @param conf    Pointer to miniconf structure, created ith mincf_read or mincf_readf.
        !! @param key   String containing the key
        !! @param buf   Destination buffer
        !! @return  Length of value, 0 if empty or MINCF_NOT_FOUND if not found.
        function mincf_get(conf,key,buf) result(r)
            import
            character (len=*), intent(in) :: key
            character (len=*), intent(out) :: buf
            type(c_ptr),intent(in),value :: conf
            integer :: r
        end function
        function mincf_get_rq(conf,key,buf) result(r)
            import
            character (len=*), intent(in) :: key
            character (len=*), intent(out) :: buf
            type(c_ptr),intent(in),value :: conf
            integer :: r
        end function

        !> Deallocates the memory reserved for config.
        !! WARNING: without this you get a memory leak!
        !! @param conf    Pointer to miniconf structure, created ith mincf_read or mincf_readf.
        !! @see mincf_read
        !! @see mincf_readf
        subroutine mincf_free(conf)
            import
            type(c_ptr),intent(in),value :: conf
        end subroutine
    end interface

end module
