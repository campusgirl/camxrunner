      subroutine lsrate7(neq,t,y,rate,nr,r)
      implicit none
c
c----CAMx v6.00 130506
c
c     LSRATE7 computes double precision species rates
c
c     Copyright 1996 - 2013
c     ENVIRON International Corporation
c     Created by the CMC version 5.2
c
c     Routines Called:
c        LSRXN7
c
c     Called by:
c        LSODE
c
      include "camx.prm"
      include "chmdat.inc"
      include "lsbox.inc"
      include "ddmchm.inc"
c
      integer neq, nr, l
      double precision t
      double precision y(*)
      double precision rate(neq)
      double precision r(MXREACT)
      double precision loss(MXSPEC+1)
      double precision gain(MXSPEC+1)
c
c --- Entry point
c
c --- Get reaction rates, r
c
      call lsrxn7(dH2O,dM,dO2,dCH4,dH2,y,dbrk,r)
c
      do l = 1,neq
        Loss(l) = 0.0d0
        Gain(l) = 0.0d0
      enddo
c
c --- Calculate the species rates
c
c
c   NO2    NO     O    O3   NO3   O1D    OH   HO2  H2O2  N2O5
c  HNO3  HONO   PNA   SO2  SULF  C2O3  MEO2   RO2   PAN  PACD
c  AACD  CXO3  ALD2  XO2H  PANX  FORM  MEPX  MEOH  ROOH   XO2
c  XO2N   NTR  FACD    CO  HCO3  ALDX  GLYD   GLY  MGLY  ETHA
c  ETOH   KET   PAR  ACET  PRPA   ROR  ETHY   ETH   OLE  IOLE
c  ISOP  ISO2  INTR  ISPD  ISPX  EPOX  EPX2  TERP  BENZ  CRES
c  BZO2  OPEN   TOL   TO2  XOPN   XYL  XLO2   CRO  CAT1  CRON
c  CRNO  CRN2  CRPX  CAO2  OPO3  OPAN
c
        Loss(lNO2  )= +( 1.000)*r(  1)+( 1.000)*r(  5)+( 1.000)*r(  6)
     &                +( 1.000)*r( 26)+( 1.000)*r( 30)+( 1.000)*r( 36)
     &                +( 1.000)*r( 41)+( 1.000)*r( 45)+( 1.000)*r( 48)
     &                +( 1.000)*r( 54)+( 1.000)*r( 62)+( 1.000)*r(135)
     &                +( 1.000)*r(189)+( 1.000)*r(193)+( 1.000)*r(214)
c
        Gain(lNO2  )= +( 1.000)*r(  3)+( 1.000)*r(  4)+( 2.000)*r( 24)
     &                +( 1.000)*r( 25)+( 1.000)*r( 27)+( 2.000)*r( 29)
     &                +( 1.000)*r( 30)+( 1.000)*r( 31)+( 1.000)*r( 32)
     &                +( 1.000)*r( 33)+( 1.000)*r( 34)+( 2.000)*r( 35)
     &                +( 1.000)*r( 37)+( 1.000)*r( 38)+( 1.000)*r( 42)
     &                +( 1.000)*r( 44)+( 1.000)*r( 47)+( 1.000)*r( 49)
     &                +( 0.590)*r( 50)+( 1.000)*r( 51)+( 1.000)*r( 53)
     &                +( 1.000)*r( 55)+( 0.600)*r( 56)+( 1.000)*r( 61)
     &                +( 1.000)*r( 63)+( 0.600)*r( 64)+( 1.000)*r( 71)
        Gain(lNO2  ) = Gain(lNO2  )
     &                +( 1.000)*r( 75)+( 1.000)*r( 79)+( 1.000)*r( 92)
     &                +( 1.000)*r(103)+( 0.500)*r(140)+( 0.500)*r(144)
     &                +( 0.500)*r(148)+( 0.883)*r(150)+( 0.350)*r(156)
     &                +( 1.000)*r(164)+( 0.444)*r(167)+( 0.470)*r(171)
     &                +( 0.918)*r(173)+( 0.860)*r(178)+( 0.860)*r(183)
     &                +( 1.000)*r(195)+( 0.500)*r(202)+( 0.860)*r(209)
     &                +( 1.000)*r(213)+( 1.000)*r(215)
c
        Loss(lNO   )= +( 1.000)*r(  3)+( 1.000)*r(  4)+( 2.000)*r( 24)
     &                +( 1.000)*r( 25)+( 1.000)*r( 29)+( 1.000)*r( 40)
     &                +( 1.000)*r( 41)+( 1.000)*r( 53)+( 1.000)*r( 61)
     &                +( 1.000)*r( 68)+( 1.000)*r( 71)+( 1.000)*r( 75)
     &                +( 1.000)*r( 79)+( 1.000)*r( 83)+( 1.000)*r(103)
     &                +( 1.000)*r(150)+( 1.000)*r(164)+( 1.000)*r(173)
     &                +( 1.000)*r(178)+( 1.000)*r(183)+( 1.000)*r(195)
     &                +( 1.000)*r(209)+( 1.000)*r(213)
c
        Gain(lNO   )= +( 1.000)*r(  1)+( 1.000)*r(  5)+( 1.000)*r( 28)
     &                +( 1.000)*r( 30)+( 1.000)*r( 42)+( 1.000)*r( 43)
     &                +( 1.000)*r( 68)
c
        Loss(lO    )= +( 1.000)*r(  2)+( 1.000)*r(  4)+( 1.000)*r(  5)
     &                +( 1.000)*r(  6)+( 1.000)*r(  7)+( 1.000)*r( 14)
     &                +( 1.000)*r( 15)+( 1.000)*r( 23)+( 1.000)*r( 31)
     &                +( 1.000)*r( 99)+( 1.000)*r(105)+( 1.000)*r(109)
     &                +( 1.000)*r(137)+( 1.000)*r(141)+( 1.000)*r(145)
     &                +( 1.000)*r(168)
c
        Gain(lO    )= +( 1.000)*r(  1)+( 1.000)*r(  8)+( 1.000)*r( 10)
     &                +( 1.000)*r( 16)+( 1.000)*r( 27)
c
        Loss(lO3   )= +( 1.000)*r(  3)+( 1.000)*r(  7)+( 1.000)*r(  8)
     &                +( 1.000)*r(  9)+( 1.000)*r( 12)+( 1.000)*r( 13)
     &                +( 1.000)*r( 26)+( 1.000)*r( 34)+( 1.000)*r(139)
     &                +( 1.000)*r(143)+( 1.000)*r(147)+( 1.000)*r(155)
     &                +( 1.000)*r(158)+( 1.000)*r(170)+( 1.000)*r(194)
     &                +( 1.000)*r(201)+( 1.000)*r(205)
c
        Gain(lO3   )= +( 1.000)*r(  2)+( 0.150)*r( 57)+( 0.150)*r( 65)
     &                +( 0.150)*r(216)
c
        Loss(lNO3  )= +( 1.000)*r( 27)+( 1.000)*r( 28)+( 1.000)*r( 29)
     &                +( 1.000)*r( 30)+( 1.000)*r( 31)+( 1.000)*r( 32)
     &                +( 1.000)*r( 33)+( 1.000)*r( 34)+( 2.000)*r( 35)
     &                +( 1.000)*r( 36)+( 1.000)*r(100)+( 1.000)*r(107)
     &                +( 1.000)*r(111)+( 1.000)*r(115)+( 1.000)*r(118)
     &                +( 1.000)*r(120)+( 1.000)*r(140)+( 1.000)*r(144)
     &                +( 1.000)*r(148)+( 1.000)*r(156)+( 1.000)*r(159)
     &                +( 1.000)*r(171)+( 1.000)*r(188)+( 1.000)*r(192)
     &                +( 1.000)*r(202)+( 1.000)*r(206)+( 1.000)*r(208)
c
        Gain(lNO3  )= +( 1.000)*r(  6)+( 1.000)*r( 26)+( 1.000)*r( 37)
     &                +( 1.000)*r( 38)+( 1.000)*r( 46)+( 0.410)*r( 50)
     &                +( 0.400)*r( 56)+( 0.400)*r( 64)+( 0.185)*r(167)
c
        Loss(lO1D  )= +( 1.000)*r( 10)+( 1.000)*r( 11)
c
        Gain(lO1D  )= +( 1.000)*r(  9)
c
        Loss(lOH   )= +( 1.000)*r( 12)+( 1.000)*r( 14)+( 2.000)*r( 16)
     &                +( 2.000)*r( 17)+( 1.000)*r( 18)+( 1.000)*r( 22)
     &                +( 1.000)*r( 32)+( 1.000)*r( 40)+( 1.000)*r( 44)
     &                +( 1.000)*r( 45)+( 1.000)*r( 46)+( 1.000)*r( 51)
     &                +( 1.000)*r( 52)+( 1.000)*r( 87)+( 1.000)*r( 89)
     &                +( 1.000)*r( 91)+( 1.000)*r( 93)+( 1.000)*r( 94)
     &                +( 1.000)*r( 95)+( 1.000)*r( 96)+( 1.000)*r(106)
     &                +( 1.000)*r(110)+( 1.000)*r(113)+( 1.000)*r(116)
     &                +( 1.000)*r(121)+( 1.000)*r(122)+( 1.000)*r(123)
        Loss(lOH   ) = Loss(lOH   )
     &                +( 1.000)*r(124)+( 1.000)*r(125)+( 1.000)*r(126)
     &                +( 1.000)*r(127)+( 1.000)*r(130)+( 1.000)*r(131)
     &                +( 1.000)*r(132)+( 1.000)*r(136)+( 1.000)*r(138)
     &                +( 1.000)*r(142)+( 1.000)*r(146)+( 1.000)*r(149)
     &                +( 1.000)*r(157)+( 1.000)*r(161)+( 1.000)*r(162)
     &                +( 1.000)*r(167)+( 1.000)*r(169)+( 1.000)*r(172)
     &                +( 1.000)*r(177)+( 1.000)*r(182)+( 1.000)*r(187)
     &                +( 1.000)*r(191)+( 1.000)*r(198)+( 1.000)*r(200)
        Loss(lOH   ) = Loss(lOH   )
     &                +( 1.000)*r(204)+( 1.000)*r(207)
c
        Gain(lOH   )= +( 2.000)*r( 11)+( 1.000)*r( 13)+( 1.000)*r( 15)
     &                +( 2.000)*r( 21)+( 1.000)*r( 23)+( 1.000)*r( 25)
     &                +( 1.000)*r( 33)+( 1.000)*r( 43)+( 1.000)*r( 47)
     &                +( 0.410)*r( 50)+( 0.440)*r( 57)+( 0.440)*r( 65)
     &                +( 0.400)*r( 87)+( 1.000)*r( 88)+( 0.400)*r( 89)
     &                +( 1.000)*r( 90)+( 1.000)*r( 99)+( 0.200)*r(104)
     &                +( 1.000)*r(105)+( 1.000)*r(109)+( 0.190)*r(114)
     &                +( 0.700)*r(136)+( 0.300)*r(137)+( 0.160)*r(139)
     &                +( 0.100)*r(141)+( 0.334)*r(143)+( 0.500)*r(147)
        Gain(lOH   ) = Gain(lOH   )
     &                +( 0.120)*r(151)+( 0.040)*r(154)+( 0.266)*r(155)
     &                +( 0.268)*r(158)+( 0.933)*r(161)+( 1.125)*r(163)
     &                +( 0.125)*r(164)+( 0.100)*r(165)+( 0.125)*r(166)
     &                +( 0.570)*r(170)+( 0.118)*r(172)+( 0.100)*r(177)
     &                +( 0.244)*r(182)+( 1.000)*r(197)+( 0.500)*r(201)
     &                +( 0.500)*r(205)+( 0.440)*r(216)
c
        Loss(lHO2  )= +( 1.000)*r( 13)+( 1.000)*r( 15)+( 1.000)*r( 18)
     &                +( 2.000)*r( 19)+( 2.000)*r( 20)+( 1.000)*r( 25)
     &                +( 1.000)*r( 33)+( 1.000)*r( 48)+( 1.000)*r( 57)
     &                +( 1.000)*r( 65)+( 1.000)*r( 69)+( 1.000)*r( 72)
     &                +( 1.000)*r( 76)+( 1.000)*r( 80)+( 1.000)*r( 84)
     &                +( 1.000)*r(101)+( 1.000)*r(104)+( 1.000)*r(151)
     &                +( 1.000)*r(163)+( 1.000)*r(175)+( 1.000)*r(180)
     &                +( 1.000)*r(184)+( 1.000)*r(190)+( 1.000)*r(196)
     &                +( 1.000)*r(210)+( 1.000)*r(216)
c
        Gain(lHO2  )= +( 1.000)*r( 12)+( 1.000)*r( 14)+( 1.000)*r( 22)
     &                +( 1.000)*r( 23)+( 1.000)*r( 32)+( 1.000)*r( 49)
     &                +( 0.590)*r( 50)+( 1.000)*r( 52)+( 1.000)*r( 69)
     &                +( 1.000)*r( 71)+( 0.900)*r( 73)+( 0.370)*r( 74)
     &                +( 1.000)*r( 75)+( 0.800)*r( 77)+( 0.600)*r( 78)
     &                +( 0.800)*r( 85)+( 1.000)*r( 90)+( 1.000)*r( 93)
     &                +( 1.000)*r( 96)+( 2.000)*r( 97)+( 1.000)*r( 99)
     &                +( 1.000)*r(100)+( 1.000)*r(102)+( 1.000)*r(103)
     &                +( 0.200)*r(104)+( 1.000)*r(108)+( 1.000)*r(112)
        Gain(lHO2  ) = Gain(lHO2  )
     &                +( 0.200)*r(113)+( 1.400)*r(114)+( 1.000)*r(116)
     &                +( 2.000)*r(117)+( 1.000)*r(118)+( 1.000)*r(119)
     &                +( 1.000)*r(122)+( 1.000)*r(123)+( 1.000)*r(126)
     &                +( 0.900)*r(127)+( 1.000)*r(134)+( 0.300)*r(136)
     &                +( 1.000)*r(137)+( 0.160)*r(139)+( 0.100)*r(141)
     &                +( 0.080)*r(143)+( 0.803)*r(150)+( 0.120)*r(151)
     &                +( 0.709)*r(152)+( 0.803)*r(153)+( 0.800)*r(154)
     &                +( 0.066)*r(155)+( 0.090)*r(158)+( 0.850)*r(159)
        Gain(lHO2  ) = Gain(lHO2  )
     &                +( 0.333)*r(160)+( 0.825)*r(163)+( 0.825)*r(164)
     &                +( 0.660)*r(165)+( 0.825)*r(166)+( 0.530)*r(172)
     &                +( 0.918)*r(173)+( 1.000)*r(174)+( 1.000)*r(176)
     &                +( 0.180)*r(177)+( 0.860)*r(178)+( 1.000)*r(179)
     &                +( 1.000)*r(181)+( 0.155)*r(182)+( 0.860)*r(183)
     &                +( 1.000)*r(185)+( 1.000)*r(186)+( 1.000)*r(187)
     &                +( 0.700)*r(199)+( 1.000)*r(203)+( 0.560)*r(205)
     &                +( 1.200)*r(209)+( 1.000)*r(211)+( 1.000)*r(212)
c
        Loss(lH2O2 )= +( 1.000)*r( 21)+( 1.000)*r( 22)+( 1.000)*r( 23)
c
        Gain(lH2O2 )= +( 1.000)*r( 17)+( 1.000)*r( 19)+( 1.000)*r( 20)
     &                +( 0.040)*r(143)+( 0.080)*r(147)
c
        Loss(lN2O5 )= +( 1.000)*r( 37)+( 1.000)*r( 38)+( 1.000)*r( 39)
c
        Gain(lN2O5 )= +( 1.000)*r( 36)
c
        Loss(lHNO3 )= +( 1.000)*r( 46)+( 1.000)*r( 47)
c
        Gain(lHNO3 )= +( 2.000)*r( 39)+( 1.000)*r( 45)+( 1.000)*r( 91)
     &                +( 1.000)*r(100)+( 1.000)*r(107)+( 1.000)*r(111)
     &                +( 1.000)*r(115)+( 1.000)*r(118)+( 1.000)*r(120)
     &                +( 0.150)*r(159)+( 1.000)*r(188)+( 1.000)*r(192)
     &                +( 1.000)*r(206)+( 1.000)*r(208)
c
        Loss(lHONO )= +( 2.000)*r( 42)+( 1.000)*r( 43)+( 1.000)*r( 44)
c
        Gain(lHONO )= +( 1.000)*r( 40)+( 2.000)*r( 41)
c
        Loss(lPNA  )= +( 1.000)*r( 49)+( 1.000)*r( 50)+( 1.000)*r( 51)
c
        Gain(lPNA  )= +( 1.000)*r( 48)
c
        Loss(lSO2  )= +( 1.000)*r( 52)
c
        Gain(lSO2  )= 0.0
c
        Loss(lSULF )= 0.0
c
        Gain(lSULF )= +( 1.000)*r( 52)
c
        Loss(lC2O3 )= +( 1.000)*r( 53)+( 1.000)*r( 54)+( 1.000)*r( 57)
     &                +( 1.000)*r( 58)+( 2.000)*r( 59)+( 1.000)*r( 60)
     &                +( 1.000)*r( 73)+( 1.000)*r( 77)+( 1.000)*r( 81)
     &                +( 1.000)*r( 85)+( 1.000)*r(152)+( 1.000)*r(165)
     &                +( 1.000)*r(174)+( 1.000)*r(179)+( 1.000)*r(185)
     &                +( 1.000)*r(211)+( 1.000)*r(217)
c
        Gain(lC2O3 )= +( 1.000)*r( 55)+( 0.600)*r( 56)+( 1.000)*r( 58)
     &                +( 1.000)*r( 95)+( 1.000)*r(105)+( 1.000)*r(106)
     &                +( 1.000)*r(107)+( 0.800)*r(113)+( 1.000)*r(115)
     &                +( 1.000)*r(119)+( 1.000)*r(120)+( 1.000)*r(121)
     &                +( 0.500)*r(128)+( 0.620)*r(129)+( 1.000)*r(130)
     &                +( 0.379)*r(157)+( 0.114)*r(158)+( 0.967)*r(160)
     &                +( 0.300)*r(199)+( 0.600)*r(201)+( 0.120)*r(205)
c
        Loss(lMEO2 )= +( 1.000)*r( 71)+( 1.000)*r( 72)+( 1.000)*r( 73)
     &                +( 1.000)*r( 74)
c
        Gain(lMEO2 )= +( 1.000)*r( 53)+( 0.400)*r( 56)+( 0.440)*r( 57)
     &                +( 2.000)*r( 59)+( 1.000)*r( 60)+( 0.900)*r( 73)
     &                +( 0.800)*r( 77)+( 0.800)*r( 81)+( 0.800)*r( 85)
     &                +( 0.600)*r( 87)+( 1.000)*r( 88)+( 1.000)*r( 94)
     &                +( 1.000)*r(108)+( 1.000)*r(124)+( 0.500)*r(128)
     &                +( 1.380)*r(129)+( 0.800)*r(152)+( 0.800)*r(165)
     &                +( 1.000)*r(174)+( 1.000)*r(179)+( 1.000)*r(185)
     &                +( 1.000)*r(211)+( 1.000)*r(217)
c
        Loss(lRO2  )= +( 1.000)*r( 58)+( 1.000)*r( 66)+( 1.000)*r( 68)
     &                +( 1.000)*r( 69)+( 2.000)*r( 70)+( 1.000)*r( 74)
     &                +( 1.000)*r( 78)+( 1.000)*r( 82)+( 1.000)*r( 86)
     &                +( 1.000)*r(153)+( 1.000)*r(166)+( 1.000)*r(176)
     &                +( 1.000)*r(181)+( 1.000)*r(186)+( 1.000)*r(212)
     &                +( 1.000)*r(218)
c
        Gain(lRO2  )= +( 1.000)*r( 53)+( 0.400)*r( 56)+( 0.440)*r( 57)
     &                +( 2.000)*r( 59)+( 2.000)*r( 60)+( 1.000)*r( 61)
     &                +( 0.400)*r( 64)+( 0.440)*r( 65)+( 0.800)*r( 66)
     &                +( 2.000)*r( 67)+( 0.900)*r( 73)+( 1.000)*r( 74)
     &                +( 0.800)*r( 77)+( 1.000)*r( 78)+( 0.800)*r( 81)
     &                +( 1.000)*r( 82)+( 0.800)*r( 85)+( 1.000)*r( 86)
     &                +( 0.600)*r( 87)+( 1.000)*r( 88)+( 0.600)*r( 89)
     &                +( 1.000)*r( 91)+( 1.000)*r( 92)+( 1.000)*r( 94)
     &                +( 1.000)*r(108)+( 1.000)*r(112)+( 0.110)*r(114)
        Gain(lRO2  ) = Gain(lRO2  )
     &                +( 0.300)*r(116)+( 1.000)*r(118)+( 1.000)*r(120)
     &                +( 1.000)*r(124)+( 1.000)*r(125)+( 0.100)*r(127)
     &                +( 1.000)*r(128)+( 1.380)*r(129)+( 1.000)*r(130)
     &                +( 1.000)*r(131)+( 1.000)*r(132)+( 0.980)*r(133)
     &                +( 0.700)*r(137)+( 1.000)*r(138)+( 1.000)*r(140)
     &                +( 0.210)*r(141)+( 1.170)*r(142)+( 0.150)*r(143)
     &                +( 1.000)*r(144)+( 0.100)*r(145)+( 1.000)*r(146)
     &                +( 0.300)*r(147)+( 1.000)*r(148)+( 1.000)*r(149)
        Gain(lRO2  ) = Gain(lRO2  )
     &                +( 0.080)*r(150)+( 0.871)*r(152)+( 1.080)*r(153)
     &                +( 0.200)*r(155)+( 1.000)*r(156)+( 0.792)*r(157)
     &                +( 0.064)*r(158)+( 0.075)*r(159)+( 0.700)*r(160)
     &                +( 0.067)*r(161)+( 1.000)*r(162)+( 0.800)*r(165)
     &                +( 1.000)*r(166)+( 1.000)*r(167)+( 1.500)*r(169)
     &                +( 0.940)*r(170)+( 1.280)*r(171)+( 0.352)*r(172)
     &                +( 1.000)*r(174)+( 1.000)*r(176)+( 0.720)*r(177)
     &                +( 1.000)*r(179)+( 1.000)*r(181)+( 0.602)*r(182)
        Gain(lRO2  ) = Gain(lRO2  )
     &                +( 1.000)*r(185)+( 1.000)*r(186)+( 0.180)*r(187)
     &                +( 0.700)*r(188)+( 1.000)*r(199)+( 1.000)*r(200)
     &                +( 0.300)*r(201)+( 1.000)*r(202)+( 0.400)*r(204)
     &                +( 1.000)*r(207)+( 1.000)*r(211)+( 1.000)*r(212)
     &                +( 1.000)*r(213)+( 0.440)*r(216)+( 2.000)*r(217)
     &                +( 0.800)*r(218)
c
        Loss(lPAN  )= +( 1.000)*r( 55)+( 1.000)*r( 56)
c
        Gain(lPAN  )= +( 1.000)*r( 54)
c
        Loss(lPACD )= +( 1.000)*r( 95)
c
        Gain(lPACD )= +( 0.410)*r( 57)+( 0.410)*r( 65)+( 0.410)*r(216)
c
        Loss(lAACD )= +( 1.000)*r( 94)
c
        Gain(lAACD )= +( 0.150)*r( 57)+( 0.150)*r( 65)+( 0.100)*r( 73)
     &                +( 0.200)*r( 77)+( 0.200)*r( 81)+( 0.200)*r( 85)
     &                +( 0.130)*r(143)+( 0.080)*r(147)+( 0.200)*r(152)
     &                +( 0.200)*r(165)+( 0.150)*r(216)+( 0.200)*r(218)
c
        Loss(lCXO3 )= +( 1.000)*r( 60)+( 1.000)*r( 61)+( 1.000)*r( 62)
     &                +( 1.000)*r( 65)+( 1.000)*r( 66)+( 2.000)*r( 67)
c
        Gain(lCXO3 )= +( 1.000)*r( 63)+( 0.600)*r( 64)+( 1.000)*r(109)
     &                +( 1.000)*r(110)+( 1.000)*r(111)+( 0.500)*r(128)
     &                +( 0.200)*r(155)+( 0.209)*r(157)+( 0.075)*r(159)
     &                +( 0.390)*r(170)
c
        Loss(lALD2 )= +( 1.000)*r(105)+( 1.000)*r(106)+( 1.000)*r(107)
     &                +( 1.000)*r(108)
c
        Gain(lALD2 )= +( 1.000)*r( 60)+( 1.000)*r( 61)+( 0.400)*r( 64)
     &                +( 0.440)*r( 65)+( 0.800)*r( 66)+( 2.000)*r( 67)
     &                +( 1.000)*r(112)+( 0.991)*r(125)+( 0.950)*r(127)
     &                +( 0.500)*r(128)+( 0.740)*r(133)+( 0.200)*r(141)
     &                +( 0.488)*r(142)+( 0.295)*r(143)+( 0.250)*r(144)
     &                +( 1.240)*r(145)+( 1.300)*r(146)+( 0.732)*r(147)
     &                +( 0.500)*r(148)+( 0.020)*r(158)+( 0.067)*r(160)
     &                +( 0.100)*r(201)+( 0.020)*r(205)
c
        Loss(lXO2H )= +( 1.000)*r( 75)+( 1.000)*r( 76)+( 1.000)*r( 77)
     &                +( 1.000)*r( 78)
c
        Gain(lXO2H )= +( 1.000)*r( 60)+( 1.000)*r( 61)+( 0.400)*r( 64)
     &                +( 0.440)*r( 65)+( 0.800)*r( 66)+( 2.000)*r( 67)
     &                +( 0.540)*r( 89)+( 1.000)*r( 91)+( 1.000)*r( 92)
     &                +( 1.000)*r(112)+( 0.110)*r(114)+( 0.991)*r(125)
     &                +( 0.100)*r(127)+( 0.500)*r(128)+( 0.970)*r(131)
     &                +( 0.110)*r(132)+( 0.940)*r(133)+( 0.700)*r(137)
     &                +( 1.000)*r(138)+( 0.500)*r(140)+( 0.200)*r(141)
     &                +( 0.976)*r(142)+( 0.150)*r(143)+( 0.480)*r(144)
     &                +( 0.100)*r(145)+( 1.000)*r(146)+( 0.300)*r(147)
        Gain(lXO2H ) = Gain(lXO2H )
     &                +( 0.480)*r(148)+( 0.080)*r(150)+( 0.071)*r(152)
     &                +( 0.080)*r(153)+( 0.640)*r(156)+( 0.318)*r(157)
     &                +( 0.064)*r(158)+( 0.075)*r(159)+( 0.700)*r(160)
     &                +( 0.370)*r(167)+( 0.750)*r(169)+( 0.070)*r(170)
     &                +( 0.280)*r(171)+( 0.070)*r(177)+( 0.058)*r(182)
     &                +( 0.120)*r(187)+( 0.360)*r(188)+( 1.000)*r(200)
     &                +( 0.300)*r(201)+( 0.450)*r(202)+( 1.000)*r(213)
     &                +( 0.440)*r(216)+( 0.800)*r(218)
c
        Loss(lPANX )= +( 1.000)*r( 63)+( 1.000)*r( 64)
c
        Gain(lPANX )= +( 1.000)*r( 62)
c
        Loss(lFORM )= +( 1.000)*r( 96)+( 1.000)*r( 97)+( 1.000)*r( 98)
     &                +( 1.000)*r( 99)+( 1.000)*r(100)+( 1.000)*r(101)
c
        Gain(lFORM )= +( 1.000)*r( 71)+( 0.100)*r( 72)+( 1.000)*r( 73)
     &                +( 0.685)*r( 74)+( 0.400)*r( 87)+( 1.000)*r(102)
     &                +( 0.740)*r(114)+( 1.000)*r(126)+( 0.078)*r(127)
     &                +( 1.000)*r(130)+( 1.000)*r(137)+( 1.560)*r(138)
     &                +( 1.000)*r(139)+( 1.125)*r(140)+( 0.200)*r(141)
     &                +( 0.781)*r(142)+( 0.555)*r(143)+( 0.500)*r(144)
     &                +( 0.128)*r(147)+( 0.660)*r(150)+( 0.120)*r(151)
     &                +( 0.583)*r(152)+( 0.660)*r(153)+( 0.040)*r(154)
     &                +( 0.600)*r(155)+( 0.350)*r(156)+( 0.240)*r(157)
        Gain(lFORM ) = Gain(lFORM )
     &                +( 0.150)*r(158)+( 0.282)*r(159)+( 0.900)*r(160)
     &                +( 0.375)*r(163)+( 0.375)*r(164)+( 0.300)*r(165)
     &                +( 0.375)*r(166)+( 0.592)*r(167)+( 0.280)*r(169)
     &                +( 0.240)*r(170)+( 0.060)*r(187)+( 0.240)*r(188)
     &                +( 0.080)*r(205)+( 0.344)*r(209)
c
        Loss(lMEPX )= +( 1.000)*r( 87)+( 1.000)*r( 88)
c
        Gain(lMEPX )= +( 0.900)*r( 72)+( 0.500)*r(104)
c
        Loss(lMEOH )= +( 1.000)*r(126)
c
        Gain(lMEOH )= +( 0.315)*r( 74)+( 0.150)*r(114)
c
        Loss(lROOH )= +( 1.000)*r( 89)+( 1.000)*r( 90)
c
        Gain(lROOH )= +( 1.000)*r( 76)+( 1.000)*r( 80)+( 1.000)*r( 84)
c
        Loss(lXO2  )= +( 1.000)*r( 79)+( 1.000)*r( 80)+( 1.000)*r( 81)
     &                +( 1.000)*r( 82)
c
        Gain(lXO2  )= +( 0.300)*r(116)+( 1.000)*r(118)+( 1.000)*r(120)
     &                +( 1.000)*r(130)+( 0.760)*r(132)+( 0.500)*r(140)
     &                +( 0.195)*r(142)+( 0.480)*r(144)+( 0.480)*r(148)
     &                +( 0.200)*r(155)+( 0.330)*r(156)+( 0.379)*r(157)
     &                +( 0.630)*r(167)+( 0.500)*r(169)+( 0.690)*r(170)
     &                +( 0.750)*r(171)+( 0.240)*r(188)+( 0.450)*r(202)
     &                +( 1.000)*r(217)
c
        Loss(lXO2N )= +( 1.000)*r( 83)+( 1.000)*r( 84)+( 1.000)*r( 85)
     &                +( 1.000)*r( 86)
c
        Gain(lXO2N )= +( 0.060)*r( 89)+( 0.009)*r(125)+( 0.030)*r(131)
     &                +( 0.130)*r(132)+( 0.040)*r(133)+( 0.010)*r(141)
     &                +( 0.024)*r(142)+( 0.040)*r(144)+( 0.040)*r(148)
     &                +( 0.030)*r(156)+( 0.095)*r(157)+( 0.250)*r(169)
     &                +( 0.180)*r(170)+( 0.250)*r(171)+( 0.060)*r(187)
     &                +( 0.100)*r(188)+( 0.100)*r(202)
c
        Loss(lNTR  )= +( 1.000)*r( 91)+( 1.000)*r( 92)
c
        Gain(lNTR  )= +( 1.000)*r( 83)+( 1.000)*r(135)+( 0.500)*r(140)
     &                +( 0.500)*r(144)+( 0.500)*r(148)+( 0.850)*r(159)
     &                +( 0.266)*r(167)+( 0.530)*r(171)+( 0.082)*r(173)
     &                +( 0.140)*r(178)+( 0.140)*r(183)+( 2.000)*r(193)
     &                +( 0.500)*r(202)+( 0.140)*r(209)
c
        Loss(lFACD )= +( 1.000)*r( 93)
c
        Gain(lFACD )= +( 1.000)*r(103)+( 0.500)*r(104)+( 0.300)*r(136)
     &                +( 0.370)*r(139)+( 0.090)*r(143)+( 0.074)*r(163)
     &                +( 0.185)*r(167)
c
        Loss(lCO   )= +( 1.000)*r(123)
c
        Gain(lCO   )= +( 1.000)*r( 96)+( 1.000)*r( 97)+( 1.000)*r( 98)
     &                +( 1.000)*r( 99)+( 1.000)*r(100)+( 1.000)*r(108)
     &                +( 1.000)*r(112)+( 0.890)*r(114)+( 1.700)*r(116)
     &                +( 2.000)*r(117)+( 1.000)*r(118)+( 1.000)*r(119)
     &                +( 1.000)*r(121)+( 0.380)*r(129)+( 0.300)*r(136)
     &                +( 1.000)*r(137)+( 0.510)*r(139)+( 0.200)*r(141)
     &                +( 0.378)*r(143)+( 0.100)*r(145)+( 0.245)*r(147)
     &                +( 0.066)*r(155)+( 0.079)*r(157)+( 0.225)*r(158)
     &                +( 0.643)*r(159)+( 0.333)*r(160)+( 0.251)*r(163)
        Gain(lCO   ) = Gain(lCO   )
     &                +( 0.251)*r(164)+( 0.200)*r(165)+( 0.251)*r(166)
     &                +( 0.001)*r(170)+( 0.060)*r(187)+( 0.240)*r(188)
     &                +( 0.700)*r(199)+( 0.500)*r(201)+( 1.000)*r(203)
     &                +( 1.980)*r(205)+( 0.344)*r(209)
c
        Loss(lHCO3 )= +( 1.000)*r(102)+( 1.000)*r(103)+( 1.000)*r(104)
c
        Gain(lHCO3 )= +( 1.000)*r(101)
c
        Loss(lALDX )= +( 1.000)*r(109)+( 1.000)*r(110)+( 1.000)*r(111)
     &                +( 1.000)*r(112)
c
        Gain(lALDX )= +( 0.260)*r(131)+( 0.110)*r(132)+( 0.370)*r(133)
     &                +( 0.300)*r(141)+( 0.488)*r(142)+( 0.270)*r(143)
     &                +( 0.375)*r(144)+( 0.660)*r(145)+( 0.700)*r(146)
     &                +( 0.442)*r(147)+( 0.625)*r(148)+( 0.117)*r(150)
     &                +( 0.103)*r(152)+( 0.117)*r(153)+( 0.150)*r(155)
     &                +( 0.028)*r(157)+( 0.357)*r(159)+( 0.029)*r(161)
     &                +( 0.078)*r(167)+( 0.150)*r(168)+( 0.470)*r(169)
     &                +( 0.210)*r(170)+( 0.470)*r(171)+( 0.480)*r(188)
     &                +( 1.000)*r(213)+( 0.440)*r(216)+( 1.000)*r(217)
        Gain(lALDX ) = Gain(lALDX )
     &                +( 0.800)*r(218)
c
        Loss(lGLYD )= +( 1.000)*r(113)+( 1.000)*r(114)+( 1.000)*r(115)
c
        Gain(lGLYD )= +( 0.011)*r(127)+( 0.220)*r(138)+( 0.042)*r(150)
     &                +( 0.037)*r(152)+( 0.042)*r(153)+( 0.379)*r(157)
     &                +( 0.275)*r(163)+( 0.275)*r(164)+( 0.220)*r(165)
     &                +( 0.275)*r(166)+( 0.331)*r(167)
c
        Loss(lGLY  )= +( 1.000)*r(116)+( 1.000)*r(117)+( 1.000)*r(118)
c
        Gain(lGLY  )= +( 0.200)*r(113)+( 0.110)*r(114)+( 0.700)*r(136)
     &                +( 0.075)*r(143)+( 0.240)*r(147)+( 0.038)*r(150)
     &                +( 0.034)*r(152)+( 0.038)*r(153)+( 0.275)*r(163)
     &                +( 0.275)*r(164)+( 0.220)*r(165)+( 0.275)*r(166)
     &                +( 0.918)*r(173)+( 1.000)*r(174)+( 1.000)*r(176)
     &                +( 0.417)*r(178)+( 0.480)*r(179)+( 0.480)*r(181)
     &                +( 0.221)*r(183)+( 0.260)*r(185)+( 0.260)*r(186)
     &                +( 1.400)*r(205)+( 0.400)*r(211)+( 0.400)*r(212)
c
        Loss(lMGLY )= +( 1.000)*r(119)+( 1.000)*r(120)+( 1.000)*r(121)
c
        Gain(lMGLY )= +( 0.075)*r(143)+( 0.060)*r(147)+( 0.042)*r(150)
     &                +( 0.037)*r(152)+( 0.042)*r(153)+( 0.240)*r(157)
     &                +( 0.850)*r(158)+( 0.275)*r(163)+( 0.275)*r(164)
     &                +( 0.220)*r(165)+( 0.275)*r(166)+( 0.443)*r(178)
     &                +( 0.520)*r(179)+( 0.520)*r(181)+( 0.675)*r(183)
     &                +( 0.770)*r(185)+( 0.770)*r(186)+( 0.240)*r(188)
     &                +( 1.000)*r(200)+( 1.200)*r(201)+( 0.250)*r(202)
     &                +( 0.240)*r(205)
c
        Loss(lETHA )= +( 1.000)*r(125)
c
        Gain(lETHA )= 0.0
c
        Loss(lETOH )= +( 1.000)*r(127)
c
        Gain(lETOH )= 0.0
c
        Loss(lKET  )= +( 1.000)*r(128)
c
        Gain(lKET  )= +( 0.200)*r(133)+( 1.000)*r(134)
c
        Loss(lPAR  )= +( 1.000)*r(132)
c
        Gain(lPAR  )= +(-2.500)*r(128)+( 0.260)*r(131)+(-0.110)*r(132)
     &                +(-2.700)*r(133)+( 0.200)*r(141)+(-0.730)*r(142)
     &                +(-0.790)*r(143)+(-1.000)*r(144)+( 0.100)*r(145)
     &                +( 0.290)*r(147)+( 1.000)*r(148)+( 0.115)*r(150)
     &                +( 0.102)*r(152)+( 0.115)*r(153)+( 0.350)*r(155)
     &                +( 0.843)*r(157)+( 0.360)*r(158)+( 1.282)*r(159)
     &                +( 0.832)*r(160)+( 2.175)*r(163)+( 2.175)*r(164)
     &                +( 1.740)*r(165)+( 2.175)*r(166)+( 2.700)*r(167)
     &                +( 5.120)*r(168)+( 1.660)*r(169)+( 7.000)*r(170)
c
        Loss(lACET )= +( 1.000)*r(129)+( 1.000)*r(130)
c
        Gain(lACET )= +( 0.710)*r(131)+( 0.420)*r(133)
c
        Loss(lPRPA )= +( 1.000)*r(131)
c
        Gain(lPRPA )= 0.0
c
        Loss(lROR  )= +( 1.000)*r(133)+( 1.000)*r(134)+( 1.000)*r(135)
c
        Gain(lROR  )= +( 0.760)*r(132)+( 0.020)*r(133)
c
        Loss(lETHY )= +( 1.000)*r(136)
c
        Gain(lETHY )= 0.0
c
        Loss(lETH  )= +( 1.000)*r(137)+( 1.000)*r(138)+( 1.000)*r(139)
     &                +( 1.000)*r(140)
c
        Gain(lETH  )= 0.0
c
        Loss(lOLE  )= +( 1.000)*r(141)+( 1.000)*r(142)+( 1.000)*r(143)
     &                +( 1.000)*r(144)
c
        Gain(lOLE  )= +( 0.093)*r(150)+( 0.082)*r(152)+( 0.093)*r(153)
     &                +( 0.067)*r(157)+( 0.098)*r(167)
c
        Loss(lIOLE )= +( 1.000)*r(145)+( 1.000)*r(146)+( 1.000)*r(147)
     &                +( 1.000)*r(148)
c
        Gain(lIOLE )= +( 0.050)*r(150)+( 0.044)*r(152)+( 0.050)*r(153)
     &                +( 0.029)*r(161)
c
        Loss(lISOP )= +( 1.000)*r(149)+( 1.000)*r(155)+( 1.000)*r(156)
c
        Gain(lISOP )= 0.0
c
        Loss(lISO2 )= +( 1.000)*r(150)+( 1.000)*r(151)+( 1.000)*r(152)
     &                +( 1.000)*r(153)+( 1.000)*r(154)
c
        Gain(lISO2 )= +( 1.000)*r(149)+( 0.067)*r(161)
c
        Loss(lINTR )= +( 1.000)*r(167)
c
        Gain(lINTR )= +( 0.117)*r(150)+( 0.650)*r(156)+( 0.104)*r(167)
c
        Loss(lISPD )= +( 1.000)*r(157)+( 1.000)*r(158)+( 1.000)*r(159)
     &                +( 1.000)*r(160)
c
        Gain(lISPD )= +( 0.660)*r(150)+( 0.120)*r(151)+( 0.583)*r(152)
     &                +( 0.660)*r(153)+( 0.800)*r(154)+( 0.650)*r(155)
     &                +( 0.350)*r(156)
c
        Loss(lISPX )= +( 1.000)*r(161)
c
        Gain(lISPX )= +( 0.880)*r(151)
c
        Loss(lEPOX )= +( 1.000)*r(162)
c
        Gain(lEPOX )= +( 0.904)*r(161)
c
        Loss(lEPX2 )= +( 1.000)*r(163)+( 1.000)*r(164)+( 1.000)*r(165)
     &                +( 1.000)*r(166)
c
        Gain(lEPX2 )= +( 1.000)*r(162)
c
        Loss(lTERP )= +( 1.000)*r(168)+( 1.000)*r(169)+( 1.000)*r(170)
     &                +( 1.000)*r(171)
c
        Gain(lTERP )= 0.0
c
        Loss(lBENZ )= +( 1.000)*r(172)
c
        Gain(lBENZ )= 0.0
c
        Loss(lCRES )= +( 1.000)*r(187)+( 1.000)*r(188)
c
        Gain(lCRES )= +( 0.530)*r(172)+( 0.180)*r(177)+( 0.155)*r(182)
     &                +( 1.000)*r(190)
c
        Loss(lBZO2 )= +( 1.000)*r(173)+( 1.000)*r(174)+( 1.000)*r(175)
     &                +( 1.000)*r(176)
c
        Gain(lBZO2 )= +( 0.352)*r(172)
c
        Loss(lOPEN )= +( 1.000)*r(203)+( 1.000)*r(204)+( 1.000)*r(205)
     &                +( 1.000)*r(206)
c
        Gain(lOPEN )= +( 0.118)*r(172)+( 0.918)*r(173)+( 1.000)*r(174)
     &                +( 1.000)*r(176)+( 0.100)*r(177)+( 0.660)*r(178)
     &                +( 0.770)*r(179)+( 0.770)*r(181)+( 0.300)*r(183)
     &                +( 0.350)*r(185)+( 0.350)*r(186)+( 0.130)*r(187)
     &                +( 0.120)*r(188)+( 0.250)*r(202)
c
        Loss(lTOL  )= +( 1.000)*r(177)
c
        Gain(lTOL  )= 0.0
c
        Loss(lTO2  )= +( 1.000)*r(178)+( 1.000)*r(179)+( 1.000)*r(180)
     &                +( 1.000)*r(181)
c
        Gain(lTO2  )= +( 0.650)*r(177)
c
        Loss(lXOPN )= +( 1.000)*r(199)+( 1.000)*r(200)+( 1.000)*r(201)
     &                +( 1.000)*r(202)
c
        Gain(lXOPN )= +( 0.200)*r(178)+( 0.230)*r(179)+( 0.230)*r(181)
     &                +( 0.244)*r(182)+( 0.560)*r(183)+( 0.650)*r(185)
     &                +( 0.650)*r(186)
c
        Loss(lXYL  )= +( 1.000)*r(182)
c
        Gain(lXYL  )= 0.0
c
        Loss(lXLO2 )= +( 1.000)*r(183)+( 1.000)*r(184)+( 1.000)*r(185)
     &                +( 1.000)*r(186)
c
        Gain(lXLO2 )= +( 0.544)*r(182)
c
        Loss(lCRO  )= +( 1.000)*r(189)+( 1.000)*r(190)
c
        Gain(lCRO  )= +( 0.060)*r(187)+( 0.300)*r(188)+( 1.000)*r(208)
c
        Loss(lCAT1 )= +( 1.000)*r(207)+( 1.000)*r(208)
c
        Gain(lCAT1 )= +( 0.732)*r(187)
c
        Loss(lCRON )= +( 1.000)*r(191)+( 1.000)*r(192)
c
        Gain(lCRON )= +( 1.000)*r(189)
c
        Loss(lCRNO )= +( 1.000)*r(193)+( 1.000)*r(194)
c
        Gain(lCRNO )= +( 1.000)*r(191)+( 1.000)*r(192)+( 1.000)*r(195)
     &                +( 1.000)*r(197)
c
        Loss(lCRN2 )= +( 1.000)*r(195)+( 1.000)*r(196)
c
        Gain(lCRN2 )= +( 1.000)*r(194)+( 1.000)*r(198)
c
        Loss(lCRPX )= +( 1.000)*r(197)+( 1.000)*r(198)
c
        Gain(lCRPX )= +( 1.000)*r(196)
c
        Loss(lCAO2 )= +( 1.000)*r(209)+( 1.000)*r(210)+( 1.000)*r(211)
     &                +( 1.000)*r(212)
c
        Gain(lCAO2 )= +( 1.000)*r(199)+( 1.000)*r(200)+( 0.400)*r(204)
     &                +( 1.000)*r(207)
c
        Loss(lOPO3 )= +( 1.000)*r(213)+( 1.000)*r(214)+( 1.000)*r(216)
     &                +( 1.000)*r(217)+( 1.000)*r(218)
c
        Gain(lOPO3 )= +( 1.000)*r(203)+( 0.600)*r(204)+( 1.000)*r(206)
     &                +( 1.000)*r(215)
c
        Loss(lOPAN )= +( 1.000)*r(215)
c
        Gain(lOPAN )= +( 1.000)*r(214)
c
c
      do l = 1,neq
        rate(l) = gain(l) -loss(l)
      enddo
c
      return
      end