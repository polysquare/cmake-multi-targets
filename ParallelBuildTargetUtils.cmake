# /ParallelBuildTargetUtils.cmake
#
# Utility functions for making "parallel" builds of targets with different
# compiler options.
#
# psq_setup_mirrored_build_target takes a pre-existing TARGET and creates
# a new "mirrored" build target with the suffix SUFFIX and
# with CXX_FLAGS and C_FLAGS appended to the
# already-set CMAKE_CXX_FLAGS and CMAKE_C_FLAGS. It will not set up any of
# its dependencies or link libraries. EXCLUDE_FROM_ALL will be set on the
# target.
#
# psq_wire_mirrored_build_target_dependencies takes a pre-existing TARGET
# and will, for a SUFFIX, find the created mirrored build target using that
# suffix and wire its dependencies up.
#
# psq_create_mirrored_build_target will perform both of these steps together.
#
# See LICENCE.md for Copyright information

set (CMAKE_MODULE_PATH
     ${CMAKE_MODULE_PATH}
     ${CMAKE_CURRENT_LIST_DIR}/tooling-cmake-util)

include (CMakeParseArguments)
include (PolysquareToolingUtil)

# psq_setup_mirrored_build_target:
#
# Sets up "mirrored" build target for TARGET, using its sources. Definitions
# and include directories are currently inherited from the directory and
# target-level include directories and definitions on TARGET.
#
# This does not set up a mirrored target's link libraries or dependencies.
#
# TARGET: Target to mirror
# SUFFIX: Suffix on this mirrored target
# [Optional] COMPILE_FLAGS: Additional compiler flags for this mirrored target
# [Optional] LINK_FLAGS: Additional linker flags for this mirrored target
function (psq_setup_mirrored_build_target TARGET SUFFIX)

    set (SETUP_MIRRORED_BUILD_TARGET_MULTIVAR_ARGS COMPILE_FLAGS LINK_FLAGS)

    cmake_parse_arguments (SETUP_MIRRORED_BUILD_TARGET
                           ""
                           ""
                           "${SETUP_MIRRORED_BUILD_TARGET_MULTIVAR_ARGS}"
                           ${ARGN})

    
    set (MIRRORED_TARGET ${TARGET}_${SUFFIX})

    get_target_property (TARGET_TYPE ${TARGET} TYPE)
    get_target_property (TARGET_SOURCES ${TARGET} SOURCES)

    string (STRIP "${TARGET_TYPE}" TARGET_TYPE)

    if (TARGET_TYPE MATCHES "^.*_LIBRARY")

        string (FIND "${TARGET_TYPE}" "_" UNDERSCORE_POS)
        string (SUBSTRING "${TARGET_TYPE}" 0 ${UNDERSCORE_POS} LIBRARY_TYPE)

        add_library (${MIRRORED_TARGET} ${LIBRARY_TYPE}
                     ${TARGET_SOURCES})

    elseif ("${TARGET_TYPE}" STREQUAL "EXECUTABLE")

        add_executable (${MIRRORED_TARGET}
                        ${TARGET_SOURCES})

    else (TARGET_TYPE MATCHES "^.*_LIBRARY")

        message (FATAL_ERROR "Mirroring targets of type: ${TARGET_TYPE} to "
                             "generate ${MIRRORED_TARGET} is not possible.\n"
                             "The only supported types are STATIC_LIBRARY, "
                             "SHARED_LIBRARY and EXECUTABLE")

    endif (TARGET_TYPE MATCHES "^.*_LIBRARY")

    set_property (TARGET ${MIRRORED_TARGET}
                  PROPERTY COMPILE_FLAGS
                  ${SETUP_MIRRORED_BUILD_TARGET_COMPILE_FLAGS}
                  APPEND)
    set_property (TARGET ${MIRRORED_TARGET}
                  PROPERTY LINK_FLAGS
                  ${SETUP_MIRRORED_BUILD_TARGET_LINK_FLAGS}
                  APPEND)

endfunction (psq_setup_mirrored_build_target)

# psq_wire_mirrored_build_target_dependencies
#
# For a TARGET, find the corresponding mirrored build target
# TARGET_SUFFIX and wire up its dependencies as follows:
# 1. For each of the original target's LINK_LIBRARIES, find any libraries
#    that are built in this project as targets, determine if a corresponding
#    mirrored version of that target exists with the SUFFIX specified and then
#    link this mirrored target to that one.
# 2. For all other libraries, link the mirrored target to that library.
# 3. Add dependencies as specified in DEPENDS
#
# [Optional] DEPENDS: Additional dependencies
function (psq_wire_mirrored_build_target_dependencies TARGET SUFFIX)

    set (MIRRORED_TARGET ${TARGET}_${SUFFIX})

    # Early fail, no ${TARGET}_${SUFFIX}
    if (NOT TARGET ${MIRRORED_TARGET})

        message (FATAL_ERROR "A target named ${MIRRORED_TARGET} must exist "
                             "to use "
                             "psq_wire_mirrored_build_target_dependencies")

    endif (NOT TARGET ${MIRRORED_TARGET})

    set (WIRE_MIRRORED_MULTIVAR_ARGS DEPENDS)

    cmake_parse_arguments (WIRE_MIRRORED
                           ""
                           ""
                           "${WIRE_MIRRORED_MULTIVAR_ARGS}"
                           ${ARGN})

    if (WIRE_MIRRORED_DEPENDS)

        add_dependencies (${MIRRORED_TARGET}
                          ${WIRE_MIRRORED_DEPENDS})

    endif (WIRE_MIRRORED_DEPENDS)

    get_property (TARGET_LIBRARIES
                  TARGET ${TARGET}
                  PROPERTY LINK_LIBRARIES)

    if (TARGET_LIBRARIES)

        foreach (LIBRARY ${TARGET_LIBRARIES})

            # If LIBRARY is a target then it might also have a
            # corresponding mirrored target, check for that too
            if (TARGET ${LIBRARY})

                set (LIBRARY_MIRRORED_TARGET ${LIBRARY}_${SUFFIX})

                if (TARGET ${LIBRARY_MIRRORED_TARGET})

                    target_link_libraries (${MIRRORED_TARGET}
                                           ${LIBRARY_MIRRORED_TARGET})

                else (TARGET ${LIBRARY_MIRRORED_TARGET})

                    target_link_libraries (${MIRRORED_TARGET}
                                           ${LIBRARY})

                endif (TARGET ${LIBRARY_MIRRORED_TARGET})

            else (TARGET ${LIBRARY})

                target_link_libraries (${MIRRORED_TARGET}
                                       ${LIBRARY})

            endif (TARGET ${LIBRARY})

        endforeach ()

    endif (TARGET_LIBRARIES)

endfunction (psq_wire_mirrored_build_target_dependencies)

# psq_create_mirrored_build_target:
#
# Creates a mirrored build target for TARGET named TARGET_SUFFIX. The mirrored
# build target will use the specified COMPILE_FLAGS and LINK_FLAGS and depend
# on the orignal target's library dependencies (or mirrored library deps) with
# the same SUFFIX. The dependencies in DEPENDS will be added to the mirrored
# target
#
# TARGET: Target to mirror
# SUFFIX: Suffix to add to mirrored target
# COMPILE_FLAGS: Additional compile flags for mirrored target
# LINK_FLAGS: Additional link flags for mirrored target
# DEPENDS: Other targets for mirrored target to depend on
function (psq_create_mirrored_build_target TARGET SUFFIX)

    set (CREATE_MIRRORED_BUILD_TARGET_MULTIVAR_ARGS
         COMPILE_FLAGS LINK_FLAGS DEPENDS)

    cmake_parse_arguments (CREATE_MIRRORED
                           ""
                           ""
                           "${CREATE_MIRRORED_BUILD_TARGET_MULTIVAR_ARGS}"
                           ${ARGN})

    psq_forward_options (CREATE_MIRRORED SETUP_TARGET_FORWARD_OPTIONS
                         MULTIVAR_ARGS COMPILE_FLAGS LINK_FLAGS)
    psq_setup_mirrored_build_target (${TARGET} ${SUFFIX}
                                     ${SETUP_TARGET_FORWARD_OPTIONS})
    psq_forward_options (CREATE_MIRRORED WIRE_TARGET_FORWARD_OPTIONS
                         MULTIVAR_ARGS DEPENDS)
    psq_wire_mirrored_build_target_dependencies (${TARGET} ${SUFFIX}
                                                 ${WIRE_TARGET_FORWARD_OPTIONS})

endfunction ()
 
