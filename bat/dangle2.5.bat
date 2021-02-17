@echo off
setlocal
call "%~dp0\paths.bat"

set ENTRY_MODULE=%CCPNMR_TOP_DIR%\%VERSION_PATH%\python\cambridge\dangle\DangleGui.py
"%CONDA%"\python -i -O -W ignore "%ENTRY_MODULE%" %*
endlocal
