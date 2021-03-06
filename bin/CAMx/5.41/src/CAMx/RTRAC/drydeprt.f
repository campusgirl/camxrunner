      subroutine drydeprt(m1,m2,m3,nrtsp,itzon,
     &                  tsurf,cellat,cellon,lrdlai,lai,pwc,cwc,height,
     &                  press,windu,windv,fcloud,water,fsurf,tempk,
     &                  lrdruf,icdruf,ruflen,lrddrt,icddrt,lrdsno,
     &                  icdsno,vdep)
      use filunit
      use chmstry
      use bndary
      use camxcom
      use rtracchm
      use tracer
c
c----CAMx v5.41 121109
c 
c     This version is for the RTRAC species.
c     DRYDEPRT is the driver for the calculation of gridded dry deposition 
c     velocities for a given grid. Deposition velocities are calculated for
c     each gas species and for each aerosol size bin, weighted by the
c     fractional land use specified for each cell.
c 
c     Copyright 1996 - 2012
c     ENVIRON International Corporation
c           
c     Modifications:
c        7/22/03   Taken from DRYDEP for regular model
c        11/19/04  Incorporated season-dependent roughness length
c        7/19/10   Added the Zhang et al (2003) dry deposition option
c
c     Input arguments:
c        ncol                number of columns 
c        nrow                number of rows 
c        nlay                number of layers 
c        nrtsp               number of species
c        itzon               time zone
c        tsurf               surface temperature field (K)
c        cellat              cell centroid latitude (deg)
c        cellon              cell centroid longitude (deg)
c        lrdlai              flag that LAI data were read
c        lai                 gridded LAI data from file
c        pwc                 precipitation water content (g/m3)
c        cwc                 cloud water content (g/m3)
c        height              layer interface height field (m)
c        press               layer pressure field (mb)
c        windu               layer U-component wind field (m/s)
c        windv               layer V-component wind field (m/s)
c        fcloud              fractional cloud cover field (fraction)
c        water               layer water vapor field (ppm)
c        fsurf               fractional landuse cover field (fraction)
c        tempk               layer temperature field (K)
c        lrdruf              flag that gridded roughness is available
c        icdruf              optional surface roughness length index
c        ruflen              optional surface roughness length value (m)
c        lrddrt              flag that gridded drought stress is available
c        icddrt              optional drought index
c        lrdsno              flag that gridded snow cover is available
c        icdsno              optional snow index
c             
c     Output arguments: 
c        vdep                species-dependent deposition velocity field (m/s)
c             
c     Routines called: 
c        CALDATE
c        GETZNTH
c        MICROMET
c        VD_GAS
c        VD_AER
c        HENRYFNC
c             
c     Called by: 
c        EMISTRNS
c 
      include 'camx.prm'
      include 'deposit.inc'
      include 'camx_aero.inc'
      include 'flags.inc'
c
      integer :: m1,m2,m3,iday,iyear
      integer, dimension(12) :: nday
      real, dimension(m1,m2) :: tsurf, cellat, cellon, lai
      integer, dimension(m1,m2) :: icdruf, icddrt, icdsno
      real, dimension(m1,m2,m3) :: height
      real, dimension(m1,m2,m3) :: press, windu, windv, fcloud,
     &                             water, tempk, pwc, cwc
      real, dimension(m1,m2,NLU) :: fsurf
      real, dimension(m1,m2,nspec) :: vdep

      real ruflen(NRUF),lai_ref_intpl,rlai,ref_lai,lai_f
      real*8 coszen,solflux
      logical ldark,lrdruf,lrddrt,lrdsno,lrdlai,lstable
c
      data pi/3.1415927/
      data nday/31,28,31,30,31,30,31,31,30,31,30,31/
c
c-----Entry point
c
      idate = date
      call caldate(idate)
      iyear = idate/10000
      month = (idate - 10000*iyear)/100
      if (mod(iyear,4).eq.0) nday(2)=29
      iday = idate - 100*(idate/100)
c
c-----Loop over rows and columns
c
      do 30 j = 2,m2-1 
        do 20 i = 2,m1-1
c
c-----Determine season
c
          mbin = month
          if (cellat(i,j).lt.0.) then
            mbin = mod(month+6,12)
            if (mbin.eq.0) mbin = 12
          endif
          latbin = 1
          if (abs(cellat(i,j)).gt.20.) then
            latbin = 2
          elseif (abs(cellat(i,j)).gt.35.) then
            latbin = 3
          elseif (abs(cellat(i,j)).gt.50.) then
            latbin = 4
          elseif (abs(cellat(i,j)).gt.75.) then
            latbin = 5
          endif
          if ((cellat(i,j).gt.50. .and. cellat(i,j).lt.75.) .and.
     &        (cellon(i,j).gt.-15. .and. cellon(i,j).lt.15.)) latbin = 3
          isesn = iseason(latbin,mbin)
c
c-----Use input snow cover to set season, if specified
c         
          if (lrdsno .and. icdsno(i,j).eq.1) isesn = 4
c
c-----Determine cell-average relative LAI
c
          if (lrdlai) then
            ref_lai = 0.
            do m = 1,NLU
              lai_ref_intpl = lai_ref(m,mbin) +
     &                    float(min(nday(mbin),iday))/float(nday(mbin))*
     &                    (lai_ref(m,mbin+1) - lai_ref(m,mbin))
              ref_lai = ref_lai + fsurf(i,j,m)*lai_ref_intpl
            enddo
            rlai = lai(i,j)/(ref_lai + 1.e-10)
          endif
c
c-----Calculate solar flux
c
          call getznth(cellat(i,j),cellon(i,j),time,date,itzon,
     &                 zenith,ldark)
          coszen = cos(DBLE(zenith)*DBLE(pi)/180.)
          solflux = (990.*coszen - 30.)*(1. - 0.75*
     &                                   DBLE(fcloud(i,j,1))**3.4)
          solflux = dmax1(DBLE(0.0),solflux)
c
c-----Load local met variables
c
          deltaz = height(i,j,1)/2.
          temp0 = tsurf(i,j) - 273.15
          prss0 = press(i,j,1) - 2.*deltaz*(press(i,j,2) - 
     &                             press(i,j,1))/height(i,j,2)
          ucomp = (windu(i,j,1) + windu(i-1,j,1))/2.
          vcomp = (windv(i,j,1) + windv(i,j-1,1))/2.
          wind = sqrt(ucomp**2 + vcomp**2)
          wind = amax1(0.1,wind)
c
c-----Determine surface wetness
c
          qwatr = 1.e-6*water(i,j,1)*18./28.8
          ev = qwatr*prss0/(qwatr + eps) 
          es = e0*exp((lv/rv)*(1./273. - 1./tsurf(i,j))) 
          rh = amin1(1.,ev/es)
          iwet = 0
          if (pwc(i,j,1).gt.cwmin) then
            iwet = 2
          elseif (cwc(i,j,1).gt.cwmin) then
            iwet = 1
          else
            dew = (1. - rh)*(wind + 0.6) 
            if (dew.lt.0.19) iwet = 1
          endif
c
c-----Use input drought stress, if specified
c
          istress = 0
          if (lrddrt .and. icddrt(i,j).gt.0) istress = icddrt(i,j)
c
c-----Loop over land use; surface roughness for water is dependent on
c     wind speed
c
          do l = 1,nrtrac
            vdep(i,j,l) = 0.
          enddo
          totland = 0.
c
          do 10 m = 1,NLU
            if (fsurf(i,j,m).lt.0.01) goto 10
            totland = totland + fsurf(i,j,m)
c
c-----Set surface roughness for Wesely (1989) scheme
c
            if (idrydep.eq.1) then
              z0 = z0lu(m,isesn)
              if (m.eq.7) z0 = amax1(z0,2.0e-6*wind**2.5)
c
c-----Use input surface roughness, if specified
c
              if (lrdruf .and. icdruf(i,j).gt.0) then
                z0 = ruflen(icdruf(i,j))
              endif
c
c-----Set surface roughness and LAI for Zhang (2003) scheme
c
            else
              lai_f = lai_ref(m,mbin) +
     &                float(min(nday(mbin),iday))/float(nday(mbin))*
     &                (lai_ref(m,mbin+1) - lai_ref(m,mbin))
              if (lrdlai) then
                lai_f = lai_f*rlai
                lai_f = amin1(lai_ref(m,15),lai_f)
                lai_f = amax1(lai_ref(m,14),lai_f)
              endif
              if (m.eq.1 .or. m.eq.3) then
                z0 = 2.0e-6*wind**2.5
              else
                if (z02(m).gt.z01(m)) then
                  z0 = z01(m) + (lai_f - lai_ref(m,14))/
     &                          (lai_ref(m,15) - lai_ref(m,14))*
     &                          (z02(m) - z01(m))
                else
                  z0 = z01(m)
                endif
              endif
            endif
c 
c-----Get surface layer micrometeorological parameters for this cell and
c     landuse type
c 
            call micromet(tempk(i,j,1),tsurf(i,j),press(i,j,1),prss0,
     &                    deltaz,wind,z0,pbl,ustar,el,psih,wstar,lstable)
            zl = deltaz/el
            if (zl.lt.0.) then
              zl = min(-5.,zl)
            else
              zl = max(5.,zl)
            endif
c
c-----Loop over GAS species, and calculate deposition velocity for this cell,
c     landuse, and current species.
c     Use input drought stress code, if specified
c
            call henryfnc(0,henso20,tfactso2,tsurf(i,j),7.,1,1,1,
     &                    henso2)
            do 40 l = 1,nrtgas
              if (rthlaw(l).gt.1.e-6) then
                call henryfnc(0,rthlaw(l),rttfact(l),tsurf(i,j),7.,1,
     &                        1,1,henry)
                iflgso2 = 0
                iflgo3 = 0
                if (idrydep .eq. 1) then   ! Use Wesely (1989) algorithm
                  call vd_gas(m,istress,iwet,iflgso2,iflgo3,z0,
     &                     deltaz,psih,ustar,rtdrate(l),henry,henso2,
     &                     rtreact(l),rtscale(l),temp0,dstress(0),
     &                     solflux,rj(m,isesn),rlu(m,isesn),
     &                     rac(m,isesn),rlcs(m,isesn),rlco(m,isesn),
     &                     rgss(m,isesn),rgso(m,isesn),vd)
                elseif (idrydep .eq. 2) then ! Use Zhang (2003) algorithm
                  call vd_gas_zhang(deltaz,zl,z0,ustar,tempk(i,j,1),
     &                          tsurf(i,j),solflux,rh,fcloud(i,j,1),
     &                          pwc(i,j,1),coszen,m,isesn,henry,
     &                          henso2,l,lai_f,vd)
                endif
              else
                vd = 0.
              endif
              vdep(i,j,l) = vdep(i,j,l) + vd*fsurf(i,j,m)
 40         continue
c
c-----Loop over AEROSOL size bins, and calculate deposition velocity for
c     this cell and landuse
c
            if (nrtaero .gt. 0) then
              do 50 l = nrtgas+1,nrtrac
                diam = sqrt(rtlcut(l)*rtucut(l))*1.e-6
                if (idrydep.eq.1) then     ! Use Wesely (1989) algorithm
                  call vd_aer(z0,deltaz,psih,ustar,diam,rtdens(l),
     &                        tsurf(i,j),vd)
                elseif (idrydep.eq.2) then ! Use Zhang (2001) algorithm
                   call vd_aer_zhang(deltaz,zl,z0,ustar,diam,rtdens(l),
     &                               tsurf(i,j),tempk(i,j,1),m,lai_f,vd)
                endif
                vdep(i,j,l) = vdep(i,j,l) + vd*fsurf(i,j,m)
 50           continue
            endif

 10       continue
c
c-----Calculate final landuse-weighted deposition velocities
c
          totland = amax1(totland, 0.01)
          do l = 1,nrtrac
            vdep(i,j,l) = vdep(i,j,l)/totland
          enddo
c
 20     continue
 30   continue
c
      return
      end
