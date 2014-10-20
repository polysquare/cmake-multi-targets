# /test/CreateMirroredExecutableWithSuffix.cmake
#
# Checks that when we mirror an executable, a new executable called
# executable_suffix is created.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ParallelBuildTargetUtils)

set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
file (WRITE ${SOURCE_FILE} "")
set (TARGET executable)
set (SUFFIX suffix)

add_executable (${TARGET} ${SOURCE_FILE})
psq_setup_mirrored_build_target (${TARGET} ${SUFFIX})

assert_target_exists (${TARGET}_${SUFFIX})
assert_has_property_with_value (TARGET ${TARGET}_${SUFFIX}
                                TYPE STRING EQUAL "EXECUTABLE")
