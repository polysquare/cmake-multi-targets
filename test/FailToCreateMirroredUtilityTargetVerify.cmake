# /test/FailToCreateMirroredUtilityTargetVerify.cmake
#
# Checks that we failed with an error message about how mirroring
# targets of this type is not possible.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (CONFIGURE_ERROR ${CMAKE_CURRENT_BINARY_DIR}/CONFIGURE.error)

assert_file_has_line_matching (${CONFIGURE_ERROR}
                               "^.*Mirroring targets of.*$")
