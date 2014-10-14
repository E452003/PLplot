!   Copyright (C) 2004  Alan W. Irwin
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

!--------------------------------------------------------------------------
!   main
!
!   Does a series of 3-d plots for a given data set, with different
!   viewing options in each plot.
!--------------------------------------------------------------------------

program x18f95
    use plplot, PI => PL_PI, TWOPI => PL_TWOPI
    implicit none

    integer(kind=plint), parameter :: NPTS = 1000_plint

    integer(kind=plint)            :: i, k
    real(kind=plflt), dimension(NPTS) :: x, y, z, r
    character(len=80)  :: title

    integer(kind=plint)            :: opt(4_plint) = (/    1_plint,          0_plint,          1_plint,          0_plint       /)
    real(kind=plflt)   :: alt(4_plint) = (/ 20.0_plflt, 35.0_plflt, 50.0_plflt, 65.0_plflt /)
    real(kind=plflt)   :: az(4_plint)  = (/ 30.0_plflt, 40.0_plflt, 50.0_plflt, 60.0_plflt /)

    integer(kind=plint), dimension(NPTS) :: ia = (/(i,i=1,NPTS)/)

!   Process command-line arguments
    call plparseopts(PL_PARSE_FULL)

!   Initialize plplot

    call plinit()

    do k = 1_plint, 4_plint
        call test_poly(k, alt(k), az(k))
    enddo

!   From the mind of a sick and twisted physicist...

    z = -1._plflt + 2._plflt * dble (ia-1) / dble (NPTS)

!   Pick one ...

!   r = 1. - dble (ia-1) / dble (NPTS)
    r = z

    x = r * cos( 2._plflt * PI * 6._plflt * dble (ia-1) / dble (NPTS) )
    y = r * sin( 2._plflt * PI * 6._plflt * dble (ia-1) / dble (NPTS) )

    do k = 1_plint, 4_plint
        call pladv(0_plint)
        call plvpor(0.0_plflt, 1.0_plflt, 0.0_plflt, 0.9_plflt)
        call plwind(-1.0_plflt, 1.0_plflt, -0.9_plflt, 1.1_plflt)
        call plcol0(1_plint)
        call plw3d(1.0_plflt, 1.0_plflt, 1.0_plflt, &
            -1.0_plflt, 1.0_plflt, -1.0_plflt,  &
            1.0_plflt, -1.0_plflt, 1.0_plflt, &
            alt(k), az(k))
        call plbox3('bnstu', 'x axis', 0.0_plflt, 0_plint, &
            'bnstu', 'y axis', 0.0_plflt, 0_plint, &
            'bcdmnstuv', 'z axis', 0.0_plflt, 0_plint)

        call plcol0(2_plint)

        if ( opt(k).gt. 0_plint ) then
            call plline3(x, y, z)
        else
            !U+22C5 DOT OPERATOR.
            call plstring3( x, y, z, "⋅" )
        endif

        call plcol0(3_plint)
        write( title, '(a,i2,a,i2)') '#frPLplot Example 18 - Alt=', nint(alt(k)), ', Az=', nint(az(k))
        call plmtex('t', 1.0_plflt, 0.5_plflt, 0.5_plflt, title)
    enddo

    call plend()
contains

subroutine test_poly(k, alt, az)
    integer(kind=plint)          :: k
    real(kind=plflt) :: alt, az

    real(kind=plflt) :: x(5_plint), y(5_plint), z(5_plint)
    integer(kind=plint)          :: i, j
    logical          :: draw(4_plint,4_plint) = &
        reshape( &
            (/  .true., .true., .true., .true., &
                .true., .false., .true., .false., &
                .false., .true., .false., .true., &
                .true., .true., .false., .false. /), (/4,4/) )
    integer(kind=plint), dimension(0:20)          :: ia = (/(j,j=0,20_plint)/)
    real(kind=plflt), dimension(0:20) :: theta, phi

    theta = TWOPI * ia /20._plflt
    phi   = PI * ia / 20.1_plflt

    call pladv(0_plint)
    call plvpor(0.0_plflt, 1.0_plflt, 0.0_plflt, 0.9_plflt)
    call plwind(-1.0_plflt, 1.0_plflt, -0.9_plflt, 1.1_plflt)
    call plcol0(1_plint)
    call plw3d(1.0_plflt, 1.0_plflt, 1.0_plflt, &
        -1.0_plflt, 1.0_plflt, -1.0_plflt, &
        1.0_plflt,  -1.0_plflt, 1.0_plflt, &
        alt, az)
    call plbox3('bnstu', 'x axis', 0.0_plflt, 0_plint, &
        'bnstu', 'y axis', 0.0_plflt, 0_plint, &
        'bcdmnstuv', 'z axis', 0.0_plflt, 0_plint)

    call plcol0(2_plint)


!    x = r sin(phi) cos(theta)
!    y = r sin(phi) sin(theta)
!    z = r cos(phi)
!    r = 1 :=)

    do i=0,19
        do j=0,19
            x(1_plint) = sin( phi(j) ) * cos( theta(i) )
            y(1_plint) = sin( phi(j) ) * sin( theta(i) )
            z(1_plint) = cos( phi(j) )

            x(2_plint) = sin( phi(j+1) ) * cos( theta(i) )
            y(2_plint) = sin( phi(j+1) ) * sin( theta(i) )
            z(2_plint) = cos( phi(j+1) )

            x(3_plint) = sin( phi(j+1) ) * cos( theta(i+1) )
            y(3_plint) = sin( phi(j+1) ) * sin( theta(i+1) )
            z(3_plint) = cos( phi(j+1) )

            x(4_plint) = sin( phi(j) ) * cos( theta(i+1) )
            y(4_plint) = sin( phi(j) ) * sin( theta(i+1) )
            z(4_plint) = cos( phi(j) )

            x(5_plint) = sin( phi(j) ) * cos( theta(i) )
            y(5_plint) = sin( phi(j) ) * sin( theta(i) )
            z(5_plint) = cos( phi(j) )

            call plpoly3(x, y, z, draw(:,k), .true.)
        enddo
    enddo

    call plcol0(3_plint)
    call plmtex('t', 1.0_plflt, 0.5_plflt, 0.5_plflt, 'unit radius sphere' )
end subroutine test_poly
end program x18f95
