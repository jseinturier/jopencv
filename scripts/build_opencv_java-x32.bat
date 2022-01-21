@echo on
@cls
@SETLOCAL EnableDelayedExpansion

@rem Clone and build OpenCV C++ library from official Git repository.
@rem 
@rem This installation script needs that Git binaries are presents within PATH
@rem Git for windows can be downloaded from https://gitforwindows.org
@rem 
@rem CMake for windows is also needed and its binaries have to be pointed by PATH variable.
@rem CMake for windows can be downloaded from https://cmake.org
@rem
@rem In order to build OpenCV, this script need an access to the devenv.exe command.
@rem this command is available if:
@rem   - This script is called from a Visual Studio Command Prompt (see https://docs.microsoft.com/en-us/dotnet/framework/tools/developer-command-prompt-for-vs)
@rem   - Before calling this script, the directory that contains devenv command is added to the PATH.
@rem If devenv is not accessible by this script, final build has to be performed from Visual Studio IDE.

@ECHO OpenCV installation

SET PYTHON_CMAKE=-DBUILD_opencv_python:BOOL=OFF -DBUILD_opencv_python2:BOOL=OFF -DBUILD_opencv_python3:BOOL=OFF

@rem check if Git is available
@WHERE git >nul 2>nul
@IF NOT %ERRORLEVEL% EQU 0 (
  @ECHO Git command not found, please install Git for windows from https://gitforwindows.org
  @EXIT /B
)

@rem check if Git is available
@WHERE cmake >nul 2>nul
@IF NOT %ERRORLEVEL% EQU 0 (
  @ECHO CMake command not found, please install CMake for windows from https://cmake.org
  @EXIT /B
)

@SET local_repository=%~dp0%git

@SET logfile=%~dp0%build.log

@SET opencvtag="4.5.3"
@SET opencvcontribtag="4.5.3"

@ECHO   Using repository %local_repository%

@rem Visual studio configuration
@SET VISUAL_STUDIO_VC=vc16
@SET CMAKE_GENERATOR="Visual Studio 16 2019"
@SET CMAKE_GENERATOR_TOOLSET="v142,host=x86"

@rem TBB integration
@SET TBBROOT=""
@SET TBB_TARGET_ARCH=intel64
@SET TBB_TARGET_VS=%VISUAL_STUDIO_VC%

@SET TBB_ARCH_PLATFORM="%TBB_TARGET_ARCH%\%TBB_TARGET_VS%"
@SET TBB_BIN_DIR="%TBBROOT%\bin"
@SET TBB_INCLUDE_DIRS="%TBBROOT%\include"
@SET TBB_LIB_DIR="%TBBROOT%\lib\%TBB_TARGET_ARCH%\%TBB_TARGET_VS%"
@SET TBB_STDDEF_PATH=%TBB_INCLUDE_DIRS%\tbb\tbb_stddef.h"

@rem Checking platform constructor
@ECHO.
@ECHO Checking CPU
@wmic cpu get name /VALUE | findstr /i "intel" >nul 2>&1
@IF ERRORLEVEL 0 (
    @ECHO   Intel Architecture found, enabling TBB
) ELSE (
    @ECHO   No Intel Architecture found, disabling TBB
    @SET TBBROOT=
)

@IF EXIST %TBBROOT% (
    @ECHO   Integrating TBB from %TBBROOT%
    @SET TBB_INTEGRATION="-DWITH_TBB:BOOL=ON -DBUILD_TBB:BOOL=OFF -DTBB_ENV_INCLUDE:PATH=!TBB_INCLUDE_DIRS! -DTBB_ENV_LIB:FILEPATH=!TBB_LIB_DIR!/tbb.lib -DTBB_ENV_LIB_DEBUG:FILEPATH=!TBB_LIB_DIR!/tbb_debug.lib"
    @ECHO   CMAKE properties: !TBB_INTEGRATION!
) ELSE (
    @ECHO   No TBB library provided.
    @SET TBB_INTEGRATION=
)
    
@SET IPP_INTEGRATION=

@ECHO CUDA is not activated
@SET CUDA_INTEGRATION=-DWITH_CUDA:BOOL=OFF -DWITH_CUBLAS:BOOL=ON

@ECHO.
@ECHO Getting OpenCV from git repository
@IF EXIST %local_repository% (
  @ECHO   Updating opencv
) ELSE (
  @ECHO   Clonning opencv
  @mkdir %local_repository%
  @pushd %local_repository%
  git clone -b %opencvtag% --depth 1 --single-branch "https://github.com/opencv/opencv.git"
  @popd
    

)

@IF EXIST build (
  @rmdir build
)

@mkdir build
@mkdir build\opencv
    
@IF EXIST install (
  @rmdir install
)
@mkdir install
@mkdir install\opencv

@ECHO.
@ECHO Checking opencv_contrib git repository
@IF EXIST %local_repository%\opencv_contrib (
    @echo   Updating opencv_contrib
    @rem cd opencv_contrib
    @rem git pull --rebase https://github.com/opencv/opencv_contrib.git ${opencvcontribtag}
    @rem cd ..
) ELSE (
    @echo   Clonning opencv_contrib
    @pushd %local_repository%
    git clone -b %opencvcontribtag% --depth 1 --single-branch "https://github.com/opencv/opencv_contrib.git"
    @popd
    @mkdir build\opencv_contrib
)

SET JAVA_CMAKE=-DBUILD_JAVA:BOOL=ON -DBUILD_opencv_java:BOOL=ON -DBUILD_opencv_java_bindings_generator:BOOL=ON

@ECHO.
@ECHO CMAKE processing

@pushd build\opencv

@ECHO   Running CMAKE (see %logfile% for details)
@SET CMAKE_OPTIONS=%PYTHON_CMAKE% %JAVA_CMAKE% -DBUILD_PERF_TESTS:BOOL=OFF -DBUILD_TESTS:BOOL=OFF -DOPENCV_ENABLE_NONFREE:BOOL=ON -DBUILD_DOCS:BOOL=OFF -DBUILD_EXAMPLES:BOOL=OFF -DBUILD_SHARED_LIBS:BOOL=OFF

@ECHO   CMake options:
@ECHO     General: %CMAKE_OPTIONS%
@ECHO     Ipp integration : %IPP_INTEGRATION%
@ECHO     TBB integration : %TBB_INTEGRATION%
@ECHO     CUDA integration: %CUDA_INTEGRATION%

cmake -G%CMAKE_GENERATOR% -T%CMAKE_GENERATOR_TOOLSET% -A win32 %CMAKE_OPTIONS% %IPP_INTEGRATION% %TBB_INTEGRATION% %CUDA_INTEGRATION% -DOPENCV_EXTRA_MODULES_PATH=%local_repository%\opencv_contrib\modules -DCMAKE_INSTALL_PREFIX=..\..\install\opencv %local_repository%\opencv > %logfile% 2>&1

@ECHO   Running CMAKE build config release (see %logfile% for details)
cmake --build .  --config release >> %logfile% 2>&1

@ECHO   Running CMAKE build target release (see %logfile% for details)
cmake --build .  --target install --config release >> %logfile% 2>&1

@popd


@ENDLOCAL