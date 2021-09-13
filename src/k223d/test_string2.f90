program test_string2

implicit none

integer :: i
integer, parameter :: index_a=7808
character (len=14) :: stringa
character (len=5) :: stringa_aux

write(stringa_aux,"(I5)") index_a
print*, stringa_aux
stringa='"(' // trim(stringa_aux) // 'F10.6)"'
print*,stringa
return
end program
