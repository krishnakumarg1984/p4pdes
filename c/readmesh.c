#include <petscmat.h>
#include <petscksp.h>
#include "convenience.h"
#include "readmesh.h"

//STARTGET
PetscErrorCode getmeshfile(MPI_Comm comm, const char suffix[],
                           char filename[], PetscViewer *viewer) {
  PetscErrorCode ierr;
  PetscBool      fset;
  ierr = PetscOptionsBegin(comm, "", "options for readmesh", ""); CHKERRQ(ierr);
  ierr = PetscOptionsString("-f", "filename root with PETSc binary, for reading", "", "",
                            filename, PETSC_MAX_PATH_LEN, &fset); CHKERRQ(ierr);
  ierr = PetscOptionsEnd(); CHKERRQ(ierr);
  if (!fset) {
    SETERRQ(comm,1,"option  -f FILENAME  required");
  }
  strcat(filename,suffix);
  ierr = PetscPrintf(comm,"  opening mesh file %s ...\n",filename); CHKERRQ(ierr);
  ierr = PetscViewerBinaryOpen(comm,filename,FILE_MODE_READ,
             viewer); CHKERRQ(ierr);
  return 0;
}
//ENDGET

//STARTREADMESH
PetscErrorCode readmesh(MPI_Comm comm, PetscViewer viewer,
                        Vec *E, Vec *x, Vec *y, Vec *Q) {
  PetscInt Ebs,Qbs,N,K,M;
  PetscErrorCode ierr;
  ierr = PetscPrintf(comm,"  reading mesh Vec E,x,y,Q from file ...\n"); CHKERRQ(ierr);
  ierr = VecCreate(comm,E); CHKERRQ(ierr);
  VecSetOptionsPrefix(*E,"E_");
  ierr = VecLoad(*E,viewer); CHKERRQ(ierr);
  ierr = VecCreate(comm,x); CHKERRQ(ierr);
  VecSetOptionsPrefix(*x,"x_");
  ierr = VecLoad(*x,viewer); CHKERRQ(ierr);
  ierr = VecCreate(comm,y); CHKERRQ(ierr);
  VecSetOptionsPrefix(*y,"y_");
  ierr = VecLoad(*y,viewer); CHKERRQ(ierr);
  ierr = VecCreate(comm,Q); CHKERRQ(ierr);
  VecSetOptionsPrefix(*Q,"Q_");
  ierr = VecLoad(*Q,viewer); CHKERRQ(ierr);
  ierr = VecGetBlockSize(*E,&Ebs); CHKERRQ(ierr);
  ierr = VecGetBlockSize(*Q,&Qbs); CHKERRQ(ierr);
  ierr = PetscPrintf(comm,"    block size for E is %d, for Q is %d\n",Ebs,Qbs); CHKERRQ(ierr);
  ierr = PetscObjectSetName((PetscObject)(*E),"E-element-full-info"); CHKERRQ(ierr);
  ierr = PetscObjectSetName((PetscObject)(*x),"x-coordinate"); CHKERRQ(ierr);
  ierr = PetscObjectSetName((PetscObject)(*y),"y-coordinate"); CHKERRQ(ierr);
  ierr = PetscObjectSetName((PetscObject)(*Q),"Q-boundary-segment"); CHKERRQ(ierr);
  ierr = getmeshsizes(comm,*E,*x,*Q,&N,&K,&M); CHKERRQ(ierr);
  ierr = PetscPrintf(comm,"    N=%d nodes, K=%d elements, M=%d boundary segments\n",
                     N,K,M); CHKERRQ(ierr);
  return 0;
}
//ENDREADMESH

PetscErrorCode getmeshsizes(MPI_Comm comm, Vec E, Vec x, Vec Q,
                            PetscInt *N, PetscInt *K, PetscInt *M) {
  PetscErrorCode ierr;
  if (N) {  ierr = VecGetSize(x,N); CHKERRQ(ierr); }
  if (K) {
    ierr = VecGetSize(E,K); CHKERRQ(ierr);
    if (*K % 12 != 0) {
      SETERRQ(comm,3,"element node index array P invalid: must have 12 K entries"); }
    *K /= 12;
  }
  if (M) {
    ierr = VecGetSize(Q,M); CHKERRQ(ierr);
    if (*M % 2 != 0) {
      SETERRQ(comm,3,"element node index array Q invalid: must have 2 M entries"); }
    *M /= 2;
  }
  return 0;
}
