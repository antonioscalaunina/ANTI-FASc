module utils

Integer, Parameter :: kdp = selected_real_kind(15)
public :: mrgrnk,find,erasedupli,sort_rows
private :: kdp

private :: R_mrgrnk, I_mrgrnk, D_mrgrnk
private :: find_1dI,find_1dR, find_2d ,find_2dI
private :: R_nearless, I_nearless, D_nearless, nearless

interface nearless
  module procedure D_nearless, R_nearless, I_nearless
end interface nearless


interface mrgrnk
  module procedure D_mrgrnk, R_mrgrnk, I_mrgrnk
end interface mrgrnk

interface find
         module procedure find_1dI,find_1dR, find_2dR,find_2dI
end interface


contains

  
!=================================================
! arrange array 'a' in ascending order
subroutine sort_rows(a,n,m)
implicit none
integer,intent(in) :: n,m
integer, dimension(n,m),intent(inout) :: a
integer, dimension(n,m) :: a_dummy
integer, dimension(n) :: idx
integer :: i


a_dummy = a

do i = 1,n
! descending order
!  idx(i) = maxloc(a_dummy(:,1),1)
!  a_dummy(idx(i),1) = minval(a_dummy(:,1),1)-1
  idx(i) = minloc(a_dummy(:,1),1)
  a_dummy(idx(i),1) = maxval(a_dummy(:,1),1)+1
enddo

a = a(idx,:)

end subroutine sort_rows
!=================================================

Function D_nearless (XVAL) result (D_nl)
!  Nearest value less than given value
! __________________________________________________________
       Double precision, Intent (In) :: XVAL
       Double precision :: D_nl

!      Real (kind=kdp), Intent (In) :: XVAL
!      Real (kind=kdp) :: D_nl
! __________________________________________________________
      D_nl = nearest (XVAL, -1.0_kdp)
      return
!
End Function D_nearless
Function R_nearless (XVAL) result (R_nl)
!  Nearest value less than given value
! __________________________________________________________
      Real, Intent (In) :: XVAL
      Real :: R_nl
! __________________________________________________________
      R_nl = nearest (XVAL, -1.0)
      return
!
End Function R_nearless
Function I_nearless (XVAL) result (I_nl)
!  Nearest value less than given value
! __________________________________________________________
      Integer, Intent (In) :: XVAL
      Integer :: I_nl
! __________________________________________________________
      I_nl = XVAL - 1
      return
!
End Function I_nearless
!========================================================
!Module m_mrgrnk
!take from http://www.fortran-2000.com/rank/mrgrnk.f90
Subroutine D_mrgrnk (XDONT, IRNGT)
! __________________________________________________________
!   MRGRNK = Merge-sort ranking of an array
!   For performance reasons, the first 2 passes are taken
!   out of the standard loop, and use dedicated coding.
! __________________________________________________________
! __________________________________________________________
      Double Precision, Dimension (:), Intent (In) :: XDONT
!      Real (kind=kdp), Dimension (:), Intent (In) :: XDONT
      Integer, Dimension (:), Intent (Out) :: IRNGT
! __________________________________________________________
      Double Precision :: XVALA, XVALB
!      Real (kind=kdp) :: XVALA, XVALB
!
      Integer, Dimension (SIZE(IRNGT)) :: JWRKT
      Integer :: LMTNA, LMTNC, IRNG1, IRNG2
      Integer :: NVAL, IIND, IWRKD, IWRK, IWRKF, JINDA, IINDA, IINDB
!
      NVAL = Min (SIZE(XDONT), SIZE(IRNGT))
      Select Case (NVAL)
      Case (:0)
         Return
      Case (1)
         IRNGT (1) = 1
         Return
      Case Default
         Continue
      End Select
!
!  Fill-in the index array, creating ordered couples
!
      Do IIND = 2, NVAL, 2
         If (XDONT(IIND-1) <= XDONT(IIND)) Then
            IRNGT (IIND-1) = IIND - 1
            IRNGT (IIND) = IIND
         Else
            IRNGT (IIND-1) = IIND
            IRNGT (IIND) = IIND - 1
         End If
      End Do
      If (Modulo(NVAL, 2) /= 0) Then
         IRNGT (NVAL) = NVAL
      End If
!
!  We will now have ordered subsets A - B - A - B - ...
!  and merge A and B couples into     C   -   C   - ...
!
      LMTNA = 2
      LMTNC = 4
!
!  First iteration. The length of the ordered subsets goes from 2 to 4
!
      Do
         If (NVAL <= 2) Exit
!
!   Loop on merges of A and B into C
!
         Do IWRKD = 0, NVAL - 1, 4
            If ((IWRKD+4) > NVAL) Then
               If ((IWRKD+2) >= NVAL) Exit
!
!   1 2 3
!
               If (XDONT(IRNGT(IWRKD+2)) <= XDONT(IRNGT(IWRKD+3))) Exit
!
!   1 3 2
!
               If (XDONT(IRNGT(IWRKD+1)) <= XDONT(IRNGT(IWRKD+3))) Then
                  IRNG2 = IRNGT (IWRKD+2)
                  IRNGT (IWRKD+2) = IRNGT (IWRKD+3)
                  IRNGT (IWRKD+3) = IRNG2
!
!   3 1 2
!
               Else
                  IRNG1 = IRNGT (IWRKD+1)
                  IRNGT (IWRKD+1) = IRNGT (IWRKD+3)
                  IRNGT (IWRKD+3) = IRNGT (IWRKD+2)
                  IRNGT (IWRKD+2) = IRNG1
               End If
               Exit
            End If
!
!   1 2 3 4
!
            If (XDONT(IRNGT(IWRKD+2)) <= XDONT(IRNGT(IWRKD+3))) Cycle
!
!   1 3 x x
!
            If (XDONT(IRNGT(IWRKD+1)) <= XDONT(IRNGT(IWRKD+3))) Then
               IRNG2 = IRNGT (IWRKD+2)
               IRNGT (IWRKD+2) = IRNGT (IWRKD+3)
               If (XDONT(IRNG2) <= XDONT(IRNGT(IWRKD+4))) Then
!   1 3 2 4
                  IRNGT (IWRKD+3) = IRNG2
               Else
!   1 3 4 2
                  IRNGT (IWRKD+3) = IRNGT (IWRKD+4)
                  IRNGT (IWRKD+4) = IRNG2
               End If
!
!   3 x x x
!
            Else
               IRNG1 = IRNGT (IWRKD+1)
               IRNG2 = IRNGT (IWRKD+2)
               IRNGT (IWRKD+1) = IRNGT (IWRKD+3)
               If (XDONT(IRNG1) <= XDONT(IRNGT(IWRKD+4))) Then
                  IRNGT (IWRKD+2) = IRNG1
                  If (XDONT(IRNG2) <= XDONT(IRNGT(IWRKD+4))) Then
!   3 1 2 4
                     IRNGT (IWRKD+3) = IRNG2
                  Else
!   3 1 4 2
                     IRNGT (IWRKD+3) = IRNGT (IWRKD+4)
                     IRNGT (IWRKD+4) = IRNG2
                  End If
               Else
!   3 4 1 2
                  IRNGT (IWRKD+2) = IRNGT (IWRKD+4)
                  IRNGT (IWRKD+3) = IRNG1
                  IRNGT (IWRKD+4) = IRNG2
               End If
            End If
         End Do
!
!  The Cs become As and Bs
!
         LMTNA = 4
         Exit
      End Do
!
!  Iteration loop. Each time, the length of the ordered subsets
!  is doubled.
!
      Do
         If (LMTNA >= NVAL) Exit
         IWRKF = 0
         LMTNC = 2 * LMTNC
!
!   Loop on merges of A and B into C
!
         Do
            IWRK = IWRKF
            IWRKD = IWRKF + 1
            JINDA = IWRKF + LMTNA
            IWRKF = IWRKF + LMTNC
            If (IWRKF >= NVAL) Then
               If (JINDA >= NVAL) Exit
               IWRKF = NVAL
            End If
            IINDA = 1
            IINDB = JINDA + 1
!
!   Shortcut for the case when the max of A is smaller
!   than the min of B. This line may be activated when the
!   initial set is already close to sorted.
!
!          IF (XDONT(IRNGT(JINDA)) <= XDONT(IRNGT(IINDB))) CYCLE
!
!  One steps in the C subset, that we build in the final rank array
!
!  Make a copy of the rank array for the merge iteration
!
            JWRKT (1:LMTNA) = IRNGT (IWRKD:JINDA)
!
            XVALA = XDONT (JWRKT(IINDA))
            XVALB = XDONT (IRNGT(IINDB))
!
            Do
               IWRK = IWRK + 1
!
!  We still have unprocessed values in both A and B
!
               If (XVALA > XVALB) Then
                  IRNGT (IWRK) = IRNGT (IINDB)
                  IINDB = IINDB + 1
                  If (IINDB > IWRKF) Then
!  Only A still with unprocessed values
                     IRNGT (IWRK+1:IWRKF) = JWRKT (IINDA:LMTNA)
                     Exit
                  End If
                  XVALB = XDONT (IRNGT(IINDB))
               Else
                  IRNGT (IWRK) = JWRKT (IINDA)
                  IINDA = IINDA + 1
                  If (IINDA > LMTNA) Exit! Only B still with unprocessed values
                  XVALA = XDONT (JWRKT(IINDA))
               End If
!
            End Do
         End Do
!
!  The Cs become As and Bs
!
         LMTNA = 2 * LMTNA
      End Do
!
      Return
!
End Subroutine D_mrgrnk

Subroutine R_mrgrnk (XDONT, IRNGT)
! __________________________________________________________
!   MRGRNK = Merge-sort ranking of an array
!   For performance reasons, the first 2 passes are taken
!   out of the standard loop, and use dedicated coding.
! __________________________________________________________
! _________________________________________________________
      Real, Dimension (:), Intent (In) :: XDONT
      Integer, Dimension (:), Intent (Out) :: IRNGT
! __________________________________________________________
      Real :: XVALA, XVALB
!
      Integer, Dimension (SIZE(IRNGT)) :: JWRKT
      Integer :: LMTNA, LMTNC, IRNG1, IRNG2
      Integer :: NVAL, IIND, IWRKD, IWRK, IWRKF, JINDA, IINDA, IINDB
!
      NVAL = Min (SIZE(XDONT), SIZE(IRNGT))
      Select Case (NVAL)
      Case (:0)
         Return
      Case (1)
         IRNGT (1) = 1
         Return
      Case Default
         Continue
      End Select
!
!  Fill-in the index array, creating ordered couples
!
      Do IIND = 2, NVAL, 2
         If (XDONT(IIND-1) <= XDONT(IIND)) Then
            IRNGT (IIND-1) = IIND - 1
            IRNGT (IIND) = IIND
         Else
            IRNGT (IIND-1) = IIND
            IRNGT (IIND) = IIND - 1
         End If
      End Do
      If (Modulo(NVAL, 2) /= 0) Then
         IRNGT (NVAL) = NVAL
      End If
!
!  We will now have ordered subsets A - B - A - B - ...
!  and merge A and B couples into     C   -   C   - ...
!
      LMTNA = 2
      LMTNC = 4
!
!  First iteration. The length of the ordered subsets goes from 2 to 4
!
      Do
         If (NVAL <= 2) Exit
!
!   Loop on merges of A and B into C
!
         Do IWRKD = 0, NVAL - 1, 4
            If ((IWRKD+4) > NVAL) Then
               If ((IWRKD+2) >= NVAL) Exit
!
!   1 2 3
!
               If (XDONT(IRNGT(IWRKD+2)) <= XDONT(IRNGT(IWRKD+3))) Exit
!
!   1 3 2
!
               If (XDONT(IRNGT(IWRKD+1)) <= XDONT(IRNGT(IWRKD+3))) Then
                  IRNG2 = IRNGT (IWRKD+2)
                  IRNGT (IWRKD+2) = IRNGT (IWRKD+3)
                  IRNGT (IWRKD+3) = IRNG2
!
!   3 1 2
!
               Else
                  IRNG1 = IRNGT (IWRKD+1)
                  IRNGT (IWRKD+1) = IRNGT (IWRKD+3)
                  IRNGT (IWRKD+3) = IRNGT (IWRKD+2)
                  IRNGT (IWRKD+2) = IRNG1
               End If
               Exit
            End If
!
!   1 2 3 4
!
            If (XDONT(IRNGT(IWRKD+2)) <= XDONT(IRNGT(IWRKD+3))) Cycle
!
!   1 3 x x
!
            If (XDONT(IRNGT(IWRKD+1)) <= XDONT(IRNGT(IWRKD+3))) Then
               IRNG2 = IRNGT (IWRKD+2)
               IRNGT (IWRKD+2) = IRNGT (IWRKD+3)
               If (XDONT(IRNG2) <= XDONT(IRNGT(IWRKD+4))) Then
!   1 3 2 4
                  IRNGT (IWRKD+3) = IRNG2
               Else
!   1 3 4 2
                  IRNGT (IWRKD+3) = IRNGT (IWRKD+4)
                  IRNGT (IWRKD+4) = IRNG2
               End If
!
!   3 x x x
!
            Else
               IRNG1 = IRNGT (IWRKD+1)
               IRNG2 = IRNGT (IWRKD+2)
               IRNGT (IWRKD+1) = IRNGT (IWRKD+3)
               If (XDONT(IRNG1) <= XDONT(IRNGT(IWRKD+4))) Then
                  IRNGT (IWRKD+2) = IRNG1
                  If (XDONT(IRNG2) <= XDONT(IRNGT(IWRKD+4))) Then
!   3 1 2 4
                     IRNGT (IWRKD+3) = IRNG2
                  Else
!   3 1 4 2
                     IRNGT (IWRKD+3) = IRNGT (IWRKD+4)
                     IRNGT (IWRKD+4) = IRNG2
                  End If
               Else
!   3 4 1 2
                  IRNGT (IWRKD+2) = IRNGT (IWRKD+4)
                  IRNGT (IWRKD+3) = IRNG1
                  IRNGT (IWRKD+4) = IRNG2
               End If
            End If
         End Do
!
!  The Cs become As and Bs
!
         LMTNA = 4
         Exit
      End Do
!
!  Iteration loop. Each time, the length of the ordered subsets
!  is doubled.
!
      Do
         If (LMTNA >= NVAL) Exit
         IWRKF = 0
         LMTNC = 2 * LMTNC
!
!   Loop on merges of A and B into C
!
         Do
            IWRK = IWRKF
            IWRKD = IWRKF + 1
            JINDA = IWRKF + LMTNA
            IWRKF = IWRKF + LMTNC
            If (IWRKF >= NVAL) Then
               If (JINDA >= NVAL) Exit
               IWRKF = NVAL
            End If
            IINDA = 1
            IINDB = JINDA + 1
!
!   Shortcut for the case when the max of A is smaller
!   than the min of B. This line may be activated when the
!   initial set is already close to sorted.
!
!          IF (XDONT(IRNGT(JINDA)) <= XDONT(IRNGT(IINDB))) CYCLE
!
!  One steps in the C subset, that we build in the final rank array
!
!  Make a copy of the rank array for the merge iteration
!
            JWRKT (1:LMTNA) = IRNGT (IWRKD:JINDA)
!
            XVALA = XDONT (JWRKT(IINDA))
            XVALB = XDONT (IRNGT(IINDB))
!
            Do
               IWRK = IWRK + 1
!
!  We still have unprocessed values in both A and B
!
               If (XVALA > XVALB) Then
                  IRNGT (IWRK) = IRNGT (IINDB)
                  IINDB = IINDB + 1
                  If (IINDB > IWRKF) Then
!  Only A still with unprocessed values
                     IRNGT (IWRK+1:IWRKF) = JWRKT (IINDA:LMTNA)
                     Exit
                  End If
                  XVALB = XDONT (IRNGT(IINDB))
               Else
                  IRNGT (IWRK) = JWRKT (IINDA)
                  IINDA = IINDA + 1
                  If (IINDA > LMTNA) Exit! Only B still with unprocessed values
                  XVALA = XDONT (JWRKT(IINDA))
               End If
!
            End Do
         End Do
!
!  The Cs become As and Bs
!
         LMTNA = 2 * LMTNA
      End Do
!
      Return
!
End Subroutine R_mrgrnk
Subroutine I_mrgrnk (XDONT, IRNGT)
! __________________________________________________________
!   MRGRNK = Merge-sort ranking of an array
!   For performance reasons, the first 2 passes are taken
!   out of the standard loop, and use dedicated coding.
! __________________________________________________________
! __________________________________________________________
      Integer, Dimension (:), Intent (In)  :: XDONT
      Integer, Dimension (:), Intent (Out) :: IRNGT
! __________________________________________________________
      Integer :: XVALA, XVALB
!
      Integer, Dimension (SIZE(IRNGT)) :: JWRKT
      Integer :: LMTNA, LMTNC, IRNG1, IRNG2
      Integer :: NVAL, IIND, IWRKD, IWRK, IWRKF, JINDA, IINDA, IINDB
!
      NVAL = Min (SIZE(XDONT), SIZE(IRNGT))
      Select Case (NVAL)
      Case (:0)
         Return
      Case (1)
         IRNGT (1) = 1
         Return
      Case Default
         Continue
      End Select
!
!  Fill-in the index array, creating ordered couples
!
      Do IIND = 2, NVAL, 2
         If (XDONT(IIND-1) <= XDONT(IIND)) Then
            IRNGT (IIND-1) = IIND - 1
            IRNGT (IIND) = IIND
         Else
            IRNGT (IIND-1) = IIND
            IRNGT (IIND) = IIND - 1
         End If
      End Do
      If (Modulo(NVAL, 2) /= 0) Then
         IRNGT (NVAL) = NVAL
      End If
!
!  We will now have ordered subsets A - B - A - B - ...
!  and merge A and B couples into     C   -   C   - ...
!
      LMTNA = 2
      LMTNC = 4
!
!  First iteration. The length of the ordered subsets goes from 2 to 4
!
      Do
         If (NVAL <= 2) Exit
!
!   Loop on merges of A and B into C
!
         Do IWRKD = 0, NVAL - 1, 4
            If ((IWRKD+4) > NVAL) Then
               If ((IWRKD+2) >= NVAL) Exit
!
!   1 2 3
!
               If (XDONT(IRNGT(IWRKD+2)) <= XDONT(IRNGT(IWRKD+3))) Exit
!
!   1 3 2
!
               If (XDONT(IRNGT(IWRKD+1)) <= XDONT(IRNGT(IWRKD+3))) Then
                  IRNG2 = IRNGT (IWRKD+2)
                  IRNGT (IWRKD+2) = IRNGT (IWRKD+3)
                  IRNGT (IWRKD+3) = IRNG2
!
!   3 1 2
!
               Else
                  IRNG1 = IRNGT (IWRKD+1)
                  IRNGT (IWRKD+1) = IRNGT (IWRKD+3)
                  IRNGT (IWRKD+3) = IRNGT (IWRKD+2)
                  IRNGT (IWRKD+2) = IRNG1
               End If
               Exit
            End If
!
!   1 2 3 4
!
            If (XDONT(IRNGT(IWRKD+2)) <= XDONT(IRNGT(IWRKD+3))) Cycle
!
!   1 3 x x
!
            If (XDONT(IRNGT(IWRKD+1)) <= XDONT(IRNGT(IWRKD+3))) Then
               IRNG2 = IRNGT (IWRKD+2)
               IRNGT (IWRKD+2) = IRNGT (IWRKD+3)
               If (XDONT(IRNG2) <= XDONT(IRNGT(IWRKD+4))) Then
!   1 3 2 4
                  IRNGT (IWRKD+3) = IRNG2
               Else
!   1 3 4 2
                  IRNGT (IWRKD+3) = IRNGT (IWRKD+4)
                  IRNGT (IWRKD+4) = IRNG2
               End If
!
!   3 x x x
!
            Else
               IRNG1 = IRNGT (IWRKD+1)
               IRNG2 = IRNGT (IWRKD+2)
               IRNGT (IWRKD+1) = IRNGT (IWRKD+3)
               If (XDONT(IRNG1) <= XDONT(IRNGT(IWRKD+4))) Then
                  IRNGT (IWRKD+2) = IRNG1
                  If (XDONT(IRNG2) <= XDONT(IRNGT(IWRKD+4))) Then
!   3 1 2 4
                     IRNGT (IWRKD+3) = IRNG2
                  Else
!   3 1 4 2
                     IRNGT (IWRKD+3) = IRNGT (IWRKD+4)
                     IRNGT (IWRKD+4) = IRNG2
                  End If
               Else
!   3 4 1 2
                  IRNGT (IWRKD+2) = IRNGT (IWRKD+4)
                  IRNGT (IWRKD+3) = IRNG1
                  IRNGT (IWRKD+4) = IRNG2
               End If
            End If
         End Do
!
!  The Cs become As and Bs
!
         LMTNA = 4
         Exit
      End Do
!
!  Iteration loop. Each time, the length of the ordered subsets
!  is doubled.
!
      Do
         If (LMTNA >= NVAL) Exit
         IWRKF = 0
         LMTNC = 2 * LMTNC
!
!   Loop on merges of A and B into C
!
         Do
            IWRK = IWRKF
            IWRKD = IWRKF + 1
            JINDA = IWRKF + LMTNA
            IWRKF = IWRKF + LMTNC
            If (IWRKF >= NVAL) Then
               If (JINDA >= NVAL) Exit
               IWRKF = NVAL
            End If
            IINDA = 1
            IINDB = JINDA + 1
!
!   Shortcut for the case when the max of A is smaller
!   than the min of B. This line may be activated when the
!   initial set is already close to sorted.
!
!          IF (XDONT(IRNGT(JINDA)) <= XDONT(IRNGT(IINDB))) CYCLE
!
!  One steps in the C subset, that we build in the final rank array
!
!  Make a copy of the rank array for the merge iteration
!
            JWRKT (1:LMTNA) = IRNGT (IWRKD:JINDA)
!
            XVALA = XDONT (JWRKT(IINDA))
            XVALB = XDONT (IRNGT(IINDB))
!
            Do
               IWRK = IWRK + 1
!
!  We still have unprocessed values in both A and B
!
               If (XVALA > XVALB) Then
                  IRNGT (IWRK) = IRNGT (IINDB)
                  IINDB = IINDB + 1
                  If (IINDB > IWRKF) Then
!  Only A still with unprocessed values
                     IRNGT (IWRK+1:IWRKF) = JWRKT (IINDA:LMTNA)
                     Exit
                  End If
                  XVALB = XDONT (IRNGT(IINDB))
               Else
                  IRNGT (IWRK) = JWRKT (IINDA)
                  IINDA = IINDA + 1
                  If (IINDA > LMTNA) Exit! Only B still with unprocessed values
                  XVALA = XDONT (JWRKT(IINDA))
               End If
!
            End Do
         End Do
!
!  The Cs become As and Bs
!
         LMTNA = 2 * LMTNA
      End Do
!
      Return
!
End Subroutine I_mrgrnk
!end module m_mrgrnk
!========================================================
subroutine find_1dR(array,condt,target_value,idx)
implicit none
real,dimension(:),intent(in) :: array
integer,allocatable,dimension(:), intent(out) :: idx
integer,allocatable,dimension(:) :: loc
character(2),intent(in) :: condt
integer :: i,n,target_value,inx

n = size(array)
allocate(loc(n))
loc = 0
inx = 0
if (condt == '==') then
       do i = 1,n
              if(array(i) == target_value) then
                     inx = inx+1
                     loc(inx) = i
              endif
       enddo
else
       do i = 1,n
              if(array(i) /= target_value) then
                     inx = inx+1
                     loc(inx) = i
              endif
       enddo
endif


if (inx > 0) then  ! target_value is in array
	allocate(idx(inx))
	idx = loc(1:inx)
else   ! target_value is not in array
	allocate(idx(1))
	idx = -1 !loc(1)

endif
deallocate(loc)

return

end subroutine find_1dR
!========================================================
!========================================================
subroutine find_1dI(array,condt,target_value,idx)
implicit none
integer,dimension(:),intent(in) :: array
integer,allocatable,dimension(:), intent(out) :: idx
integer,allocatable,dimension(:) :: loc
integer :: i,n,target_value,inx
character(2),intent(in) :: condt

n = size(array,1)
allocate(loc(n))
loc = 0
inx = 0

if (condt == '==') then
       do i = 1,n
              if(array(i) == target_value) then
                     inx = inx+1
                     loc(inx) = i
              endif
       enddo
else
       do i = 1,n
              if(array(i) /= target_value) then
                     inx = inx+1
                     loc(inx) = i
              endif
       enddo
endif


if (inx > 0) then  ! target_value is in array
	allocate(idx(inx))
	idx = loc(1:inx)
else   ! target_value is not in array
	allocate(idx(1))
	idx = -1 !loc(1)

endif
deallocate(loc)

return

end subroutine find_1dI
!========================================================
subroutine find_2dR(array,condt,target_value,idx,jdx)
implicit none
real,dimension(:,:),intent(in) :: array
integer,allocatable,dimension(:), intent(out) :: idx,jdx
integer,allocatable,dimension(:) :: loc_i,loc_j
real :: target_value
integer :: i,j,n,m,inx
character(2),intent(in) :: condt

n = size(array,1)
m = size(array,2)

allocate(loc_i(n*m),loc_j(n*m))

loc_i(:) = 0
loc_j(:) = 0

inx = 0
if (condt == '==') then
       do j = 1,m
              do i = 1,n
                     if(array(i,j) == target_value) then
                            inx = inx+1
                            loc_i(inx) = i
                            loc_j(inx) = j
                     endif
              enddo
       enddo
else
       do j = 1,m
              do i = 1,n
                     if(array(i,j) /= target_value) then
                            inx = inx+1
                            loc_i(inx) = i
                            loc_j(inx) = j
                     endif
              enddo
       enddo
endif

if (inx > 0) then  ! target_value is in array
	allocate(idx(inx))
	idx = loc_i(1:inx)

	allocate(jdx(inx))
	jdx = loc_j(1:inx)

else   ! target_value is not in array
	allocate(idx(1))
	idx = -1 !loc_i(1)

	allocate(jdx(1))
	jdx = -1 !loc_j(1)

endif
deallocate(loc_i,loc_j)

return
end subroutine find_2dR
!========================================================
!========================================================
subroutine find_2dI(array,condt,target_value,idx,jdx)
implicit none
integer,dimension(:,:),intent(in) :: array
integer,allocatable,dimension(:), intent(out) :: idx,jdx
integer,allocatable,dimension(:) :: loc_i,loc_j
integer :: i,j,n,m,target_value,inx
character(2),intent(in) :: condt

n = size(array,1)
m = size(array,2)

allocate(loc_i(n*m),loc_j(n*m))

loc_i(:) = 0
loc_j(:) = 0

inx = 0
if (condt == '==') then
       do j = 1,m
              do i = 1,n
                     if(array(i,j) == target_value) then
                            inx = inx+1
                            loc_i(inx) = i
                            loc_j(inx) = j
                     endif
              enddo
       enddo
else
       do j = 1,m
              do i = 1,n
                     if(array(i,j) /= target_value) then
                            inx = inx+1
                            loc_i(inx) = i
                            loc_j(inx) = j
                     endif
              enddo
       enddo
endif


if (inx > 0) then  ! target_value is in array
	allocate(idx(inx))
	idx = loc_i(1:inx)

	allocate(jdx(inx))
	jdx = loc_j(1:inx)

else   ! target_value is not in array
	allocate(idx(1))
	idx = -1 !loc_i(1)

	allocate(jdx(1))
	jdx = -1 !loc_j(1)

endif
deallocate(loc_i,loc_j)

return
end subroutine find_2dI
!========================================================
subroutine erasedupli(val,nv,nnv)
   integer :: nv,nnv
   integer, dimension(nv) :: val
   logical, dimension(nv) :: dp
   integer :: i,j

   dp=.false.
   do i=1,nv-1
      if (val(i) == 0) dp(i)=.true.
      if (dp(i)) cycle
      do j=i+1,nv
         if (.not.dp(j)) dp(j)=(val(i) == val(j))
      enddo
   enddo
!   do i=1,nv
!      write(*,*) val(i),dp(i)
!   enddo
   i=1
   nnv=nv
   do while (i <= nnv)
      if (dp(i)) then
         do j=i,nnv-1
            val(j)=val(j+1)
            dp(j)=dp(j+1)
         enddo
         nnv=nnv-1
      else
         i=i+1
      endif
   enddo

   return
end subroutine erasedupli
!========================================================
subroutine utm_geo(rlon,rlat,rx,ry,UTM_PROJECTION_ZONE,iway,SUPPRESS_UTM_PROJECTION)

  ! convert geodetic longitude and latitude to UTM, and back
  ! use iway = ILONGLAT2UTM for long/lat to UTM, IUTM2LONGLAT for UTM to
  ! lat/long
  ! a list of UTM zones of the world is available at
  ! www.dmap.co.uk/utmworld.htm
    implicit none
  !!  include "constants.h"

  !
  !-----CAMx v2.03
  !
  !     UTM_GEO performs UTM to geodetic (long/lat) translation, and back.
  !
  !     This is a Fortran version of the BASIC program "Transverse
  !     Mercator
  !     Conversion", Copyright 1986, Norman J. Berls (Stefan Musarra,
  !     2/94)
  !     Based on algorithm taken from "Map Projections Used by the USGS"
  !     by John P. Snyder, Geological Survey Bulletin 1532, USDI.
  !
  !     Input/Output arguments:
  !
  !        rlon                  Longitude (deg, negative for West)
  !        rlat                  Latitude (deg)
  !        rx                    UTM easting (m)
  !        ry                    UTM northing (m)
  !        UTM_PROJECTION_ZONE   UTM zone
  !        iway                  Conversion type
  !                              ILONGLAT2UTM = geodetic to UTM
  !                              IUTM2LONGLAT = UTM to geodetic
  !
    integer UTM_PROJECTION_ZONE,iway
    logical SUPPRESS_UTM_PROJECTION
!    double precision rx,ry,rlon,rlat
!    double precision,parameter :: pi = 3.14159265358979323846264338327950
!    double precision, parameter :: degrad=pi/180.d0, raddeg=180.d0/pi
!    double precision, parameter :: semimaj=6378206.4d0,semimin=6356583.8d0
!    double precision, parameter :: scfa=0.9996d0
    real rx,ry,rlon,rlat
    real,parameter :: pi = 3.14159265358979323846264338327950
    real, parameter :: degrad=pi/180., raddeg=180./pi
    real, parameter :: semimaj=6378206.4,semimin=6356583.8
    real, parameter :: scfa=0.9996

  ! some extracts about UTM:
  !
  ! There are 60 longitudinal projection zones numbered 1 to 60 starting
  ! at 180Â°W.
  ! Each of these zones is 6 degrees wide, apart from a few exceptions
  ! around Norway and Svalbard.
  ! There are 20 latitudinal zones spanning the latitudes 80Â°S to 84Â°N
  ! and denoted
  ! by the letters C to X, ommitting the letter O.
  ! Each of these is 8 degrees south-north, apart from zone X which is 12
  ! degrees south-north.
  !
  ! To change the UTM zone and the hemisphere in which the
  ! calculations are carried out, need to change the fortran code and
  ! recompile. The UTM zone is described
  ! actually by the central meridian of that zone, i.e. the longitude at
  ! the midpoint of the zone, 3 degrees
  ! from either zone boundary.
  ! To change hemisphere need to change the "north" variable:
  !  - north=0 for northern hemisphere and
  !  - north=10000000 (10000km) for southern hemisphere. values must be in
  !  metres i.e. north=10000000.
  !
  ! Note that the UTM grids are actually Mercators which
  ! employ the standard UTM scale factor 0.9996 and set the
  ! Easting Origin to 500,000;
  ! the Northing origin in the southern
  ! hemisphere is kept at 0 rather than set to 10,000,000
  ! and this gives a uniform scale across the equator if the
  ! normal convention of selecting the Base Latitude (origin)
  ! at the equator (0 deg.) is followed.  Northings are
  ! positive in the northern hemisphere and negative in the
  ! southern hemisphere.
     real, parameter :: north=10000000 ! in southern hemisphere   !north=0.d0
     real, parameter :: east=500000.
     real e2,e4,e6,ep2,xx,yy,dlat,dlon,zone,cm,cmr,delam
     real f1,f2,f3,f4,rm,rn,t,c,a,e1,u,rlat1,dlat1,c1,t1,rn1,r1,d
     real rx_save,ry_save,rlon_save,rlat_save
!    double precision, parameter :: north=10000.d3 ! in southern hemisphere   !north=0.d0
!    double precision, parameter :: east=500000.d0
!    double precision e2,e4,e6,ep2,xx,yy,dlat,dlon,zone,cm,cmr,delam
!    double precision f1,f2,f3,f4,rm,rn,t,c,a,e1,u,rlat1,dlat1,c1,t1,rn1,r1,d
!    double precision rx_save,ry_save,rlon_save,rlat_save

  ! flag for projection from latitude/longitude to UTM, and back
    integer, parameter :: ILONGLAT2UTM = 0, IUTM2LONGLAT = 1


    ! checks if conversion to utm has to be done
    if(SUPPRESS_UTM_PROJECTION) then
      if (iway == ILONGLAT2UTM) then
        rx = rlon
        ry = rlat
      else
        rlon = rx
        rlat = ry
      endif
      return
    endif

  ! save original parameters
    rlon_save = rlon
    rlat_save = rlat
    rx_save = rx
    ry_save = ry

    xx = 0.0
    yy = 0.0
    dlat = 0.0
    dlon = 0.0
!    xx = 0.d0
!    yy = 0.d0
!    dlat = 0.d0
!    dlon = 0.d0

  ! define parameters of reference ellipsoid
    e2=1.0-(semimin/semimaj)**2.0
    e4=e2*e2
    e6=e2*e4
    ep2=e2/(1.-e2)

    if (iway == IUTM2LONGLAT) then
      xx = rx
      yy = ry
    else
      dlon = rlon
      dlat = rlat
    endif
  !
  !----- Set Zone parameters
  !
    zone = dble(UTM_PROJECTION_ZONE)
    ! sets central meridian for this zone
    cm = zone*6.0 - 183.0
    cmr = cm*degrad
  !
  !---- Lat/Lon to UTM conversion
  !
    if (iway == ILONGLAT2UTM) then

    rlon = degrad*dlon
    rlat = degrad*dlat

    delam = dlon - cm
    if (delam < -180.) delam = delam + 360.
    if (delam > 180.) delam = delam - 360.
    delam = delam*degrad

    f1 = (1. - e2/4. - 3.*e4/64. - 5.*e6/256)*rlat
    f2 = 3.*e2/8. + 3.*e4/32. + 45.*e6/1024.
    f2 = f2*sin(2.*rlat)
    f3 = 15.*e4/256.*45.*e6/1024.
    f3 = f3*sin(4.*rlat)
    f4 = 35.*e6/3072.
    f4 = f4*sin(6.*rlat)
    rm = semimaj*(f1 - f2 + f3 - f4)
    if (dlat == 90. .or. dlat == -90.) then
      xx = 0.
      yy = scfa*rm
    else
      rn = semimaj/sqrt(1. - e2*sin(rlat)**2)
      t = tan(rlat)**2
      c = ep2*cos(rlat)**2
      a = cos(rlat)*delam

      f1 = (1. - t + c)*a**3/6.
      f2 = 5. - 18.*t + t**2 + 72.*c - 58.*ep2
      f2 = f2*a**5/120.
      xx = scfa*rn*(a + f1 + f2)
      f1 = a**2/2.
      f2 = 5. - t + 9.*c + 4.*c**2
      f2 = f2*a**4/24.
      f3 = 61. - 58.*t + t**2 + 600.*c - 330.*ep2
      f3 = f3*a**6/720.
      yy = scfa*(rm + rn*tan(rlat)*(f1 + f2 + f3))
    endif
    xx = xx + east
    yy = yy + north

  !
  !---- UTM to Lat/Lon conversion
  !
    else

    xx = xx - east
    yy = yy - north
    e1 = sqrt(1. - e2)
    e1 = (1. - e1)/(1. + e1)
    rm = yy/scfa
    u = 1. - e2/4. - 3.*e4/64. - 5.*e6/256.
    u = rm/(semimaj*u)

    f1 = 3.*e1/2. - 27.*e1**3./32.
    f1 = f1*sin(2.*u)
    f2 = 21.*e1**2/16. - 55.*e1**4/32.
    f2 = f2*sin(4.*u)
    f3 = 151.*e1**3./96.
    f3 = f3*sin(6.*u)
    rlat1 = u + f1 + f2 + f3
    dlat1 = rlat1*raddeg
    if (dlat1 >= 90. .or. dlat1 <= -90.) then
      dlat1 = dmin1(dlat1,dble(90.) )
      dlat1 = dmax1(dlat1,dble(-90.) )
      dlon = cm
    else
      c1 = ep2*cos(rlat1)**2.
      t1 = tan(rlat1)**2.
      f1 = 1. - e2*sin(rlat1)**2.
      rn1 = semimaj/sqrt(f1)
      r1 = semimaj*(1. - e2)/sqrt(f1**3)
      d = xx/(rn1*scfa)

      f1 = rn1*tan(rlat1)/r1
      f2 = d**2/2.
      f3 = 5.*3.*t1 + 10.*c1 - 4.*c1**2 - 9.*ep2
      f3 = f3*d**2*d**2/24.
      f4 = 61. + 90.*t1 + 298.*c1 + 45.*t1**2. - 252.*ep2 - 3.*c1**2
      f4 = f4*(d**2)**3./720.
      rlat = rlat1 - f1*(f2 - f3 + f4)
      dlat = rlat*raddeg

      f1 = 1. + 2.*t1 + c1
      f1 = f1*d**2*d/6.
      f2 = 5. - 2.*c1 + 28.*t1 - 3.*c1**2 + 8.*ep2 + 24.*t1**2.
      f2 = f2*(d**2)**2*d/120.
      rlon = cmr + (d - f1 + f2)/cos(rlat1)
      dlon = rlon*raddeg
      if (dlon < -180.) dlon = dlon + 360.
      if (dlon > 180.) dlon = dlon - 360.
    endif
    endif

    if (iway == IUTM2LONGLAT) then
      rlon = dlon
      rlat = dlat
      rx = rx_save
      ry = ry_save
    else
      rx = xx
      ry = yy
      rlon = rlon_save
      rlat = rlat_save
    endif

  end subroutine utm_geo
!=================================================
!  ########################################################################################

end module utils
