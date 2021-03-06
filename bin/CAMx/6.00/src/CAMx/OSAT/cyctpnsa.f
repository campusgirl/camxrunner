c*** CYCTPNSA
c
      subroutine cyctpnsa(nspc,convfac,cold,delcon,rrxn_irr,alphaNTR,
     &                    alphaHN3,betaTPN,cycTPN,betaRGN,delRGN)
      use chmstry
c
c----CAMx v6.00 130506
c
c-----------------------------------------------------------------------
c   Description:
c     This routine calculates the coefficients used in the chemistry
c     calculations of the nitrate species in PSAT.
c
c     Copyright 1996 - 2013
c     ENVIRON International Corporation
c
c   Argument descriptions:
c     Inputs:
c       nspc       I  number of model species
c       convfac    R  conversion factor used for lower bound value
c       cold       R  array of concentrations at last time step
c       delcon     R  array of change in concentrations total
c       rrxn_irr   R  array of reactions from last chemistry step
c     Outputs:
c       alphaNTR   R  coefficient used in chemistry adjustment 
c                     calculations
c       alphaHN3   R  coefficient used in chemistry adjustment 
c                     calculations
c       betaTPN    R  coefficient used in chemistry adjustment 
c                     calculations
c       cycTPN     R  coefficient used in chemistry adjustment 
c                     calculations
c       betaRGN    R  coefficient used in chemistry adjustment 
c                     calculations
c       delRGN     R  change in concentration over RGN species
c
c-----------------------------------------------------------------------
c   LOG:
c-----------------------------------------------------------------------
c
c     09/28/03   --gwilson--  Original development
c     12/29/06   --bkoo--     Revised for the updated SOA scheme
c     01/08/06   --bkoo--     Added Mechanism 6 (CB05)
c     05/17/07   --gwilson--  Changes to improve handling of small
c                             concentrations near lower bounds
c     07/22/10   --jjung--    Added Mechanism 7 (CB6)
c     10/09/12   --jjung--    Added Mechanism 2 (CB6r1)
c
c-----------------------------------------------------------------------
c   Include files:
c-----------------------------------------------------------------------
c
      include 'camx.prm'
c
c-----------------------------------------------------------------------
c    Argument declarations:
c-----------------------------------------------------------------------
c
      real convfac
      real cold(nspc)
      real delcon(5,MXSPEC)
      real rrxn_irr(*)
      real alphaNTR
      real alphaHN3
      real betaTPN
      real cycTPN
      real betaRGN
      real delRGN
c
c-----------------------------------------------------------------------
c    Local variables:
c-----------------------------------------------------------------------
c
      real FUZZ
      parameter (FUZZ = 10.0)
      real lossPAN,lossPNA,lossPANX,lossPAN2,lossPBZN,lossMPAN,lossHNO4,
     &     lossOPAN
      real prodPAN,prodPNA,prodPANX,prodPAN2,prodPBZN,prodMPAN,prodHNO4,
     &     prodOPAN
      real cycPAN, cycPNA, cycPANX, cycPAN2, cycPBZN, cycMPAN, cycHNO4,
     &     cycOPAN
      real delTPN
c
c-----------------------------------------------------------------------
c    Entry point:
c-----------------------------------------------------------------------
c
c  ---- caclulate the cycle TPN and delta values for the
c       CB6r1 mechanism ------
c
      if( idmech .EQ. 2 ) then
c
        delRGN = delcon(2,kno) + delcon(2,kno2) +
     &           delcon(2,kno3) + 2.0*delcon(2,kn2o5) + delcon(2,khono)
c
        alphaNTR = rrxn_irr(91) + rrxn_irr(92) + 0.63 * rrxn_irr(170)
        if((cold(kntr) + cold(kintr)).LT. FUZZ*convfac*bdnl(kntr))
     &     alphaNTR = 0.0
c
        alphaHN3 = rrxn_irr(46) + rrxn_irr(47)
        if( cold(khno3) .LT. FUZZ*convfac*bdnl(khno3) ) alphaHN3 = 0.0
c
        lossPAN = cold(kpan) *
     &         (1 - EXP(-(rrxn_irr(55)+rrxn_irr(56))/cold(kpan)) )
        prodPAN = cold(kno2) * (1 - EXP(-rrxn_irr(54)/cold(kno2)) )
        cycPAN = 0.5 * AMIN1(lossPAN, prodPAN)
c
        lossPANX = cold(kpanx) *
     &         (1 - EXP(-(rrxn_irr(63)+rrxn_irr(64))/cold(kpanx)) )
        prodPANX = cold(kno2) * (1 - EXP(-rrxn_irr(62)/cold(kno2)) )
        cycPANX = 0.5 * AMIN1(lossPANX, prodPANX)
c
        lossOPAN = cold(kopan) *
     &         (1 - EXP(-(rrxn_irr(209)+rrxn_irr(213))/cold(kopan)) )
        prodOPAN = cold(kno2) * (1 - EXP(-rrxn_irr(208)/cold(kno2)) )
        cycOPAN = 0.5 * AMIN1(lossOPAN, prodOPAN)
c
        lossPNA = cold(kpna) *
     &         (1 - EXP(-(rrxn_irr(49)+rrxn_irr(51)+rrxn_irr(50))
     &                                               /cold(kpna)) )
        prodPNA = cold(kno2) * (1 - EXP(-rrxn_irr(48)/cold(kno2)) )
        cycPNA = 0.5 * AMIN1(lossPNA, prodPNA)
c
        sumTPN = cold(kpan) + cold(kpanx) + cold(kopan) + cold(kpna)
        cycTPN = cold(kpan)/sumTPN * cycPAN +
     &              cold(kpanx)/sumTPN * cycPANX +
     &                 cold(kopan)/sumTPN * cycOPAN +
     &                    cold(kpna)/sumTPN * cycPNA
        if( sumTPN .LT. FUZZ*convfac*
     &              (bdnl(kpan)+bdnl(kpanx)+bdnl(kpna)) ) cycTPN = 0.0
c
        delTPN = delcon(2,kpan) + delcon(2,kpanx) + delcon(2,kopan)
     &          + delcon(2,kpna)
c
c  ---- calculate the cycle TPN and delta values for the
c       SAPRC99 mechanism ------
c
      elseif( idmech .EQ. 5 ) then
c
         delRGN = delcon(2,kno) + delcon(2,kno2) +
     &            delcon(2,kno3) + 2.0*delcon(2,kn2o5) + delcon(2,khono)
c
         alphaHN3 = rrxn_irr(27) + rrxn_irr(28)
         if( cold(khno3) .LT. FUZZ*convfac*bdnl(khno3) ) alphaHN3 = 0.0
c
         alphaNTR = rrxn_irr(176) + rrxn_irr(177)
         if( cold(krno3) .LT. FUZZ*convfac*bdnl(krno3) ) alphaNTR = 0.0
c
         lossPAN = cold(kpan) * (1 - EXP(-rrxn_irr(70)/cold(kpan)) )
         prodPAN = cold(kno2) * (1 - EXP(-rrxn_irr(69)/cold(kno2)) )
         cycPAN = 0.5 * AMIN1(lossPAN, prodPAN)
c
         lossPAN2 = cold(kpan2) * (1 - EXP(-rrxn_irr(80)/cold(kpan2)) )
         prodPAN2 = cold(kno2) * (1 - EXP(-rrxn_irr(79)/cold(kno2)) )
         cycPAN2 = 0.5 * AMIN1(lossPAN2, prodPAN2)
c
         lossPBZN = cold(kpbzn) * (1 - EXP(-rrxn_irr(91)/cold(kpbzn)) )
         prodPBZN = cold(kno2) * (1 - EXP(-rrxn_irr(90)/cold(kno2)) )
         cycPBZN = 0.5 * AMIN1(lossPBZN, prodPBZN)
c
         lossMPAN = cold(kmpan) * (1 - EXP(-rrxn_irr(103)/cold(kmpan)) )
         prodMPAN = cold(kno2) * (1 - EXP(-rrxn_irr(102)/cold(kno2)) )
         cycMPAN = 0.5 * AMIN1(lossMPAN, prodMPAN)
c
         lossHNO4 = cold(khno4) * 
     &          (1 - EXP(-(rrxn_irr(33)+rrxn_irr(34)+rrxn_irr(35))
     &                                                  /cold(khno4)) )
         prodHNO4 = cold(kno2) * (1 - EXP(-rrxn_irr(32)/cold(kno2)) )
         cycHNO4 = 0.5 * AMIN1(lossHNO4, prodHNO4)
c
         sumTPN = cold(kpan) + cold(kpan2) + cold(kpbzn) + 
     &                                        cold(kmpan) + cold(khno4)
         cycTPN = cold(kpan)/sumTPN * cycPAN + 
     &               cold(kpan2)/sumTPN * cycPAN2 + 
     &                     cold(kpbzn)/sumTPN * cycPBZN + 
     &                        cold(kmpan)/sumTPN * cycMPAN + 
     &                           cold(khno4)/sumTPN * cycHNO4 
         if( sumTPN .LT. FUZZ*convfac*
     &        ( bdnl(kpan)+bdnl(kpan2)+bdnl(kpbzn)
     &                       +bdnl(kmpan)+bdnl(khno4) )
     &                                                  ) cycTPN = 0.0
c
         delTPN = delcon(2,kpan) + delcon(2,kpan2) + delcon(2,kpbzn) +
     &                                delcon(2,kmpan) + delcon(2,khno4)
c
c  ---- calculate the cycle TPN and delta values for the
c       CB05 mechanism ------
c
      elseif( idmech .EQ. 6 ) then
c
        delRGN = delcon(2,kno) + delcon(2,kno2) +
     &           delcon(2,kno3) + 2.0*delcon(2,kn2o5) + delcon(2,khono)
c
        alphaNTR = rrxn_irr(61) + rrxn_irr(62)
        if( cold(kntr) .LT. FUZZ*convfac*bdnl(kntr) ) alphaNTR = 0.0
c
        alphaHN3 = rrxn_irr(29) + rrxn_irr(52)
        if( cold(khno3) .LT. FUZZ*convfac*bdnl(khno3) ) alphaHN3 = 0.0
c
        lossPAN = cold(kpan) * 
     &         (1 - EXP(-(rrxn_irr(90)+rrxn_irr(91))/cold(kpan)) )
        prodPAN = cold(kno2) * (1 - EXP(-rrxn_irr(89)/cold(kno2)) )
        cycPAN = 0.5 * AMIN1(lossPAN, prodPAN)
c
        lossPANX = cold(kpanx) * 
     &         (1 - EXP(-(rrxn_irr(105)+rrxn_irr(106)+rrxn_irr(107))
     &                                               /cold(kpanx)) )
        prodPANX = cold(kno2) * (1 - EXP(-rrxn_irr(104)/cold(kno2)) )
        cycPANX = 0.5 * AMIN1(lossPANX, prodPANX)
c
        lossPNA = cold(kpna) * 
     &         (1 - EXP(-(rrxn_irr(32)+rrxn_irr(33)+rrxn_irr(51))
     &                                               /cold(kpna)) )
        prodPNA = cold(kno2) * (1 - EXP(-rrxn_irr(31)/cold(kno2)) )
        cycPNA = 0.5 * AMIN1(lossPNA, prodPNA)
c
        sumTPN = cold(kpan) + cold(kpanx) + cold(kpna)
        cycTPN = cold(kpan)/sumTPN * cycPAN +
     &              cold(kpanx)/sumTPN * cycPANX +
     &                 cold(kpna)/sumTPN * cycPNA
        if( sumTPN .LT. FUZZ*convfac*
     &              (bdnl(kpan)+bdnl(kpanx)+bdnl(kpna)) ) cycTPN = 0.0
c
        delTPN = delcon(2,kpan) + delcon(2,kpanx) + delcon(2,kpna)
c
c  ---- calculate the cycle TPN and delta values for the
c       CB6 mechanism ------
c
      elseif( idmech .EQ. 7 ) then
c
        delRGN = delcon(2,kno) + delcon(2,kno2) +
     &           delcon(2,kno3) + 2.0*delcon(2,kn2o5) + delcon(2,khono)
c
        alphaNTR = rrxn_irr(91) + rrxn_irr(92) + 0.63 * rrxn_irr(167)
        if((cold(kntr) + cold(kintr)).LT. FUZZ*convfac*bdnl(kntr))
     &     alphaNTR = 0.0
c
        alphaHN3 = rrxn_irr(46) + rrxn_irr(47)
        if( cold(khno3) .LT. FUZZ*convfac*bdnl(khno3) ) alphaHN3 = 0.0
c
        lossPAN = cold(kpan) *
     &         (1 - EXP(-(rrxn_irr(55)+rrxn_irr(56))/cold(kpan)) )
        prodPAN = cold(kno2) * (1 - EXP(-rrxn_irr(54)/cold(kno2)) )
        cycPAN = 0.5 * AMIN1(lossPAN, prodPAN)
c
        lossPANX = cold(kpanx) *
     &         (1 - EXP(-(rrxn_irr(63)+rrxn_irr(64))/cold(kpanx)) )
        prodPANX = cold(kno2) * (1 - EXP(-rrxn_irr(62)/cold(kno2)) )
        cycPANX = 0.5 * AMIN1(lossPANX, prodPANX)
c
        lossOPAN = cold(kopan) *(1 - EXP(-rrxn_irr(215)/cold(kopan)) )
        prodOPAN = cold(kno2) * (1 - EXP(-rrxn_irr(214)/cold(kno2)) )
        cycOPAN = 0.5 * AMIN1(lossOPAN, prodOPAN)
c
        lossPNA = cold(kpna) *
     &         (1 - EXP(-(rrxn_irr(49)+rrxn_irr(51)+rrxn_irr(50))
     &                                               /cold(kpna)) )
        prodPNA = cold(kno2) * (1 - EXP(-rrxn_irr(48)/cold(kno2)) )
        cycPNA = 0.5 * AMIN1(lossPNA, prodPNA)
c
        sumTPN = cold(kpan) + cold(kpanx) + cold(kopan) + cold(kpna)
        cycTPN = cold(kpan)/sumTPN * cycPAN +
     &              cold(kpanx)/sumTPN * cycPANX +
     &                 cold(kopan)/sumTPN * cycOPAN +
     &                    cold(kpna)/sumTPN * cycPNA
        if( sumTPN .LT. FUZZ*convfac*
     &              (bdnl(kpan)+bdnl(kpanx)+bdnl(kpna)) ) cycTPN = 0.0
c
        delTPN = delcon(2,kpan) + delcon(2,kpanx) + delcon(2,kopan)
     &          + delcon(2,kpna)
c
c  ---- stop if the mechanism is undefined -----
c
      else
         write(iout,'(//,a)') 'ERROR in CYCTPNSA:'
         write(iout,'(/,1X,A,I10)')
     &             'Unknown chemical mechanism ID number: ',idmech
         write(iout,'(/,1X,2A)')
     &             'Ozone source apportionment is not available ',
     &             'for this chemical mechanism'
         call camxerr()
      endif
c
      if( ( cold(kno)+cold(kno2)+cold(khono)
     &               +cold(kno3)+2.0*cold(kn2o5) ) .LT.
     &               FUZZ*convfac*( bdnl(kno)+bdnl(kno2)+bdnl(khono)
     &                             +bdnl(kno3)+2.0*bdnl(kn2o5) ) ) then
         alphaNTR = 0.0
         alphaHN3 = 0.0
         cycTPN   = 0.0
      endif
c
c   --- set the output variables and return ---
c
      cycTPN  = AMIN1( cold(kno2)-delTPN, sumTPN+delTPN, cycTPN )
      betaTPN = AMAX1( -delTPN, 0.) + cycTPN
      betaRGN = AMAX1(  delTPN, 0.) + cycTPN
      cycTPN  = 0.
c
c-----------------------------------------------------------------------
c    Return point:
c-----------------------------------------------------------------------
c
      return
      end
