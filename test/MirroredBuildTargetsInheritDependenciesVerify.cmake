# /test/MirroredBuildTargetsInheritDependenciesVerify.cmake
# Verifies the generated mirrored target inherits all non-library
# dependencies - eg, that our custom command is run when running the
# mirrored target.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
set (CUSTOM_COMMAND_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/custom_command_output)

assert_file_exists (${CUSTOM_COMMAND_OUTPUT})
