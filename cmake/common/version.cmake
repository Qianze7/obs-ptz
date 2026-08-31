set(PLUGIN_VERSION_FULL "${_version}")

# Generate a version number from the git tag that can be embedded in the binary
find_package(Git QUIET)
if(GIT_FOUND)
  execute_process(
    COMMAND git describe --dirty
    OUTPUT_VARIABLE _git_describe
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    RESULT_VARIABLE _git_describe_result
  )
  if(_git_describe_result EQUAL 0 AND _git_describe)
    set(PLUGIN_VERSION_FULL "${_git_describe}")
    if(_git_describe MATCHES "^v?([0-9]+)\\.([0-9]+)\\.([0-9]+)(-.+)?$")
      set(_version "${_git_describe}")
    else()
      message(
        WARNING
        "git version '${_git_describe}' isn't in 'x.y.z'; "
        "falling back to buildspec version '${_version}'"
      )
    endif()
  endif()
endif()

# _version must be in the form MAJOR.MINOR.PATCH, optionally followed by a
# git-tag-shaped pre-release suffix (e.g. "0.19.0" or "0.19.0-rc1")
if(NOT _version MATCHES "^v?([0-9]+)\\.([0-9]+)\\.([0-9]+)(-.+)?$")
  message(
    FATAL_ERROR
    "'version' must be in the format MAJOR.MINOR.PATCH or "
    "MAJOR.MINOR.PATCH-SUFFIX (e.g. 0.19.0 or 0.19.0-rc1), got '${_version}'"
  )
endif()
set(PLUGIN_VERSION_MAJOR ${CMAKE_MATCH_1})
set(PLUGIN_VERSION_MINOR ${CMAKE_MATCH_2})
set(PLUGIN_VERSION_PATCH ${CMAKE_MATCH_3})
# Numeric-only version: required by CMake's target VERSION/SOVERSION properties and
# Xcode's Marketing Version, neither of which accept a git-describe-style suffix.
set(PLUGIN_VERSION "${PLUGIN_VERSION_MAJOR}.${PLUGIN_VERSION_MINOR}.${PLUGIN_VERSION_PATCH}")

message(STATUS "PTZ Plugin version ${_version}")
