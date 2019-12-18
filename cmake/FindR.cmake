## FindHTSlib.cmake
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
PKG_CHECK_MODULES(PC_R libRmath)
set(R_DEFINITIONS ${PC_R_CFLAGS_OTHER})

find_path(R_INCLUDE_DIR NAMES Rmath.h
   HINTS
   ${PC_R_INCLUDEDIR}
   ${PC_R_INCLUDE_DIRS}
   PATH_SUFFIXES R
   )

# CMake 3.9 and below used 'R_LIBRARIES' as the name of
# the cache entry storing the find_library result.  Use the
# value if it was set by the project or user.
if(DEFINED R_LIBRARIES AND NOT DEFINED R_LIBRARY)
  set(R_LIBRARY ${R_LIBRARIES})
endif()

find_library(R_LIBRARY NAMES R
   HINTS
   ${PC_R_LIBDIR}
   ${PC_R_LIBRARY_DIRS}
   )

message( STATUS "R_FOUND: ${PC_R_FOUND}" ) # no output for this

if(PC_R_VERSION)
  message( STATUS "R_VERSION: ${PC_R_VERSION}" ) # no output for this
    set(R_VERSION_STRING ${PC_R_VERSION})
elseif(R_INCLUDE_DIR AND EXISTS "${R_INCLUDE_DIR}/htslib/hts.h")
    file(STRINGS "${R_INCLUDE_DIR}/htslib/hts.h" htslib_version_str
         REGEX "^#define[\t ]+HTS_VERSION[\t ]+\".*\"")

    string(REGEX REPLACE "^#define[\t ]+HTS_VERSION[\t ]+\"([^\"]*)\".*" "\\1"
           R_VERSION_STRING "${htslib_version_str}")
    unset(htslib_version_str)
endif()

set(R_INCLUDE_DIRS ${R_INCLUDE_DIR} ${PC_R_INCLUDE_DIRS})
set(R_LIBRARIES ${R_LIBRARY})


FIND_PACKAGE_HANDLE_STANDARD_ARGS(HTSlib
                                  REQUIRED_VARS R_LIBRARY R_INCLUDE_DIR
                                  VERSION_VAR R_VERSION_STRING)

mark_as_advanced(R_INCLUDE_DIR R_LIBRARY)

if(HTSlib_FOUND AND NOT TARGET HTSlib::HTSlib)
  add_library(HTSlib::HTSlib UNKNOWN IMPORTED)
  set_target_properties(HTSlib::HTSlib PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${R_INCLUDE_DIRS}")
  set_property(TARGET HTSlib::HTSlib APPEND PROPERTY IMPORTED_LOCATION "${R_LIBRARY}")
endif()
