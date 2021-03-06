      subroutine ierate9(neq,t,y,rate,nr,r)
      implicit none
c
c----CAMx v5.41 121109
c
c     IERATE9 computes rates for IEH solver fast species
c
c     Copyright 1996 - 2012
c     ENVIRON International Corporation
c     Created by the CMC version 5.2
c
c     Routines Called:
c        IERXN9
c
c     Called by:
c        LSODE
c
      include "camx.prm"
      include "chmdat.inc"
      include "iehchem.inc"
      include "lsbox.inc"
c
      integer neq(3), ny, nr, nk, l
      real t, H2O, M, O2, CH4, H2, N2
      real y(neq(2)+6)
      real rate(neq(1))
      real r(neq(3))
      real loss(MXSPEC+1)
      real gain(MXSPEC+1)
c
c --- Entry point
c
      ny = neq(2)
      nk = neq(3)
      H2O = y(ny+2)
      M   = y(ny+3)
      O2  = y(ny+4)
      CH4 = y(ny+5)
      H2  = y(ny+6)
      N2  = M - O2
c
      do l=1,ny
        Loss(l) = 0.0
        Gain(l) = 0.0
      enddo
c
c --- Get the reaction rates
c
      call ierxn9(y,ny,r,rrk,nk)
c
c --- Solve the steady state species
c
c
c   O1D
c
        Loss(iO1D  )= +( 1.000)*r( 10)+( 1.000)*r( 11)+( 1.000)*r( 38)
c
        Gain(iO1D  )= +( 1.000)*r(  9)
c
      if (loss(iO1D).gt.1.0e-25.or.loss(iO1D).lt.-1.0e-25) then
        y(iO1D) = gain(iO1D)/loss(iO1D)*y(iO1D)
      else
        y(iO1D) = 0.0
      endif
      r( 10) = rrk( 10)*y(iO1D)*M
      r( 11) = rrk( 11)*y(iO1D)*H2O
      r( 38) = rrk( 38)*y(iO1D)*H2
c
c     O
c
        Loss(iO    )= +( 1.000)*r(  2)+( 1.000)*r(  4)+( 1.000)*r(  5)
     &                +( 1.000)*r(  6)+( 1.000)*r( 40)+( 1.000)*r( 44)
     &                +( 1.000)*r( 45)+( 1.000)*r( 46)+( 1.000)*r( 77)
     &                +( 1.000)*r( 84)+( 1.000)*r( 99)+( 1.000)*r(119)
     &                +( 1.000)*r(123)+( 1.000)*r(127)+( 1.000)*r(144)
     &                +( 1.000)*r(153)
c
        Gain(iO    )= +( 1.000)*r(  1)+( 1.000)*r(  8)+( 1.000)*r( 10)
     &                +( 1.000)*r( 14)+( 1.000)*r( 41)+( 0.500)*r(129)
     &                +( 1.000)*r(197)
c
      if (loss(iO).gt.1.0e-25.or.loss(iO).lt.-1.0e-25) then
        y(iO) = gain(iO)/loss(iO)*y(iO)
      else
        y(iO) = 0.0
      endif
      r(  2) = rrk(  2)*y(iO)*O2*M
      r(  4) = rrk(  4)*y(iO)*y(iNO2)
      r(  5) = rrk(  5)*y(iO)*y(iNO2)
      r(  6) = rrk(  6)*y(iO)*y(iNO)
      r( 40) = rrk( 40)*y(iOH)*y(iO)
      r( 44) = rrk( 44)*y(iHO2)*y(iO)
      r( 45) = rrk( 45)*y(iH2O2)*y(iO)
      r( 46) = rrk( 46)*y(iNO3)*y(iO)
      r( 77) = rrk( 77)*y(iFORM)*y(iO)
      r( 84) = rrk( 84)*y(iALD2)*y(iO)
      r( 99) = rrk( 99)*y(iALDX)*y(iO)
      r(119) = rrk(119)*y(iO)*y(iOLE)
      r(123) = rrk(123)*y(iO)*y(iETH)
      r(127) = rrk(127)*y(iIOLE)*y(iO)
      r(144) = rrk(144)*y(iO)*y(iISOP)
      r(153) = rrk(153)*y(iTERP)*y(iO)
c
c    CL
c
        Loss(iCL   )= +( 1.000)*r(159)+( 1.000)*r(167)+( 1.000)*r(171)
     &                +( 1.000)*r(172)+( 1.000)*r(173)+( 1.000)*r(174)
     &                +( 1.000)*r(175)+( 1.000)*r(176)+( 1.000)*r(177)
     &                +( 1.000)*r(178)+( 1.000)*r(179)+( 1.000)*r(180)
     &                +( 1.000)*r(181)+( 1.000)*r(182)+( 1.000)*r(183)
     &                +( 1.000)*r(184)+( 1.000)*r(185)+( 1.000)*r(186)
c
        Gain(iCL   )= +( 2.000)*r(157)+( 1.000)*r(158)+( 1.400)*r(160)
     &                +( 1.000)*r(161)+( 1.000)*r(166)+( 1.000)*r(168)
     &                +( 1.000)*r(169)+( 1.000)*r(170)+( 1.000)*r(188)
c
      if (loss(iCL).gt.1.0e-25.or.loss(iCL).lt.-1.0e-25) then
        y(iCL) = gain(iCL)/loss(iCL)*y(iCL)
      else
        y(iCL) = 0.0
      endif
      r(159) = rrk(159)*y(iCL)*y(iO3)
      r(167) = rrk(167)*y(iCL)*y(iN3CL)
      r(171) = rrk(171)*y(iCL)*H2
      r(172) = rrk(172)*y(iCL)*CH4
      r(173) = rrk(173)*y(iCL)*y(iPAR)
      r(174) = rrk(174)*y(iCL)*y(iETHA)
      r(175) = rrk(175)*y(iCL)*y(iETH)
      r(176) = rrk(176)*y(iCL)*y(iOLE)
      r(177) = rrk(177)*y(iCL)*y(iIOLE)
      r(178) = rrk(178)*y(iCL)*y(iISOP)
      r(179) = rrk(179)*y(iCL)*y(iTERP)
      r(180) = rrk(180)*y(iCL)*y(iTOL)
      r(181) = rrk(181)*y(iCL)*y(iXYL)
      r(182) = rrk(182)*y(iCL)*y(iFORM)
      r(183) = rrk(183)*y(iCL)*y(iALD2)
      r(184) = rrk(184)*y(iCL)*y(iALDX)
      r(185) = rrk(185)*y(iCL)*y(iMEOH)
      r(186) = rrk(186)*y(iCL)*y(iETOH)
c
c   CLO
c
        Loss(iCLO  )= +( 2.000)*r(160)+( 1.000)*r(161)+( 1.000)*r(162)
     &                +( 1.000)*r(163)
c
        Gain(iCLO  )= +( 1.000)*r(159)+( 1.000)*r(164)+( 1.000)*r(165)
c
      if (loss(iCLO).gt.1.0e-25.or.loss(iCLO).lt.-1.0e-25) then
        y(iCLO) = gain(iCLO)/loss(iCLO)*y(iCLO)
      else
        y(iCLO) = 0.0
      endif
      r(160) = rrk(160)*y(iCLO)*y(iCLO)
      r(161) = rrk(161)*y(iCLO)*y(iNO)
      r(162) = rrk(162)*y(iCLO)*y(iHO2)
      r(163) = rrk(163)*y(iCLO)*y(iNO2)
c
c --- Calculate the species rates
c
c
c  N2O5   NO3    OH   HO2  C2O3   XO2  XO2N   TO2   ROR   CRO
c  MEO2  HCO3  CXO3     I    NO   NO2    O3   PAN  PANX   PNA
c
c
        Loss(iN2O5 )= +( 1.000)*r( 19)+( 1.000)*r( 20)+( 1.000)*r( 21)
     &                +( 1.000)*r( 53)+( 1.000)*r(187)
c
        Gain(iN2O5 )= +( 1.000)*r( 18)
c
        Loss(iNO3  )= +( 1.000)*r( 14)+( 1.000)*r( 15)+( 1.000)*r( 16)
     &                +( 1.000)*r( 17)+( 1.000)*r( 18)+( 1.000)*r( 46)
     &                +( 1.000)*r( 47)+( 1.000)*r( 48)+( 1.000)*r( 49)
     &                +( 2.000)*r( 50)+( 1.000)*r( 78)+( 1.000)*r( 86)
     &                +( 1.000)*r(101)+( 1.000)*r(122)+( 1.000)*r(126)
     &                +( 1.000)*r(130)+( 1.000)*r(135)+( 1.000)*r(147)
     &                +( 1.000)*r(151)+( 1.000)*r(156)+( 1.000)*r(194)
     &                +( 1.000)*r(206)
c
        Gain(iNO3  )= +( 1.000)*r(  5)+( 1.000)*r(  7)+( 1.000)*r( 21)
     &                +( 1.000)*r( 29)+( 0.390)*r( 51)+( 1.000)*r( 53)
     &                +( 1.000)*r(166)+( 1.000)*r(167)+( 0.500)*r(213)
c
        Loss(iOH   )= +( 1.000)*r( 12)+( 1.000)*r( 24)+( 1.000)*r( 26)
     &                +( 1.000)*r( 28)+( 1.000)*r( 29)+( 1.000)*r( 33)
     &                +( 1.000)*r( 37)+( 1.000)*r( 39)+( 1.000)*r( 40)
     &                +( 2.000)*r( 41)+( 2.000)*r( 42)+( 1.000)*r( 43)
     &                +( 1.000)*r( 47)+( 1.000)*r( 61)+( 1.000)*r( 63)
     &                +( 1.000)*r( 64)+( 1.000)*r( 66)+( 1.000)*r( 67)
     &                +( 1.000)*r( 71)+( 1.000)*r( 73)+( 1.000)*r( 74)
     &                +( 1.000)*r( 83)+( 1.000)*r( 85)+( 1.000)*r( 96)
     &                +( 1.000)*r( 98)+( 1.000)*r(100)+( 1.000)*r(107)
        Loss(iOH   ) = Loss(iOH   )
     &                +( 1.000)*r(113)+( 1.000)*r(114)+( 1.000)*r(115)
     &                +( 1.000)*r(120)+( 1.000)*r(124)+( 1.000)*r(128)
     &                +( 1.000)*r(131)+( 1.000)*r(134)+( 1.000)*r(139)
     &                +( 1.000)*r(141)+( 1.000)*r(142)+( 1.000)*r(145)
     &                +( 1.000)*r(149)+( 1.000)*r(154)+( 1.000)*r(168)
     &                +( 1.000)*r(169)+( 1.000)*r(205)+( 1.000)*r(209)
     &                +( 1.000)*r(216)+( 1.000)*r(217)+( 1.000)*r(220)
     &                +( 1.000)*r(221)
c
        Gain(iOH   )= +( 2.000)*r( 11)+( 1.000)*r( 13)+( 1.000)*r( 25)
     &                +( 1.000)*r( 30)+( 2.000)*r( 36)+( 1.000)*r( 38)
     &                +( 1.000)*r( 44)+( 1.000)*r( 45)+( 0.390)*r( 51)
     &                +( 1.000)*r( 52)+( 1.000)*r( 65)+( 1.000)*r( 72)
     &                +( 1.000)*r( 77)+( 1.000)*r( 84)+( 1.000)*r( 97)
     &                +( 1.000)*r( 99)+( 0.100)*r(119)+( 0.100)*r(121)
     &                +( 0.300)*r(123)+( 0.130)*r(125)+( 0.500)*r(129)
     &                +( 0.080)*r(140)+( 0.266)*r(146)+( 0.268)*r(150)
     &                +( 0.570)*r(155)+( 1.000)*r(158)+( 1.000)*r(215)
c
        Loss(iHO2  )= +( 1.000)*r( 13)+( 1.000)*r( 30)+( 1.000)*r( 31)
     &                +( 2.000)*r( 34)+( 2.000)*r( 35)+( 1.000)*r( 43)
     &                +( 1.000)*r( 44)+( 1.000)*r( 48)+( 1.000)*r( 56)
     &                +( 1.000)*r( 57)+( 1.000)*r( 69)+( 1.000)*r( 79)
     &                +( 1.000)*r( 82)+( 1.000)*r( 92)+( 1.000)*r(108)
     &                +( 1.000)*r(137)+( 1.000)*r(162)+( 1.000)*r(191)
     &                +( 1.000)*r(200)
c
        Gain(iHO2  )= +( 1.000)*r( 12)+( 1.000)*r( 32)+( 1.000)*r( 37)
     &                +( 1.000)*r( 38)+( 1.000)*r( 39)+( 1.000)*r( 40)
     &                +( 1.000)*r( 45)+( 1.000)*r( 47)+( 0.610)*r( 51)
     &                +( 1.000)*r( 61)+( 1.000)*r( 62)+( 1.000)*r( 63)
     &                +( 1.000)*r( 65)+( 1.000)*r( 66)+( 1.000)*r( 68)
     &                +( 0.740)*r( 70)+( 0.300)*r( 71)+( 1.000)*r( 72)
     &                +( 1.000)*r( 73)+( 1.000)*r( 74)+( 2.000)*r( 75)
     &                +( 1.000)*r( 77)+( 1.000)*r( 78)+( 1.000)*r( 80)
     &                +( 1.000)*r( 81)+( 1.000)*r( 83)+( 1.000)*r( 87)
        Gain(iHO2  ) = Gain(iHO2  )
     &                +( 0.900)*r( 93)+( 1.000)*r(102)+( 1.000)*r(103)
     &                +( 1.000)*r(109)+( 2.000)*r(111)+( 1.000)*r(112)
     &                +( 1.000)*r(113)+( 1.000)*r(114)+( 0.110)*r(115)
     &                +( 0.940)*r(116)+( 1.000)*r(117)+( 0.300)*r(119)
     &                +( 0.950)*r(120)+( 0.440)*r(121)+( 1.700)*r(123)
     &                +( 1.000)*r(124)+( 0.130)*r(125)+( 0.100)*r(127)
     &                +( 1.000)*r(128)+( 0.500)*r(129)+( 1.000)*r(130)
     &                +( 0.440)*r(131)+( 0.900)*r(132)+( 1.000)*r(133)
        Gain(iHO2  ) = Gain(iHO2  )
     &                +( 0.600)*r(134)+( 1.000)*r(138)+( 2.000)*r(139)
     &                +( 0.760)*r(140)+( 0.700)*r(141)+( 1.000)*r(143)
     &                +( 0.250)*r(144)+( 0.912)*r(145)+( 0.066)*r(146)
     &                +( 0.800)*r(147)+( 0.800)*r(148)+( 0.503)*r(149)
     &                +( 0.154)*r(150)+( 0.925)*r(151)+( 1.033)*r(152)
     &                +( 0.750)*r(154)+( 0.070)*r(155)+( 0.280)*r(156)
     &                +( 1.000)*r(170)+( 1.000)*r(171)+( 0.110)*r(173)
     &                +( 1.000)*r(174)+( 1.000)*r(175)+( 1.000)*r(176)
        Gain(iHO2  ) = Gain(iHO2  )
     &                +( 1.000)*r(177)+( 0.920)*r(178)+( 0.750)*r(179)
     &                +( 0.880)*r(180)+( 0.840)*r(181)+( 1.000)*r(182)
     &                +( 1.000)*r(185)+( 1.000)*r(186)+( 1.000)*r(218)
     &                +( 0.820)*r(220)+( 1.000)*r(221)
c
        Loss(iC2O3 )= +( 1.000)*r( 88)+( 1.000)*r( 89)+( 1.000)*r( 92)
     &                +( 1.000)*r( 93)+( 1.000)*r( 94)+( 2.000)*r( 95)
     &                +( 1.000)*r(112)
c
        Gain(iC2O3 )= +( 1.000)*r( 84)+( 1.000)*r( 85)+( 1.000)*r( 86)
     &                +( 1.000)*r( 90)+( 1.000)*r( 91)+( 1.000)*r( 96)
     &                +( 1.000)*r(138)+( 1.000)*r(139)+( 0.620)*r(140)
     &                +( 1.000)*r(142)+( 1.000)*r(143)+( 0.210)*r(149)
     &                +( 0.114)*r(150)+( 0.967)*r(152)+( 1.000)*r(183)
     &                +( 1.000)*r(222)
c
        Loss(iXO2  )= +( 1.000)*r( 54)+( 1.000)*r( 56)+( 2.000)*r( 58)
     &                +( 1.000)*r( 60)+( 1.000)*r( 94)+( 1.000)*r(110)
c
        Gain(iXO2  )= +( 1.000)*r( 64)+( 0.300)*r( 71)+( 1.000)*r(103)
     &                +( 0.900)*r(109)+( 2.000)*r(111)+( 1.000)*r(112)
     &                +( 0.991)*r(113)+( 0.100)*r(114)+( 0.870)*r(115)
     &                +( 0.960)*r(116)+( 0.200)*r(119)+( 0.800)*r(120)
     &                +( 0.220)*r(121)+( 0.910)*r(122)+( 0.700)*r(123)
     &                +( 1.000)*r(124)+( 1.000)*r(126)+( 0.100)*r(127)
     &                +( 1.000)*r(128)+( 0.080)*r(131)+( 0.600)*r(134)
     &                +( 1.000)*r(139)+( 0.030)*r(140)+( 0.500)*r(141)
     &                +( 1.000)*r(142)+( 0.250)*r(144)+( 0.991)*r(145)
        Gain(iXO2  ) = Gain(iXO2  )
     &                +( 0.200)*r(146)+( 1.000)*r(147)+( 1.000)*r(148)
     &                +( 0.713)*r(149)+( 0.064)*r(150)+( 0.075)*r(151)
     &                +( 0.700)*r(152)+( 1.250)*r(154)+( 0.760)*r(155)
     &                +( 1.030)*r(156)+( 0.870)*r(173)+( 0.991)*r(174)
     &                +( 2.000)*r(175)+( 1.870)*r(176)+( 1.800)*r(177)
     &                +( 1.700)*r(178)+( 1.200)*r(179)+( 0.880)*r(180)
     &                +( 0.840)*r(181)+( 1.000)*r(219)+( 1.000)*r(220)
     &                +( 1.000)*r(221)+( 2.000)*r(222)
c
        Loss(iXO2N )= +( 1.000)*r( 55)+( 1.000)*r( 57)+( 2.000)*r( 59)
     &                +( 1.000)*r( 60)
c
        Gain(iXO2N )= +( 0.009)*r(113)+( 0.130)*r(115)+( 0.040)*r(116)
     &                +( 0.010)*r(119)+( 0.090)*r(122)+( 0.088)*r(145)
     &                +( 0.250)*r(154)+( 0.180)*r(155)+( 0.250)*r(156)
     &                +( 0.130)*r(173)+( 0.009)*r(174)+( 0.080)*r(178)
     &                +( 0.250)*r(179)+( 0.120)*r(180)+( 0.160)*r(181)
c
        Loss(iTO2  )= +( 1.000)*r(132)+( 1.000)*r(133)
c
        Gain(iTO2  )= +( 0.560)*r(131)+( 0.300)*r(141)
c
        Loss(iROR  )= +( 1.000)*r(116)+( 1.000)*r(117)+( 1.000)*r(118)
c
        Gain(iROR  )= +( 0.760)*r(115)+( 0.020)*r(116)+( 0.760)*r(173)
c
        Loss(iCRO  )= +( 1.000)*r(136)+( 1.000)*r(137)
c
        Gain(iCRO  )= +( 0.400)*r(134)+( 1.000)*r(135)
c
        Loss(iMEO2 )= +( 1.000)*r( 68)+( 1.000)*r( 69)+( 2.000)*r( 70)
     &                +( 1.000)*r( 93)+( 1.000)*r(109)
c
        Gain(iMEO2 )= +( 1.000)*r( 67)+( 0.700)*r( 71)+( 1.000)*r( 87)
     &                +( 1.000)*r( 88)+( 0.900)*r( 93)+( 0.900)*r( 94)
     &                +( 2.000)*r( 95)+( 1.000)*r( 97)+( 1.000)*r( 98)
     &                +( 1.000)*r(102)+( 1.000)*r(112)+( 1.000)*r(172)
     &                +( 1.000)*r(218)
c
        Loss(iHCO3 )= +( 1.000)*r( 80)+( 1.000)*r( 81)+( 1.000)*r( 82)
c
        Gain(iHCO3 )= +( 1.000)*r( 79)
c
        Loss(iCXO3 )= +( 1.000)*r(103)+( 1.000)*r(104)+( 1.000)*r(108)
     &                +( 1.000)*r(109)+( 1.000)*r(110)+( 2.000)*r(111)
     &                +( 1.000)*r(112)
c
        Gain(iCXO3 )= +( 1.000)*r( 99)+( 1.000)*r(100)+( 1.000)*r(101)
     &                +( 1.000)*r(105)+( 1.000)*r(106)+( 0.250)*r(144)
     &                +( 0.200)*r(146)+( 0.250)*r(149)+( 0.075)*r(151)
     &                +( 0.390)*r(155)+( 1.000)*r(184)
c
        Loss(iI    )= +( 1.000)*r(190)+( 1.000)*r(191)+( 1.000)*r(192)
     &                +( 1.000)*r(193)+( 1.000)*r(194)+( 1.000)*r(195)
     &                +( 1.000)*r(196)
c
        Gain(iI    )= +( 1.000)*r(197)+( 1.000)*r(198)+( 1.000)*r(201)
     &                +( 2.000)*r(204)+( 1.000)*r(205)+( 1.000)*r(206)
     &                +( 1.000)*r(207)+( 0.500)*r(211)+( 1.000)*r(212)
     &                +( 0.500)*r(213)+( 1.000)*r(215)+( 1.000)*r(217)
     &                +( 1.000)*r(218)+( 1.000)*r(219)+( 0.180)*r(220)
     &                +( 1.000)*r(222)
c
        Loss(iNO   )= +( 1.000)*r(  3)+( 1.000)*r(  6)+( 1.000)*r( 16)
     &                +( 2.000)*r( 22)+( 1.000)*r( 23)+( 1.000)*r( 24)
     &                +( 1.000)*r( 30)+( 1.000)*r( 54)+( 1.000)*r( 55)
     &                +( 1.000)*r( 68)+( 1.000)*r( 81)+( 1.000)*r( 88)
     &                +( 1.000)*r(103)+( 1.000)*r(132)+( 1.000)*r(161)
     &                +( 1.000)*r(192)+( 1.000)*r(198)+( 1.000)*r(208)
c
        Gain(iNO   )= +( 1.000)*r(  1)+( 1.000)*r(  4)+( 1.000)*r( 15)
     &                +( 1.000)*r( 17)+( 1.000)*r( 25)+( 1.000)*r( 27)
     &                +( 0.200)*r(148)+( 1.000)*r(195)+( 0.500)*r(211)
c
        Loss(iNO2  )= +( 1.000)*r(  1)+( 1.000)*r(  4)+( 1.000)*r(  5)
     &                +( 1.000)*r(  7)+( 1.000)*r( 17)+( 1.000)*r( 18)
     &                +( 1.000)*r( 23)+( 1.000)*r( 28)+( 1.000)*r( 31)
     &                +( 1.000)*r( 89)+( 1.000)*r(104)+( 1.000)*r(118)
     &                +( 1.000)*r(136)+( 1.000)*r(148)+( 1.000)*r(163)
     &                +( 1.000)*r(193)+( 1.000)*r(199)
c
        Gain(iNO2  )= +( 1.000)*r(  3)+( 1.000)*r(  6)+( 1.000)*r( 14)
     &                +( 2.000)*r( 16)+( 1.000)*r( 17)+( 1.000)*r( 21)
     &                +( 2.000)*r( 22)+( 1.000)*r( 26)+( 1.000)*r( 27)
     &                +( 1.000)*r( 30)+( 1.000)*r( 32)+( 1.000)*r( 33)
     &                +( 1.000)*r( 46)+( 1.000)*r( 47)+( 1.000)*r( 49)
     &                +( 2.000)*r( 50)+( 0.610)*r( 51)+( 1.000)*r( 52)
     &                +( 1.000)*r( 53)+( 1.000)*r( 54)+( 1.000)*r( 62)
     &                +( 1.000)*r( 68)+( 1.000)*r( 81)+( 1.000)*r( 88)
     &                +( 1.000)*r( 90)+( 1.000)*r( 91)+( 1.000)*r(103)
        Gain(iNO2  ) = Gain(iNO2  )
     &                +( 1.000)*r(105)+( 1.000)*r(106)+( 1.000)*r(107)
     &                +( 1.000)*r(122)+( 1.000)*r(126)+( 1.000)*r(130)
     &                +( 0.900)*r(132)+( 0.200)*r(147)+( 0.470)*r(156)
     &                +( 1.000)*r(161)+( 1.000)*r(164)+( 1.000)*r(165)
     &                +( 1.000)*r(188)+( 1.000)*r(194)+( 1.000)*r(196)
     &                +( 1.000)*r(198)+( 1.000)*r(208)+( 0.500)*r(211)
     &                +( 1.000)*r(212)+( 0.500)*r(213)+( 1.000)*r(214)
c
        Loss(iO3   )= +( 1.000)*r(  3)+( 1.000)*r(  7)+( 1.000)*r(  8)
     &                +( 1.000)*r(  9)+( 1.000)*r( 12)+( 1.000)*r( 13)
     &                +( 1.000)*r( 49)+( 1.000)*r(121)+( 1.000)*r(125)
     &                +( 1.000)*r(129)+( 1.000)*r(140)+( 1.000)*r(146)
     &                +( 1.000)*r(150)+( 1.000)*r(155)+( 1.000)*r(159)
     &                +( 1.000)*r(190)
c
        Gain(iO3   )= +( 1.000)*r(  2)+( 0.200)*r( 92)+( 0.200)*r(108)
c
        Loss(iPAN  )= +( 1.000)*r( 90)+( 1.000)*r( 91)
c
        Gain(iPAN  )= +( 1.000)*r( 89)
c
        Loss(iPANX )= +( 1.000)*r(105)+( 1.000)*r(106)+( 1.000)*r(107)
c
        Gain(iPANX )= +( 1.000)*r(104)
c
        Loss(iPNA  )= +( 1.000)*r( 32)+( 1.000)*r( 33)+( 1.000)*r( 51)
c
        Gain(iPNA  )= +( 1.000)*r( 31)
c
c
      do l=1,neq(1)
        rate(l) = gain(l) -loss(l)
      enddo
c
      return
      end
