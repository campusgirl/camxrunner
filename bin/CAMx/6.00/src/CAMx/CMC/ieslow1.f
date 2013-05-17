      subroutine ieslow1(r,rate,gain,loss,nr,ny,n1,n2)
      implicit none
c
c----CAMx v6.00 130506
c
c     IESLOW1 computes rates for IEH solver slow species
c
c     Copyright 1996 - 2013
c     ENVIRON International Corporation
c     Created by the CMC version 5.2
c
c     Routines Called:
c        none
c
c     Called by:
c        IEHSOLV
c
      include "camx.prm"
      include "chmdat.inc"
      include "iehchem.inc"
c
      integer ny, nr, n1, n2, l
      real loss(ny+1)
      real gain(ny+1)
      real rate(ny+1)
      real r(nr)
c
c --- Entry point
c
      do l = n1,n2
        Loss(l) = 0.0
        Gain(l) = 0.0
      enddo
c
c --- Calculate the species rates
c
c
c  AACD  ACET  ALD2  ALDX  BENZ  CAT1    CO  CRES  CRON  CRPX
c  EPOX   ETH  ETHA  ETHY  ETOH  FACD  FORM   GLY  GLYD  H2O2
c  HNO3  HONO  INTR  IOLE  ISOP  ISPD  ISPX   KET  MEOH  MEPX
c  MGLY   NTR   OLE  OPEN  PACD   PAR  PRPA  ROOH   SO2  SULF
c  TERP   TOL  XOPN   XYL    I2  I2O2  IXOY    HI   HOI  HIO3
c   INO  INO2  INO3  CH3I   MIC   MIB   MI2  IALK
c
        Loss(iAACD )= +( 1.000)*r( 94)
c
        Gain(iAACD )= +( 0.150)*r( 57)+( 0.150)*r( 65)+( 0.100)*r( 73)
     &                +( 0.200)*r( 77)+( 0.200)*r( 81)+( 0.200)*r( 85)
     &                +( 0.130)*r(143)+( 0.080)*r(147)+( 0.200)*r(152)
     &                +( 0.200)*r(165)+( 0.150)*r(216)+( 0.200)*r(218)
c
        Loss(iACET )= +( 1.000)*r(129)+( 1.000)*r(130)
c
        Gain(iACET )= +( 0.710)*r(131)+( 0.420)*r(133)
c
        Loss(iALD2 )= +( 1.000)*r(105)+( 1.000)*r(106)+( 1.000)*r(107)
     &                +( 1.000)*r(108)
c
        Gain(iALD2 )= +( 1.000)*r( 60)+( 1.000)*r( 61)+( 0.400)*r( 64)
     &                +( 0.440)*r( 65)+( 0.800)*r( 66)+( 2.000)*r( 67)
     &                +( 1.000)*r(112)+( 0.991)*r(125)+( 0.950)*r(127)
     &                +( 0.500)*r(128)+( 0.740)*r(133)+( 0.200)*r(141)
     &                +( 0.488)*r(142)+( 0.295)*r(143)+( 0.250)*r(144)
     &                +( 1.240)*r(145)+( 1.300)*r(146)+( 0.732)*r(147)
     &                +( 0.500)*r(148)+( 0.020)*r(158)+( 0.067)*r(160)
     &                +( 0.100)*r(201)+( 0.020)*r(205)
c
        Loss(iALDX )= +( 1.000)*r(109)+( 1.000)*r(110)+( 1.000)*r(111)
     &                +( 1.000)*r(112)
c
        Gain(iALDX )= +( 0.260)*r(131)+( 0.110)*r(132)+( 0.370)*r(133)
     &                +( 0.300)*r(141)+( 0.488)*r(142)+( 0.270)*r(143)
     &                +( 0.375)*r(144)+( 0.660)*r(145)+( 0.700)*r(146)
     &                +( 0.442)*r(147)+( 0.625)*r(148)+( 0.117)*r(150)
     &                +( 0.103)*r(152)+( 0.117)*r(153)+( 0.150)*r(155)
     &                +( 0.028)*r(157)+( 0.357)*r(159)+( 0.029)*r(161)
     &                +( 0.078)*r(167)+( 0.150)*r(168)+( 0.470)*r(169)
     &                +( 0.210)*r(170)+( 0.470)*r(171)+( 0.480)*r(188)
     &                +( 1.000)*r(213)+( 0.440)*r(216)+( 1.000)*r(217)
        Gain(iALDX ) = Gain(iALDX )
     &                +( 0.800)*r(218)+( 1.000)*r(251)
c
        Loss(iBENZ )= +( 1.000)*r(172)
c
        Gain(iBENZ )= 0.0
c
        Loss(iCAT1 )= +( 1.000)*r(207)+( 1.000)*r(208)
c
        Gain(iCAT1 )= +( 0.732)*r(187)
c
        Loss(iCO   )= +( 1.000)*r(123)
c
        Gain(iCO   )= +( 1.000)*r( 96)+( 1.000)*r( 97)+( 1.000)*r( 98)
     &                +( 1.000)*r( 99)+( 1.000)*r(100)+( 1.000)*r(108)
     &                +( 1.000)*r(112)+( 0.890)*r(114)+( 1.700)*r(116)
     &                +( 2.000)*r(117)+( 1.000)*r(118)+( 1.000)*r(119)
     &                +( 1.000)*r(121)+( 0.380)*r(129)+( 0.300)*r(136)
     &                +( 1.000)*r(137)+( 0.510)*r(139)+( 0.200)*r(141)
     &                +( 0.378)*r(143)+( 0.100)*r(145)+( 0.245)*r(147)
     &                +( 0.066)*r(155)+( 0.079)*r(157)+( 0.225)*r(158)
     &                +( 0.643)*r(159)+( 0.333)*r(160)+( 0.251)*r(163)
        Gain(iCO   ) = Gain(iCO   )
     &                +( 0.251)*r(164)+( 0.200)*r(165)+( 0.251)*r(166)
     &                +( 0.001)*r(170)+( 0.060)*r(187)+( 0.240)*r(188)
     &                +( 0.700)*r(199)+( 0.500)*r(201)+( 1.000)*r(203)
     &                +( 1.980)*r(205)+( 0.344)*r(209)
c
        Loss(iCRES )= +( 1.000)*r(187)+( 1.000)*r(188)
c
        Gain(iCRES )= +( 0.530)*r(172)+( 0.180)*r(177)+( 0.155)*r(182)
     &                +( 1.000)*r(190)
c
        Loss(iCRON )= +( 1.000)*r(191)+( 1.000)*r(192)
c
        Gain(iCRON )= +( 1.000)*r(189)
c
        Loss(iCRPX )= +( 1.000)*r(197)+( 1.000)*r(198)
c
        Gain(iCRPX )= +( 1.000)*r(196)
c
        Loss(iEPOX )= +( 1.000)*r(162)
c
        Gain(iEPOX )= +( 0.904)*r(161)
c
        Loss(iETH  )= +( 1.000)*r(137)+( 1.000)*r(138)+( 1.000)*r(139)
     &                +( 1.000)*r(140)
c
        Gain(iETH  )= 0.0
c
        Loss(iETHA )= +( 1.000)*r(125)
c
        Gain(iETHA )= 0.0
c
        Loss(iETHY )= +( 1.000)*r(136)
c
        Gain(iETHY )= 0.0
c
        Loss(iETOH )= +( 1.000)*r(127)
c
        Gain(iETOH )= 0.0
c
        Loss(iFACD )= +( 1.000)*r( 93)
c
        Gain(iFACD )= +( 1.000)*r(103)+( 0.500)*r(104)+( 0.300)*r(136)
     &                +( 0.370)*r(139)+( 0.090)*r(143)+( 0.074)*r(163)
     &                +( 0.185)*r(167)
c
        Loss(iFORM )= +( 1.000)*r( 96)+( 1.000)*r( 97)+( 1.000)*r( 98)
     &                +( 1.000)*r( 99)+( 1.000)*r(100)+( 1.000)*r(101)
c
        Gain(iFORM )= +( 1.000)*r( 71)+( 0.100)*r( 72)+( 1.000)*r( 73)
     &                +( 0.685)*r( 74)+( 0.400)*r( 87)+( 1.000)*r(102)
     &                +( 0.740)*r(114)+( 1.000)*r(126)+( 0.078)*r(127)
     &                +( 1.000)*r(130)+( 1.000)*r(137)+( 1.560)*r(138)
     &                +( 1.000)*r(139)+( 1.125)*r(140)+( 0.200)*r(141)
     &                +( 0.781)*r(142)+( 0.555)*r(143)+( 0.500)*r(144)
     &                +( 0.128)*r(147)+( 0.660)*r(150)+( 0.120)*r(151)
     &                +( 0.583)*r(152)+( 0.660)*r(153)+( 0.040)*r(154)
     &                +( 0.600)*r(155)+( 0.350)*r(156)+( 0.240)*r(157)
        Gain(iFORM ) = Gain(iFORM )
     &                +( 0.150)*r(158)+( 0.282)*r(159)+( 0.900)*r(160)
     &                +( 0.375)*r(163)+( 0.375)*r(164)+( 0.300)*r(165)
     &                +( 0.375)*r(166)+( 0.592)*r(167)+( 0.280)*r(169)
     &                +( 0.240)*r(170)+( 0.060)*r(187)+( 0.240)*r(188)
     &                +( 0.080)*r(205)+( 0.344)*r(209)+( 1.000)*r(248)
     &                +( 1.000)*r(249)+( 1.000)*r(250)
c
        Loss(iGLY  )= +( 1.000)*r(116)+( 1.000)*r(117)+( 1.000)*r(118)
c
        Gain(iGLY  )= +( 0.200)*r(113)+( 0.110)*r(114)+( 0.700)*r(136)
     &                +( 0.075)*r(143)+( 0.240)*r(147)+( 0.038)*r(150)
     &                +( 0.034)*r(152)+( 0.038)*r(153)+( 0.275)*r(163)
     &                +( 0.275)*r(164)+( 0.220)*r(165)+( 0.275)*r(166)
     &                +( 0.918)*r(173)+( 1.000)*r(174)+( 1.000)*r(176)
     &                +( 0.417)*r(178)+( 0.480)*r(179)+( 0.480)*r(181)
     &                +( 0.221)*r(183)+( 0.260)*r(185)+( 0.260)*r(186)
     &                +( 1.400)*r(205)+( 0.400)*r(211)+( 0.400)*r(212)
c
        Loss(iGLYD )= +( 1.000)*r(113)+( 1.000)*r(114)+( 1.000)*r(115)
c
        Gain(iGLYD )= +( 0.011)*r(127)+( 0.220)*r(138)+( 0.042)*r(150)
     &                +( 0.037)*r(152)+( 0.042)*r(153)+( 0.379)*r(157)
     &                +( 0.275)*r(163)+( 0.275)*r(164)+( 0.220)*r(165)
     &                +( 0.275)*r(166)+( 0.331)*r(167)
c
        Loss(iH2O2 )= +( 1.000)*r( 21)+( 1.000)*r( 22)+( 1.000)*r( 23)
c
        Gain(iH2O2 )= +( 1.000)*r( 17)+( 1.000)*r( 19)+( 1.000)*r( 20)
     &                +( 0.040)*r(143)+( 0.080)*r(147)
c
        Loss(iHNO3 )= +( 1.000)*r( 46)+( 1.000)*r( 47)
c
        Gain(iHNO3 )= +( 2.000)*r( 39)+( 1.000)*r( 45)+( 1.000)*r( 91)
     &                +( 1.000)*r(100)+( 1.000)*r(107)+( 1.000)*r(111)
     &                +( 1.000)*r(115)+( 1.000)*r(118)+( 1.000)*r(120)
     &                +( 0.150)*r(159)+( 1.000)*r(188)+( 1.000)*r(192)
     &                +( 1.000)*r(206)+( 1.000)*r(208)
c
        Loss(iHONO )= +( 2.000)*r( 42)+( 1.000)*r( 43)+( 1.000)*r( 44)
c
        Gain(iHONO )= +( 1.000)*r( 40)+( 2.000)*r( 41)
c
        Loss(iINTR )= +( 1.000)*r(167)
c
        Gain(iINTR )= +( 0.117)*r(150)+( 0.650)*r(156)+( 0.104)*r(167)
c
        Loss(iIOLE )= +( 1.000)*r(145)+( 1.000)*r(146)+( 1.000)*r(147)
     &                +( 1.000)*r(148)
c
        Gain(iIOLE )= +( 0.050)*r(150)+( 0.044)*r(152)+( 0.050)*r(153)
     &                +( 0.029)*r(161)
c
        Loss(iISOP )= +( 1.000)*r(149)+( 1.000)*r(155)+( 1.000)*r(156)
c
        Gain(iISOP )= 0.0
c
        Loss(iISPD )= +( 1.000)*r(157)+( 1.000)*r(158)+( 1.000)*r(159)
     &                +( 1.000)*r(160)
c
        Gain(iISPD )= +( 0.660)*r(150)+( 0.120)*r(151)+( 0.583)*r(152)
     &                +( 0.660)*r(153)+( 0.800)*r(154)+( 0.650)*r(155)
     &                +( 0.350)*r(156)
c
        Loss(iISPX )= +( 1.000)*r(161)
c
        Gain(iISPX )= +( 0.880)*r(151)
c
        Loss(iKET  )= +( 1.000)*r(128)
c
        Gain(iKET  )= +( 0.200)*r(133)+( 1.000)*r(134)
c
        Loss(iMEOH )= +( 1.000)*r(126)
c
        Gain(iMEOH )= +( 0.315)*r( 74)+( 0.150)*r(114)
c
        Loss(iMEPX )= +( 1.000)*r( 87)+( 1.000)*r( 88)
c
        Gain(iMEPX )= +( 0.900)*r( 72)+( 0.500)*r(104)
c
        Loss(iMGLY )= +( 1.000)*r(119)+( 1.000)*r(120)+( 1.000)*r(121)
c
        Gain(iMGLY )= +( 0.075)*r(143)+( 0.060)*r(147)+( 0.042)*r(150)
     &                +( 0.037)*r(152)+( 0.042)*r(153)+( 0.240)*r(157)
     &                +( 0.850)*r(158)+( 0.275)*r(163)+( 0.275)*r(164)
     &                +( 0.220)*r(165)+( 0.275)*r(166)+( 0.443)*r(178)
     &                +( 0.520)*r(179)+( 0.520)*r(181)+( 0.675)*r(183)
     &                +( 0.770)*r(185)+( 0.770)*r(186)+( 0.240)*r(188)
     &                +( 1.000)*r(200)+( 1.200)*r(201)+( 0.250)*r(202)
     &                +( 0.240)*r(205)
c
        Loss(iNTR  )= +( 1.000)*r( 91)+( 1.000)*r( 92)
c
        Gain(iNTR  )= +( 1.000)*r( 83)+( 1.000)*r(135)+( 0.500)*r(140)
     &                +( 0.500)*r(144)+( 0.500)*r(148)+( 0.850)*r(159)
     &                +( 0.266)*r(167)+( 0.530)*r(171)+( 0.082)*r(173)
     &                +( 0.140)*r(178)+( 0.140)*r(183)+( 2.000)*r(193)
     &                +( 0.500)*r(202)+( 0.140)*r(209)
c
        Loss(iOLE  )= +( 1.000)*r(141)+( 1.000)*r(142)+( 1.000)*r(143)
     &                +( 1.000)*r(144)
c
        Gain(iOLE  )= +( 0.093)*r(150)+( 0.082)*r(152)+( 0.093)*r(153)
     &                +( 0.067)*r(157)+( 0.098)*r(167)
c
        Loss(iOPEN )= +( 1.000)*r(203)+( 1.000)*r(204)+( 1.000)*r(205)
     &                +( 1.000)*r(206)
c
        Gain(iOPEN )= +( 0.118)*r(172)+( 0.918)*r(173)+( 1.000)*r(174)
     &                +( 1.000)*r(176)+( 0.100)*r(177)+( 0.660)*r(178)
     &                +( 0.770)*r(179)+( 0.770)*r(181)+( 0.300)*r(183)
     &                +( 0.350)*r(185)+( 0.350)*r(186)+( 0.130)*r(187)
     &                +( 0.120)*r(188)+( 0.250)*r(202)
c
        Loss(iPACD )= +( 1.000)*r( 95)
c
        Gain(iPACD )= +( 0.410)*r( 57)+( 0.410)*r( 65)+( 0.410)*r(216)
c
        Loss(iPAR  )= +( 1.000)*r(132)
c
        Gain(iPAR  )= +(-2.500)*r(128)+( 0.260)*r(131)+(-0.110)*r(132)
     &                +(-2.700)*r(133)+( 0.200)*r(141)+(-0.730)*r(142)
     &                +(-0.790)*r(143)+(-1.000)*r(144)+( 0.100)*r(145)
     &                +( 0.290)*r(147)+( 1.000)*r(148)+( 0.115)*r(150)
     &                +( 0.102)*r(152)+( 0.115)*r(153)+( 0.350)*r(155)
     &                +( 0.843)*r(157)+( 0.360)*r(158)+( 1.282)*r(159)
     &                +( 0.832)*r(160)+( 2.175)*r(163)+( 2.175)*r(164)
     &                +( 1.740)*r(165)+( 2.175)*r(166)+( 2.700)*r(167)
     &                +( 5.120)*r(168)+( 1.660)*r(169)+( 7.000)*r(170)
c
        Loss(iPRPA )= +( 1.000)*r(131)
c
        Gain(iPRPA )= 0.0
c
        Loss(iROOH )= +( 1.000)*r( 89)+( 1.000)*r( 90)
c
        Gain(iROOH )= +( 1.000)*r( 76)+( 1.000)*r( 80)+( 1.000)*r( 84)
c
        Loss(iSO2  )= +( 1.000)*r( 52)
c
        Gain(iSO2  )= 0.0
c
        Loss(iSULF )= 0.0
c
        Gain(iSULF )= +( 1.000)*r( 52)
c
        Loss(iTERP )= +( 1.000)*r(168)+( 1.000)*r(169)+( 1.000)*r(170)
     &                +( 1.000)*r(171)
c
        Gain(iTERP )= 0.0
c
        Loss(iTOL  )= +( 1.000)*r(177)
c
        Gain(iTOL  )= 0.0
c
        Loss(iXOPN )= +( 1.000)*r(199)+( 1.000)*r(200)+( 1.000)*r(201)
     &                +( 1.000)*r(202)
c
        Gain(iXOPN )= +( 0.200)*r(178)+( 0.230)*r(179)+( 0.230)*r(181)
     &                +( 0.244)*r(182)+( 0.560)*r(183)+( 0.650)*r(185)
     &                +( 0.650)*r(186)
c
        Loss(iXYL  )= +( 1.000)*r(182)
c
        Gain(iXYL  )= 0.0
c
        Loss(iI2   )= +( 1.000)*r(223)+( 1.000)*r(224)+( 1.000)*r(225)
c
        Gain(iI2   )= +( 1.000)*r(241)+( 1.000)*r(242)+( 1.000)*r(244)
     &                +( 1.000)*r(246)
c
        Loss(iI2O2 )= +( 1.000)*r(239)+( 1.000)*r(240)
c
        Gain(iI2O2 )= +( 0.600)*r(231)
c
        Loss(iIXOY )= 0.0
c
        Gain(iIXOY )= +( 1.000)*r(237)+( 1.000)*r(238)+( 1.000)*r(240)
c
        Loss(iHI   )= +( 1.000)*r(226)
c
        Gain(iHI   )= +( 1.000)*r(220)
c
        Loss(iHOI  )= +( 1.000)*r(232)+( 1.000)*r(233)
c
        Gain(iHOI  )= +( 1.000)*r(224)+( 1.000)*r(230)
c
        Loss(iHIO3 )= 0.0
c
        Gain(iHIO3 )= +( 1.000)*r(236)
c
        Loss(iINO  )= +( 1.000)*r(241)+( 2.000)*r(242)
c
        Gain(iINO  )= +( 1.000)*r(221)
c
        Loss(iINO2 )= +( 1.000)*r(243)+( 2.000)*r(244)
c
        Gain(iINO2 )= +( 1.000)*r(222)
c
        Loss(iINO3 )= +( 1.000)*r(245)+( 1.000)*r(246)
c
        Gain(iINO3 )= +( 1.000)*r(225)+( 1.000)*r(229)
c
        Loss(iCH3I )= +( 1.000)*r(247)
c
        Gain(iCH3I )= 0.0
c
        Loss(iMIC  )= +( 1.000)*r(250)
c
        Gain(iMIC  )= 0.0
c
        Loss(iMIB  )= +( 1.000)*r(249)
c
        Gain(iMIB  )= 0.0
c
        Loss(iMI2  )= +( 1.000)*r(248)
c
        Gain(iMI2  )= 0.0
c
        Loss(iIALK )= +( 1.000)*r(251)
c
        Gain(iIALK )= 0.0
c
c
      do l=n1,n2
        rate(l) = gain(l) -loss(l)
      enddo
c
      return
      end
