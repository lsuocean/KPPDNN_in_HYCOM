!#include "cppdefs.h"
      ! To avoid confliction of var_names with other files,
      ! a prefix 'b_' is added to all var_names in this module
      module mod_interp1d
      USE mod_kinds
      implicit none 


      interface interp_linear
        module procedure interp_linear_pt, interp_linear_vec 
      end interface 

      private
      public :: interp_linear
      public :: interp_spline
    
      contains
      function interp_linear_internal(b_x,b_y,b_xout) result(b_yout)

        implicit none
        real(r8), intent(IN)  :: b_x(2), b_y(2), b_xout
        real(r8) :: b_yout
        real(r8) :: b_alph

        if ( b_xout .lt. b_x(1) .or. b_xout .gt. b_x(2) ) then
            write(*,*) "interp1: xout < x0 or xout > x1 !"
            write(*,*) "xout = ",b_xout
            write(*,*) "x0   = ",b_x(1)
            write(*,*) "x1   = ",b_x(2)
            stop
        end if

        b_alph = (b_xout - b_x(1)) / (b_x(2) - b_x(1))
        b_yout = b_y(1) + b_alph*(b_y(2) - b_y(1))

        return

      end function interp_linear_internal 

      function interp_linear_pt(b_x,b_y,b_xout) result(b_yout)
        ! Interpolate y from ordered x to ordered xout positions

        implicit none 
        real(r8), dimension(:), intent(IN) :: b_x, b_y
        real(r8), intent(IN) :: b_xout
        real(r8) :: b_yout 
        integer :: b_i, b_j, b_n, b_nout 

        b_n    = size(b_x) 

        if (b_xout .lt. b_x(1)) then
            b_yout = b_y(1)
        else if (b_xout .gt. b_x(b_n)) then
            b_yout = b_y(b_n)
        else
            do b_j = 1, b_n 
                if (b_x(b_j) .ge. b_xout) exit 
            end do

            if (b_j .eq. 1) then 
                b_yout = b_y(1) 
            else if (b_j .eq. b_n+1) then 
                b_yout = b_y(b_n)
            else 
                b_yout = interp_linear_internal(b_x(b_j-1:b_j),         &
     &                   b_y(b_j-1:b_j),b_xout)
            end if 
        end if 

        return 

      end function interp_linear_pt

      function interp_linear_vec(b_x,b_y,b_xout) result(b_yout)
        ! Interpolate y from ordered x to ordered xout positions

        implicit none 
        real(r8), dimension(:), intent(IN) :: b_x, b_y
        real(r8), dimension(:), intent(IN) :: b_xout
        real(r8), dimension(size(b_xout)) :: b_yout 
        integer :: b_i, b_j, b_n, b_nout 

        b_n    = size(b_x) 
        b_nout = size(b_xout)

!         write(*,*) minval(x), maxval(x), n, nout

        do b_i = 1, b_nout 
            if (b_xout(b_i) .lt. b_x(1)) then
                b_yout(b_i) = b_y(1)
!                 write(*,*) 1, xout(i)
            else if (b_xout(b_i) .gt. b_x(b_n)) then
                b_yout(b_i) = b_y(b_n)
!                 write(*,*) 2, xout(i)
            else
                do b_j = 1, b_n 
                    if (b_x(b_j) .ge. b_xout(b_i)) exit 
                end do

                if (b_j .eq. 1) then 
                    b_yout(b_i) = b_y(1) 
!                     write(*,*) 3, xout(i)
                else if (b_j .eq. b_n+1) then 
                    b_yout(b_i) = b_y(b_n)
!                     write(*,*) 4, xout(i)
                else 
                    b_yout(b_i) =interp_linear_internal(b_x(b_j-1:b_j), &
     &                       b_y(b_j-1:b_j),b_xout(b_i))
!                     write(*,*) 5, xout(i)
                end if 
            end if 
        end do

        return 

      end function interp_linear_vec

      function interp_spline(b_x,b_y,b_xout) result(b_yout)

        implicit none 
        real(r8), dimension(:), intent(IN) :: b_x, b_y
        real(r8), dimension(:), intent(IN) :: b_xout
        real(r8), dimension(size(b_xout)) :: b_yout 
        real(r8), dimension(:), allocatable :: b_b, b_c, b_d 
        real(r8) :: b_uh, b_dx, b_yh  
        integer :: b_i, b_n, b_nout 

        b_n    = size(b_x) 
        b_nout = size(b_xout)

        ! Get spline coefficients b, c, d
        allocate(b_b(b_n),b_c(b_n),b_d(b_n))
        call spline (b_x, b_y, b_b, b_c, b_d, b_n)

        do b_i = 1, b_nout 
            if (b_xout(b_i) .lt. b_x(1)) then
                b_dx = b_x(1)-b_xout(b_i)
                b_uh = b_x(1)+b_dx
                b_yh = ispline(b_uh,b_x,b_y,b_b,b_c,b_d,b_n)
                b_yout(b_i) = b_y(1) + (b_y(1)-b_yh)
                !write(*,*) x(1), xout(i), dx, uh, y(1), yh, yout(i)
            else if (b_xout(b_i) .gt. b_x(b_n)) then
                b_dx = b_xout(b_i)-b_x(b_n)
                b_uh = b_x(b_n)-b_dx
                b_yh = ispline(b_uh,b_x,b_y,b_b,b_c,b_d,b_n)
                b_yout(b_i) = b_y(b_n) + (b_y(b_n)-b_yh)
                !write(*,*) x(n), xout(i), dx, uh, y(n), yh, yout(i)
            else
                b_yout(b_i)=ispline(b_xout(b_i),b_x,b_y,b_b,b_c,b_d,b_n)
            end if 
        end do 

        return

      end function interp_spline 

!     function ispline_outer(u, x, y, b, c, d, n) result(yout)

!         implicit none 

!         integer :: n
!         double precision ::  u, x(n), y(n), b(n), c(n), d(n)
!         double precision :: uh, dx, yh  

!         if (u .lt. x(1)) then 
!             dx = x(1)-u
!             uh = x(1) + dx 
!             yh = ispline(uh,x,y,b,c,d,n)
!             yout = y(1) + (yh-y(1))
!         else if (u .gt. x(n)) then
!             dx = u-x(n)
!             uh = x(n)-dx 
!             yh = ispline(uh,x,y,b,c,d,n)
!             yout = y(n) + (y(n)-yh)
!         end if 

!         return

!     end function ispline_outer 


      subroutine spline (b_x, b_y, b_b, b_c, b_d, b_n)
!======================================================================
!  SOURCE:
!  http://ww2.odu.edu/~agodunov/computing/programs/book2/Ch01/spline.f90
!  Calculate the coefficients b(i), c(i), and d(i), i=1,2,...,n
!  for cubic spline interpolation
!  s(x) = y(i) + b(i)*(x-x(i)) + c(i)*(x-x(i))**2 + d(i)*(x-x(i))**3
!  for  x(i) <= x <= x(i+1)
!  Alex G: January 2010
!----------------------------------------------------------------------
!  input..
!  x = the arrays of data abscissas (in strictly increasing order)
!  y = the arrays of data ordinates
!  n = size of the arrays xi() and yi() (n>=2)
!  output..
!  b, c, d  = arrays of spline coefficients
!  comments ...
!  spline.f90 program is based on fortran version of program spline.f
!  the accompanying function fspline can be used for interpolation
!======================================================================
      implicit none
      integer b_n
      real(r8), dimension(:) :: b_x, b_y, b_b, b_c, b_d 
!double precision x(n), y(n), b(n), c(n), d(n)
      integer b_i, b_j, b_gap
      real(r8) b_h

      b_gap = b_n-1
! check input
      if ( b_n < 2 ) return
      if ( b_n < 3 ) then
        b_b(1) = (b_y(2)-b_y(1))/(b_x(2)-b_x(1))   ! linear interpolation
        b_c(1) = 0.
        b_d(1) = 0.
        b_b(2) = b_b(1)
        b_c(2) = 0.
        b_d(2) = 0.
        return
      end if
!
! step 1: preparation
!
      b_d(1) = b_x(2) - b_x(1)
      b_c(2) = (b_y(2) - b_y(1))/b_d(1)
      do b_i = 2, b_gap
        b_d(b_i) = b_x(b_i+1) - b_x(b_i)
        b_b(b_i) = 2.0*(b_d(b_i-1) + b_d(b_i))
        b_c(b_i+1) = (b_y(b_i+1) - b_y(b_i))/b_d(b_i)
        b_c(b_i) = b_c(b_i+1) - b_c(b_i)
      end do
!
! step 2: end conditions 
!
      b_b(1) = -b_d(1)
      b_b(b_n) = -b_d(b_n-1)
      b_c(1) = 0.0
      b_c(b_n) = 0.0
      if(b_n /= 3) then
        b_c(1) = b_c(3)/(b_x(4)-b_x(2)) - b_c(2)/(b_x(3)-b_x(1))
        b_c(b_n) = b_c(b_n-1)/(b_x(b_n)-b_x(b_n-2)) -                   & 
     &             b_c(b_n-2)/(b_x(b_n-1)-b_x(b_n-3))
        b_c(1) = b_c(1)*b_d(1)**2/(b_x(4)-b_x(1))
        b_c(b_n) = -b_c(b_n)*b_d(b_n-1)**2/(b_x(b_n)-b_x(b_n-3))
      end if
!
! step 3: forward elimination 
!
      do b_i = 2, b_n
        b_h = b_d(b_i-1)/b_b(b_i-1)
        b_b(b_i) = b_b(b_i) - b_h*b_d(b_i-1)
        b_c(b_i) = b_c(b_i) - b_h*b_c(b_i-1)
      end do
!
! step 4: back substitution
!
      b_c(b_n) = b_c(b_n)/b_b(b_n)
      do b_j = 1, b_gap
        b_i = b_n-b_j
        b_c(b_i) = (b_c(b_i) - b_d(b_i)*b_c(b_i+1))/b_b(b_i)
      end do
!
! step 5: compute spline coefficients
!
      b_b(b_n) = (b_y(b_n) - b_y(b_gap))/b_d(b_gap) +                   &
     &           b_d(b_gap)*(b_c(b_gap) + 2.0*b_c(b_n))
      do b_i = 1, b_gap
        b_b(b_i) = (b_y(b_i+1) - b_y(b_i))/b_d(b_i) -                   &
     &             b_d(b_i)*(b_c(b_i+1) + 2.0*b_c(b_i))                 
        b_d(b_i) = (b_c(b_i+1) - b_c(b_i))/b_d(b_i)
        b_c(b_i) = 3.*b_c(b_i)
      end do
      b_c(b_n) = 3.0*b_c(b_n)
      b_d(b_n) = b_d(b_n-1)
      end subroutine spline

        function ispline(b_u, b_x, b_y, b_b, b_c, b_d, b_n)
!======================================================================
! SOURCE:
! http://ww2.odu.edu/~agodunov/computing/programs/book2/Ch01/spline.f90
! function ispline evaluates the cubic spline interpolation at point z
! ispline = y(i)+b(i)*(u-x(i))+c(i)*(u-x(i))**2+d(i)*(u-x(i))**3
! where  x(i) <= u <= x(i+1)
!----------------------------------------------------------------------
! input..
! u       = the abscissa at which the spline is to be evaluated
! x, y    = the arrays of given data points
! b, c, d = arrays of spline coefficients computed by spline
! n       = the number of data points
! output:
! ispline = interpolated value at point u
!=======================================================================
      implicit none
      real(r8) ispline
      integer b_n
! double precision  u, x(n), y(n), b(n), c(n), d(n)
      real(r8) :: b_u 
      real(r8), dimension(:) :: b_x, b_y, b_b, b_c, b_d 
      integer b_i, b_j, b_k
      real(r8) b_dx

! if u is ouside the x() interval take a boundary value (left or right)
      if(b_u <= b_x(1)) then
        ispline = b_y(1)
        return
      end if
      if(b_u >= b_x(b_n)) then
        ispline = b_y(b_n)
        return
      end if

!*
!  binary search for for i, such that x(i) <= u <= x(i+1)
!*
      b_i = 1
      b_j = b_n+1
      do while (b_j > b_i+1)
        b_k = (b_i+b_j)/2
        if(b_u < b_x(b_k)) then
          b_j=b_k
        else
          b_i=b_k
        end if
      end do
!*
!  evaluate spline interpolation
!*
      b_dx = b_u - b_x(b_i)
      ispline = b_y(b_i) + b_dx*(b_b(b_i)+b_dx*(b_c(b_i)+b_dx*b_d(b_i)))
      end function ispline


      end module mod_interp1d


! program test

!     use interp1D 

!     implicit none 

!     double precision, parameter :: pi = 2.d0*acos(0.d0)

!     integer, parameter :: n    = 12
!     integer, parameter :: nout = 360
    
!     double precision, dimension(n)    :: x, y
!     double precision, dimension(nout) :: xout, yout

!     integer :: k, q 

!     do k = 1, n 
!         x(k) = k*30-15 
!         y(k) = sin(x(k)*2*pi/dble(nout)) + (k-6)*0.3d0
!     end do 

!     do k = 1, nout 
!         xout(k) = k 
!     end do 

!     yout = interp_spline(x,y,xout)

!     q = 1 
!     do k = 1, nout 
        
!         if (xout(k) .eq. x(q)) then 
!             write(*,"(2f10.3,2f10.3)") x(q), y(q), xout(k), yout(k) 
!             q = q+1
!         else
!             write(*,"(2a10,2f10.3)") "NA","NA", xout(k), yout(k) 
!         end if 

!     end do 

! end program test 

!      program main
!        use mod_interp1d
!       use iso_fortran_env, only: int32, int64, real32, real64, real128
!        implicit none
!        real(r8) :: a1(3),a2(4),b1(3),b2(4)

!        a1 = [1.0,1.4, 2.0]
!        b1 = [3.0,3.5, 5.0]
!        a2 = [1.1,1.4,1.7,1.9]
!        b2 = interp_linear(a1,b1,a2)
!        write(*,*) b1
!        write(*,*) b2
!        write(*,*) interp_spline(a1,b1,a2)
!      end
