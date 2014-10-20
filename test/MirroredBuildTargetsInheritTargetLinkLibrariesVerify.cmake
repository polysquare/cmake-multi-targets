# /test/UnityBuildTargetsInheritTargetLinkLibrariesVerify.cmake
# Verifies the generated mirrored target inherits all non-library
# target link libraries, even if external.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

# Check to see if ext_library was built and linked
assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*executable_suffix.*ext_library.*$")
