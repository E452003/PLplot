*
      program example09
*     =================
*
* Demonstration of contour plotting      
*      
      integer i,j,nptsx,nptsy
      parameter (nptsx=41,nptsy=35)
*
      real z(nptsx,nptsy), w(nptsx,nptsy), clevel(11)
      real xmin, xmax, ymin, ymax, x, y
*
      common /plplot/ tr(6)
*
      data clevel /-1.,-.8,-.6,-.4,-.2,0,.2,.4,.6,.8,1./
*

      tr(1) = 0.05
      tr(2) = 0.0
      tr(3) = -1.0
      tr(4) = 0.0
      tr(5) = 0.05
      tr(6) = -1.0
*
      x = 1.0
      y = 1.0
      xmin = tr(1) * (x-1) + tr(2) * (y-1) + tr(3)
      ymin = tr(4) * (x-1) + tr(5) * (y-1) + tr(6)
      x = nptsx
      y = nptsy
      xmax = tr(1) * (x-1) + tr(2) * (y-1) + tr(3)
      ymax = tr(4) * (x-1) + tr(5) * (y-1) + tr(6)
*            
      do 2 i=1,nptsx
        xx = (i-1-(nptsx/2))/real(nptsx/2)
        do 3 j=1,nptsy
          yy = (j-1-(nptsy/2))/real(nptsy/2) - 1.0
          z(i,j) = xx*xx - yy*yy
          w(i,j) = 2*xx*yy
    3   continue
    2 continue
*
      call plinit()
      call plenv(xmin,xmax,ymin,ymax,0,0)
      call plcol(2)
      call plcont(z,nptsx,nptsy,1,nptsx,1,nptsy,clevel,11)
      call plstyl(1,1500,1500)
      call plcol(3)
      call plcont(w,nptsx,nptsy,1,nptsx,1,nptsy,clevel,11)
      call plcol(1)
      call pllab('X Coordinate', 'Y Coordinate', 
     *           'Contour Plots of Saddle Points')

      call polar()
*
      call plend
      end

c----------------------------------------------------------------------------!
c Routine for demonstrating use of transformation arrays in contour plots.
c Sorry for the formatting, as this has been through a preprocessor.

      subroutine polar()

      parameter (NCX=40, NCY=64, NPLT=200)
      parameter (TWOPI=6.2831853071795864768)

      real z(NCX, NCY), ztmp(NCX, NCY+1)
      real xg(NCX, NCY+1), yg(NCX, NCY+1), xtm(NPLT), ytm(NPLT)

      real clevel(40)
      character*8 xopt, yopt

      nx = NCX
      ny = NCY

      kx = 1
      lx = nx
      ky = 1
      ly = ny

c Set up r-theta grids
c Tack on extra cell in theta to handle periodicity.

      do 23000 i = 1, nx
         r = i - 0.5
         do 23002 j = 1, ny
            theta = TWOPI/float(ny) * (j-0.5)
            xg(i,j) = r * cos(theta)
            yg(i,j) = r * sin(theta)
23002    continue
         xg(i, ny+1) = xg(i, 1)
         yg(i, ny+1) = yg(i, 1)
23000 continue
      call a2mnmx(xg, nx, ny, xmin, xmax)
      call a2mnmx(yg, nx, ny, ymin, ymax)
      rmax = r
      x0 = (xmin + xmax)/2.
      y0 = (ymin + ymax)/2.

c Potential inside a conducting cylinder (or sphere) by method of images.
c Charge 1 is placed at (d1, d1), with image charge at (d2, d2).
c Charge 2 is placed at (d1, -d1), with image charge at (d2, -d2).
c Also put in smoothing term at small distances.

      eps = 2.

      q1 = 1.
      d1 = r/4.

      q1i = - q1*r/d1
      d1i = r**2/d1

      q2 = -1.
      d2 = r/4.

      q2i = - q2*r/d2
      d2i = r**2/d2

      do 23004 i = 1, nx
         do 23006 j = 1, ny
            div1 = sqrt((xg(i,j)-d1)**2 + (yg(i,j)-d1)**2 + eps**2)
            div1i = sqrt((xg(i,j)-d1i)**2 + (yg(i,j)-d1i)**2 + eps**2)

            div2 = sqrt((xg(i,j)-d2)**2 + (yg(i,j)+d2)**2 + eps**2)
            div2i = sqrt((xg(i,j)-d2i)**2 + (yg(i,j)+d2i)**2 + eps**2)

            z(i,j) = q1/div1 + q1i/div1i + q2/div2 + q2i/div2i
23006    continue
23004 continue

c Tack on extra cell in theta to handle periodicity.

      do 23008 i = 1, nx
         do 23010 j = 1, ny
            ztmp(i,j) = z(i,j)
23010    continue
         ztmp(i, ny+1) = z(i, 1)
23008 continue
      call a2mnmx(z, nx, ny, zmin, zmax)

c Set up contour levels.

      nlevel = 20
      dz = abs(zmax - zmin)/float(nlevel)
      do 23012 i = 1, nlevel
         clevel(i) = zmin + (i-0.5)*dz
23012 continue

c Split contours into two parts, z > 0, and z < 0.
c Dashed contours will be at levels 'ilevlt' through 'ilevlt+nlevlt'.
c Solid  contours will be at levels 'ilevgt' through 'ilevgt+nlevgt'.

      ilevlt = 1
      nlevlt = 0
      do 23014 i = 1, nlevel
         if(clevel(i) .gt. 0.) go to 23015
         nlevlt = nlevlt + 1
23014 continue
23015 continue
      ilevgt = ilevlt + nlevlt
      nlevgt = nlevel - nlevlt

c Advance graphics frame and get ready to plot.

      ncollin = 11
      ncolbox = 1
      ncollab = 2

      call pladv(0)
      call plcol(ncolbox)

c Scale window to user coordinates.
c Make a bit larger so the boundary doesn't get clipped.

      eps = 0.05
      xpmin = xmin - abs(xmin)*eps
      xpmax = xmax + abs(xmax)*eps
      ypmin = ymin - abs(ymin)*eps
      ypmax = ymax + abs(ymax)*eps

      call plvpas(0.1, 0.9, 0.1, 0.9, 1.0)
      call plwind(xpmin, xpmax, ypmin, ypmax)

      xopt = ' '
      yopt = ' '
      xtick = 0.
      nxsub = 0
      ytick = 0.
      nysub = 0

      call plbox(xopt, xtick, nxsub, yopt, ytick, nysub)

c Call plotter once for z < 0 (dashed), once for z > 0 (solid lines).

      call plcol(ncollin)
      if(nlevlt .gt. 0) then
         call pllsty(2)
         call plcon2(ztmp, nx, ny+1, kx, lx, ky, ly+1, clevel(ilevlt), 
     &nlevlt, xg, yg)
      endif
      if(nlevgt .gt. 0) then
         call pllsty(1)
         call plcon2(ztmp, nx, ny+1, kx, lx, ky, ly+1, clevel(ilevgt), 
     &nlevgt, xg, yg)
      endif

c Draw boundary.

      do 23016 i = 1, NPLT
         theta = (TWOPI)/(NPLT-1) * float(i-1)
         xtm(i) = x0 + rmax * cos(theta)
         ytm(i) = y0 + rmax * sin(theta)
23016 continue
      call plcol(ncolbox)
      call plline(NPLT, xtm, ytm)

      call plcol(ncollab)
      call pllab(' ', ' ', 
     &'Shielded potential of charges in a conducting sphere')

      return
      end

c----------------------------------------------------------------------------!
c Subroutine a2mnmx
c----------------------------------------------------------------------------!
c Minimum and the maximum elements of a 2-d array.
c----------------------------------------------------------------------------!

      subroutine a2mnmx(f, nx, ny, fmin, fmax)

      integer nx, ny
      real f(nx, ny), fmin, fmax

      fmax=f(1, 1)
      fmin=fmax
      do 23000 j=1, ny
         do 23002 i=1, nx
            fmax=max(fmax, f(i, j))
            fmin=min(fmin, f(i, j))
23002    continue
23000 continue

      return 
      end
