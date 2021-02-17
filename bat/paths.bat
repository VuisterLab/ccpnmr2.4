@echo off
set CCPNMR_TOP_DIR=%~dp0\..

set CONDA=%CCPNMR_TOP_DIR%\miniconda
set VERSION_PATH=ccpnmr2.5
set PYTHONPATH=.;%CCPNMR_TOP_DIR%\%VERSION_PATH%\python
set PATH=%CONDA%\lib\site-packages\numpy\.libs;%CONDA%;%CONDA%\Library\mingw-w64\bin;%CONDA%\Library\usr\bin;%CONDA%\Library\bin;%CONDA%\Scripts;%CONDA%\bin;%CCPNMR_TOP_DIR%\bin;%PATH%
set LD_LIBRARY_PATH=%CONDA%\lib
