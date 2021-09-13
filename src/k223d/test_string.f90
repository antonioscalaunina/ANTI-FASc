program test_string

implicit none

integer :: i
character (len=9), allocatable, dimension(:) :: index_string
character (len=9) :: k
character :: dummy
integer, allocatable, dimension(:) :: numb_gauss

allocate(index_string(920),numb_gauss(920))

open(11,file='index_file.dat',status='unknown',action='read')

read(11,*)

do i=1,920
   read(11,"(A,A,I1)") index_string(i),dummy, numb_gauss(i)
   k=index_string(i)
   print*,i, k(1:5), numb_gauss(i)
enddo

close(11)

deallocate(index_string,numb_gauss)
return
end program
