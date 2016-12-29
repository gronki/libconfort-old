module tests_common


contains

    subroutine test0(file,line,l,name)
        character(len=*), intent(in) :: file,name
        integer, intent(in) :: line
        logical, intent(in) :: l
        character(len=*), parameter :: fmt = '(A," has ",A," the test (",I0,"): ",A)'

        if (l) then
            write (*,fmt)  file,  "PASSED", line, name
        else
            write (*,fmt)  file,  "FAILED", line, name
        end if
    end subroutine

    logical function ftest0(file,line,l,name)
        character(len=*), intent(in) :: file,name
        integer, intent(in) :: line
        logical, intent(in) :: l
        character(len=*), parameter :: fmt = '(A," has ",A," the test (",I0,"): ",A)'

        if (l) then
            write (*,fmt)  file,  "PASSED", line, name
        else
            write (*,fmt)  file,  "FAILED", line, name
        end if

        ftest0 = l
    end function

end module
