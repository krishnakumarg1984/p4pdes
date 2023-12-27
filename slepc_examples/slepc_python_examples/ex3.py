import sys

import slepc4py

slepc4py.init(sys.argv)

import numpy as np  # noqa: E402
from petsc4py import PETSc  # noqa: E402
from slepc4py import SLEPc  # noqa: E402

# this a sequential example
assert PETSc.COMM_WORLD.getSize() == 1

Print = PETSc.Sys.Print


def laplace2d(U, x, y):  # noqa: N803
    U[:, :] = 0
    U[1:-1, 1:-1] = x
    # Grid spacing
    m, n = x.shape
    hx = 1.0 / (m - 1)  # x grid spacing
    hy = 1.0 / (n - 1)  # y grid spacing
    # Setup 5-points stencil
    u = U[1:-1, 1:-1]  # center
    uN = U[1:-1, :-2]  # north # noqa: N806
    uS = U[1:-1, 2:]  # south # noqa: N806
    uW = U[:-2, 1:-1]  # west # noqa: N806
    uE = U[2:, 1:-1]  # east # noqa: N806
    # Apply Laplacian
    y[:, :] = (2 * u - uE - uW) * (hy / hx) + (2 * u - uN - uS) * (hx / hy)


class Laplacian2D(object):
    def __init__(self, m, n):
        self.m, self.n = m, n
        scalar = PETSc.ScalarType
        self.U = np.zeros([m + 2, n + 2], dtype=scalar)

    def mult(self, A, x, y):  # noqa: N803, ARG002
        m, n = self.m, self.n
        xx = x.getArray(readonly=1).reshape(m, n)
        yy = y.getArray(readonly=0).reshape(m, n)
        laplace2d(self.U, xx, yy)


def construct_operator(m, n):
    """
    Standard symmetric eigenproblem corresponding to the
    Laplacian operator in 2 dimensions. Uses *shell* matrix.
    """
    context = Laplacian2D(m, n)  # Create shell matrix
    # print(context)
    print(type(context))
    A = PETSc.Mat().createPython([m * n, m * n], context)  # noqa: N806
    A.setUp()
    return A


def solve_eigensystem(A, problem_type=SLEPc.EPS.ProblemType.HEP):  # noqa: N803
    # Create the result vectors
    xr, xi = A.createVecs()

    # Setup the eigensolver
    E = SLEPc.EPS().create()  # noqa: N806
    E.setOperators(A, None)
    E.setDimensions(3, PETSc.DECIDE)
    E.setProblemType(problem_type)
    E.setFromOptions()

    # Solve the eigensystem
    E.solve()
    Print("")
    its = E.getIterationNumber()
    Print("Number of iterations of the method: %i" % its)
    sol_type = E.getType()
    Print("Solution method: %s" % sol_type)
    nev, ncv, mpd = E.getDimensions()
    Print("Number of requested eigenvalues: %i" % nev)
    tol, maxit = E.getTolerances()
    Print("Stopping condition: tol=%.4g, maxit=%d" % (tol, maxit))
    nconv = E.getConverged()
    Print("Number of converged eigenpairs: %d" % nconv)
    if nconv > 0:
        Print("")
        Print("        k          ||Ax-kx||/||kx|| ")
        Print("----------------- ------------------")
        for i in range(nconv):
            k = E.getEigenpair(i, xr, xi)
            error = E.computeError(i)
            if k.imag != 0.0:
                Print(" %9f%+9f j  %12g" % (k.real, k.imag, error))
            else:
                Print(" %12f       %12g" % (k.real, error))
        Print("")


def main():
    opts = PETSc.Options()
    N = opts.getInt("N", 32)  # noqa: N806
    m = opts.getInt("m", N)
    n = opts.getInt("n", m)
    Print(f"Symmetric Eigenproblem (matrix-free), N={m * n} ({m}x{n} grid)")
    A = construct_operator(m, n)  # noqa: N806, RUF100, F841,
    solve_eigensystem(A)


if __name__ == "__main__":
    main()
