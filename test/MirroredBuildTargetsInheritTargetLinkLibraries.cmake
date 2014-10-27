# /test/MirrorBuildTargetsInheritTargetLinkLibraries.cmake
# Verifies the generated target inherits all external target link
# libraries
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

set (LIBRARY ext_library)
file (WRITE ${LIBRARY_SOURCE_FILE} ${LIBRARY_SOURCE_FILE_CONTENTS})

# psq_create_mirrored_build_target is not called on LIBRARY, so
# it will be linked as a normal non-mirrored target instead
add_library (${LIBRARY} SHARED ${LIBRARY_SOURCE_FILE})

# Set up main source file for mirrored build
set (SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS
     "extern int function ()\;\n"
     "int main ()\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})

set (EXECUTABLE executable)

add_executable (${EXECUTABLE} ${SOURCE_FILE})
target_link_libraries (${EXECUTABLE} ${LIBRARY})

set (SUFFIX suffix)
psq_create_mirrored_build_target (${EXECUTABLE} ${SUFFIX})
