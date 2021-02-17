@echo off
setlocal
call "%~dp0\paths"

set ENTRY_MODULE=%CCPNMR_TOP_DIR%\%VERSION_PATH%\python\pdbe\deposition\dataFileImport\dataFileImportGui.py
"%CONDA%"\python -i -O -W ignore "%ENTRY_MODULE%" %*
endlocal
