# /tests/CMakeLists.txt
# Main entry point for the MIRRORED_BUILD_TARGETS-target-cmake tests.
#
# See LICENCE.md for Copyright information

if (POLICY CMP0025)

    cmake_policy (SET CMP0025 NEW)

endif (POLICY CMP0025)
project (MirroredBuildTargetCMakeTests)
cmake_minimum_required (VERSION 2.8)

# We assume that it is one-above us
set (MIRRORED_BUILD_TARGETS_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (MIRRORED_BUILD_TARGETS_CMAKE_DIRECTORY
                        ${MIRRORED_BUILD_TARGETS_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)
set (CMAKE_UNIT_DIRECTORY
     ${MIRRORED_BUILD_TARGETS_CMAKE_DIRECTORY}/cmake-unit)

set (MIRRORED_BUILD_TARGETS_INITIAL_CACHE_CONTENTS
     "set (CMAKE_C_COMPILER\n"
     "     ${CMAKE_C_COMPILER}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (CMAKE_CXX_COMPILER\n"
     "     ${CMAKE_CXX_COMPILER}\n"
     "     CACHE STRING \"\" FORCE)\n")

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${MIRRORED_BUILD_TARGETS_CMAKE_DIRECTORY}
     ${CMAKE_MODULE_PATH})

foreach (PATH ${CMAKE_MODULE_PATH})
     set (MIRRORED_BUILD_TARGETS_INITIAL_CACHE_CONTENTS
          "${MIRRORED_BUILD_TARGETS_INITIAL_CACHE_CONTENTS}\n"
          "set (CMAKE_MODULE_PATH ${PATH} \${CMAKE_MODULE_PATH}\n"
          "     CACHE STRING \"\" FORCE)\n")
endforeach ()

include (CMakeUnitRunner)

bootstrap_cmake_unit (INITIAL_CACHE_CONTENTS
                      MIRRORED_BUILD_TARGETS_INITIAL_CACHE_CONTENTS)

add_cmake_test (MirroredBuildTargetsInheritSources)
add_cmake_test (CreateMirroredExecutableWithSuffix)
add_cmake_test (CreateMirroredStaticLibraryWithSuffix)
add_cmake_test (CreateMirroredSharedLibraryWithSuffix)

add_cmake_build_test (FailToCreateMirroredUtilityTarget
                      FailToCreateMirroredUtilityTargetVerify
                      ALLOW_CONFIGURE_FAIL)

add_cmake_build_test (MirroredBuildTargetsAdditionalCompileFlags
                      MirroredBuildTargetsAdditionalCompileFlagsVerify)
add_cmake_build_test (MirroredBuildTargetsAdditionalLinkFlags
                      MirroredBuildTargetsAdditionalLinkFlagsVerify)
add_cmake_build_test (MirroredBuildTargetsDependOnMirroredDependencies
                      MirroredBuildTargetsDependOnMirroredDependenciesVerify)
add_cmake_build_test (MirroredBuildTargetsInheritDirectoryDefines
                      MirroredBuildTargetsInheritDirectoryDefinesVerify)
add_cmake_build_test (MirroredBuildTargetsInheritDirectoryIncludes
                      MirroredBuildTargetsInheritDirectoryIncludesVerify)
add_cmake_build_test (MirroredBuildTargetsInheritTargetLinkLibraries
                      MirroredBuildTargetsInheritTargetLinkLibrariesVerify)
add_cmake_build_test (MirroredBuildTargetsInheritDependencies
                      MirroredBuildTargetsInheritDependenciesVerify)
