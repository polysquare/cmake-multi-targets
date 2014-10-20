# /test/FailToCreateMirroredUtilityTarget.cmake
#
# Checks that when we mirror a utility target, we fail with an error message
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (ParallelBuildTargetUtils)

set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
file (WRITE ${SOURCE_FILE} "")
set (TARGET utility)
set (SUFFIX suffix)

add_custom_target (${TARGET})
psq_setup_mirrored_build_target (${TARGET} ${SUFFIX})
