cmake_minimum_required(VERSION 2.6)

project(callflow NONE)

set(VERSION_MAJOR 20110914)
set(VERSION_MINOR 160)
set(VERSION_STRING "${VERSION_MAJOR}-${VERSION_MINOR}")
message(STATUS "*** Will build version ${VERSION_STRING} ***")

# Perhaps redundant, but nice to have the if structure around as an example
if(UNIX)
  set(BINDIR "${CMAKE_INSTALL_PREFIX}/bin")
elseif(APPLE)
  set(BINDIR "bin")
elseif(WIN32)
  set(BINDIR "bin")
endif()

set(MANDIR "share/man/")
set(SHAREDIR "share/${PROJECT_NAME}/")
add_definitions("-DSHAREDIR=\\\"${CMAKE_INSTALL_PREFIX}/${SHAREDIR}\\\"")
if(DEFINED DOCDIR)
  set(DOCFOLDER "${DOCDIR}")
else()
  set(DOCFOLDER "${PREFIX}/share/doc/${PROJECT_NAME}")
endif()
add_definitions("-DDOCDIR=\\\"${CMAKE_INSTALL_PREFIX}/${DOCDIR}\\\"")

add_subdirectory(js)
add_subdirectory(css)
add_subdirectory(man)
add_subdirectory(conf)
add_subdirectory(images)
add_subdirectory(scripts)

#
# Installation
#

install(PROGRAMS
  callflow
  DESTINATION "${BINDIR}"
)

install(FILES
  AUTHORS
  LICENSE
  README
  DESTINATION "${DOCFOLDER}"
)

# If the cmake version includes cpack, use it
if(EXISTS "${CMAKE_ROOT}/Modules/CPack.cmake")
  set(CPACK_PACKAGE_EXECUTABLES callflow)
  set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Dummy Value")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Callflow Sequence Diagram Generator")
  
  if(WIN32)
    set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${VERSION_STRING}-win32")
    set(CPACK_GENERATOR ZIP)
  elseif(APPLE)
    # TODO
    # see http://cmake.org/Wiki/CMake:CPackPackageGenerators#Bundle_.28OSX_only.29
    #
    set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${VERSION_STRING}-osx")
    set(CPACK_PACKAGE_ICON "")
    set(CPACK_BUNDLE_NAME ${PROJECT_NAME})
    set(CPACK_BUNDLE_ICON "")
    set(CPACK_BUNDLE_PLIST "")
    set(CPACK_GENERATOR BUNDLE)
  else()
    set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${VERSION_STRING}")
    set(CPACK_GENERATOR TGZ)
    set(CPACK_SOURCE_GENERATOR TBZ2)
  endif()
  
  include(CPack)

endif(EXISTS "${CMAKE_ROOT}/Modules/CPack.cmake")

