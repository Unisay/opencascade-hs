# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Haskell FFI bindings for the OpenCASCADE CAD kernel. Monorepo with four packages:
- **opencascade-hs** — thin C FFI wrapper over OpenCASCADE C++ classes
- **waterfall-cad** — high-level declarative CAD/solid modeling API built on opencascade-hs
- **waterfall-cad-svg** — SVG import/export for waterfall-cad
- **waterfall-cad-examples** — example programs (also serve as integration tests)

Dependency chain: `waterfall-cad-examples → waterfall-cad-svg → waterfall-cad → opencascade-hs → [OpenCASCADE C++ libs]`

## Build Commands

```bash
stack build                    # build all packages
stack build opencascade-hs     # build single package
stack haddock                  # generate docs
stack exec waterfall-cad-examples -- --csg --dark-mode-svg out.svg  # run example
```

Cabal alternative: `cabal.project` configures the same four packages.

Versioning is centralized in `package-defaults.yaml` — all four packages share a single version (currently 0.6.2.0).

## System Dependencies

Requires OpenCASCADE >= 7.8.x C++ libraries installed system-wide.
- Linux (Debian): `libocct-*-7.9` and `libocct-*-dev` packages
- macOS: `brew install opencascade` (plus CPATH/LIBRARY_PATH exports for Apple Silicon)

## Compiler Settings

Defined in `package-defaults.yaml`:
- GHC: `-Wall` plus `-Werror` on incomplete patterns, partial fields, missing export lists, redundant constraints
- C++: `--std=c++17 -Wall -Werror`

All modules must have explicit export lists (`-Werror=missing-export-lists`).

## FFI Binding Architecture (opencascade-hs)

Each wrapped OpenCASCADE class requires three files following a strict naming convention:

1. **C++ wrapper** (`cpp/hs_<module_path>.cpp`) — allocates via `new`, delegates to OpenCASCADE methods, dereferences pointers with `*` for pass-by-value params
2. **C header** (`cpp/hs_<module_path>.h`) — `extern "C"` declarations; types from `hs_types.h` (opaque `typedef void` in C mode)
3. **Haskell module** (`src/OpenCascade/<Module>/...hs`) — `{-# LANGUAGE CApiFFI #-}`, imports raw C functions, wraps constructors in `Acquire` with matching destructor

Key patterns:
- **Memory management**: constructors return `Acquire (Ptr T)` using `mkAcquire rawNew deleteT` for deterministic cleanup via `resourcet`
- **Type hierarchy**: `SubTypeOf a b` (compile-time upcast via `castPtr`) and `DiscriminatedSubTypeOf a b` (runtime downcast) in `OpenCascade.Inheritance`
- **Handle types**: reference-counted OpenCASCADE handles wrapped in `OpenCascade.Handle`
- **Destructors**: each type's destructor lives in `<Module>.Internal.Destructors`
- **Opaque types**: C sees `typedef void gp_Pnt;` etc. in `hs_types.h`; Haskell declares matching empty ADTs in `Types` modules

Naming: `hs_<occt_class>_<Method>` for C functions, e.g. `hs_gp_Pnt_X` → `OpenCascade.GP.Pnt.getX`

## waterfall-cad Architecture

Higher-level API that hides `Ptr` and `Acquire` behind solid modeling operations:
- `Waterfall.Solids` — primitive shapes (box, sphere, cylinder, cone, torus, platonic solids)
- `Waterfall.Booleans` — union, intersection, difference
- `Waterfall.Transforms` — translate, rotate, scale, mirror
- `Waterfall.Revolution`, `Sweep`, `Loft`, `Offset` — shape construction
- `Waterfall.TwoD.*` — 2D paths and shapes
- `Waterfall.Path` — 3D paths with Bezier/BSpline support
- `Waterfall.IO` — STEP, STL, glTF, OBJ file I/O
- `Waterfall.Internal.*` — conversion layer between waterfall types and opencascade-hs pointers

## Testing

No formal test suite. Validation is done by running examples and inspecting generated SVG/GLB output:
```bash
./scripts/regenerate-images.sh   # rebuild all example images
```

## Releasing

Release scripts in `scripts/releasing/`. All packages are published to Hackage.
