!   Alpha color values demonstration
!
!   Copyright (C) 2008 Hazen Babcock
!   Copyright (C) 2008 Andrew Ross
!
!   This file is part of PLplot.
!
!   PLplot is free software; you can redistribute it and/or modify
!   it under the terms of the GNU Library General Public License as
!   published by the Free Software Foundation; either version 2 of the
!   License, or (at your option) any later version.
!
!   PLplot is distributed in the hope that it will be useful,
!   but WITHOUT ANY WARRANTY; without even the implied warranty of
!   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!   GNU Library General Public License for more details.
!
!   You should have received a copy of the GNU Library General Public
!   License along with PLplot; if not, write to the Free Software
!   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
!

program x30f95
  use plplot

  implicit none

  integer(kind=plint), dimension(4) ::  red, green, blue
  real(kind=plflt), dimension (4) :: alpha, px, py
  real(kind=plflt), dimension (2) :: pos, rcoord, gcoord, bcoord, acoord
  logical, dimension(2) :: rev

  data red   / 0_plint, 255_plint, 0_plint, 0_plint /
  data green / 0_plint, 0_plint, 255_plint, 0_plint /
  data blue  / 0_plint, 0_plint, 0_plint, 255_plint /
  data alpha / 1.0_plflt, 1.0_plflt, 1.0_plflt, 1.0_plflt /
  data px / 0.1_plflt, 0.5_plflt, 0.5_plflt, 0.1_plflt /
  data py / 0.1_plflt, 0.1_plflt, 0.5_plflt, 0.5_plflt /
  data pos / 0.0_plflt, 1.0_plflt / 
  data rcoord / 1.0_plflt, 1.0_plflt / 
  data gcoord / 0.0_plflt, 0.0_plflt / 
  data bcoord / 0.0_plflt, 0.0_plflt / 
  data acoord / 0.0_plflt, 1.0_plflt /
  data rev / .false. , .false. /

  integer(kind=plint) i, j
  integer(kind=plint) icol, r, g, b
  real(kind=plflt) :: a

  call plparseopts(PL_PARSE_FULL)

  call plinit()

  call plscmap0n(4_plint)

  call plscmap0a (red, green, blue, alpha)

  ! 
  ! Page 1:
  !
  ! This is a series of red, green and blue rectangles overlaid
  ! on each other with gradually increasing transparency.
  !

  ! Set up the window
  call pladv (0_plint)
  call plvpor (0.0_plflt, 1.0_plflt, 0.0_plflt, 1.0_plflt)
  call plwind (0.0_plflt, 1.0_plflt, 0.0_plflt, 1.0_plflt)
  call plcol0 (0_plint)
  call plbox ("", 1.0_plflt, 0_plint, "", 1.0_plflt, 0_plint)

  ! Draw the boxes 
  do i = 1_plint,9
     icol = mod(i-1,3_plint) + 1_plint

     ! Get a color, change its transparency and 
     ! set it as the current color.
     call plgcol0a (icol, r, g, b, a)
     call plscol0a (icol, r, g, b, 1.0_plflt - dble(i-1)/9.0_plflt)
     call plcol0 (icol)

     ! Draw the rectangle
     call plfill (px, py)

     ! Shift the rectangles coordinates
     do j = 1_plint,4
        px(j) = px(j) + 0.5_plflt/9.0_plflt
        py(j) = py(j) + 0.5_plflt/9.0_plflt
     enddo
  enddo
  !
  ! Page 2:
  !
  ! This is a bunch of boxes colored red, green or blue with a single 
  ! large (red) box of linearly varying transparency overlaid. The
  ! overlaid box is completely transparent at the bottom and completely
  ! opaque at the top.
  ! 

  ! Set up the window
  call pladv(0_plint)
  call plvpor(0.1_plflt, 0.9_plflt, 0.1_plflt, 0.9_plflt)
  call plwind(0.0_plflt, 1.0_plflt, 0.0_plflt, 1.0_plflt)

  ! Draw the boxes. There are 25_plint of them drawn on a 5_plint x 5_plint grid.
  do i = 1_plint,5
     ! Set box X position
     px(1_plint) = 0.05_plflt + 0.2_plflt * dble(i-1)
     px(2_plint) = px(1_plint) + 0.1_plflt
     px(3_plint) = px(2_plint)
     px(4_plint) = px(1_plint)

     ! We don't want the boxes to be transparent, so since we changed
     ! the colors transparencies in the first example we have to change
     ! the transparencies back to completely opaque.
     icol = mod(i-1,3_plint) + 1_plint
     call plgcol0a (icol, r, g, b, a)
     call plscol0a (icol, r, g, b, 1.0_plflt)
     call plcol0 (icol)
     do j = 1_plint, 5_plint
        ! Set box y position and draw the box.
        py(1_plint) = 0.05_plflt + 0.2_plflt * dble(j-1)
        py(2_plint) = py(1_plint)
        py(3_plint) = py(1_plint) + 0.1_plflt
        py(4_plint) = py(3_plint)
        call plfill(px, py)
     enddo
  enddo

  ! Create the color map with 128_plint colors and call plscmap1la to initialize
  ! the color values with a linearly varying red transparency (or alpha)
  call plscmap1n(128_plint)
  call plscmap1la(.true., pos, rcoord, gcoord, bcoord, acoord, rev)

  ! Use that cmap1 to create a transparent red gradient for the whole
  ! window.
  px(1_plint) = 0._plflt
  px(2_plint) = 1._plflt
  px(3_plint) = 1._plflt
  px(4_plint) = 0._plflt

  py(1_plint) = 0._plflt
  py(2_plint) = 0._plflt
  py(3_plint) = 1._plflt
  py(4_plint) = 1._plflt

  call plgradient( px, py, 90._plflt )
  call plend()

end program x30f95

