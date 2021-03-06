      SUBROUTINE REGCON (IOUT,IDONE)
C
C
C      PROGRAM READS THE TOP OF REGION  FILE THAT IS INPUT INTO
C      THE SAI AIRSHED MODEL FOR LA AND REFORMATS THIS FILE SO
C      IT CAN BE WRITTEN TO TAPE AND SENT TO SAI.
C
      INCLUDE 'nampar.cmd'
      COMMON /LCM/ RTOP(MXX,MXY),EMOB(MXX,MXY,29)
      REAL*8     RTOPX(MXX,MXY)
C
C
C
C   READ AND WRITE OUT FILE HEADER INFORMATION
C
C
C  FILE DESCRIPTION
C
      IDONE=1
      READ (7,2100)IFILE,NOTE,NSEG,NSPECS,IDATE,BEGTIM,JDATE,ENDTIM
      WRITE (9) IFILE, NOTE, NSEG, NSPECS, IDATE, BEGTIM, JDATE, ENDTIM
      WRITE (IOUT,1005) IDATE, BEGTIM, JDATE, ENDTIM
C
C  REGION DESCRIPTION
C
      READ  (7,2001) ORGX,ORGY,IZONE,UTMX,UTMY,DELTAX,DELTAY,NX,NY,
     $ NZ,NZLOWR,NZUPPR,HTSUR,HTLOW,HTUPP
      WRITE (9) ORGX, ORGY, IZONE, UTMX, UTMY, DELTAX, DELTAY,
     $          NX, NY, NZ, NZLOWR, NZUPPR, HTSUR, HTLOW, HTUPP
C
C  SEGMENT DESCRIPTOR
C
      IF (NSEG.LE.0) GO TO 10
      READ  (7,1002) IX,IY,NXCLL,NYCLL
      WRITE (9) IX, IY, NXCLL, NYCLL
C
  10  IBHR=BEGTIM +1
      IEHR=ENDTIM
      L=1
C
C    LARGE LOOP FOR 24 HOURS OF TOP CONCENTRATIONS
C
      DO 1000 IH = 1,9999
          READ  (7,1005,END=999) IBGDAT, BEGTIM, IENDAT, ENDTIM
          WRITE (9)     IBGDAT,BEGTIM,IENDAT,ENDTIM
          WRITE(IOUT,1005) IBGDAT,BEGTIM,IENDAT,ENDTIM

          READ  (7,1006) ISEG, (MSPEC(M,L),M=1,10)
          READ  (7,1007) ((RTOPX(I,J),I=1,NX),J=1,NY)
          DO 500 I=1,NX
             DO 500 J=1,NY
                RTOP(I,J) = RTOPX(I,J)
  500        CONTINUE
          WRITE (9) ISEG, (MSPEC(M,L),M = 1,10), ((RTOP(I,J),
     $       I=1,NX),J=1,NY)
 1000 CONTINUE
  999 RETURN
1002  FORMAT(4I5)
1005  FORMAT(2(I10,F10.2))
1006  FORMAT(I4,10A1)
1007  FORMAT(7D16.9)
 2001 FORMAT(2(F16.5,1X),I3,1X,4(F16.5,1X),5I4,3F7.0)
2100  FORMAT(10A1,60A1,/,I2,1X,I2,1X,I6,F6.0,I6,F6.0)
      END
