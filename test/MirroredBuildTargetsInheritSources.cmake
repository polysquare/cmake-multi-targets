# /test/MirroredBuildTargetsInheritSources.cmake
#
# Checks that when we mirror a build target, it has exactly the same
# sources as the original.

include (CMakeUnit)
include (ParallelBuildTargetUtils)

set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
file (WRITE ${SOURCE_FILE} "")
set (TARGET executable)
set (SUFFIX suffix)

add_executable (${TARGET} ${SOURCE_FILE})
psq_setup_mirrored_build_target (${TARGET} ${SUFFIX})

assert_has_property_with_value (TARGET ${TARGET}
                                SOURCES STRING EQUAL ${SOURCE_FILE})
