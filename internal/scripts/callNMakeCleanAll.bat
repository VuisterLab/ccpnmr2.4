rem Batch file to deep clean all the Windows .pyd files
@echo off
setlocal

set WIN_CMD=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat
rem Call the batch to set up the x64 native vs2019 environment
call "%WIN_CMD%"
call "%~dp0\..\..\bat\paths"

rem Call NMake to deep clean all the c code
nmake realclean
nmake cleanpyd

endlocal
