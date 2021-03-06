#include "../defines.inc"
!---------------------------------------------------------------*

!
!     This subroutine performs the RK step for user inputted timestep
!     size
!
!     Andrew Spakowitz
!     Written 6-6-04

      subroutine RKstep(RS,R,US,U,DRDT,DUDT,RK,DT)

      use params, only : dp, pi
      implicit none
      real(dp) RS(3,WLC_P__NT)  ! Saved bead positions
      real(dp) R(3,WLC_P__NT)  ! Temp bead positions
      real(dp) US(3,WLC_P__NT) ! Unit tangent
      real(dp) U(3,WLC_P__NT) ! Unit tangent
      real(dp) DRDT(3,WLC_P__NT,4) ! Change rate of beads
      real(dp) DUDT(3,WLC_P__NT,4) ! Change rate of beads
      real(dp) DT       ! Time step size
      integer RK                ! RK number
      integer I,J,IB         ! Index number
      real(dp) MAGU

      IB = 1
      do 10 I = 1,WLC_P__NT
            if(RK == 1) then
               R(1,IB) = RS(1,IB) + DT*DRDT(1,IB,RK)/2.
               R(2,IB) = RS(2,IB) + DT*DRDT(2,IB,RK)/2.
               R(3,IB) = RS(3,IB) + DT*DRDT(3,IB,RK)/2.
               U(1,IB) = US(1,IB) + DT*DUDT(1,IB,RK)/2.
               U(2,IB) = US(2,IB) + DT*DUDT(2,IB,RK)/2.
               U(3,IB) = US(3,IB) + DT*DUDT(3,IB,RK)/2.
            elseif(RK == 2) then
               R(1,IB) = RS(1,IB) + DT*DRDT(1,IB,RK)/2.
               R(2,IB) = RS(2,IB) + DT*DRDT(2,IB,RK)/2.
               R(3,IB) = RS(3,IB) + DT*DRDT(3,IB,RK)/2.
               U(1,IB) = US(1,IB) + DT*DUDT(1,IB,RK)/2.
               U(2,IB) = US(2,IB) + DT*DUDT(2,IB,RK)/2.
               U(3,IB) = US(3,IB) + DT*DUDT(3,IB,RK)/2.
            elseif(RK == 3) then
               R(1,IB) = RS(1,IB) + DT*DRDT(1,IB,RK)
               R(2,IB) = RS(2,IB) + DT*DRDT(2,IB,RK)
               R(3,IB) = RS(3,IB) + DT*DRDT(3,IB,RK)
               U(1,IB) = US(1,IB) + DT*DUDT(1,IB,RK)
               U(2,IB) = US(2,IB) + DT*DUDT(2,IB,RK)
               U(3,IB) = US(3,IB) + DT*DUDT(3,IB,RK)
            elseif(RK == 4) then
               R(1,IB) = RS(1,IB) + DT*(DRDT(1,IB,1)/6. + DRDT(1,IB,2)/3. + DRDT(1,IB,3)/3. + DRDT(1,IB,4)/6.)
               R(2,IB) = RS(2,IB) + DT*(DRDT(2,IB,1)/6. + DRDT(2,IB,2)/3. + DRDT(2,IB,3)/3. + DRDT(2,IB,4)/6.)
               R(3,IB) = RS(3,IB) + DT*(DRDT(3,IB,1)/6. + DRDT(3,IB,2)/3. + DRDT(3,IB,3)/3. + DRDT(3,IB,4)/6.)
               U(1,IB) = US(1,IB) + DT*(DUDT(1,IB,1)/6. + DUDT(1,IB,2)/3. + DUDT(1,IB,3)/3. + DUDT(1,IB,4)/6.)
               U(2,IB) = US(2,IB) + DT*(DUDT(2,IB,1)/6. + DUDT(2,IB,2)/3. + DUDT(2,IB,3)/3. + DUDT(2,IB,4)/6.)
               U(3,IB) = US(3,IB) + DT*(DUDT(3,IB,1)/6. + DUDT(3,IB,2)/3. + DUDT(3,IB,3)/3. + DUDT(3,IB,4)/6.)
            endif

            MAGU = sqrt(U(1,IB)**2. + U(2,IB)**2. + U(3,IB)**2.)
            U(1,IB) = U(1,IB)/MAGU
            U(2,IB) = U(2,IB)/MAGU
            U(3,IB) = U(3,IB)/MAGU

            IB = IB + 1
 10   continue

      RETURN
      END

!---------------------------------------------------------------*

