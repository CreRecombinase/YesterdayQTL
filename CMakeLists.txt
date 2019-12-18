cmake_minimum_required (VERSION 3.15)
project (YesterdayQTL CXX)
include(FetchContent)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


set(USE_EIGEN TRUE CACHE INTERNAL "")
find_package (GSL REQUIRED)
find_package (Eigen3 3.3 REQUIRED NO_MODULE)
find_package(BZip2 REQUIRED)



FetchContent_Declare(
  rmath
  GIT_REPOSITORY https://github.com/statslabs/rmath.git
  )
FetchContent_MakeAvailable(rmath)



if(NOT rmath_POPULATED)
  message( STATUS "rmath not found..." )
  FetchContent_Populate(rmath)
  add_subdirectory(${rmath_SOURCE_DIR} ${rmath_BINARY_DIR})
  message( STATUS "rmath_SRC ... ${rmath_SOURCE_DIR}")
  message( STATUS "rmath_BIN ... ${rmath_BINARY_DIR}")
  elseif(rmath_POPULATED)
    message( STATUS "rmath_SRC ... ${rmath_SOURCE_DIR}")
    message( STATUS "rmath_BIN ... ${rmath_BINARY_DIR}")
endif()

# find_package(R REQUIRED)

IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Release)
ENDIF(NOT CMAKE_BUILD_TYPE)




find_package(HTSlib REQUIRED htslib)
find_package(Boost COMPONENTS iostreams program_options REQUIRED)
message("boost lib: ${Boost_LIBRARIES}, inc:${Boost_INCLUDE_DIR}")
# target_include_directories(

add_executable(fastqtl src/analysisMapping.cpp
  src/analysisPermutationPerGroup.cpp
  src/df.cpp
  src/readCovariates.cpp
  src/readInteractions.cpp
  src/residualizer.cpp
  src/analysisNominal.cpp
  src/analysisPermutationSequence.cpp
  src/fastQTL.cpp
  src/readGenotypes.cpp
  src/readPhenotypes.cpp
  src/residualizer.h
  src/analysisPermutation.cpp
  src/commands.cpp
  src/management.cpp
  src/readGroups.cpp
  src/readThresholds.cpp
  src/analysisPermutationInteraction.cpp
  src/data.h
  src/mle.cpp
  src/readInclusionsExclusions.cpp
  src/region.h
  src/ranker.h
  src/readInteractions.cpp
  src/utils.h
  src/utils.cpp
  src/tabix.cpp
  src/tabix.hpp)

# target_include_directories(
#   fastqtl
#   PRIVATE $<TARGET_PROPERTY:rmath,INTERFACE_INCLUDE_DIRECTORIES>)
# target_link_libraries(
#   fastqtl
#   PRIVATE $<TARGET_PROPERTY:rmath,INTERFACE_LINK_LIBRARIES>)
target_link_libraries(
  fastqtl
  PRIVATE rmath)

#target_link_libraries(fastqtl PRIVATE rmath)
target_link_libraries(fastqtl PRIVATE GSL::gsl)
#find_package(rmath REQUIRED)

#   fastqtl
#   PRIVATE $<TARGET_PROPERTY:HighFive,INTERFACE_INCLUDE_DIRECTORIES>)
target_link_libraries (fastqtl PRIVATE HTSlib::HTSlib)

target_link_libraries (fastqtl PRIVATE ${CMAKE_THREAD_LIBS_INIT})
#target_link_libraries (fastqtl PRIVATE rmath::rmath)
target_link_libraries (fastqtl PRIVATE HTSlib::HTSlib)

# target_link_libraries(
#   fastqtl
#   PRIVATE $<TARGET_PROPERTY:HighFive,INTERFACE_LINK_LIBRARIES>)
target_include_directories(fastqtl PRIVATE ${Boost_INCLUDE_DIRS})

target_link_libraries(fastqtl PRIVATE Boost::iostreams)
target_link_libraries(fastqtl PRIVATE Boost::program_options)

# target_include_directories(
#   vcf2h5
#   PRIVATE $<TARGET_PROPERTY:range-v3,INTERFACE_INCLUDE_DIRECTORIES>)
# target_link_libraries(
#   vcf2h5
#   PRIVATE $<TARGET_PROPERTY:range-v3,INTERFACE_LINK_LIBRARIES>)
