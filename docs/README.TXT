=================================================================
 Carmageddon (DOS, 3dfx/Glide) - video mode patch
 CARMAVR.EXE  /  MAKEVR.BAT + PATCH.COM
 Patch author: Pr1ha
=================================================================

File encoding: plain ASCII (readable both in DOS and Windows).

WHAT IT DOES
------------
The game has a single mode flag that switches the 3dfx driver between
"Voodoo Graphics" and "Voodoo Rush" behaviour (-vgraphics / -vrush).

This patch changes exactly ONE thing in the executable: four CALL
instructions (5 bytes each) are replaced with NOPs. Those four calls
are the "unlock -> draw -> lock" pairs that the game executed around
every single 2D primitive. On Voodoo Rush each pair is expensive,
because the linear frame buffer has to be re-acquired through the
2D chip.

Nothing else is touched: no new code, no header changes, the file
size stays exactly the same (1 386 650 bytes).

PATCH SITES
-----------
   file offset    linear address    what was there
     0x066BDA        0x0437DA        unlock  (2D blit wrapper 1)
     0x066C02        0x043802        lock    (2D blit wrapper 1)
     0x07391E        0x05051E        unlock  (2D blit wrapper 2)
     0x073928        0x050528        lock    (2D blit wrapper 2)

EFFECT PER MODE
---------------
-vgraphics  (behaviour unchanged, exactly like the original game):
     fastest possible, not a single frame buffer lock per frame.
     The user interface flickers, because the LFB pointer is never
     refreshed after a buffer swap.

-vrush      (this is what the patch improves):
     the 2D layer is drawn into the same buffer as the screen and the
     LFB is re-acquired around the buffer swap, but the per-primitive
     flushes are gone.
       result: fast, no UI flicker;
       side effect: HUD elements may disappear, become darker or
       lighter depending on what is displayed on the screen.

WHY THAT EFFECT IS NOT FIXED
----------------------------
The per-primitive unlock/lock pair is not only a pointer refresh, it
also orders the CPU writes against the 3D pipeline. Without it, 2D
elements are composed against a scene that is still being drawn -
that is why HUD elements may disappear or change brightness.

FILES
-----
  MAKEVR.BAT    builds CARMAVR.EXE from CARMAV.EXE
  PATCH.COM     the patcher itself (461 bytes), called by MAKEVR.BAT
  PATCH.ASM     patcher source code (NASM)
  README.TXT    this text in English, ASCII
  READMERU.TXT  this text in Russian, CP866 (for DOS)
  READMEW.TXT   this text in Russian, CP1251 (for Windows)

HOW TO APPLY
------------
  1. put CARMAV.EXE, MAKEVR.BAT and PATCH.COM into the game directory
  2. run:  MAKEVR
  3. start: CARMAVR.EXE -vrush      (or without any key)

HOW TO REVERT
-------------
  delete CARMAVR.EXE (CARMAV.EXE is never modified by the patcher).

SAFETY
------
PATCH.COM checks that every patch site still starts with E8 (CALL)
before writing to it. On an already patched or foreign executable it
prints an error, exits with code 1, and MAKEVR.BAT deletes the
half-made CARMAVR.EXE. The original file is never modified by the
patcher - MAKEVR.BAT always patches a fresh copy.
