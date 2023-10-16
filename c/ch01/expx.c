#include <math.h>
#include <mpi.h>
#include <petsc.h>
#include <petscerror.h>
#include <petsclog.h>
#include <petscmath.h>
#include <petscsys.h>
#include <petscsystypes.h>

int main(int argc, char** argv)
{
    PetscCall(PetscInitialize(
        &argc, &argv, PETSC_NULLPTR,
        "Compute 'e^x' in parallel with PETSc.\nSupply 'x' as a real number as a command-line option.\n\n"));

    PetscMPIInt rank;
    PetscCall(MPI_Comm_rank(PETSC_COMM_WORLD, &rank));

    PetscReal x = 0.0;
    PetscOptionsBegin(PETSC_COMM_WORLD, "", "Options for expx", PETSC_NULLPTR);
    PetscCall(PetscOptionsReal("-x", "input to exp(x) function", PETSC_NULLPTR, x, &x, PETSC_NULLPTR));
    PetscOptionsEnd();

    // compute x^n/n! where n = rank of process
    PetscReal localval = pow(x, rank);
    for (PetscInt i = 2; i < rank + 1; ++i)
    {
        localval /= i;
    }

    PetscReal globalsum;
    // sum the contributions over all processes
    PetscCall(MPI_Allreduce(&localval, &globalsum, 1, MPIU_REAL, MPIU_SUM, PETSC_COMM_WORLD));

    // output estimate of e and report on work from each process
    PetscMPIInt nprocs;
    PetscCall(MPI_Comm_size(PETSC_COMM_WORLD, &nprocs));
    PetscCall(PetscPrintf(PETSC_COMM_WORLD, "e^%3.2f using %d processes is about %17.15f\n", x, nprocs, globalsum));
    // PetscCall(PetscPrintf(PETSC_COMM_SELF, "rank %d did %d flops\n", rank, (rank > 0) ? rank - 1 : 0));
    PetscCall(PetscFinalize());

    return 0;
}
