      subroutine lsrate9(neq,t,y,rate,nr,r)
      implicit none
c
c----CAMx v6.00 130506
c
c     LSRATE9 computes double precision species rates
c
c     Copyright 1996 - 2013
c     ENVIRON International Corporation
c     Created by the CMC version 5.2
c
c     Routines Called:
c        LSRXN9
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
      call lsrxn9(dH2O,dM,dO2,dCH4,dH2,y,dbrk,r)
c
      do l = 1,neq
        Loss(l) = 0.0d0
        Gain(l) = 0.0d0
      enddo
c
c --- Calculate the species rates
c
c
c   NO2    NO     O    O3   NO3   O1D    OH   HO2  N2O5  HNO3
c  HONO   PNA  H2O2   XO2  XO2N   NTR  ROOH  FORM  ALD2  ALDX
c   PAR   SO2  SULF    CO  MEO2  MEPX  MEOH  HCO3  FACD  C2O3
c   PAN  PACD  AACD  CXO3  PANX  ETHA  ETOH   ROR   OLE   ETH
c  IOLE   TOL  CRES   TO2  OPEN   CRO  MGLY   XYL  ISOP  ISPD
c  TERP   CL2    CL  HOCL   CLO  N3CL   HCL  FMCL  NTCL    SS
c     I    IO    HI   INO  INO2    I2  INO3   HOI   OIO  IXOY
c  HIO3  CH3I  NBUI  IBUO  IBAC
c
        Loss(lNO2  )= +( 1.000)*r(  1)+( 1.000)*r(  4)+( 1.000)*r(  5)
     &                +( 1.000)*r(  7)+( 1.000)*r( 17)+( 1.000)*r( 18)
     &                +( 1.000)*r( 23)+( 1.000)*r( 28)+( 1.000)*r( 31)
     &                +( 1.000)*r( 89)+( 1.000)*r(104)+( 1.000)*r(118)
     &                +( 1.000)*r(136)+( 1.000)*r(148)+( 1.000)*r(163)
     &                +( 1.000)*r(193)+( 1.000)*r(199)
c
        Gain(lNO2  )= +( 1.000)*r(  3)+( 1.000)*r(  6)+( 1.000)*r( 14)
     &                +( 2.000)*r( 16)+( 1.000)*r( 17)+( 1.000)*r( 21)
     &                +( 2.000)*r( 22)+( 1.000)*r( 26)+( 1.000)*r( 27)
     &                +( 1.000)*r( 30)+( 1.000)*r( 32)+( 1.000)*r( 33)
     &                +( 1.000)*r( 46)+( 1.000)*r( 47)+( 1.000)*r( 49)
     &                +( 2.000)*r( 50)+( 0.610)*r( 51)+( 1.000)*r( 52)
     &                +( 1.000)*r( 53)+( 1.000)*r( 54)+( 1.000)*r( 62)
     &                +( 1.000)*r( 68)+( 1.000)*r( 81)+( 1.000)*r( 88)
     &                +( 1.000)*r( 90)+( 1.000)*r( 91)+( 1.000)*r(103)
        Gain(lNO2  ) = Gain(lNO2  )
     &                +( 1.000)*r(105)+( 1.000)*r(106)+( 1.000)*r(107)
     &                +( 1.000)*r(122)+( 1.000)*r(126)+( 1.000)*r(130)
     &                +( 0.900)*r(132)+( 0.200)*r(147)+( 0.470)*r(156)
     &                +( 1.000)*r(161)+( 1.000)*r(164)+( 1.000)*r(165)
     &                +( 1.000)*r(188)+( 1.000)*r(194)+( 1.000)*r(196)
     &                +( 1.000)*r(198)+( 1.000)*r(208)+( 0.500)*r(211)
     &                +( 1.000)*r(212)+( 0.500)*r(213)+( 1.000)*r(214)
c
        Loss(lNO   )= +( 1.000)*r(  3)+( 1.000)*r(  6)+( 1.000)*r( 16)
     &                +( 2.000)*r( 22)+( 1.000)*r( 23)+( 1.000)*r( 24)
     &                +( 1.000)*r( 30)+( 1.000)*r( 54)+( 1.000)*r( 55)
     &                +( 1.000)*r( 68)+( 1.000)*r( 81)+( 1.000)*r( 88)
     &                +( 1.000)*r(103)+( 1.000)*r(132)+( 1.000)*r(161)
     &                +( 1.000)*r(192)+( 1.000)*r(198)+( 1.000)*r(208)
c
        Gain(lNO   )= +( 1.000)*r(  1)+( 1.000)*r(  4)+( 1.000)*r( 15)
     &                +( 1.000)*r( 17)+( 1.000)*r( 25)+( 1.000)*r( 27)
     &                +( 0.200)*r(148)+( 1.000)*r(195)+( 0.500)*r(211)
c
        Loss(lO    )= +( 1.000)*r(  2)+( 1.000)*r(  4)+( 1.000)*r(  5)
     &                +( 1.000)*r(  6)+( 1.000)*r( 40)+( 1.000)*r( 44)
     &                +( 1.000)*r( 45)+( 1.000)*r( 46)+( 1.000)*r( 77)
     &                +( 1.000)*r( 84)+( 1.000)*r( 99)+( 1.000)*r(119)
     &                +( 1.000)*r(123)+( 1.000)*r(127)+( 1.000)*r(144)
     &                +( 1.000)*r(153)
c
        Gain(lO    )= +( 1.000)*r(  1)+( 1.000)*r(  8)+( 1.000)*r( 10)
     &                +( 1.000)*r( 14)+( 1.000)*r( 41)+( 0.500)*r(129)
     &                +( 1.000)*r(197)
c
        Loss(lO3   )= +( 1.000)*r(  3)+( 1.000)*r(  7)+( 1.000)*r(  8)
     &                +( 1.000)*r(  9)+( 1.000)*r( 12)+( 1.000)*r( 13)
     &                +( 1.000)*r( 49)+( 1.000)*r(121)+( 1.000)*r(125)
     &                +( 1.000)*r(129)+( 1.000)*r(140)+( 1.000)*r(146)
     &                +( 1.000)*r(150)+( 1.000)*r(155)+( 1.000)*r(159)
     &                +( 1.000)*r(190)
c
        Gain(lO3   )= +( 1.000)*r(  2)+( 0.200)*r( 92)+( 0.200)*r(108)
c
        Loss(lNO3  )= +( 1.000)*r( 14)+( 1.000)*r( 15)+( 1.000)*r( 16)
     &                +( 1.000)*r( 17)+( 1.000)*r( 18)+( 1.000)*r( 46)
     &                +( 1.000)*r( 47)+( 1.000)*r( 48)+( 1.000)*r( 49)
     &                +( 2.000)*r( 50)+( 1.000)*r( 78)+( 1.000)*r( 86)
     &                +( 1.000)*r(101)+( 1.000)*r(122)+( 1.000)*r(126)
     &                +( 1.000)*r(130)+( 1.000)*r(135)+( 1.000)*r(147)
     &                +( 1.000)*r(151)+( 1.000)*r(156)+( 1.000)*r(194)
     &                +( 1.000)*r(206)
c
        Gain(lNO3  )= +( 1.000)*r(  5)+( 1.000)*r(  7)+( 1.000)*r( 21)
     &                +( 1.000)*r( 29)+( 0.390)*r( 51)+( 1.000)*r( 53)
     &                +( 1.000)*r(166)+( 1.000)*r(167)+( 0.500)*r(213)
c
        Loss(lO1D  )= +( 1.000)*r( 10)+( 1.000)*r( 11)+( 1.000)*r( 38)
c
        Gain(lO1D  )= +( 1.000)*r(  9)
c
        Loss(lOH   )= +( 1.000)*r( 12)+( 1.000)*r( 24)+( 1.000)*r( 26)
     &                +( 1.000)*r( 28)+( 1.000)*r( 29)+( 1.000)*r( 33)
     &                +( 1.000)*r( 37)+( 1.000)*r( 39)+( 1.000)*r( 40)
     &                +( 2.000)*r( 41)+( 2.000)*r( 42)+( 1.000)*r( 43)
     &                +( 1.000)*r( 47)+( 1.000)*r( 61)+( 1.000)*r( 63)
     &                +( 1.000)*r( 64)+( 1.000)*r( 66)+( 1.000)*r( 67)
     &                +( 1.000)*r( 71)+( 1.000)*r( 73)+( 1.000)*r( 74)
     &                +( 1.000)*r( 83)+( 1.000)*r( 85)+( 1.000)*r( 96)
     &                +( 1.000)*r( 98)+( 1.000)*r(100)+( 1.000)*r(107)
        Loss(lOH   ) = Loss(lOH   )
     &                +( 1.000)*r(113)+( 1.000)*r(114)+( 1.000)*r(115)
     &                +( 1.000)*r(120)+( 1.000)*r(124)+( 1.000)*r(128)
     &                +( 1.000)*r(131)+( 1.000)*r(134)+( 1.000)*r(139)
     &                +( 1.000)*r(141)+( 1.000)*r(142)+( 1.000)*r(145)
     &                +( 1.000)*r(149)+( 1.000)*r(154)+( 1.000)*r(168)
     &                +( 1.000)*r(169)+( 1.000)*r(205)+( 1.000)*r(209)
     &                +( 1.000)*r(216)+( 1.000)*r(217)+( 1.000)*r(220)
     &                +( 1.000)*r(221)
c
        Gain(lOH   )= +( 2.000)*r( 11)+( 1.000)*r( 13)+( 1.000)*r( 25)
     &                +( 1.000)*r( 30)+( 2.000)*r( 36)+( 1.000)*r( 38)
     &                +( 1.000)*r( 44)+( 1.000)*r( 45)+( 0.390)*r( 51)
     &                +( 1.000)*r( 52)+( 1.000)*r( 65)+( 1.000)*r( 72)
     &                +( 1.000)*r( 77)+( 1.000)*r( 84)+( 1.000)*r( 97)
     &                +( 1.000)*r( 99)+( 0.100)*r(119)+( 0.100)*r(121)
     &                +( 0.300)*r(123)+( 0.130)*r(125)+( 0.500)*r(129)
     &                +( 0.080)*r(140)+( 0.266)*r(146)+( 0.268)*r(150)
     &                +( 0.570)*r(155)+( 1.000)*r(158)+( 1.000)*r(215)
c
        Loss(lHO2  )= +( 1.000)*r( 13)+( 1.000)*r( 30)+( 1.000)*r( 31)
     &                +( 2.000)*r( 34)+( 2.000)*r( 35)+( 1.000)*r( 43)
     &                +( 1.000)*r( 44)+( 1.000)*r( 48)+( 1.000)*r( 56)
     &                +( 1.000)*r( 57)+( 1.000)*r( 69)+( 1.000)*r( 79)
     &                +( 1.000)*r( 82)+( 1.000)*r( 92)+( 1.000)*r(108)
     &                +( 1.000)*r(137)+( 1.000)*r(162)+( 1.000)*r(191)
     &                +( 1.000)*r(200)
c
        Gain(lHO2  )= +( 1.000)*r( 12)+( 1.000)*r( 32)+( 1.000)*r( 37)
     &                +( 1.000)*r( 38)+( 1.000)*r( 39)+( 1.000)*r( 40)
     &                +( 1.000)*r( 45)+( 1.000)*r( 47)+( 0.610)*r( 51)
     &                +( 1.000)*r( 61)+( 1.000)*r( 62)+( 1.000)*r( 63)
     &                +( 1.000)*r( 65)+( 1.000)*r( 66)+( 1.000)*r( 68)
     &                +( 0.740)*r( 70)+( 0.300)*r( 71)+( 1.000)*r( 72)
     &                +( 1.000)*r( 73)+( 1.000)*r( 74)+( 2.000)*r( 75)
     &                +( 1.000)*r( 77)+( 1.000)*r( 78)+( 1.000)*r( 80)
     &                +( 1.000)*r( 81)+( 1.000)*r( 83)+( 1.000)*r( 87)
        Gain(lHO2  ) = Gain(lHO2  )
     &                +( 0.900)*r( 93)+( 1.000)*r(102)+( 1.000)*r(103)
     &                +( 1.000)*r(109)+( 2.000)*r(111)+( 1.000)*r(112)
     &                +( 1.000)*r(113)+( 1.000)*r(114)+( 0.110)*r(115)
     &                +( 0.940)*r(116)+( 1.000)*r(117)+( 0.300)*r(119)
     &                +( 0.950)*r(120)+( 0.440)*r(121)+( 1.700)*r(123)
     &                +( 1.000)*r(124)+( 0.130)*r(125)+( 0.100)*r(127)
     &                +( 1.000)*r(128)+( 0.500)*r(129)+( 1.000)*r(130)
     &                +( 0.440)*r(131)+( 0.900)*r(132)+( 1.000)*r(133)
        Gain(lHO2  ) = Gain(lHO2  )
     &                +( 0.600)*r(134)+( 1.000)*r(138)+( 2.000)*r(139)
     &                +( 0.760)*r(140)+( 0.700)*r(141)+( 1.000)*r(143)
     &                +( 0.250)*r(144)+( 0.912)*r(145)+( 0.066)*r(146)
     &                +( 0.800)*r(147)+( 0.800)*r(148)+( 0.503)*r(149)
     &                +( 0.154)*r(150)+( 0.925)*r(151)+( 1.033)*r(152)
     &                +( 0.750)*r(154)+( 0.070)*r(155)+( 0.280)*r(156)
     &                +( 1.000)*r(170)+( 1.000)*r(171)+( 0.110)*r(173)
     &                +( 1.000)*r(174)+( 1.000)*r(175)+( 1.000)*r(176)
        Gain(lHO2  ) = Gain(lHO2  )
     &                +( 1.000)*r(177)+( 0.920)*r(178)+( 0.750)*r(179)
     &                +( 0.880)*r(180)+( 0.840)*r(181)+( 1.000)*r(182)
     &                +( 1.000)*r(185)+( 1.000)*r(186)+( 1.000)*r(218)
     &                +( 0.820)*r(220)+( 1.000)*r(221)
c
        Loss(lN2O5 )= +( 1.000)*r( 19)+( 1.000)*r( 20)+( 1.000)*r( 21)
     &                +( 1.000)*r( 53)+( 1.000)*r(187)
c
        Gain(lN2O5 )= +( 1.000)*r( 18)
c
        Loss(lHNO3 )= +( 1.000)*r( 29)+( 1.000)*r( 52)+( 1.000)*r(189)
c
        Gain(lHNO3 )= +( 2.000)*r( 19)+( 2.000)*r( 20)+( 1.000)*r( 28)
     &                +( 1.000)*r( 48)+( 1.000)*r( 61)+( 1.000)*r( 78)
     &                +( 1.000)*r( 86)+( 1.000)*r(101)+( 1.000)*r(135)
     &                +( 0.150)*r(151)+( 1.000)*r(187)
c
        Loss(lHONO )= +( 1.000)*r( 25)+( 1.000)*r( 26)+( 2.000)*r( 27)
c
        Gain(lHONO )= +( 2.000)*r( 23)+( 1.000)*r( 24)
c
        Loss(lPNA  )= +( 1.000)*r( 32)+( 1.000)*r( 33)+( 1.000)*r( 51)
c
        Gain(lPNA  )= +( 1.000)*r( 31)
c
        Loss(lH2O2 )= +( 1.000)*r( 36)+( 1.000)*r( 37)+( 1.000)*r( 45)
c
        Gain(lH2O2 )= +( 1.000)*r( 34)+( 1.000)*r( 35)+( 1.000)*r( 42)
c
        Loss(lXO2  )= +( 1.000)*r( 54)+( 1.000)*r( 56)+( 2.000)*r( 58)
     &                +( 1.000)*r( 60)+( 1.000)*r( 94)+( 1.000)*r(110)
c
        Gain(lXO2  )= +( 1.000)*r( 64)+( 0.300)*r( 71)+( 1.000)*r(103)
     &                +( 0.900)*r(109)+( 2.000)*r(111)+( 1.000)*r(112)
     &                +( 0.991)*r(113)+( 0.100)*r(114)+( 0.870)*r(115)
     &                +( 0.960)*r(116)+( 0.200)*r(119)+( 0.800)*r(120)
     &                +( 0.220)*r(121)+( 0.910)*r(122)+( 0.700)*r(123)
     &                +( 1.000)*r(124)+( 1.000)*r(126)+( 0.100)*r(127)
     &                +( 1.000)*r(128)+( 0.080)*r(131)+( 0.600)*r(134)
     &                +( 1.000)*r(139)+( 0.030)*r(140)+( 0.500)*r(141)
     &                +( 1.000)*r(142)+( 0.250)*r(144)+( 0.991)*r(145)
        Gain(lXO2  ) = Gain(lXO2  )
     &                +( 0.200)*r(146)+( 1.000)*r(147)+( 1.000)*r(148)
     &                +( 0.713)*r(149)+( 0.064)*r(150)+( 0.075)*r(151)
     &                +( 0.700)*r(152)+( 1.250)*r(154)+( 0.760)*r(155)
     &                +( 1.030)*r(156)+( 0.870)*r(173)+( 0.991)*r(174)
     &                +( 2.000)*r(175)+( 1.870)*r(176)+( 1.800)*r(177)
     &                +( 1.700)*r(178)+( 1.200)*r(179)+( 0.880)*r(180)
     &                +( 0.840)*r(181)+( 1.000)*r(219)+( 1.000)*r(220)
     &                +( 1.000)*r(221)+( 2.000)*r(222)
c
        Loss(lXO2N )= +( 1.000)*r( 55)+( 1.000)*r( 57)+( 2.000)*r( 59)
     &                +( 1.000)*r( 60)
c
        Gain(lXO2N )= +( 0.009)*r(113)+( 0.130)*r(115)+( 0.040)*r(116)
     &                +( 0.010)*r(119)+( 0.090)*r(122)+( 0.088)*r(145)
     &                +( 0.250)*r(154)+( 0.180)*r(155)+( 0.250)*r(156)
     &                +( 0.130)*r(173)+( 0.009)*r(174)+( 0.080)*r(178)
     &                +( 0.250)*r(179)+( 0.120)*r(180)+( 0.160)*r(181)
c
        Loss(lNTR  )= +( 1.000)*r( 61)+( 1.000)*r( 62)
c
        Gain(lNTR  )= +( 1.000)*r( 55)+( 1.000)*r(118)+( 0.100)*r(132)
     &                +( 1.000)*r(136)+( 0.800)*r(147)+( 0.800)*r(148)
     &                +( 0.850)*r(151)+( 0.530)*r(156)+( 1.000)*r(189)
c
        Loss(lROOH )= +( 1.000)*r( 64)+( 1.000)*r( 65)
c
        Gain(lROOH )= +( 1.000)*r( 56)+( 1.000)*r( 57)
c
        Loss(lFORM )= +( 1.000)*r( 74)+( 1.000)*r( 75)+( 1.000)*r( 76)
     &                +( 1.000)*r( 77)+( 1.000)*r( 78)+( 1.000)*r( 79)
     &                +( 1.000)*r(182)
c
        Gain(lFORM )= +( 0.330)*r( 61)+( 0.330)*r( 62)+( 1.000)*r( 68)
     &                +( 1.370)*r( 70)+( 1.000)*r( 72)+( 1.000)*r( 73)
     &                +( 1.000)*r( 80)+( 1.000)*r( 93)+( 0.100)*r(109)
     &                +( 0.100)*r(114)+( 0.200)*r(119)+( 0.800)*r(120)
     &                +( 0.740)*r(121)+( 1.000)*r(122)+( 1.000)*r(123)
     &                +( 1.560)*r(124)+( 1.000)*r(125)+( 2.000)*r(126)
     &                +( 0.250)*r(129)+( 1.000)*r(139)+( 0.700)*r(140)
     &                +( 0.500)*r(144)+( 0.629)*r(145)+( 0.600)*r(146)
     &                +( 0.167)*r(149)+( 0.150)*r(150)+( 0.282)*r(151)
        Gain(lFORM ) = Gain(lFORM )
     &                +( 0.900)*r(152)+( 0.280)*r(154)+( 0.240)*r(155)
     &                +( 1.000)*r(175)+( 0.130)*r(176)+( 0.200)*r(177)
     &                +( 1.000)*r(185)+( 1.000)*r(222)
c
        Loss(lALD2 )= +( 1.000)*r( 84)+( 1.000)*r( 85)+( 1.000)*r( 86)
     &                +( 1.000)*r( 87)+( 1.000)*r(183)
c
        Gain(lALD2 )= +( 0.330)*r( 61)+( 0.330)*r( 62)+( 0.500)*r( 64)
     &                +( 0.500)*r( 65)+( 1.000)*r(103)+( 1.000)*r(107)
     &                +( 0.900)*r(109)+( 0.900)*r(110)+( 2.000)*r(111)
     &                +( 1.000)*r(112)+( 0.991)*r(113)+( 0.900)*r(114)
     &                +( 0.060)*r(115)+( 0.600)*r(116)+( 0.200)*r(119)
     &                +( 0.330)*r(120)+( 0.180)*r(121)+( 0.350)*r(122)
     &                +( 1.240)*r(127)+( 1.300)*r(128)+( 0.650)*r(129)
     &                +( 1.180)*r(130)+( 0.252)*r(149)+( 0.020)*r(150)
     &                +( 0.067)*r(152)+( 0.060)*r(173)+( 0.991)*r(174)
        Gain(lALD2 ) = Gain(lALD2 )
     &                +( 0.580)*r(176)+( 0.270)*r(177)+( 1.000)*r(186)
c
        Loss(lALDX )= +( 1.000)*r( 99)+( 1.000)*r(100)+( 1.000)*r(101)
     &                +( 1.000)*r(102)+( 1.000)*r(184)
c
        Gain(lALDX )= +( 0.330)*r( 61)+( 0.330)*r( 62)+( 0.500)*r( 64)
     &                +( 0.500)*r( 65)+( 0.050)*r(114)+( 0.050)*r(115)
     &                +( 0.500)*r(116)+( 0.300)*r(119)+( 0.620)*r(120)
     &                +( 0.320)*r(121)+( 0.560)*r(122)+( 0.220)*r(124)
     &                +( 0.660)*r(127)+( 0.700)*r(128)+( 0.350)*r(129)
     &                +( 0.640)*r(130)+( 0.030)*r(140)+( 0.150)*r(146)
     &                +( 0.800)*r(147)+( 0.800)*r(148)+( 0.120)*r(149)
     &                +( 0.357)*r(151)+( 0.150)*r(153)+( 0.470)*r(154)
     &                +( 0.210)*r(155)+( 0.470)*r(156)+( 0.050)*r(173)
        Gain(lALDX ) = Gain(lALDX )
     &                +( 0.290)*r(176)+( 0.530)*r(177)+( 0.450)*r(179)
     &                +( 1.000)*r(219)+( 0.180)*r(220)
c
        Loss(lPAR  )= +( 1.000)*r(115)+( 1.000)*r(173)
c
        Gain(lPAR  )= +(-0.660)*r( 61)+(-0.660)*r( 62)+(-0.110)*r(115)
     &                +(-2.100)*r(116)+( 0.200)*r(119)+(-0.700)*r(120)
     &                +(-1.000)*r(121)+(-1.000)*r(122)+( 0.100)*r(127)
     &                +( 1.100)*r(141)+( 0.250)*r(144)+( 0.350)*r(146)
     &                +( 2.400)*r(147)+( 2.400)*r(148)+( 1.565)*r(149)
     &                +( 0.360)*r(150)+( 1.282)*r(151)+( 0.832)*r(152)
     &                +( 5.120)*r(153)+( 1.660)*r(154)+( 7.000)*r(155)
     &                +(-0.110)*r(173)+(-1.000)*r(176)+( 0.200)*r(177)
     &                +( 1.800)*r(179)+( 2.000)*r(219)+( 0.360)*r(220)
c
        Loss(lSO2  )= +( 1.000)*r( 63)
c
        Gain(lSO2  )= 0.0
c
        Loss(lSULF )= 0.0
c
        Gain(lSULF )= +( 1.000)*r( 63)
c
        Loss(lCO   )= +( 1.000)*r( 66)
c
        Gain(lCO   )= +( 1.000)*r( 74)+( 1.000)*r( 75)+( 1.000)*r( 76)
     &                +( 1.000)*r( 77)+( 1.000)*r( 78)+( 1.000)*r( 87)
     &                +( 1.000)*r(102)+( 0.200)*r(119)+( 0.330)*r(121)
     &                +( 1.000)*r(123)+( 0.630)*r(125)+( 0.100)*r(127)
     &                +( 0.250)*r(129)+( 1.000)*r(138)+( 2.000)*r(139)
     &                +( 0.690)*r(140)+( 1.000)*r(143)+( 0.066)*r(146)
     &                +( 0.334)*r(149)+( 0.225)*r(150)+( 0.643)*r(151)
     &                +( 0.333)*r(152)+( 0.001)*r(155)+( 1.000)*r(169)
     &                +( 1.000)*r(170)+( 1.000)*r(182)
c
        Loss(lMEO2 )= +( 1.000)*r( 68)+( 1.000)*r( 69)+( 2.000)*r( 70)
     &                +( 1.000)*r( 93)+( 1.000)*r(109)
c
        Gain(lMEO2 )= +( 1.000)*r( 67)+( 0.700)*r( 71)+( 1.000)*r( 87)
     &                +( 1.000)*r( 88)+( 0.900)*r( 93)+( 0.900)*r( 94)
     &                +( 2.000)*r( 95)+( 1.000)*r( 97)+( 1.000)*r( 98)
     &                +( 1.000)*r(102)+( 1.000)*r(112)+( 1.000)*r(172)
     &                +( 1.000)*r(218)
c
        Loss(lMEPX )= +( 1.000)*r( 71)+( 1.000)*r( 72)
c
        Gain(lMEPX )= +( 1.000)*r( 69)+( 1.000)*r( 82)
c
        Loss(lMEOH )= +( 1.000)*r( 73)+( 1.000)*r(185)
c
        Gain(lMEOH )= +( 0.630)*r( 70)
c
        Loss(lHCO3 )= +( 1.000)*r( 80)+( 1.000)*r( 81)+( 1.000)*r( 82)
c
        Gain(lHCO3 )= +( 1.000)*r( 79)
c
        Loss(lFACD )= +( 1.000)*r( 83)
c
        Gain(lFACD )= +( 1.000)*r( 81)+( 0.370)*r(125)
c
        Loss(lC2O3 )= +( 1.000)*r( 88)+( 1.000)*r( 89)+( 1.000)*r( 92)
     &                +( 1.000)*r( 93)+( 1.000)*r( 94)+( 2.000)*r( 95)
     &                +( 1.000)*r(112)
c
        Gain(lC2O3 )= +( 1.000)*r( 84)+( 1.000)*r( 85)+( 1.000)*r( 86)
     &                +( 1.000)*r( 90)+( 1.000)*r( 91)+( 1.000)*r( 96)
     &                +( 1.000)*r(138)+( 1.000)*r(139)+( 0.620)*r(140)
     &                +( 1.000)*r(142)+( 1.000)*r(143)+( 0.210)*r(149)
     &                +( 0.114)*r(150)+( 0.967)*r(152)+( 1.000)*r(183)
     &                +( 1.000)*r(222)
c
        Loss(lPAN  )= +( 1.000)*r( 90)+( 1.000)*r( 91)
c
        Gain(lPAN  )= +( 1.000)*r( 89)
c
        Loss(lPACD )= +( 1.000)*r( 96)+( 1.000)*r( 97)
c
        Gain(lPACD )= +( 0.800)*r( 92)+( 0.800)*r(108)
c
        Loss(lAACD )= +( 1.000)*r( 98)
c
        Gain(lAACD )= +( 0.200)*r( 92)+( 0.100)*r( 93)+( 0.100)*r( 94)
     &                +( 0.200)*r(108)+( 0.100)*r(109)+( 0.100)*r(110)
c
        Loss(lCXO3 )= +( 1.000)*r(103)+( 1.000)*r(104)+( 1.000)*r(108)
     &                +( 1.000)*r(109)+( 1.000)*r(110)+( 2.000)*r(111)
     &                +( 1.000)*r(112)
c
        Gain(lCXO3 )= +( 1.000)*r( 99)+( 1.000)*r(100)+( 1.000)*r(101)
     &                +( 1.000)*r(105)+( 1.000)*r(106)+( 0.250)*r(144)
     &                +( 0.200)*r(146)+( 0.250)*r(149)+( 0.075)*r(151)
     &                +( 0.390)*r(155)+( 1.000)*r(184)
c
        Loss(lPANX )= +( 1.000)*r(105)+( 1.000)*r(106)+( 1.000)*r(107)
c
        Gain(lPANX )= +( 1.000)*r(104)
c
        Loss(lETHA )= +( 1.000)*r(113)+( 1.000)*r(174)
c
        Gain(lETHA )= 0.0
c
        Loss(lETOH )= +( 1.000)*r(114)+( 1.000)*r(186)
c
        Gain(lETOH )= 0.0
c
        Loss(lROR  )= +( 1.000)*r(116)+( 1.000)*r(117)+( 1.000)*r(118)
c
        Gain(lROR  )= +( 0.760)*r(115)+( 0.020)*r(116)+( 0.760)*r(173)
c
        Loss(lOLE  )= +( 1.000)*r(119)+( 1.000)*r(120)+( 1.000)*r(121)
     &                +( 1.000)*r(122)+( 1.000)*r(176)
c
        Gain(lOLE  )= +( 0.130)*r(176)+( 0.200)*r(177)
c
        Loss(lETH  )= +( 1.000)*r(123)+( 1.000)*r(124)+( 1.000)*r(125)
     &                +( 1.000)*r(126)+( 1.000)*r(175)
c
        Gain(lETH  )= 0.0
c
        Loss(lIOLE )= +( 1.000)*r(127)+( 1.000)*r(128)+( 1.000)*r(129)
     &                +( 1.000)*r(130)+( 1.000)*r(177)
c
        Gain(lIOLE )= 0.0
c
        Loss(lTOL  )= +( 1.000)*r(131)+( 1.000)*r(180)
c
        Gain(lTOL  )= 0.0
c
        Loss(lCRES )= +( 1.000)*r(134)+( 1.000)*r(135)
c
        Gain(lCRES )= +( 0.360)*r(131)+( 1.000)*r(133)+( 1.000)*r(137)
     &                +( 0.200)*r(141)
c
        Loss(lTO2  )= +( 1.000)*r(132)+( 1.000)*r(133)
c
        Gain(lTO2  )= +( 0.560)*r(131)+( 0.300)*r(141)
c
        Loss(lOPEN )= +( 1.000)*r(138)+( 1.000)*r(139)+( 1.000)*r(140)
c
        Gain(lOPEN )= +( 0.900)*r(132)+( 0.300)*r(134)
c
        Loss(lCRO  )= +( 1.000)*r(136)+( 1.000)*r(137)
c
        Gain(lCRO  )= +( 0.400)*r(134)+( 1.000)*r(135)
c
        Loss(lMGLY )= +( 1.000)*r(142)+( 1.000)*r(143)
c
        Gain(lMGLY )= +( 0.200)*r(140)+( 0.800)*r(141)+( 0.168)*r(149)
     &                +( 0.850)*r(150)
c
        Loss(lXYL  )= +( 1.000)*r(141)+( 1.000)*r(181)
c
        Gain(lXYL  )= 0.0
c
        Loss(lISOP )= +( 1.000)*r(144)+( 1.000)*r(145)+( 1.000)*r(146)
     &                +( 1.000)*r(147)+( 1.000)*r(148)+( 1.000)*r(178)
c
        Gain(lISOP )= 0.0
c
        Loss(lISPD )= +( 1.000)*r(149)+( 1.000)*r(150)+( 1.000)*r(151)
     &                +( 1.000)*r(152)
c
        Gain(lISPD )= +( 0.750)*r(144)+( 0.912)*r(145)+( 0.650)*r(146)
     &                +( 0.200)*r(147)+( 0.200)*r(148)+( 0.920)*r(178)
c
        Loss(lTERP )= +( 1.000)*r(153)+( 1.000)*r(154)+( 1.000)*r(155)
     &                +( 1.000)*r(156)+( 1.000)*r(179)
c
        Gain(lTERP )= 0.0
c
        Loss(lCL2  )= +( 1.000)*r(157)
c
        Gain(lCL2  )= +( 0.300)*r(160)+( 1.000)*r(167)
c
        Loss(lCL   )= +( 1.000)*r(159)+( 1.000)*r(167)+( 1.000)*r(171)
     &                +( 1.000)*r(172)+( 1.000)*r(173)+( 1.000)*r(174)
     &                +( 1.000)*r(175)+( 1.000)*r(176)+( 1.000)*r(177)
     &                +( 1.000)*r(178)+( 1.000)*r(179)+( 1.000)*r(180)
     &                +( 1.000)*r(181)+( 1.000)*r(182)+( 1.000)*r(183)
     &                +( 1.000)*r(184)+( 1.000)*r(185)+( 1.000)*r(186)
c
        Gain(lCL   )= +( 2.000)*r(157)+( 1.000)*r(158)+( 1.400)*r(160)
     &                +( 1.000)*r(161)+( 1.000)*r(166)+( 1.000)*r(168)
     &                +( 1.000)*r(169)+( 1.000)*r(170)+( 1.000)*r(188)
c
        Loss(lHOCL )= +( 1.000)*r(158)
c
        Gain(lHOCL )= +( 1.000)*r(162)
c
        Loss(lCLO  )= +( 2.000)*r(160)+( 1.000)*r(161)+( 1.000)*r(162)
     &                +( 1.000)*r(163)
c
        Gain(lCLO  )= +( 1.000)*r(159)+( 1.000)*r(164)+( 1.000)*r(165)
c
        Loss(lN3CL )= +( 1.000)*r(164)+( 1.000)*r(165)+( 1.000)*r(166)
     &                +( 1.000)*r(167)
c
        Gain(lN3CL )= +( 1.000)*r(163)
c
        Loss(lHCL  )= +( 1.000)*r(168)+( 1.000)*r(187)
c
        Gain(lHCL  )= +( 1.000)*r(171)+( 1.000)*r(172)+( 1.000)*r(173)
     &                +( 1.000)*r(174)+( 0.130)*r(176)+( 0.200)*r(177)
     &                +( 0.150)*r(178)+( 0.400)*r(179)+( 1.000)*r(180)
     &                +( 1.000)*r(181)+( 1.000)*r(182)+( 1.000)*r(183)
     &                +( 1.000)*r(184)+( 1.000)*r(185)+( 1.000)*r(186)
     &                +( 1.000)*r(189)
c
        Loss(lFMCL )= +( 1.000)*r(169)+( 1.000)*r(170)
c
        Gain(lFMCL )= +( 1.000)*r(175)+( 0.870)*r(176)+( 0.800)*r(177)
     &                +( 0.850)*r(178)+( 0.600)*r(179)
c
        Loss(lNTCL )= +( 1.000)*r(188)
c
        Gain(lNTCL )= +( 1.000)*r(187)
c
        Loss(lSS   )= +( 1.000)*r(189)
c
        Gain(lSS   )= 0.0
c
        Loss(lI    )= +( 1.000)*r(190)+( 1.000)*r(191)+( 1.000)*r(192)
     &                +( 1.000)*r(193)+( 1.000)*r(194)+( 1.000)*r(195)
     &                +( 1.000)*r(196)
c
        Gain(lI    )= +( 1.000)*r(197)+( 1.000)*r(198)+( 1.000)*r(201)
     &                +( 2.000)*r(204)+( 1.000)*r(205)+( 1.000)*r(206)
     &                +( 1.000)*r(207)+( 0.500)*r(211)+( 1.000)*r(212)
     &                +( 0.500)*r(213)+( 1.000)*r(215)+( 1.000)*r(217)
     &                +( 1.000)*r(218)+( 1.000)*r(219)+( 0.180)*r(220)
     &                +( 1.000)*r(222)
c
        Loss(lIO   )= +( 1.000)*r(197)+( 1.000)*r(198)+( 1.000)*r(199)
     &                +( 1.000)*r(200)+( 2.000)*r(201)+( 2.000)*r(202)
     &                +( 1.000)*r(203)
c
        Gain(lIO   )= +( 1.000)*r(190)+( 1.000)*r(194)+( 1.000)*r(208)
     &                +( 0.500)*r(211)+( 0.500)*r(213)+( 1.000)*r(214)
     &                +( 1.000)*r(216)
c
        Loss(lHI   )= +( 1.000)*r(217)
c
        Gain(lHI   )= +( 1.000)*r(191)
c
        Loss(lINO  )= +( 1.000)*r(195)
c
        Gain(lINO  )= +( 1.000)*r(192)
c
        Loss(lINO2 )= +( 1.000)*r(196)+( 1.000)*r(211)+( 1.000)*r(212)
c
        Gain(lINO2 )= +( 1.000)*r(193)
c
        Loss(lI2   )= +( 1.000)*r(204)+( 1.000)*r(205)+( 1.000)*r(206)
c
        Gain(lI2   )= +( 1.000)*r(195)+( 1.000)*r(196)
c
        Loss(lINO3 )= +( 1.000)*r(213)+( 1.000)*r(214)
c
        Gain(lINO3 )= +( 1.000)*r(199)+( 1.000)*r(206)
c
        Loss(lHOI  )= +( 1.000)*r(215)+( 1.000)*r(216)
c
        Gain(lHOI  )= +( 1.000)*r(200)+( 1.000)*r(205)
c
        Loss(lOIO  )= +( 1.000)*r(207)+( 1.000)*r(208)+( 1.000)*r(209)
     &                +( 1.000)*r(210)
c
        Gain(lOIO  )= +( 1.000)*r(201)
c
        Loss(lIXOY )= +( 1.000)*r(203)+( 1.000)*r(210)
c
        Gain(lIXOY )= +( 1.000)*r(202)+( 1.500)*r(203)+( 1.500)*r(210)
c
        Loss(lHIO3 )= 0.0
c
        Gain(lHIO3 )= +( 1.000)*r(209)
c
        Loss(lCH3I )= +( 1.000)*r(218)
c
        Gain(lCH3I )= 0.0
c
        Loss(lNBUI )= +( 1.000)*r(219)+( 1.000)*r(220)
c
        Gain(lNBUI )= 0.0
c
        Loss(lIBUO )= +( 1.000)*r(221)
c
        Gain(lIBUO )= +( 0.820)*r(220)
c
        Loss(lIBAC )= +( 1.000)*r(222)
c
        Gain(lIBAC )= +( 1.000)*r(221)
c
c
      do l = 1,neq
        rate(l) = gain(l) -loss(l)
      enddo
c
      return
      end
