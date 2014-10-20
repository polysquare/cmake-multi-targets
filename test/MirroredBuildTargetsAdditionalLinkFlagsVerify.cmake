# /test/MirroredBuildTargetsAdditionalLinkFlagsVerify.cmake
#
# Checks that when we mirror an executable, we can give it custom link flags
# and those link flags are actually passed when compiling one of its sources.
# (eg, -L${CMAKE_CURRENT_BINARY_DIR})
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/BUILD.output)

set (LINK_FLAGS_REGEX "^.*-L${CMAKE_CURRENT_BINARY_DIR}.*executable_suffix.*$")
assert_file_has_line_matching (${BUILD_OUTPUT} "${LINK_FLAGS_REGEX}")
