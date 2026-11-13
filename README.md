# Carmageddon - Voodoo Rush video mode patch

[![release](https://img.shields.io/github/v/release/Pr1ha/carmageddon-voodoo-rush-patch)](https://github.com/Pr1ha/carmageddon-voodoo-rush-patch/releases)

A patch for the DOS version of **Carmageddon** (3dfx/Glide build) that removes the
interface flicker in `-vrush` mode without bringing back the slowness of the stock
Rush path.

The patch ships no game code: it is a small DOS patcher (461 bytes) plus a
description of a four-instruction change. It is applied to your own copy of
`CARMAV.EXE`.

## What it does

The executable has a single mode flag that switches the 3dfx driver between
"Voodoo Graphics" and "Voodoo Rush" behaviour (`-vgraphics` / `-vrush`). The patch
replaces **four `CALL` instructions with `NOP`s** - those are the
`unlock -> draw -> lock` pairs the game executed around every 2D primitive. On
Voodoo Rush each pair is expensive, because the linear frame buffer has to be
re-acquired through the 2D chip.

Nothing else is changed: no code is added, headers are untouched, the file size
stays exactly the same (1,386,650 bytes).

| file offset | linear address | what was there |
|---|---|---|
| `0x066BDA` | `0x0437DA` | `unlock` (2D blit wrapper 1) |
| `0x066C02` | `0x043802` | `lock` (2D blit wrapper 1) |
| `0x07391E` | `0x05051E` | `unlock` (2D blit wrapper 2) |
| `0x073928` | `0x050528` | `lock` (2D blit wrapper 2) |

## Effect per mode

**`-vgraphics`** - behaviour unchanged, exactly like the original game: as fast as
possible, not a single frame buffer lock per frame. The interface flickers because
the LFB pointer is never refreshed after a buffer swap.

**`-vrush`** - this is what the patch improves: the 2D layer is drawn into the same
buffer as the screen, the LFB is re-acquired around the buffer swap, but the
per-primitive flushes are gone.

- result: fast, no UI flicker;
- side effect: HUD elements may disappear, become darker or lighter depending on
  what is displayed on the screen.

### Why the side effect is not fixed

The per-primitive `unlock/lock` pair is not only a pointer refresh: it also orders
the CPU writes against the 3D pipeline. Without it, 2D elements are composited
against a scene that is still being drawn, which is why HUD elements may disappear
or change brightness.

## Installation

1. Put `CARMAV.EXE`, `MAKEVR.BAT` and `PATCH.COM` into the game directory.
2. Run `MAKEVR` - it creates `CARMAVR.EXE` (the original file is never modified).
3. Start `CARMAVR.EXE -vrush` (or without any key).

Alternatively use the ready-made `dist/CARMAVR.ZIP` (classic ZIP, readable by any
DOS unpacker) - it contains the same files.

## Building the patcher

`src/PATCH.ASM` is assembled with NASM into a `.COM`:

```
nasm -f bin -o PATCH.COM src/PATCH.ASM
```

or run `BUILD.BAT` (NASM must be in `PATH`).

## Verification

- The patcher logic was run in an 8086 emulator (unicorn) against a copy of the
  image: exactly 20 bytes changed, all `0x90`, offsets match the reference; a
  second run on an already patched file is rejected with exit code 1.
- The patch was tested on real hardware: Voodoo Rush under DOS.

## Files

```
MAKEVR.BAT        builds CARMAVR.EXE from CARMAV.EXE
PATCH.COM         the patcher (DOS, real mode)
BUILD.BAT         rebuilds PATCH.COM from source
src/PATCH.ASM     patcher source (NASM)
docs/README.TXT   description, ASCII
docs/READMERU.TXT description, CP866 (for DOS)
docs/READMEW.TXT  description, CP1251 (for Windows)
docs/ANALYSIS.md  technical write-up
dist/CARMAVR.ZIP  ready-to-use archive for DOS
```

## Disclaimer

This project distributes no game files. `CARMAV.EXE` and `CARMAVR.EXE` are not part
of the repository and are listed in `.gitignore` - the patch is applied to the copy
you already own. Carmageddon and related trademarks belong to their respective
owners.

## Author and license

Author: **Pr1ha** - MIT, see [LICENSE](LICENSE).
