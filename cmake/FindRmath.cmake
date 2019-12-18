## FindRmath.cmake
#
# Finds the HTSlib library
#
# This will define the following variables
#
#    HTSlib_FOUND
#    HTSlib_INCLUDE_DIRS
#
# and the following imported targets
#
#     HTSlib::HTSlib
#
# Author Nicholas Knoblauch (borrowing heavily from): find libxml2

find_package(PkgConfig)
find_package(PkgConfig QUIET)
PKG_CHECK_MODULES(PC_RMATH libRmath)
set(RMATH_DEFINITIONS ${PC_RMATH_CFLAGS_OTHER})

find_path(RMATH_INCLUDE_DIR NAMES Rmath.h
   HINTS
   ${PC_RMATH_INCLUDEDIR}
   ${PC_RMATH_INCLUDE_DIRS}
   )

 # find_path(R2_INCLUDE_DIR NAMES Boolean.h
 #   HINTS
 #   ${PC_RMATH_INCLUDEDIR}
 #   ${PC_RMATH_INCLUDE_DIRS}
 #   ${PC_RMATH_INCLUDE_DIRS}
 #   PATH_SUFFIXES R)
 find_path(R2_INCLUDE_DIR NAMES Rmath.h
   HINTS
   "${PC_RMATH_INCLUDEDIR}/R"
   "${PC_RMATH_INCLUDE_DIRS}/R"
   "${PC_RMATH_INCLUDE_DIRS}/R")


 if(DEFINED R2_INCLUDE_DIR)
   message( STATUS "R2_FOUND: ${R2_INCLUDE_DIR}" ) # no output for this
   set(RMATH_INCLUDE_DIR "${RMATH_INCLUDE_DIR}" "${R2_INCLUDE_DIR}")
   message( STATUS "RMATH_INCLUDE_DIR: ${RMATH_INCLUDE_DIR}" ) # no output for this
 endif()
# CMake 3.9 and below used 'RMATH_LIBRARIES' as the name of
# the cache entry storing the find_library result.  Use the
# value if it was set by the project or user.
if(DEFINED RMATH_LIBRARIES AND NOT DEFINED RMATH_LIBRARY)
  set(RMATH_LIBRARY ${RMATH_LIBRARIES})
endif()

find_library(RMATH_LIBRARY NAMES Rmath
   HINTS
   ${PC_RMATH_LIBDIR}
   ${PC_RMATH_LIBRARY_DIRS}
   )

 message( STATUS "RMATH_FOUND: ${PC_RMATH_FOUND}" ) # no output for this
 message( STATUS "RMATH_LIBRARY: ${RMATH_LIBRARY}" ) # no output for this

if(PC_RMATH_VERSION)
  message( STATUS "RMATH_VERSION: ${PC_RMATH_VERSION}" ) # no output for this
    set(RMATH_VERSION_STRING ${PC_RMATH_VERSION})
elseif(RMATH_INCLUDE_DIR AND EXISTS "${RMATH_INCLUDE_DIR}/Rmath.h")
    file(STRINGS "${RMATH_INCLUDE_DIR}/Rmath.h" rmath_version_str
         REGEX "^#define[\t ]+R_VERSION_STRING[\t ]+\".*\"")

    string(REGEX REPLACE "^#define[\t ]+R_VERSION_STRING[\t ]+\"([^\"]*)\".*" "\\1"
           RMATH_VERSION_STRING "${rmath_version_str}")
    unset(rmath_version_str)
endif()

set(RMATH_INCLUDE_DIRS ${RMATH_INCLUDE_DIR} ${PC_RMATH_INCLUDE_DIRS})
set(RMATH_LIBRARIES ${RMATH_LIBRARY})


FIND_PACKAGE_HANDLE_STANDARD_ARGS(Rmath
                                  REQUIRED_VARS RMATH_LIBRARY RMATH_INCLUDE_DIR
                                  VERSION_VAR RMATH_VERSION_STRING)

mark_as_advanced(RMATH_INCLUDE_DIR RMATH_LIBRARY)

if(Rmath_FOUND AND NOT TARGET Rmath::Rmath)
  add_library(Rmath::Rmath UNKNOWN IMPORTED)
  message( STATUS "Setting property RMATH_INCLUDE_DIRS: ${RMATH_INCLUDE_DIRS}" ) # no output for this
  set_target_properties(Rmath::Rmath PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${RMATH_INCLUDE_DIRS}")
  message( STATUS "Setting property RMATH_LIBRARY: ${RMATH_LIBRARY}" ) # no output for this
  set_property(TARGET Rmath::Rmath APPEND PROPERTY IMPORTED_LOCATION "${RMATH_LIBRARY}")
endif()
