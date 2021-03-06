#include "../defines.inc"
!---------------------------------------------------------------*

!
!     This subroutine calculates the elastic forces for a wormlike
!     chain with a stretching potential.  The stretch and bend
!     moduli are fed along with the bead positions.
!
!     Andrew Spakowitz
!     Written 9-1-04

      subroutine stress(SIG,R,U,PARA,inTON,SIMTYPE)
    
      use params, only : dp
      use polydispersity, only: length_of_chain, first_bead_of_chain
      implicit none
      real(dp) FELAS(3,WLC_P__NT) ! Elastic force
      real(dp) FPONP(3,WLC_P__NT) ! Self-interaction force
      real(dp) TELAS(3,WLC_P__NT) ! Elastic force
      real(dp) R(3,WLC_P__NT)  ! Bead positions
      real(dp) U(3,WLC_P__NT)  ! Tangent vectors
      real(dp) L0       ! Bead separation
      real(dp) FTOT(3)  ! Compress force
      real(dp) FBEND(3) ! Bend force
      integer inTON             ! Include polymer interactions
      integer I,J,IB                 ! Index holders
      integer SIMTYPE

!     Variables in the simulation

      real(dp) EB,EPAR,EPERP
      real(dp) GAM,ETA
      real(dp) XIR,XIU
      real(dp) LBOX     ! Box edge length
      real(dp) LHC      ! Length of HC int
      real(dp) VHC      ! HC strength
      real(dp) PARA(10)
      real(dp) DT

!     Variables for force and torque calculations

      real(dp) RCOM(3)  ! Center of mass
      real(dp) SIG(3,3)
      integer N

!     Load the input parameters

      EB = PARA(1)
      EPAR = PARA(2)
      EPERP = PARA(3)
      GAM = PARA(4)
      ETA = PARA(5)
      XIR = PARA(6)
      XIU = PARA(7)
      LBOX = PARA(8)
      LHC = PARA(9)
      VHC = PARA(10)

      DT = 0.0001
      call force_elas(FELAS,TELAS,R,U,EB,EPAR,EPERP,GAM,ETA,SIMTYPE)

      if (inTON == 1) then
         call force_ponp(FPONP,R,LHC,VHC,LBOX,GAM,DT,XIR)
      endif

      SIG(1,1) = 0.
      SIG(1,2) = 0.
      SIG(1,3) = 0.
      SIG(2,1) = 0.
      SIG(2,2) = 0.
      SIG(2,3) = 0.
      SIG(3,1) = 0.
      SIG(3,2) = 0.
      SIG(3,3) = 0.
      do 10 I = 1,WLC_P__NP
         N = length_of_chain(I)
         RCOM(1) = 0.
         RCOM(2) = 0.
         RCOM(3) = 0.
         IB = first_bead_of_chain(I)
         do 20 J = 1,N
            RCOM(1) = RCOM(1) + R(1,IB)/N
            RCOM(2) = RCOM(2) + R(2,IB)/N
            RCOM(3) = RCOM(3) + R(3,IB)/N
            IB = IB + 1
 20      continue

         IB = first_bead_of_chain(I)
         do 30 J = 1,N
            FTOT(1) = FELAS(1,IB) + inTON*FPONP(1,IB)
            FTOT(2) = FELAS(2,IB) + inTON*FPONP(2,IB)
            FTOT(3) = FELAS(3,IB) + inTON*FPONP(3,IB)
            SIG(1,1) = SIG(1,1)-(R(1,IB)-RCOM(1))*FTOT(1)
            SIG(1,2) = SIG(1,2)-(R(1,IB)-RCOM(1))*FTOT(2)
            SIG(1,3) = SIG(1,3)-(R(1,IB)-RCOM(1))*FTOT(3)
            SIG(2,1) = SIG(2,1)-(R(2,IB)-RCOM(2))*FTOT(1)
            SIG(2,2) = SIG(2,2)-(R(2,IB)-RCOM(2))*FTOT(2)
            SIG(2,3) = SIG(2,3)-(R(2,IB)-RCOM(2))*FTOT(3)
            SIG(3,1) = SIG(3,1)-(R(3,IB)-RCOM(3))*FTOT(1)
            SIG(3,2) = SIG(3,2)-(R(3,IB)-RCOM(3))*FTOT(2)
            SIG(3,3) = SIG(3,3)-(R(3,IB)-RCOM(3))*FTOT(3)
            IB=IB + 1
 30      continue
 10   continue

      RETURN
      END

!---------------------------------------------------------------*
