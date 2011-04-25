      SUBROUTINE schu(nz,o2col,iw,secchi,dto2,xscho2)

*-----------------------------------------------------------------------------*
*=  PURPOSE:                                                                 =*
*=  Calculate the equivalent absorption cross section of O2 in the SR bands. =*
*=  The algorithm is based on:  G.Kockarts, Penetration of solar radiation   =*
*=  in the Schumann-Runge bands of molecular oxygen:  a robust approximation,=*
*=  Annales Geophysicae, v12, n12, pp. 1207ff, Dec 1994.  Calculation is     =*
*=  done on the wavelength grid used by Kockarts (1994).  Final values do    =*
*=  include effects from the Herzberg continuum.                             =*
*-----------------------------------------------------------------------------*
*=  PARAMETERS:                                                              =*
*=  NZ      - INTEGER, number of specified altitude levels in the working (I)=*
*=            grid                                                           =*
*=  O2COL   - REAL, slant overhead O2 column (molec/cc) at each specified (I)=*
*=            altitude                                                       =*
*=  IW      - INTEGER, index of current wavelength bin (Kockarts' grid)   (I)=*
*=  SECCHI  - REAL, 1/COS(SZA)  for SZA <= 75 deg                         (I)=*
*=                  1/CHAP(SZA) for 75 deg < SZA <= 95 deg                   =*
*=  DTO2    - REAL, optical depth due to O2 absorption at each specified  (O)=*
*=            vertical layer at each specified wavelength                    =*
*=  XSCHO2  - REAL, molecular absorption cross section in SR bands at     (O)=*
*=            each specified wavelength.  Includes Herzberg continuum        =*
*-----------------------------------------------------------------------------*
*=  EDIT HISTORY:                                                            =*
*=  03/97  fix problem with last loop, define xscho2 at top level seperately =*
*=  10/96  converted to "true" double precision in all calculations, modified=*
*=         criterion to decide whether cross section should be zero          =*
*=  07/96  Force calculation on internal grid independent of user-defined    =*
*=         working wavelength grid                                           =*
*-----------------------------------------------------------------------------*
*= This program is free software;  you can redistribute it and/or modify     =*
*= it under the terms of the GNU General Public License as published by the  =*
*= Free Software Foundation;  either version 2 of the license, or (at your   =*
*= option) any later version.                                                =*
*= The TUV package is distributed in the hope that it will be useful, but    =*
*= WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHANTIBI-  =*
*= LITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public     =*
*= License for more details.                                                 =*
*= To obtain a copy of the GNU General Public License, write to:             =*
*= Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.   =*
*-----------------------------------------------------------------------------*
*= To contact the authors, please mail to:                                   =*
*= Sasha Madronich, NCAR/ACD, P.O.Box 3000, Boulder, CO, 80307-3000, USA  or =*
*= send email to:  sasha@ucar.edu                                            =*
*-----------------------------------------------------------------------------*
*= Copyright (C) 1994,95,96  University Corporation for Atmospheric Research =*
*-----------------------------------------------------------------------------*

      IMPLICIT NONE
      INCLUDE 'params'

      REAL o2col(kz),dto2(kz,16), xscho2(kz,16)
C     REAL dsdh(kz,kz)
      REAL secchi
      DOUBLE PRECISION a(16,12),b(16,12),rjm(kz),rjo2(kz)
      integer iw, nz, i, j, lev

c  a(16,12)             coefficients for Rj(M) (Table 1 in Kockarts 1994)
c  b(16,12)                              Rj(O2)(Table 2 in Kockarts 1994)
c  rjm                  attenuation coefficients Rj(M)
c  rjo2                 Rj(O2)
      
      data((a(i,j),j=1,12),i=1,16)/
ca 57000-56500.5 cm-1
     l 1.13402D-01,1.00088D-20,3.48747D-01,2.76282D-20,3.47322D-01
     l,1.01267D-19
     l,1.67351D-01,5.63588D-19,2.31433D-02,1.68267D-18,0.00000D+00
     l,0.00000D+00
ca 56500-56000.5 cm-1
     l,2.55268D-03,1.64489D-21,1.85483D-01,2.03591D-21,2.60603D-01
     l,4.62276D-21
     l,2.50337D-01,1.45106D-20,1.92340D-01,7.57381D-20,1.06363D-01
     l,7.89634D-19
ca 56000-55500.5 cm-1
     l,4.21594D-03,8.46639D-22,8.91886D-02,1.12935D-21,2.21334D-01
     l,1.67868D-21
     l,2.84446D-01,3.94782D-21,2.33442D-01,1.91554D-20,1.63433D-01
     l,2.25346D-19
ca 55500-55000.5 cm-1
     l,3.93529D-03,6.79660D-22,4.46906D-02,9.00358D-22,1.33060D-01
     l,1.55952D-21
     l,3.25506D-01,3.43763D-21,2.79405D-01,1.62086D-20,2.10316D-01
     l,1.53883D-19
ca 55000-54500.5 cm-1
     l,2.60939D-03,2.33791D-22,2.08101D-02,3.21734D-22,1.67186D-01
     l,5.77191D-22
     l,2.80694D-01,1.33362D-21,3.26867D-01,6.10533D-21,1.96539D-01
     l,7.83142D-20
ca 54500-54000.5 cm-1
     l,9.33711D-03,1.32897D-22,3.63980D-02,1.78786D-22,1.46182D-01 
     l,3.38285D-22
     l,3.81762D-01,8.93773D-22,2.58549D-01,4.28115D-21,1.64773D-01
     l,4.67537D-20
ca 54000-53500.5 cm-1
     l,9.51799D-03,1.00252D-22,3.26320D-02,1.33766D-22,1.45962D-01
     l,2.64831D-22
     l,4.49823D-01,6.42879D-22,2.14207D-01,3.19594D-21,1.45616D-01
     l,2.77182D-20
ca 53500-53000.5 cm-1
     l,7.87331D-03,3.38291D-23,6.91451D-02,4.77708D-23,1.29786D-01
     l,8.30805D-23
     l,3.05103D-01,2.36167D-22,3.35007D-01,8.59109D-22,1.49766D-01
     l,9.63516D-21
ca 53000-52500.5 cm-1
     l,6.92175D-02,1.56323D-23,1.44403D-01,3.03795D-23,2.94489D-01 
     l,1.13219D-22
     l,3.34773D-01,3.48121D-22,9.73632D-02,2.10693D-21,5.94308D-02 
     l,1.26195D-20
ca 52500-52000.5 cm-1
     l,1.47873D-01,8.62033D-24,3.15881D-01,3.51859D-23,4.08077D-01 
     l,1.90524D-22
     l,8.08029D-02,9.93062D-22,3.90399D-02,6.38738D-21,8.13330D-03
     l,9.93644D-22
ca 52000-51500.5 cm-1
     l,1.50269D-01,1.02621D-23,2.39823D-01,3.48120D-23,3.56408D-01
     l,1.69494D-22
     l,1.61277D-01,6.59294D-22,8.89713D-02,2.94571D-21,3.25063D-03
     l,1.25548D-20
ca 51500-51000.5 cm-1
     l,2.55746D-01,8.49877D-24,2.94733D-01,2.06878D-23,2.86382D-01 
     l,9.30992D-23
     l,1.21011D-01,3.66239D-22,4.21105D-02,1.75700D-21,0.00000D+00
     l,0.00000D+00
ca 51000-50500.5 cm-1
     l,5.40111D-01,7.36085D-24,2.93263D-01,2.46742D-23,1.63417D-01
     l,1.37832D-22
     l,3.23781D-03,2.15052D-21,0.00000D+00,0.00000D+00,0.00000D+00
     l,0.00000D+00
ca 50500-50000.5 cm-1
     l,8.18514D-01,7.17937D-24,1.82262D-01,4.17496D-23,0.00000D+00 
     l,0.00000D+00
     l,0.00000D+00,0.00000D+00,0.00000D+00,0.00000D+00,0.00000D+00
     l,0.00000D+00
ca 50000-49500.5 cm-1
     l,8.73680D-01,7.13444D-24,1.25583D-01,2.77819D-23,0.00000D+00 
     l,0.00000D+00
     l,0.00000D+00,0.00000D+00,0.00000D+00,0.00000D+00,0.00000D+00 
     l,0.00000D+00
ca 49500-49000.5 cm-1
     l,3.32476D-04,7.00362D-24,9.89000D-01,6.99600D-24,0.00000D+00
     l,0.00000D+00
     l,0.00000D+00,0.00000D+00,0.00000D+00,0.00000D+00,0.00000D+00
     l,0.00000D+00/


      data((b(i,j),j=1,12),i=1,16)/
c  57000-56500.5 cm-1
     l 1.07382D-21,9.95029D-21,7.19430D-21,2.48960D-20,2.53735D-20
     l,7.54467D-20
     l,4.48987D-20,2.79981D-19,9.72535D-20,9.29745D-19,2.30892D-20
     l,4.08009D-17
c  56500-56000.5 cm-1
     l,3.16903D-22,1.98251D-21,5.87326D-22,3.44057D-21,2.53094D-21
     l,8.81484D-21
     l,8.82299D-21,4.17179D-20,2.64703D-20,2.43792D-19,8.73831D-20
     l,1.46371D-18
c  56000-55500.5 cm-1
     l,1.64421D-23,9.26011D-22,2.73137D-22,1.33640D-21,9.79188D-22
     l,2.99706D-21
     l,3.37768D-21,1.39438D-20,1.47898D-20,1.04322D-19,4.08014D-20
     l,6.31023D-19
c  55500-55000.5 cm-1
     l,8.68729D-24,7.31056D-22,8.78313D-23,1.07173D-21,8.28170D-22
     l,2.54986D-21
     l,2.57643D-21,9.42698D-21,9.92377D-21,5.21402D-20,3.34301D-20
     l,2.91785D-19
c  55000-54500.5 cm-1
     l,1.20679D-24,2.44092D-22,2.64326D-23,4.03998D-22,2.53514D-22
     l,8.53166D-22
     l,1.29834D-21,3.74482D-21,5.12103D-21,2.65798D-20,2.10948D-20
     l,2.35315D-19
c  54500-54000.5 cm-1
     l,2.79656D-24,1.40820D-22,3.60824D-23,2.69510D-22,4.02850D-22
     l,8.83735D-22
     l,1.77198D-21,6.60221D-21,9.60992D-21,8.13558D-20,4.95591D-21
     l,1.22858D-17
c  54000-53500.5 cm-1
     l,2.36959D-24,1.07535D-22,2.83333D-23,2.16789D-22,3.35242D-22
     l,6.42753D-22
     l,1.26395D-21,5.43183D-21,4.88083D-21,5.42670D-20,3.27481D-21
     l,1.58264D-17
c  53500-53000.5 cm-1
     l,8.65018D-25,3.70310D-23,1.04351D-23,6.43574D-23,1.17431D-22
     l,2.70904D-22
     l,4.88705D-22,1.65505D-21,2.19776D-21,2.71172D-20,2.65257D-21
     l,2.13945D-17
c  53000-52500.5 cm-1
     l,9.63263D-25,1.54249D-23,4.78065D-24,2.97642D-23,6.40637D-23
     l,1.46464D-22
     l,1.82634D-22,7.12786D-22,1.64805D-21,2.37376D-17,9.33059D-22
     l,1.13741D-20
c  52500-52000.5 cm-1
     l,1.08414D-24,8.37560D-24,9.15550D-24,2.99295D-23,9.38405D-23
     l,1.95845D-22
     l,2.84356D-22,3.39699D-21,1.94524D-22,2.72227D-19,1.18924D-21
     l,3.20246D-17
c  52000-51500.5 cm-1
     l,1.52817D-24,1.01885D-23,1.22946D-23,4.16517D-23,9.01287D-23 
     l,2.34869D-22
     l,1.93510D-22,1.44956D-21,1.81051D-22,5.17773D-21,9.82059D-22
     l,6.22768D-17
c  51500-51000.5 cm-1
     l,2.12813D-24,8.48035D-24,5.23338D-24,1.93052D-23,1.99464D-23 
     l,7.48997D-23
     l,4.96642D-22,6.15691D-17,4.47504D-23,2.76004D-22,8.26788D-23
     l,1.65278D-21
c  51000-50500.5 cm-1
     l,3.81336D-24,7.32307D-24,5.60549D-24,2.04651D-23,3.36883D-22
     l,6.15708D-17
     l,2.09877D-23,1.07474D-22,9.13562D-24,8.41252D-22,0.00000D+00
     l,0.00000D+00
c  50500-50000.5 cm-1
     l,5.75373D-24,7.15986D-24,5.90031D-24,3.05375D-23,2.97196D-22
     l,8.92000D-17
     l,8.55920D-24,1.66709D-17,0.00000D+00,0.00000D+00,0.00000D+00
     l,0.00000D+00
c  50000-49500.5 cm-1
     l,6.21281D-24,7.13108D-24,3.30780D-24,2.61196D-23,1.30783D-22 
     l,9.42550D-17
     l,2.69241D-24,1.46500D-17,0.00000D+00,0.00000D+00,0.00000D+00 
     l,0.00000D+00
c  49500-49000.5 cm-1
     l,6.81118D-24,6.98767D-24,7.55667D-25,2.75124D-23,1.94044D-22 
     l,1.45019D-16
     l,1.92236D-24,3.73223D-17,0.00000D+00,0.00000D+00,0.00000D+00 
     l,0.00000D+00/

c initialize R(M)
      do lev = 1, nz
        rjm(lev) = 0.D+00
        rjo2(lev) = 0.D+00
      end do

c calculate sum of exponentials (eqs 7 and 8 of Kockarts 1994)
      do j=1,11,2
        do lev = 1, nz-1
           rjm(lev) = rjm(lev) + a(iw,j)*dexp(-a(iw,j+1)*
     >                           DBLE(o2col(lev)))
           rjo2(lev) = rjo2(lev) + b(iw,j)*dexp(-b(iw,j+1)*
     >                           DBLE(o2col(lev)))
        end do
c do the last level seperate, as it is implied that o2col(nz) = 0.
        lev = nz
        rjm(lev) = rjm(lev) + a(iw,j)
        rjo2(lev) = rjo2(lev) + b(iw,j)
      end do

      do lev = 1, nz-1
        IF (rjm(lev) .GT. 1.D-100) THEN
          xscho2(lev,iw) = rjo2(lev)/rjm(lev)
          IF (rjm(lev+1) .GT. 0.) THEN
             dto2(lev,iw) = (LOG(rjm(lev+1))-LOG(rjm(lev))) / secchi
          ELSE
             dto2(lev,iw) = 100.
          ENDIF
        ELSE
          xscho2(lev,iw) = 0.
          dto2(lev,iw) = 100.
        ENDIF
      end do

      dto2(nz,iw) = 0.
      xscho2(nz,iw) = rjo2(nz)/rjm(nz)

      end
