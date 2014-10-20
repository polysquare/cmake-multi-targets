# /test/MirroredBuildTargetsDependOnSUFFIXDependencies.cmake
# Verifies the generated mirrored target depends on the mirrored version
# of other targets where those exist.
#
# See LICENCE.md for Copyright information.

include (ParallelBuildTargetUtils)
include (CMakeUnit)

set (COTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES 1 CACHE BOOL "" FORCE)

set (LIBRARY_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/LibrarySource.c)
set (LIBRARY_SOURCE_FILE_CONTENTS
     "int function ()\n"
     "{\n"
     "    return 1\;\n"
     "}\n")
file (WRITE ${LIBRARY_SOURCE_FILE} ${LIBRARY_SOURCE_FILE_CONTENTS})

set (SUFFIX suffix)

set (LIBRARY library)

include_directories (${CMAKE_CURRENT_SOURCE_DIR})

add_library (${LIBRARY} SHARED ${LIBRARY_SOURCE_FILE})
psq_create_mirrored_build_target (${LIBRARY} ${SUFFIX})

# Executable which links to library
set (EXECUTABLE_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (EXECUTABLE_SOURCE_FILE_CONTENTS
     "int main ()\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
file (WRITE ${EXECUTABLE_SOURCE_FILE} ${EXECUTABLE_SOURCE_FILE_CONTENTS})

set (EXECUTABLE executable)

add_executable (${EXECUTABLE} ${EXECUTABLE_SOURCE_FILE})
target_link_libraries (${EXECUTABLE} ${LIBRARY})
psq_create_mirrored_build_target (${EXECUTABLE} ${SUFFIX})

set (EXECUTABLE_SUFFIX ${EXECUTABLE}_${SUFFIX})
set (LIBRARY_SUFFIX ${LIBRARY}_${SUFFIX})

get_property (LIBRARIES TARGET ${EXECUTABLE_SUFFIX}
              PROPERTY LINK_LIBRARIES)

message ("LIBRARIES: ${LIBRARIES}")

assert_target_is_linked_to (${EXECUTABLE_SUFFIX} ${LIBRARY_SUFFIX})
