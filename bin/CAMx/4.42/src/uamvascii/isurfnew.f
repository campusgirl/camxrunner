      subroutine isurfnew(mlus)

      include 'uamvascii.inc'

   10 continue
   

c
c  In the 5.30+ file, there is a header of 8 bytes we must read as well

      read(InNum,end=100,err=200) sfchdr 
      write(OutNum,31,err=210) sfchdr 

      read(InNum,end=100,err=200) 
     &    (((fland(i,j,k), i=1,nox),j=1,noy),k=1,mlus)
      do k = 1, mlus
          write(OutNum,30,err=210)  
     &        ((fland(i,j,k), i=1,nox),j=1,noy)
      enddo

   30 format(9E14.7)
   31 format(a8)

      goto 10

  100 continue
      return

  200 continue
      write(ErrNum, 220) 'Error reading isurf file'
      write(*, 220) 'Error reading isurf file'
      stop

  210 continue
      write(ErrNum, 220) 'Error writing isurf file'
      write(*, 220) 'Error writing isurf file'
      stop

  220 format(A)

      end
