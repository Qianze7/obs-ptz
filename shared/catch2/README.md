# Vendored catchorg/Catch2 (amalgamated)

Source: https://github.com/catchorg/Catch2
Version: `v3.15.3` release, `catch_amalgamated.hpp`/`catch_amalgamated.cpp`
(the `extras/` amalgamated distribution upstream builds and attaches to
every v3 release for exactly this kind of single-static-lib vendoring, not
a hand-rolled repackaging).
License: Boost Software License 1.0 (see `COPYING` in this directory) -
upstream copyright/license header preserved as-is at the top of both files;
do not remove it.

## Why vendored, and why the amalgamated form specifically

Used only by `tests/uart-hil/`, a hardware-in-the-loop test suite for
`PTZUARTWrapper` (see that directory's `README.md`) - not part of the
`obs-ptz` plugin itself. Upstream's own preferred integration path for a
large/long-lived project is building Catch2 from its full multi-file source
as a static library (faster incremental rebuilds), but that trade-off
doesn't apply here: this is a small, rarely-changed test binary, so the
two-file amalgamated form's slower from-scratch compile is a non-issue, and
it avoids vendoring Catch2's own multi-file source tree and CMake package
machinery for a single consumer.

## What's here vs. upstream

Only `catch_amalgamated.hpp`/`catch_amalgamated.cpp`, downloaded directly
from the v3.15.3 GitHub release assets. Not vendored: upstream's own
`CMakeLists.txt`/`CMakeUserPresets.json`, the multi-file `src/` tree, docs,
examples, or the `extras/catch_amalgamated.hpp`'s sibling single-header
`catch.hpp` (Catch2 v2 compatibility form - not used, this project is v3).

## Updating

Replace both files with the same two assets from a newer `vX.Y.Z` GitHub
release (`https://github.com/catchorg/Catch2/releases/download/vX.Y.Z/catch_amalgamated.{hpp,cpp}`),
update the version noted above, and skim the release notes for any breaking
`TEST_CASE`/`Catch::Session` API changes affecting `tests/uart-hil/`.
