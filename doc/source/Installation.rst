.. _Installation:

Installation 
------------

This section assumes you want to compile the DAFoam optimization package (v1.1) from the source on a Linux system. If you use the pre-compiled version, skip this section.

The DAFoam package can be compiled with various dependency versions. Here we elaborate on how to compile it on Ubuntu 18.04 using the dependencies shown in the following table. 

.. list-table::
   :header-rows: 1

   *  - Ubuntu
      - Compiler
      - OpenMPI
      - mpi4py
      - PETSc
      - petsc4py
      - CGNS
      - python
      - numpy
      - scipy
      - Cython

   *  - 18.04
      - gcc/7.5
      - 1.10.7
      - 3.0.2
      - 3.11.0
      - 3.11.0
      - 3.3.0
      - 3.6.5
      - 1.14.3
      - 1.1.0
      - 0.28.2

To compile, you can just copy the code blocks in the following steps and run them on the terminal. **NOTE:** if a code block contains multiple lines, copy all the lines and run them on the terminal. Make sure each step run successfully before going to the next one. The entire compilation may take a few hours, the most time-consuming part is OpenFOAM.

#. **Prerequisites**. Run this on terminal::

    sudo apt-get update && \
    sudo apt-get install -y build-essential flex bison cmake zlib1g-dev libboost-system-dev libboost-thread-dev libreadline-dev libncurses-dev libxt-dev qt5-default libqt5x11extras5-dev libqt5help5 qtdeclarative5-dev qttools5-dev libqtwebkit-dev freeglut3-dev libqt5opengl5-dev texinfo  libscotch-dev libcgal-dev gfortran swig wget git vim cmake-curses-gui libfl-dev apt-utils --no-install-recommends

#. **Python**. Install Anaconda3-5.2.0::

    mkdir -p $HOME/packages && \
    cd $HOME/packages && \
    wget https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh --no-check-certificate && \
    chmod 755 Anaconda3-5.2.0-Linux-x86_64.sh && \
    ./Anaconda3-5.2.0-Linux-x86_64.sh -b -p $HOME/packages/anaconda3 && \
    echo '# Anaconda3' >> $HOME/.bashrc && \
    echo 'export PATH=$HOME/packages/anaconda3/bin:$PATH' >> $HOME/.bashrc && \
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/packages/anaconda3/lib' >> $HOME/.bashrc && \
    . $HOME/.bashrc

#. **OpenMPI**. Append relevant environmental variables by running::

    echo '# OpenMPI-1.10.7' >> $HOME/.bashrc && \
    echo 'export MPI_INSTALL_DIR=$HOME/packages/openmpi-1.10.7/opt-gfortran' >> $HOME/.bashrc && \
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MPI_INSTALL_DIR/lib' >> $HOME/.bashrc && \
    echo 'export PATH=$MPI_INSTALL_DIR/bin:$PATH' >> $HOME/.bashrc && \
    . $HOME/.bashrc
 
   Then, configure and build OpenMPI::

    cd $HOME/packages && \
    wget https://download.open-mpi.org/release/open-mpi/v1.10/openmpi-1.10.7.tar.gz --no-check-certificate && \
    tar -xvf openmpi-1.10.7.tar.gz && \
    cd openmpi-1.10.7 && \
    ./configure --prefix=$MPI_INSTALL_DIR && \
    make all install

   Append one more relevant environmental variable by running::

    echo 'export LD_PRELOAD=$MPI_INSTALL_DIR/lib/libmpi.so' >> $HOME/.bashrc && \
    . $HOME/.bashrc

   To verify the installation, run::

    mpicc -v
  
   You should see the version of the compiled OpenMPI.

   Finally, install mpi4py-3.0.2::

    cd $HOME/packages && \
    wget https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-3.0.2.tar.gz --no-check-certificate && \
    tar -xvf mpi4py-3.0.2.tar.gz && \
    cd mpi4py-3.0.2 && \
    rm -rf build && \
    python setup.py install --user

#. **Petsc**. Append relevant environmental variables by running::
   
    echo '# Petsc-3.11.0' >> $HOME/.bashrc && \
    echo 'export PETSC_DIR=$HOME/packages/petsc-3.11.0' >> $HOME/.bashrc && \
    echo 'export PETSC_ARCH=real-opt' >> $HOME/.bashrc && \
    echo 'export PATH=$PETSC_DIR/$PETSC_ARCH/bin:$PATH' >> $HOME/.bashrc && \
    echo 'export PATH=$PETSC_DIR/$PETSC_ARCH/include:$PATH' >> $HOME/.bashrc && \
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PETSC_DIR/$PETSC_ARCH/lib' >> $HOME/.bashrc && \
    echo 'export PETSC_LIB=$PETSC_DIR/$PETSC_ARCH/lib' >> $HOME/.bashrc
    . $HOME/.bashrc

   Then, configure and compile::

    cd $HOME/packages && \
    wget http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.11.0.tar.gz --no-check-certificate && \
    tar -xvf petsc-3.11.0.tar.gz && \
    cd petsc-3.11.0 && \
    sed -i 's/ierr = MPI_Finalize();CHKERRQ(ierr);/\/\/ierr = MPI_Finalize();CHKERRQ(ierr);/g' src/sys/objects/pinit.c && \
    ./configure --PETSC_ARCH=real-opt --with-scalar-type=real --with-debugging=0 --with-mpi-dir=$MPI_INSTALL_DIR --download-metis=yes --download-parmetis=yes --download-superlu_dist=yes --download-fblaslapack=yes --with-shared-libraries=yes --with-fortran-bindings=1 --with-cxx-dialect=C++11 && \
    make PETSC_DIR=$HOME/packages/petsc-3.11.0 PETSC_ARCH=real-opt all

   NOTE: The above ``sed`` command comments out line 1367 in src/sys/objects/pinit.c to prevent Petsc from conflicting with OpenFOAM MPI_Finalize. 

   Finally, install petsc4py-3.11.0::

    cd $HOME/packages && \
    wget https://bitbucket.org/petsc/petsc4py/downloads/petsc4py-3.11.0.tar.gz --no-check-certificate && \
    tar -xvf petsc4py-3.11.0.tar.gz && \
    cd petsc4py-3.11.0 && \
    rm -rf build && \
    python setup.py install --user

#. **CGNS**. Append relevant environmental variables by running::
  
    echo '# CGNS-3.3.0' >> $HOME/.bashrc && \
    echo 'export CGNS_HOME=$HOME/packages/CGNS-3.3.0/opt-gfortran' >> $HOME/.bashrc && \
    echo 'export PATH=$PATH:$CGNS_HOME/bin' >> $HOME/.bashrc && \
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CGNS_HOME/lib' >> $HOME/.bashrc && \
    . $HOME/.bashrc

   Then, configure and compile::

    cd $HOME/packages && \
    wget https://github.com/CGNS/CGNS/archive/v3.3.0.tar.gz --no-check-certificate && \
    tar -xvaf v3.3.0.tar.gz && \
    cd CGNS-3.3.0 && \
    mkdir -p build && \
    cd build && \
    cmake .. -DCGNS_ENABLE_FORTRAN=1 -DCMAKE_INSTALL_PREFIX=$CGNS_HOME -DCGNS_BUILD_CGNSTOOLS=0 && \
    make all install
  
#. **MACH framework**. First create a ``repos`` folder and setup relevant environmental variables::

    echo '# Python Path' >> $HOME/.bashrc && \
    echo 'export PYTHONPATH=$PYTHONPATH:$HOME/repos' >> $HOME/.bashrc
    . $HOME/.bashrc && \
    mkdir -p $HOME/repos
    
   Then run::

    cd $HOME/repos && \
    git clone https://github.com/mdolab/baseclasses -b v1.1.0 && \
    cd $HOME/repos && \
    git clone https://github.com/mdolab/pygeo -b v1.1.0 && \
    cd $HOME/repos && \
    git clone https://github.com/mdolab/multipoint -b v1.1.0 && \
    cd $HOME/repos && \
    git clone https://github.com/mdolab/pyspline -b v1.1.0 && \
    cd pyspline && \
    cp config/defaults/config.LINUX_GFORTRAN.mk config/config.mk && \
    make && \
    cd $HOME/repos && \
    git clone https://github.com/mdolab/pyhyp -b v2.1.0 && \
    cd pyhyp && \
    cp -r config/defaults/config.LINUX_GFORTRAN_OPENMPI.mk config/config.mk && \
    make && \
    cd $HOME/repos && \
    git clone https://github.com/mdolab/cgnsutilities -b v2.1.0 && \
    cd cgnsutilities && \
    cp config.mk.info config.mk && \
    make && \
    echo '# cgnsUtilities' >> $HOME/.bashrc && \
    echo 'export PATH=$PATH:$HOME/repos/cgnsutilities/bin' >> $HOME/.bashrc && \
    cd $HOME/repos && \
    git clone https://github.com/mdolab/idwarp && \
    cd idwarp && \
    git checkout f854b65 && \
    cp -r config/defaults/config.LINUX_GFORTRAN_OPENMPI.mk config/config.mk && \
    make && \
    cd $HOME/repos && \
    git clone https://github.com/mdolab/pyoptsparse -b v2.1.0 && \
    cd pyoptsparse && \
    pip install -r requirements.txt && \
    rm -rf build && \
    python setup.py install --user

#. **OpenFOAM**. Compile OpenFOAM-v1812 by running::

    mkdir -p $HOME/OpenFOAM && \
    cd $HOME/OpenFOAM && \
    wget https://sourceforge.net/projects/openfoamplus/files/v1812/OpenFOAM-v1812.tgz/download  --no-check-certificate -O OpenFOAM-v1812.tgz && \
    wget https://sourceforge.net/projects/openfoamplus/files/v1812/ThirdParty-v1812.tgz/download  --no-check-certificate -O ThirdParty-v1812.tgz && \
    tar -xvf OpenFOAM-v1812.tgz && \
    tar -xvf ThirdParty-v1812.tgz && \
    cd $HOME/OpenFOAM/OpenFOAM-v1812 && \
    wget https://github.com/mdolab/dafoam/releases/download/v1.1.0/UPstream.C --no-check-certificate && \
    mv UPstream.C src/Pstream/mpi/UPstream.C && \
    . etc/bashrc && \
    export WM_NCOMPPROCS=4 && \
    ./Allwmake
  
   NOTE: In the above command, we replaced the OpenFOAM-v1812's built-in UPstream.C file with a customized one because we need to prevent OpenFOAM from calling the MPI_Finialize function when wrapping OpenFOAM functions using Cython.

   NOTE: The above command will compile OpenFOAM using 4 CPU cores. If you want to compile OpenFOAM using more cores, change the ``WM_NCOMPPROCS`` parameter before running ``./Allwmake``

   Finally, verify the installation by running::

    simpleFoam -help

   It should see some basic information of OpenFOAM

#. **DAFoam** and **pyOFM**. First compile pyOFM::

    cd $HOME/repos && \
    git clone https://github.com/mdolab/pyofm -b v1.1.1 && \
    cd pyofm && \
    . $HOME/OpenFOAM/OpenFOAM-v1812/etc/bashrc && \
    make

   Then, compile DAFoam by running::

    cd $HOME/repos && \
    git clone https://github.com/mdolab/dafoam -b v1.1.1 && \
    . $HOME/OpenFOAM/OpenFOAM-v1812/etc/bashrc && \
    cd $HOME/repos/dafoam && \
    make
    
   Finally, run the regression test::

    cd $HOME/repos/dafoam/python/reg_tests && \
    rm -rf input.tar.gz && \
    wget https://github.com/mdolab/dafoam/raw/master/python/reg_tests/input.tar.gz --no-check-certificate && \
    tar -xvf input.tar.gz && \
    python run_reg_tests.py
    
   The regression tests should take less than 30 minutes. You should see something like::
   
    dafoam buoyantBoussinesqSimpleDAFoam: Success!
    dafoam buoyantSimpleDAFoam: Success!
    dafoam calcDeltaVolPointMat: Success!
    dafoam calcSensMap: Success!
    dafoam rhoSimpleCDAFoam: Success!
    dafoam rhoSimpleDAFoam: Success!
    dafoam simpleDAFoam: Success!
    dafoam simpleTDAFoam: Success!
    dafoam solidDisplacementDAFoam: Success!
    dafoam turboDAFoam: Success!
  
   You should see the first "Success" in less than 5 minute. If any of these tests fails or they take more than 30 minutes, check the error in the generated dafoam_reg_* files. Make sure all the tests pass before running DAFoam.

|

In summary, here is the folder structures for all the installed packages::
   
  $HOME
    - OpenFOAM
      - OpenFOAM-v1812
      - ThirdParty-v1812
    - packages
      - anaconda3
      - CGNS-3.3.0
      - mpi4py-3.0.2
      - petsc-3.11.0
      - petsc4py-3.11.0
    - repos
      - baseclasses
      - cgnsutilities
      - dafoam
      - idwarp
      - multipoint
      - pygeo
      - pyhyp
      - pyofm
      - pyoptsparse
      - pyspline

Here is the DAFoam related environmental variable setup that should appear in your bashrc file::

  # OpenMPI-1.10.7
  export MPI_INSTALL_DIR=$HOME/packages/openmpi-1.10.7/opt-gfortran
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MPI_INSTALL_DIR/lib
  export PATH=$MPI_INSTALL_DIR/bin:$PATH
  export LD_PRELOAD=$MPI_INSTALL_DIR/lib/libmpi.so
  # PETSC
  export PETSC_DIR=$HOME/packages/petsc-3.11.0
  export PETSC_ARCH=real-opt
  export PATH=$PETSC_DIR/$PETSC_ARCH/bin:$PATH
  export PATH=$PETSC_DIR/$PETSC_ARCH/include:$PATH
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PETSC_DIR/$PETSC_ARCH/lib
  export PETSC_LIB=$PETSC_DIR/$PETSC_ARCH/lib
  # CGNS-3.3.0
  export CGNS_HOME=$HOME/packages/CGNS-3.3.0/opt-gfortran
  export PATH=$PATH:$CGNS_HOME/bin
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CGNS_HOME/lib
  # Python Path
  export PYTHONPATH=$PYTHONPATH:$HOME/repos
  # cgnsUtilities
  export PATH=$PATH:$HOME/repos/cgnsutilities/bin

 

  
