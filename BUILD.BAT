@echo off
rem Rebuild PATCH.COM from src\PATCH.ASM (nasm must be in PATH)
if not exist src\PATCH.ASM goto noasm
nasm -f bin -o PATCH.COM src\PATCH.ASM
if errorlevel 1 goto failed
echo PATCH.COM rebuilt:
dir PATCH.COM | find "PATCH.COM"
goto end
:noasm
echo src\PATCH.ASM not found.
goto end
:failed
echo NASM failed - check that nasm.exe is in PATH.
:end
