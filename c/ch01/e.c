#include <mpi.h>
#include <petsc.h>
#include <petscerror.h>
#include <petsclog.h>
#include <petscmath.h>
#include <petscsys.h>
#include <petscsystypes.h>

int main(int argc, char** argv)
{
    PetscCall(PetscInitialize(&argc, &argv, PETSC_NULLPTR, "Compute 'e' in parallel with PETSc.\n\n"));

    PetscMPIInt rank;
    PetscCall(MPI_Comm_rank(PETSC_COMM_WORLD, &rank));

    // compute 1/n! where n = (rank of process) + 1
    PetscReal localval = 1.0;
    for (PetscInt i = 2; i < rank + 1; ++i)
    {
        localval /= i;
    }

    PetscReal globalsum;
    // sum the contributions over all processes
    PetscCall(MPI_Allreduce(&localval, &globalsum, 1, MPIU_REAL, MPIU_SUM, PETSC_COMM_WORLD));

    // output estimate of e and report on work from each process
    PetscCall(PetscPrintf(PETSC_COMM_WORLD, "e is about %17.15f\n", globalsum));
    PetscCall(PetscPrintf(PETSC_COMM_SELF, "rank %d did %d flops\n", rank, (rank > 0) ? rank - 1 : 0));
    PetscCall(PetscFinalize());

    return 0;
}
