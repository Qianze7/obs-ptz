# Re-resolves the plugin's full build version from `git describe` and regenerates
# generated/version.c from src/version.c.in. Run as a custom target with no declared
# inputs (see CMakeLists.txt), so it re-executes on every build -- not just at
# configure time -- keeping the compiled-in version accurate for an incremental
# `cmake --build` after a new commit or tag, without needing to reconfigure.
#
# Mirrors the git-describe resolution in version.cmake, which only runs once, at
# configure time, to additionally set the numeric PLUGIN_VERSION used by
# project()/target SOVERSION properties -- those can't be refreshed here, and stay
# fixed at whatever they were at the last configure.

if(NOT DEFINED PLUGIN_VERSION_FULL OR NOT DEFINED SOURCE_DIR OR NOT DEFINED BINARY_DIR)
  message(FATAL_ERROR "update-version.cmake requires PLUGIN_VERSION_FULL, SOURCE_DIR, BINARY_DIR")
endif()

find_package(Git QUIET)
if(GIT_FOUND)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --dirty
    WORKING_DIRECTORY "${SOURCE_DIR}"
    OUTPUT_VARIABLE _git_describe
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    RESULT_VARIABLE _git_describe_result
  )
  if(_git_describe_result EQUAL 0 AND _git_describe)
    set(PLUGIN_VERSION_FULL "${_git_describe}")
  endif()
endif()

configure_file("${SOURCE_DIR}/src/version.c.in" "${BINARY_DIR}/generated/version.c")

message(STATUS "PTZ Plugin version ${PLUGIN_VERSION_FULL}")
