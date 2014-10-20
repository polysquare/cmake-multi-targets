# /test/MirroredBuildTargetsAdditionalLinkFlags.cmake
#
# Checks that when we mirror an executable, we can give it custom link flags.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ParallelBuildTargetUtils)

set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
file (WRITE ${SOURCE_FILE}
      "int main ()\n"
      "{\n"
      "    return 0;\n"
      "}\n")
set (TARGET executable)
set (SUFFIX suffix)

add_executable (${TARGET} ${SOURCE_FILE})
psq_setup_mirrored_build_target (${TARGET} ${SUFFIX}
                                 LINK_FLAGS "-L${CMAKE_CURRENT_BINARY_DIR}")

assert_has_property_with_value (TARGET ${TARGET}_${SUFFIX}
                                LINK_FLAGS STRING EQUAL
                                "-L${CMAKE_CURRENT_BINARY_DIR}")
