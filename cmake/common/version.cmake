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

# Set up generation of version.c which embeds the version string. It is
# performed in a cmake -P script so that it can be run on every build,
# not just at configure time, so that the version number is always accurate.
set(PLUGIN_VERSION_SOURCE "${CMAKE_BINARY_DIR}/generated/version.c")
set(_plugin_version_script "${CMAKE_SOURCE_DIR}/cmake/common/update-version.cmake")
set(
  _plugin_version_args
  "-DPLUGIN_VERSION_FULL=${PLUGIN_VERSION_FULL}"
  "-DSOURCE_DIR=${CMAKE_SOURCE_DIR}"
  "-DBINARY_DIR=${CMAKE_BINARY_DIR}"
)
# Run it once at configure time: some generators (e.g. Xcode) are fussier about a
# target source that doesn't exist yet when the project is first generated.
# COMMAND_ERROR_IS_FATAL is required here -- execute_process() otherwise swallows a
# non-zero exit from update-version.cmake and configure reports success anyway.
execute_process(
  COMMAND ${CMAKE_COMMAND} ${_plugin_version_args} -P "${_plugin_version_script}"
  COMMAND_ERROR_IS_FATAL ANY
)
# Re-run on every build so the compiled-in version stays accurate
add_custom_target(
  plugin_version
  ALL
  COMMAND ${CMAKE_COMMAND} ${_plugin_version_args} -P "${_plugin_version_script}"
  BYPRODUCTS ${PLUGIN_VERSION_SOURCE}
  COMMENT "Updating plugin version string"
  VERBATIM
)
unset(_plugin_version_args)
unset(_plugin_version_script)
set_source_files_properties(${PLUGIN_VERSION_SOURCE} PROPERTIES GENERATED TRUE)
