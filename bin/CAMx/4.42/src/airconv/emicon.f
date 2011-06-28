       SUBROUTINE EMICON (IOUT,IDONE)
C
C  ** PROGRAM EMISCON.F
C
C      PROGRAM READS THE ASCII EMISSIONS FILE THAT IS INPUT INTO
C      THE SAI AIRSHED MODEL FOR LA AND REFORMATS THIS FILE SO
C      IT IS IN THE BINARY FORMAT EXPECTED BY THE PROGRAM
C   INPUT:
C         FT05F001  -  EBCDIC FILE RECEIVED FROM SAI
C   OUTPUT:
C         FT09F001  -  BINARY FILE
C         FT08F001  -  OUTPUT HOURS
C
      INCLUDE 'nampar.cmd'
Ctcm  DIMENSION MSPC1(10)
      character*4 MSPC1(10), itv, itv1
      character*256 inlin
      COMMON /LCM/ EMOB(MXX,MXY),EMO1(MXX,MXY,29)
      DATA MSPC1/'A','E','R','O',6*' '/,ITV/'T'/,ITV1/'S'/
C
C    THE ORDER IS (NO, NO2, OLE, PAR, ARO, ETH, CARB, SO2, CO AERO)
C
C**       CALL ERRSET(187,256,-1,1,1,1)
C
C   READ AND WRITE OUT FILE HEADER INFORMATION
C
      IDONE=1
      READ (7,2100)IFILE,NOTE,NSEG,NSPECS,IDATE,BEGTIM,JDATE,ENDTIM
2100  FORMAT(10A1,60A1,/,I2,1X,I2,1X,I6,F6.0,I6,F6.0)
      WRITE (IOUT,1005) IDATE, BEGTIM, JDATE, ENDTIM
      read(7,'(a)') inlin
      
      READ  (inlin,2000,iostat=iierr) 
     $ ORGX,ORGY,IZONE,UTMX,UTMY,DELTAX,DELTAY,NX,NY,
     $ NZ,NZLOWR,NZUPPR,HTSUR,HTLOW,HTUPP
     
      if (iierr .ne. 0) then
     	
        write(*,*) 'Error in region record format.'
        write(*,*) 'Trying alternate format.'
        
        READ  (inlin,2001,iostat=iierr) 
     $   ORGX,ORGY,IZONE,UTMX,UTMY,DELTAX,DELTAY,NX,NY,
     $   NZ,NZLOWR,NZUPPR,HTSUR,HTLOW,HTUPP
        if (iierr .ne. 0) then
          write(*,*) 'Error in region record format.'
          write(*,*) 'Trying alternate format.'
          READ  (inlin,2002) 
     $     ORGX,ORGY,IZONE,UTMX,UTMY,DELTAX,DELTAY,NX,NY,
     $     NZ,NZLOWR,NZUPPR,HTSUR,HTLOW,HTUPP
        endif
      
      endif
      
      IF (NSPECS .GT. MXSPC .OR. NX .GT. MXX .OR. NY .GT. MXY) THEN
        WRITE(*,'(A,/,A)') ' PROGRAM ARRAY DIMENSIONS EXCEEDED',
     $                     ' CHECK GRID SIZE'
        STOP
      ENDIF
      
c     2000 is the old format of header line 3, 2001 the new one, 2002 yet another one
 2000 FORMAT(F10.4,1X,F10.4,1X,I3,F10.4,1X,F10.4,1X,2F7.0,5I4,3F7.0)
 2001 FORMAT(2(F16.5,1X),I3,1X,4(F16.5,1X),5I4,3F7.0)
 
 2002  FORMAT(F10.1,1X,F10.1,1X,I3,F10.1,1X,F10.1,2X,F10.0,
     $        1X,F10.0,5I4,3F7.0)
      READ  (7,1002) IX,IY,NXCLL,NYCLL
 1002 FORMAT(4I5)
      READ  (7,1003) ((MSPEC(I,J),I=1,10),J=1,NSPECS)
 1003  FORMAT(10A1)
      WRITE (9) IFILE, NOTE, NSEG, NSPECS, IDATE, BEGTIM, JDATE, ENDTIM
      WRITE (9) ORGX, ORGY, IZONE, UTMX, UTMY, DELTAX, DELTAY,
     $          NX, NY, NZ, NZLOWR, NZUPPR, HTSUR, HTLOW, HTUPP
      WRITE (9) IX, IY, NXCLL, NYCLL
C      IF (MSPEC(1,NSPECS).NE.ITV.OR.MSPEC(2,NSPECS).NE.ITV1) GO TO 2
C      DO 1 J=1,10
C      MSPEC(J,NSPECS)=MSPC1(J)
C    1 CONTINUE
    2 WRITE (9) ((MSPEC(M,L),M=1,10),L=1,NSPECS)
C*
C
C    LARGE LOOP FOR 24 (or more) HOURS OF EMISSIONS
C
      DO 1000 IH = 1,9999
          READ  (7,1005,END=999) IBGDAT, BEGTIM, IENDAT, ENDTIM
          WRITE (9) IBGDAT,BEGTIM,IENDAT,ENDTIM
          WRITE(IOUT,1005) IBGDAT,BEGTIM,IENDAT,ENDTIM
1005      FORMAT(5X,2(I10,F10.2))
C
C    LOOP ON INDIVIDUAL SPECIES -  READ AND WRITE OUT IN ASCII
C
          DO 400 L = 1,NSPECS
              READ  (7,1006) ISEG, (MSPEC(M,L),M=1,10)
 1006            FORMAT(I4,10A1)
              READ  (7,1007) ((EMOB(I,J),I=1,NX),J=1,NY)
 1007            FORMAT(9E14.7)
C              IF (MSPEC(1,L).NE.ITV.OR.MSPEC(2,L).NE.ITV1) GO TO 3
C              DO 4 J=1,10
C                 MSPEC(J,L)=MSPC1(J)
C    4         CONTINUE
    3         WRITE (9) ISEG,(MSPEC(M,L),M=1,10),((EMOB(I,J),
     $          I=1,NX),J=1,NY)
  400     CONTINUE
 1000 CONTINUE
  999 RETURN
       END
