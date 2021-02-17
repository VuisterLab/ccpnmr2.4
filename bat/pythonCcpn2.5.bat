@echo off
setlocal
call "%~dp0\paths"

"%CONDA%"\python -O %*
endlocal
