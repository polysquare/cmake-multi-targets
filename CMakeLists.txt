# /CMakeLists.txt
#
# Main entry point for cmake-multi-targets tests.
#
# See /LICENCE.md for Copyright information

include ("${CMAKE_CURRENT_LIST_DIR}/conanbuildinfo.cmake")
set (CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_LIST_DIR}"
     ${CONAN_CMAKE_MODULE_PATH}  # NOLINT:correctness/quotes
     ${CMAKE_MODULE_PATH})  # NOLINT:correctness/quotes

cmake_minimum_required (VERSION 2.8)

include ("cmake/cmake-module-common/Common")
include (ParallelBuildTargetUtils)

# Checks that when we mirror an executable, a new executable called
# executable_suffix is created.
function (psq_test_create_mirrored_executable_with_suffix)

    function (psq_configure)

        set (TARGET executable)
        set (SUFFIX suffix)
        cmake_unit_create_simple_executable (${TARGET})
        psq_setup_mirrored_build_target (${TARGET} ${SUFFIX})
        cmake_unit_assert_that (${TARGET}_${SUFFIX} target_exists)
        cmake_unit_assert_that (${TARGET}_${SUFFIX} item_has_property_with_value
                                TARGET TYPE STRING EQUAL "EXECUTABLE")

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Checks that when we mirror a shared library, a new library called
# library_suffix is created.
function (psq_test_create_mirrored_shared_library_with_suffix)

    function (psq_configure)

        set (TARGET library)
        set (SUFFIX suffix)
        cmake_unit_create_simple_library (${TARGET} SHARED)
        psq_setup_mirrored_build_target (${TARGET} ${SUFFIX})
        cmake_unit_assert_that (${TARGET}_${SUFFIX} target_exists)
        cmake_unit_assert_that (${TARGET}_${SUFFIX} item_has_property_with_value
                                TARGET TYPE STRING EQUAL "SHARED_LIBRARY")

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Checks that when we mirror a static library, a new library called
# library_suffix is created.
function (psq_test_create_mirrored_static_library_with_suffix)

    function (psq_configure)

        set (TARGET library)
        set (SUFFIX suffix)
        cmake_unit_create_simple_library (${TARGET} STATIC)
        psq_setup_mirrored_build_target (${TARGET} ${SUFFIX})
        cmake_unit_assert_that (${TARGET}_${SUFFIX} target_exists)
        cmake_unit_assert_that (${TARGET}_${SUFFIX} item_has_property_with_value
                                TARGET TYPE STRING EQUAL "STATIC_LIBRARY")

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Checks that when we mirror a utility target, we fail with an error message
function (psq_test_fail_to_create_mirrored_utility_target)

    function (psq_configure)

        set (TARGET utility)
        set (SUFFIX suffix)
        add_custom_target (${TARGET})
        psq_setup_mirrored_build_target (${TARGET} ${SUFFIX})

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_CONFIGURE ERROR CONFIGURE_ERROR)
        cmake_unit_assert_that (${CONFIGURE_ERROR}
                                file_contents any_line matches_regex
                                "^.*Mirroring targets of.*$")

    endfunction ()

    cmake_unit_configure_config_only_test (CONFIGURE COMMAND psq_configure
                                           VERIFY COMMAND psq_verify
                                           INVOKE_CONFIGURE OPTIONS ALLOW_FAIL)
endfunction ()

# Checks that when we mirror an executable, we can give it custom compile flags.
function (psq_test_mirrored_build_targets_additional_compile_flags)

    function (psq_configure)

        set (TARGET executable)
        set (SUFFIX suffix)
        cmake_unit_create_simple_executable (${TARGET})
        psq_setup_mirrored_build_target (${TARGET} ${SUFFIX}
                                         COMPILE_FLAGS "-DCUSTOM_FLAG")
        cmake_unit_assert_that (${TARGET}_${SUFFIX} item_has_property_with_value
                                TARGET COMPILE_FLAGS
                                STRING EQUAL "-DCUSTOM_FLAG")

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents any_line matches_regex
                                "^.*CUSTOM_FLAG.*executable.cpp.*$")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)
endfunction ()

# Checks that when we mirror an executable, we can give it custom link flags.
function (psq_test_mirrored_build_targets_additional_link_flags)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (psq_configure)

        set (TARGET executable)
        set (SUFFIX suffix)
        cmake_unit_create_simple_executable (${TARGET})
        psq_setup_mirrored_build_target (${TARGET} ${SUFFIX}
                                         LINK_FLAGS "-L${BINARY_DIR}")
        cmake_unit_assert_that (${TARGET}_${SUFFIX} item_has_property_with_value
                                TARGET LINK_FLAGS
                                STRING EQUAL "-L${BINARY_DIR}")

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (LINK_FLAGS_REGEX "^.*-L${BINARY_DIR}.*executable_suffix.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents any_line matches_regex
                                "${LINK_FLAGS_REGEX}")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)
endfunction ()

# Verifies the generated mirrored target depends on the mirrored version
# of other targets where those exist.
function (psq_test_mirrored_build_targets_depend_on_mirrored_dependencies)

    function (psq_configure)

        set (SUFFIX suffix)
        set (LIBRARY library)
        cmake_unit_create_simple_library (${LIBRARY} SHARED)
        psq_create_mirrored_build_target (${LIBRARY} ${SUFFIX})

        set (EXECUTABLE executable)
        cmake_unit_create_simple_executable ("${EXECUTABLE}")
        target_link_libraries ("${EXECUTABLE}" ${LIBRARY})
        psq_create_mirrored_build_target ("${EXECUTABLE}" ${SUFFIX})

        set (EXECUTABLE_SUFFIX "${EXECUTABLE}_${SUFFIX}")
        set (LIBRARY_SUFFIX ${LIBRARY}_${SUFFIX})

        get_property (LIBRARIES TARGET ${EXECUTABLE_SUFFIX}
                      PROPERTY LINK_LIBRARIES)
        message ("LIBRARIES: ${LIBRARIES}")
        cmake_unit_assert_that (${EXECUTABLE_SUFFIX} is_linked_to
                                ${LIBRARY_SUFFIX})

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents any_line matches_regex
                                "^.*executable_suffix.*library_suffix.*$")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)
endfunction ()

# Verifies the generated mirrored target inherits all non-library
# dependencies
function (psq_test_mirrored_build_targets_inherit_dependencies)

    set (EXECUTABLE executable)
    set (SUFFIX suffix)
    set (CUSTOM_TARGET_NAME custom_target)
    set (COMMAND_OUTPUT custom_command_output)

    cmake_unit_get_dirs (SOURCE_DIR BINARY_DIR)

    function (psq_configure)

        add_custom_command (OUTPUT "${COMMAND_OUTPUT}"
                            COMMAND "${CMAKE_COMMAND}"
                                    -E
                                    touch
                                    "${BINARY_DIR}/${COMMAND_OUTPUT}")
        add_custom_target (${CUSTOM_TARGET_NAME}
                           DEPENDS "${COMMAND_OUTPUT}")

        cmake_unit_create_simple_executable ("${EXECUTABLE}")
        add_dependencies ("${EXECUTABLE}" ${CUSTOM_TARGET_NAME})
        psq_create_mirrored_build_target ("${EXECUTABLE}" ${SUFFIX}
                                          DEPENDS ${CUSTOM_TARGET_NAME})

    endfunction ()

    function (psq_verify)

        cmake_unit_assert_that ("${BINARY_DIR}/${COMMAND_OUTPUT}"
                                exists_as_file)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify
                               INVOKE_BUILD OPTIONS
                                            TARGET
                                            "${EXECUTABLE}_${SUFFIX}")
endfunction ()

# Checks that when we mirror a build target, it has exactly the same
# sources as the original.
function (psq_test_mirrored_build_targets_inherit_sources)

    function (psq_configure)

        set (SOURCE_FILE "${CMAKE_CURRENT_BINARY_DIR}/Source.cpp")
        file (WRITE "${SOURCE_FILE}" "")
        set (TARGET executable)
        set (SUFFIX suffix)
        add_executable (${TARGET} "${SOURCE_FILE}")
        psq_setup_mirrored_build_target (${TARGET} ${SUFFIX})
        cmake_unit_assert_that (${TARGET} item_has_property_with_value
                                TARGET SOURCES STRING EQUAL "${SOURCE_FILE}")

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND psq_configure)

endfunction ()

# Verifies the generated target inherits all external target link
# libraries
function (psq_test_mirrored_build_targets_inherit_target_link_libraries)

    function (psq_configure)

        set (LIBRARY ext_library)
        cmake_unit_create_simple_library (${LIBRARY} SHARED)

        set (EXECUTABLE executable)
        cmake_unit_create_simple_executable ("${EXECUTABLE}")
        target_link_libraries ("${EXECUTABLE}" ${LIBRARY})

        set (SUFFIX suffix)
        psq_create_mirrored_build_target ("${EXECUTABLE}" ${SUFFIX})

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents any_line matches_regex
                                "^.*executable_suffix.*ext_library.*$")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND psq_configure
                               VERIFY COMMAND psq_verify)
endfunction ()

set (CMAKE_FILES
     "${CMAKE_CURRENT_LIST_DIR}/ParallelBuildTargetUtils.cmake"
     "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt")
set (MARKDOWN_FILES
     "${CMAKE_CURRENT_LIST_DIR}/LICENSE.md"
     "${CMAKE_CURRENT_LIST_DIR}/README.md")

cmake_module_add_common_targets (NAMESPACE "psq"
                                 CMAKE_FILES ${CMAKE_FILES}
                                 DOCUMENTATION_FILES ${MARKDOWN_FILES})
