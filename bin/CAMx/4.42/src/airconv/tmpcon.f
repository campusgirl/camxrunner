      SUBROUTINE TMPCON (IOUT,IDONE)
C
C
C      PROGRAM READS THE ASCII TEMPERATURE FILE THAT WILL INPUT INTO
C      THE SAI AIRSHED MODEL FOR LA AND REFORMATS THIS FILE SO
C      IT CAN BE USED AS MODEL INPUT.
C
      INCLUDE 'nampar.cmd'
      COMMON /LCM/ EMOB(MXX,MXY),EMO1(MXX,MXY,29)
C
C
C
C   READ AND WRITE OUT FILE HEADER INFORMATION
C
      IDONE=1
      READ(7,2100) IFILE,NOTE,NSEG,NSPECS, IDATE, BEGTIM, JDATE, ENDTIM
      WRITE(9)     IFILE,NOTE,NSEG,NSPECS,IDATE,BEGTIM,JDATE,ENDTIM
      WRITE(IOUT,1005) IDATE, BEGTIM, JDATE, ENDTIM
      READ(7,2001) ORGX, ORGY, IZONE, UTMX, UTMY, DELTAX, DELTAY,
     $          NX, NY, NZ, NZLOWR, NZUPPR, HTSUR, HTLOW, HTUPP
      WRITE (9)      ORGX,ORGY,IZONE,UTMX,UTMY,DELTAX,DELTAY,NX,NY,
     $ NZ,NZLOWR,NZUPPR,HTSUR,HTLOW,HTUPP
      READ(7,1002) IX, IY, NXCLL, NYCLL
      WRITE (9)      IX,IY,NXCLL,NYCLL
2100  FORMAT(10A1,60A1,/,I2,1X,I2,1X,I6,F6.0,I6,F6.0)
      IBHR=BEGTIM+1
      IEHR=ENDTIM
 2001 FORMAT(2(F16.5,1X),I3,1X,4(F16.5,1X),5I4,3F7.0)
 1002 FORMAT(4I5)
C*
C
C    LARGE LOOP FOR 24 HOURS OF TEMPERATURE MEASURMENTS
C
      DO 1000 IH = 1,9999
          READ  (7,1005,END=999) IBGDAT,BEGTIM,IENDAT,ENDTIM
          WRITE (9)      IBGDAT, BEGTIM, IENDAT, ENDTIM
          WRITE(IOUT,1005) IBGDAT,BEGTIM,IENDAT,ENDTIM
1005      FORMAT(5X,2(I10,F10.2))
C
C    LOOP ON INDIVIDUAL SPECIES -  READ AND WRITE OUT IN ASCII
C
          READ  (7,1006) ISEG, (MNAME(M),M=1,10)
 1006            FORMAT(I4,10A1)
          READ  (7,1007) ((EMOB(I,J),I=1,NX),J=1,NY)
 1007            FORMAT(9E14.7)
          WRITE (9) ISEG, (MNAME(M),M = 1,10), ((EMOB(I,J),
     $       I=1,NX),J=1,NY)
  400     CONTINUE
 1000 CONTINUE
  999 RETURN
       END
