# /test/MirroredBuildTargetsAdditionalCompileFlagsVerify.cmake
#
# Checks that when we mirror an executable, we can give it custom compile flags
# and those compile flags are actually passed when compiling one of its sources.
# (eg, -DCUSTOM_FLAG)
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (BUILD_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*-DCUSTOM_FLAG.*Source.cpp.*$")
