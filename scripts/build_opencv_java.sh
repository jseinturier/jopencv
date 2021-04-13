#!/bin/bash

echo "OpenCV installation"

echo
echo 'System check'
# Check if Git is available
if ! [ -x "$(command -v git)" ]; then
  echo 'Git command not found, please install git package'
  exit 1
fi

# Check if CMake is available
if ! [ -x "$(command -v cmake)" ]; then
  echo 'CMake command not found, please install CMake package'
  exit 1
fi

# Check if Java is available
if ! [ -x "$(command -v javac)" ]; then
  echo 'javac command not found, please install Java Developement Kit'
  echo 'from https://jdk.java.net/ and add java executable directory to PATH.'
  exit 1
fi

# Check if Ant is available
if ! [ -x "$(command -v ant)" ]; then
  echo 'ant command not found, please install Apache Ant'
  echo 'from https://ant.apache.org/ and add ant executable directory to PATH.'
  exit 1
fi

script_directory="$(cd "$( echo "${BASH_SOURCE[0]%/*}" )" && pwd )"

local_repository=${script_directory}/git

logfile=${script_directory}/build.log

opencvtag="4.4.0"
opencvcontribtag="4.4.0"

echo "  Using repository ${local_repository}"

#TBB integration
TBBROOT=""
TBB_TARGET_ARCH=intel64

TBB_ARCH_PLATFORM="${TBB_TARGET_ARCH}"
TBB_BIN_DIR="${TBBROOT}/bin"
TBB_BIN_DIRS="${TBBROOT}/include"
TBB_LIB_DIR="${TBBROOT}/lib/${TBB_TARGET_ARCH}"
TBB_STDDEF_PATH="${TBB_BIN_DIRS}/tbb/tbb_stddef.h"

#Checking CPU
cpu_constructor=`cat /proc/cpuinfo | grep "vendor_id" | tr -d "[:blank:]"|cut -f2 -d':'`


IPP_INTEGRATION="-DUSE_IPP:BOOL=ON"

# Disabling CUDA
echo "CUDA deactivated for Java wrapper generation"
CUDA_INTEGRATION="-DWITH_CUDA:BOOL=OFF -DCUDA_FAST_MATH:BOOL=OFF -DWITH_CUBLAS:BOOL=OFF"


echo
echo "Getting OpenCV from Git repository"
if [ ! -d "${local_repository}" ]; then
  echo '  Cloning OpenCV from https://github.com/opencv/opencv.git'
  mkdir ${local_repository}
  pushd ${local_repository} > /dev/null
  git clone -b ${opencvtag} --depth 1 --single-branch "https://github.com/opencv/opencv.git"
  popd > /dev/null
else
  echo "${local_repository} already exists, using these sources."
  echo "Remove the directory to perform a clean download."
fi

if [ ! -d "${local_repository}/opencv_contrib" ]; then
  echo '  Cloning OpenCV Contrib from https://github.com/opencv/opencv_contrib.git'
  pushd ${local_repository} > /dev/null
  git clone -b ${opencvcontribtag} --single-branch --depth 1 "https://github.com/opencv/opencv_contrib.git"
  popd > /dev/null
else
  echo "${local_repository} already exists, using these sources."
  echo "Remove the directory to perform a clean download."
fi

echo
echo "Preparing build structure"
if [ -d "build" ]; then
  echo "  Cleaning build dir"
  rm -rf build
fi

echo "  Creating build dirs"
mkdir build
mkdir build/opencv
mkdir build/opencv_contrib

if [ -d "install" ]; then
  echo "  Cleaning install dir"
  rm -rf "install"
fi

echo "  Creating install dirs"
mkdir "install"
mkdir "install/opencv"

JAVA_CMAKE="-DBUILD_JAVA:BOOL=ON -DBUILD_opencv_java:bool=ON -DBUILD_opencv_java_bindings_generator:BOOL=on"

echo
echo "CMake processing"

pushd build/opencv > /dev/null

echo "  Running CMake (see ${logfile} for details)"

CMAKE_CONFIG_GENERATOR="Unix Makefiles"

CMAKE_OPTIONS="${JAVA_CMAKE} -DBUILD_PERF_TESTS:BOOL=OFF -DBUILD_TESTS:BOOL=OFF -DOPENCV_ENABLE_NONFREE:BOOL=ON -DBUILD_DOCS:BOOL=OFF -DBUILD_EXAMPLES:BOOL=OFF -DBUILD_SHARED_LIBS:BOOL=OFF"

echo "    CMake options:"
echo "      General: ${CMAKE_OPTIONS}"
echo "      IPP integration : ${IPP_INTEGRATION}"
echo "      TBB integration : ${TBB_INTEGRATION}"
echo "      CUDA integration: ${CUDA_INTEGRATION}"

cmake -G"${CMAKE_CONFIG_GENERATOR}" ${CMAKE_OPTIONS} ${IPP_INTEGRATION} ${TBB_INTEGRATION} ${CUDA_INTEGRATION} -DOPENCV_EXTRA_MODULES_PATH=${local_repository}/opencv_contrib/modules -DCMAKE_INSTALL_PREFIX=../../install/opencv ${local_repository}/opencv 1>>${logfile} 2>>${logfile}

echo "  Building"
make -j$(nproc) 1>>${logfile} 2>>${logfile}

echo "  Installing"
make install 1>>${logfile} 2>>${logfile}

echo
echo "OpenCV installation done."

echo
echo "Please update your environment variables as follows:"
echo "  OPENCV_INCDIR=${script_directory}/install/opencv/include/opencv4"
echo "  OPENCV_BINDIR=${script_directory}/install/opencv/lib"
echo "  OPENCV_LIBDIR=${script_directory}/install/opencv/lib"
popd

