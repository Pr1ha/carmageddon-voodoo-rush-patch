@echo off
rem MAKEVR.BAT - build CARMAVR.EXE from CARMAV.EXE (Carmageddon 3dfx patch)
rem Needs PATCH.COM in the same directory.
if not exist CARMAV.EXE goto nofile
if not exist PATCH.COM goto nopatch
if exist CARMAVR.EXE del CARMAVR.EXE
echo Copying CARMAV.EXE to CARMAVR.EXE ...
copy CARMAV.EXE CARMAVR.EXE >nul
if errorlevel 1 goto copyfail
echo Patching ...
PATCH.COM CARMAVR.EXE
if errorlevel 1 goto patfail
echo.
echo Done. CARMAVR.EXE is ready - run it instead of CARMAV.EXE.
goto end
:nofile
echo CARMAV.EXE not found in this directory.
goto end
:nopatch
echo PATCH.COM not found in this directory.
goto end
:copyfail
echo ERROR: cannot copy CARMAV.EXE (disk full or read-only).
goto end
:patfail
echo ERROR: patching failed - wrong or already patched file.
if exist CARMAVR.EXE del CARMAVR.EXE
echo Incomplete CARMAVR.EXE removed.
:end
