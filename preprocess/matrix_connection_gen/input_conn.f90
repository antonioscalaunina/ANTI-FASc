program k223d
use lateration
use utils
!use typedef
!use makepdf
!use forparse
implicit none

  type(mesh) :: amesh

  real, parameter :: kilo = 1000.0000
  real, parameter :: pi=acos(-1.), mega = 10.e6
  integer :: merc_zone

  character (len=3) :: geo_zone
  integer :: num_cells                ! number of nodes per cell

  integer :: iway,UTM_PROJECTION_ZONE, nuc_mode, coord_type
  logical :: SUPPRESS_UTM_PROJECTION, logical_scenario
  real :: lon,lat
  real :: ran


  integer, parameter :: nit_zone=26

  character*200 :: fname, file_out

  open(nit_zone,file='param_zone_input.dat')
  read(nit_zone,*)
  read(nit_zone,*) geo_zone
  read(nit_zone,*)
  read(nit_zone,*) merc_zone 
  !if (parse_arg('geo zone',geo_zone,nit_zone) /= PARSE_OK) stop 'Geo zone missing/syntax error'
  !if (parse_arg('mercator',merc_zone,nit_zone) /= PARSE_OK) stop &
  !' No information about mercator zone/syntax error'
  close(nit_zone)
  amesh%geo_zone=geo_zone
  amesh%merc_zone=merc_zone


! read input data files
call readfile(amesh) ! reading nodal points and ameshents

 file_out= trim(amesh%geo_zone) // '_matrix_distance.bin'
  file_out=trim(file_out)
  open(13,file=file_out,form='unformatted',access='direct',recl=amesh%Nnodes*amesh%Nnodes*4)
!     do i=1,amesh%Nnodes
        write(13,rec=1) amesh%dist   !(i,1:amesh%Nnodes)
!     enddo
  close(13)

stop
end program k223d

!##########################################################################
subroutine readfile(amesh)
        use lateration
        type(mesh) :: amesh
        integer :: i, j, numb_area, numb_slip
        character(len=200) :: fnamef, file_matrix_string
        character :: dummy_char
        ! read in mesh from file
        call read_mesh(amesh)
        !call read_mesh_vtk(amesh)
        call allvsall2d(amesh)
        ! build connectivity between elements
        call tiConnect2d(amesh)


end subroutine readfile
!##############################################################################
subroutine read_mesh(amesh)
use lateration
use utils

type(mesh) :: amesh
integer :: i,j,id
character(len=60) :: str, fnamef
integer :: iway,UTM_PROJECTION_ZONE
logical :: SUPPRESS_UTM_PROJECTION
real :: lon,lat


!open(13,file='CA_mesh_15km.inp',form = 'formatted', action = 'read')
!open(13,file='CY_mesh_15km.inp',form = 'formatted', action = 'read')
fnamef = trim(amesh%geo_zone) // '_mesh_15km.inp'
open(13,file=fnamef,form = 'formatted', action = 'read')

iway = 0 ! convert from Lat/Long to UTM
SUPPRESS_UTM_PROJECTION = .false.

UTM_PROJECTION_ZONE = amesh%merc_zone
! skip header
do i = 1,9
       read(13,*)
enddo
! find end of nodal section & element section
i = 0
id = 0
do while ( id == 0 )
    read(13,*) str
    if (trim(str) == '**') then
        id = 1
    endif
    i = i+1
enddo
amesh%Nnodes = i-1
print*,'No. of Nodes ....',amesh%Nnodes
allocate(amesh%px(amesh%Nnodes),amesh%py(amesh%Nnodes),amesh%pz(amesh%Nnodes))

do i = 1,2
       read(13,*) str
enddo
id = 0
i = 0
do while ( id == 0 )
    read(13,*) str
    if (trim(str) == '**') then
        id = 1
    endif
    i = i+1
enddo
amesh%Ncells = i-1
print*,'No of cells......',amesh%Ncells
allocate(amesh%cell(amesh%Ncells,3))

!====== now read data in
rewind(13)
! skip header
do i = 1,9
       read(13,*)
enddo


do i = 1,amesh%Nnodes
       read(13,*) id,lon,lat,amesh%pz(i)
         call utm_geo(lon,lat,amesh%px(i),amesh%py(i),UTM_PROJECTION_ZONE,iway,SUPPRESS_UTM_PROJECTION)
enddo
!print*,amesh%px(amesh%Nnodes),amesh%py(amesh%Nnodes),amesh%pz(amesh%Nnodes)

! skip header
do i = 1,3
       read(13,*) str
enddo
! read element to vertices
do i = 1,amesh%Ncells
       read(13,*) id,amesh%cell(i,1),amesh%cell(i,2),amesh%cell(i,3)
enddo
!print*,id,amesh%cell(amesh%Ncells,1),amesh%cell(amesh%Ncells,2),amesh%cell(amesh%Ncells,3)
close(13)
end subroutine read_mesh
!##########################################################################################
subroutine tiConnect2d(amesh)
        use lateration
        use utils
type(mesh) :: amesh
integer,allocatable,dimension(:,:) :: fnodes,spNodeToNode,sorted,matchL,matchR
integer,allocatable,dimension(:) :: id,buf_EToE,buf_EToF,indices_d,indices
!integer,allocatable,dimension(:) :: id,buf_EToE,buf_EToF,imult,indices_d,indices

integer :: Nfaces
integer :: irow,krow,nsize,inx,i,j

Nfaces = 3
allocate (fnodes(Nfaces*amesh%Ncells,2))
! create list of all faces 1, then 2, & 3
fnodes(1:amesh%Ncells,:) = amesh%cell(:,1:2)
fnodes(amesh%Ncells+1:2*amesh%Ncells,:) = amesh%cell(:,2:3)
fnodes(2*amesh%Ncells+1:3*amesh%Ncells,:) = amesh%cell(:,(/ 3, 1 /))


!fnodes = sort(fnodes,2)-1;
nsize = Nfaces*amesh%Ncells
do irow = 1, nsize
         krow = minloc( fnodes( irow, : ),dim=1)
         if (krow == 2) then
              fnodes( irow, : ) = fnodes( irow, (/ 2, 1 /) )
         endif
enddo

fnodes = fnodes-1

! set up default element to element and element to faces connectivity
allocate(amesh%EToE(amesh%Ncells,3),amesh%EToF(amesh%Ncells,3))
do i = 1,amesh%Ncells
       amesh%EToE(i,:) = i
       amesh%EToF(i,:) = (/ 1 , 2, 3 /)
enddo

! uniquely number each set of three faces by their node numbers
allocate(id(Nfaces*amesh%Ncells),spNodeToNode(Nfaces*amesh%Ncells,Nfaces+1))
id = fnodes(:,1)*amesh%Nnodes + fnodes(:,2)+1
deallocate(fnodes)
allocate(buf_EToE(Nfaces*amesh%Ncells),buf_EToF(Nfaces*amesh%Ncells))
buf_EToE = reshape(amesh%EToE,(/ Nfaces*amesh%Ncells/))
buf_EToF = reshape(amesh%EToF,(/ Nfaces*amesh%Ncells/))

do i = 1,Nfaces*amesh%Ncells
       spNodeToNode(i,:) = (/ id(i), i, buf_EToE(i), buf_EToF(i) /)
enddo
deallocate(buf_EToE,buf_EToF,id)

! Now we sort by global face number.
!allocate(imult(Nfaces*K),sorted(Nfaces*K,Nfaces+1))
allocate(sorted(Nfaces*amesh%Ncells,Nfaces+1))

!call sort_rows(spNodeToNode,Nfaces*K,Nfaces+1,imult)
call sort_rows(spNodeToNode,Nfaces*amesh%Ncells,Nfaces+1)
sorted = spNodeToNode;!(imult,:)

! find matches in the sorted face list
allocate(indices_d(Nfaces*amesh%Ncells-1))

inx = 0;
do i = 1,Nfaces*amesh%Ncells-1
       if (sorted(i,1) == sorted(i+1,1)) then
           inx = inx+1
           indices_d(inx) = i
       endif
enddo


allocate(indices(inx))
indices = indices_d(1:inx)
deallocate(indices_d)

! make links reflexive

allocate(matchL(inx*2,4),matchR(inx*2,4))
matchL(1:inx,:) = sorted(indices,:)
matchL(inx+1:2*inx,:) = sorted(indices+1,:)

matchR(1:inx,:) = sorted(indices+1,:)
matchR(inx+1:2*inx,:) = sorted(indices,:)

! insert matches
do i = 1,inx*2

		if (matchL(i,2) <=  amesh%Ncells) then
	       amesh%EToE(matchL(i,2),1) = matchR(i,3);
    	   amesh%EToF(matchL(i,2),1) = matchR(i,4);
		elseif (amesh%Ncells <  matchL(i,2).and. matchL(i,2) <=  2*amesh%Ncells) then
	       amesh%EToE(matchL(i,2)-amesh%Ncells,2) = matchR(i,3);
    	   amesh%EToF(matchL(i,2)-amesh%Ncells,2) = matchR(i,4);
		elseif (amesh%Ncells*2 <  matchL(i,2).and. matchL(i,2) <=  3*amesh%Ncells) then
    	   amesh%EToE(matchL(i,2)-amesh%Ncells*2,3) = matchR(i,3);
    	   amesh%EToF(matchL(i,2)-amesh%Ncells*2,3) = matchR(i,4);
    	elseif (amesh%Ncells*2 <  matchL(i,2).and. matchL(i,2) <=  3*amesh%Ncells) then
    	   amesh%EToE(matchL(i,2)-amesh%Ncells*3,4) = matchR(i,3);
    	   amesh%EToF(matchL(i,2)-amesh%Ncells*3,4) = matchR(i,4);
		endif
enddo

open(1000,file='EToE.dat',status='unknown')
do i=1,amesh%Ncells
   write(1000,"(3I7)") amesh%EToE(i,:)
end do
close(1000)



deallocate(matchR,matchL)
return
end subroutine tiConnect2d
