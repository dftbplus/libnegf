module ln_extract
  
  use ln_precision
  use ln_allocation
  use ln_constants
  use mat_def
  use sparsekit_drv
  use ln_structure, only: TStruct_Info
  use lib_param

  implicit none

  private

  public :: extract_device, extract_cont 

contains

  subroutine extract_device(negf)

    Type(Tnegf), pointer :: negf

    Integer :: nmdim

    nmdim = negf%str%central_dim

    call zextract(negf%H,1,nmdim,1,nmdim,negf%HM)
    call zextract(negf%S,1,nmdim,1,nmdim,negf%SM)

  end subroutine extract_device

  !--------------------------------------------------------------------------------------------

  subroutine extract_cont(negf)

    Type(Tnegf), pointer :: negf

    Integer :: i, ncont, i1, i2, j1, j2
    Integer :: cstart(MAXNCONT),cend(MAXNCONT),nmdim       
    Integer :: ncdim(MAXNCONT), surfdim(MAXNCONT)

    ncont =  negf%str%num_conts
    do i=1,ncont
       cstart(i) = negf%str%mat_B_start(i)
       cend(i)   = negf%str%mat_C_end(i)
       ncdim(i)  = cend(i)-cstart(i)+1
       surfdim(i) = negf%str%mat_C_start(i) - negf%str%mat_B_start(i)
    enddo


    do i=1,ncont
       !write(*,*) '(ext_cont)',i,cstart(i),cend(i),surfdim(i),ncdim(i)
       call zextract_dns(negf%H,cstart(i),cend(i),cstart(i),cend(i),negf%HC(i))       
       call zextract_dns(negf%S,cstart(i),cend(i),cstart(i),cend(i),negf%SC(i))
    enddo

    do i=1,ncont
       !print*, '(int) extract central-contact',i
       i1 = negf%str%mat_PL_start( negf%str%cblk(i) )
       i2 = negf%str%mat_PL_end( negf%str%cblk(i) ) 
       j1 = cstart(i); 
       j2 = j1+(ncdim(i)+surfdim(i))/2-1
       !print*, 'Interaction block:',i1,i2,j1,j2
       call zextract(negf%H,i1,i2,j1,j2,negf%HMC(i))         
       call zextract(negf%S,i1,i2,j1,j2,negf%SMC(i)) 

!print*,'(extract)',negf%HMC(i)%nzval
!print*,'(extract)',negf%SMC(i)%nzval

    enddo

  end subroutine extract_cont

end module ln_extract