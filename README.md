# CMake Multiple Target Generator #

Utility library to handle multiple builds of targets with different options
(for instance, those used by cotire, sanitize-target-cmake, etc)

## Status ##

| Travis CI (Ubuntu) | AppVeyor (Windows) | Coverage | Biicode | Licence |
|--------------------|--------------------|----------|---------|---------|
|[![Travis](https://img.shields.io/travis/polysquare/cmake-multi-targets.svg)](http://travis-ci.org/polysquare/cmake-multi-targets)|[![AppVeyor](https://img.shields.io/appveyor/ci/smspillaz/cmake-parallel-build-target-utils.svg)](https://ci.appveyor.com/project/smspillaz/cmake-parallel-build-target-utils)|[![Coveralls](https://img.shields.io/coveralls/polysquare/cmake-multi-targets.svg)](http://coveralls.io/polysquare/github/cmake-multi-targets)|[![Biicode](https://webapi.biicode.com/v1/badges/smspillaz/smspillaz/cmake-multi-targets/master)](https://www.biicode.com/smspillaz/cmake-multi-targets)|[![License](https://img.shields.io/github/license/polysquare/cmake-multi-targets.svg)](http://github.com/polysquare/cmake-multi-targets)|

## Usage ##

### Creating a special configuration for an already-set-up target ###

In most cases, the target which you want to create a special configuration
for will be already completely set-up. `psq_create_mirrored_build_target`
is a single function that can be called to create a special definition
for that target. New compiler and linker flags can be added to this
special definition.

#### `psq_create_mirrored_build_target` ####

Creates a mirrored build target for `TARGET` named `TARGET_SUFFIX`. The mirrored
build target will use the specified `COMPILE_FLAGS` and `LINK_FLAGS` and depend
on the original target's library dependencies (or mirrored library
dependencies) with the same `SUFFIX`. The dependencies in `DEPENDS` will be
added to the mirrored target

- `TARGET`: Target to mirror
- `SUFFIX`: Suffix to add to mirrored target
- `COMPILE_FLAGS`: Additional compile flags for mirrored target
- `LINK_FLAGS`: Additional link flags for mirrored target
- `DEPENDS`: Other targets for mirrored target to depend on

### Creating diverging configurations for target being set up ###

In some cases, you might want to create a mirrored build target but cannot
guarantee that the target's set-up hasn't completed yet. This case must
be handled differently from `psq_create_mirrored_build_target`, because
dependencies will be selected at the time that function is called, and not
at a later stage. If the original target is modified, then those modifications
will not be represented in the mirrored target.

In these cases, you will want to create the mirrored build target first
using `psq_setup_mirrored_build_target` and then wire up its dependencies
later using `psq_wire_mirrored_build_target_dependencies`.

#### `psq_setup_mirrored_build_target` ####

Sets up "mirrored" build target for `TARGET`, using its sources. Definitions
and include directories are currently inherited from the directory and
target-level include directories and definitions on `TARGET`.

This does not set up a mirrored target's link libraries or dependencies.

- `TARGET`: Target to mirror
- `SUFFIX`: Suffix on this mirrored target
- [Optional] `COMPILE_FLAGS`: Additional compiler flags for this mirrored target
- [Optional] `LINK_FLAGS`: Additional linker flags for this mirrored target

#### `psq_wire_mirrored_build_target_dependencies` ####

For a `TARGET`, find the corresponding mirrored build target
`TARGET_SUFFIX` and wire up its dependencies as follows:

    1. For each of the original target's `LINK_LIBRARIES`, find any libraries
       that are built in this project as targets, determine if a corresponding
       mirrored version of that target exists with the `SUFFIX` specified and ]
       then link this mirrored target to that one.
    2. For all other libraries, link the mirrored target to that library.
    3. Add dependencies as specified in `DEPENDS`

- [Optional] `DEPENDS`: Additional dependencies