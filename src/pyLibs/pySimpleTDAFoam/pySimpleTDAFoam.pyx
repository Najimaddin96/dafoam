
# distutils: language = c++
# distutils: sources = SimpleTDAFoam.C

'''

    DAFoam  : Discrete Adjoint with OpenFOAM
    Version : v1.1

    Description:
        Cython wrapper functions that call OpenFOAM libraries defined
        in the *.C and *.H files. The python naming convention is to 
        add "py" before the C++ class name

'''

# for using Petsc
#from petsc4py.PETSc cimport Vec, PetscVec

# declear cpp functions
cdef extern from "SimpleTDAFoam.H" namespace "Foam":
    cppclass SimpleTDAFoam:
        SimpleTDAFoam(char*) except +
        void run()

# create python wrappers that call cpp functions
cdef class pySimpleTDAFoam:

    # define a class pointer for cpp functions
    cdef:
        SimpleTDAFoam * _thisptr

    # initialize this class pointer with NULL
    def __cinit__(self):
        self._thisptr = NULL

    # deallocate the class pointer, and
    # make sure we don't have memory leak
    def __dealloc__(self):
        if self._thisptr != NULL:
            del self._thisptr

    # point the class pointer to the cpp class constructor
    def __init__(self, argsAll):
        '''
        argsAll: string that contains all the arguments
        for running OpenFOAM solvers, including
        the name of the solver.

        For example, in OpenFOAM, if we run the following:

        mpirun -np 2 simpleFoam -parallel

        Then, the corresponding call in pySimpleFoam is:

        foam = SimpleFoam("simpleFoam -parallel")
        '''
        self._thisptr = new SimpleTDAFoam(argsAll)

    # wrap all the other memeber functions in the cpp class
    def run(self):
        self._thisptr.run()
