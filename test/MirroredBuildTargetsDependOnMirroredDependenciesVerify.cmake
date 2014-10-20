# /test/UnityBuildTargetsDependOnUnityDependenciesVerify.cmake
# Verifies the generated _unity target inherits all non-library
# dependencies - eg, that our custom command is run when running the
# unity-build target.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

# Check to see if library_unity was generated and linked
assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*executable_suffix.*library_suffix.*$")
