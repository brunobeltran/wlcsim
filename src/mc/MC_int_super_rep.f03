#include "../defines.inc"
!---------------------------------------------------------------!
!
!     This subroutine calculates the change in the self energy for
!     a super reptation move.  That is a reptation move where the 
!     chain identities change along with position so that middle
!     beads appear not to change.
!
!     Created from MC_int_rep by Quinn on 8/10/17
!---------------------------------------------------------------
subroutine MC_int_super_rep(wlc_p,I1,I2,forward)
! values from wlcsim_data
use params, only: wlc_DPHIB, wlc_R, wlc_NPHI, wlc_DPHIA, wlc_inDPHI&
    , wlc_UP, wlc_ABP, wlc_U, wlc_AB, wlc_DPHI_l2, wlc_RP
use params
implicit none

!   iputs
TYPE(wlcsim_params), intent(in) :: wlc_p   ! <---- Contains output
integer, intent(in) :: I1  ! Test bead position 1
integer, intent(in) :: I2  ! Test bead position 2

!   Internal variables
integer I                 ! For looping over bins
integer II                ! For looping over IB
integer IB                ! Bead index
integer rrdr ! -1 if r, 1 if r + dr
integer IX(2),IY(2),IZ(2)
real(dp) WX(2),WY(2),WZ(2)
real(dp) WTOT       ! total weight ascribed to bin
real(dp) RBin(3)    ! bead position
integer inDBin              ! index of bin
integer ISX,ISY,ISZ
LOGICAL isA   ! The bead is of type A
real(dp), dimension(-2:2) ::  phi2
integer m_index  ! m from Ylm spherical harmonics
integer NBinX(3)
real(dp) temp    !for speeding up code
LOGICAL, intent(in) :: forward ! move forward
NBinX = wlc_p%NBINX

wlc_NPHI = 0
if (WLC_P__TWO_TAIL) then
    print*, "The Super Reptation move is not currently set up for two Tail"
    stop 1
endif
! -------------------------------------------------------------
!
!  Calculate end beads
!
!--------------------------------------------------------------

do II = 1,2
  if (II.eq.1) then
      IB = I1
      if (forward) then
          ! moving forward I1 is removed
          rrdr = -1 
      else
          ! moving backward I1 is added
          rrdr = 1
      endif
  elseif (II.eq.2) then
      IB = I2
      if (forward) then
          ! moving forward I2 is added
          rrdr = 1
      else
          ! moving forward I1 is removed
          rrdr = -1
      endif
  else
      print*, "Error in MC_int_rep, II = {1,2}"
      stop 1
  endif
   ! subract current and add new
   if (rrdr.eq.-1) then
       RBin(1) = wlc_R(1,IB)
       RBin(2) = wlc_R(2,IB)
       RBin(3) = wlc_R(3,IB)
       isA = wlc_AB(IB).eq.1
   else
       RBin(1) = wlc_RP(1,IB)
       RBin(2) = wlc_RP(2,IB)
       RBin(3) = wlc_RP(3,IB)
       isA = wlc_ABP(IB).eq.1
   endif
   if (wlc_p%CHI_L2_ON .and. isA) then
       if (rrdr == -1) then
           call Y2calc(wlc_U(:,IB),phi2)
       else
           call Y2calc(wlc_UP(:,IB),phi2)
       endif
   else
       ! You could give some MS parameter to B as well if you wanted
       phi2=0.0_dp
   endif
   ! --------------------------------------------------
   !
   !  Interpolate beads into bins
   !
   ! --------------------------------------------------
   call interp(wlc_p,RBin,IX,IY,IZ,WX,WY,WZ)

   ! -------------------------------------------------------
   !
   ! Count beads in bins
   !
   ! ------------------------------------------------------
   !   Add or Subtract volume fraction with weighting from each bin
   !   I know that it looks bad to have this section of code twice but it
   !   makes it faster.
   if (isA) then
       do ISX = 1,2
          do ISY = 1,2
             do ISZ = 1,2
                WTOT = WX(ISX)*WY(ISY)*WZ(ISZ)
                inDBin = IX(ISX) + (IY(ISY)-1)*NBinX(1) + (IZ(ISZ)-1)*NBinX(1)*NBinX(2)
                ! Generate list of which phi's change and by how much
                I = wlc_NPHI
                do
                   if (I.eq.0) then
                      wlc_NPHI = wlc_NPHI + 1
                      wlc_inDPHI(wlc_NPHI) = inDBin
                      temp = rrdr*WTOT*WLC_P__BEADVOLUME/(WLC_P__DBIN**3)
                      wlc_DPHIA(wlc_NPHI) = temp
                      wlc_DPHIB(wlc_NPHI) = 0.0_dp
                      if(wlc_p%CHI_L2_ON) then
                          do m_index = -2,2
                              wlc_DPHI_l2(m_index,wlc_NPHI) = &
                                  + phi2(m_index)*temp
                          enddo
                      endif
                      exit
                   elseif (inDBin == wlc_inDPHI(I)) then
                      temp = rrdr*WTOT*WLC_P__BEADVOLUME/(WLC_P__DBIN**3)
                      wlc_DPHIA(I) = wlc_DPHIA(I) + temp
                      if(wlc_p%CHI_L2_ON) then
                          do m_index = -2,2
                              wlc_DPHI_l2(m_index,I) = wlc_DPHI_l2(m_index,I) &
                                  + phi2(m_index)*temp
                          enddo
                      endif
                      exit
                   else
                      I = I-1
                   endif
                enddo
             enddo
          enddo
       enddo
   else
       do ISX = 1,2
          do ISY = 1,2
             do ISZ = 1,2
                WTOT = WX(ISX)*WY(ISY)*WZ(ISZ)
                inDBin = IX(ISX) + (IY(ISY)-1)*NBinX(1) + (IZ(ISZ)-1)*NBinX(1)*NBinX(2)
                ! Generate list of which phi's change and by how much
                I = wlc_NPHI
                do
                   if (I.eq.0) then
                      wlc_NPHI = wlc_NPHI + 1
                      wlc_inDPHI(wlc_NPHI) = inDBin
                      wlc_DPHIA(wlc_NPHI) = 0.0_dp
                      wlc_DPHIB(wlc_NPHI) = rrdr*WTOT*WLC_P__BEADVOLUME/(WLC_P__DBIN**3)
                      if(wlc_p%CHI_L2_ON) then
                          do m_index = -2,2
                              ! This is somewhat wastefull, could eliminate for speedup by having another NPHI for L=2
                              wlc_DPHI_l2(m_index,wlc_NPHI) = 0.0_dp
                          enddo
                      endif
                      exit
                   elseif (inDBin == wlc_inDPHI(I)) then
                      wlc_DPHIB(I) = wlc_DPHIB(I) + rrdr*WTOT*WLC_P__BEADVOLUME/(WLC_P__DBIN**3)
                      exit
                   else
                      I = I-1
                   endif
                enddo
             enddo !ISZ
          enddo !ISY
       enddo !ISX
   endif
enddo ! loop over IB  A.k.a. beads
! ---------------------------------------------------------------------
!



!----------------------------------------------------------
!
!  Intermediate Beads Don't change field
!
!-----------------------------------------------------------

! ... skipping

! ---------------------------------------------------------------------
!
! Calcualte change in energy
!
!---------------------------------------------------------------------
call hamiltonian(wlc_p,.false.)

RETURN
END

!---------------------------------------------------------------!
