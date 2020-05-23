cmake_minimum_required(VERSION 2.6)

project(callflow NONE)

# Get date
MACRO (TODAY RESULT)
    IF (WIN32)
        EXECUTE_PROCESS(COMMAND "cmd" " /C date /T" OUTPUT_VARIABLE ${RESULT})
        string(REGEX REPLACE "(..)/(..)/(....).*" "\\3\\2\\1" ${RESULT} ${${RESULT}})
    ELSEIF(UNIX)
        EXECUTE_PROCESS(COMMAND "date" "+%d/%m/%Y" OUTPUT_VARIABLE ${RESULT})
        string(REGEX REPLACE "(..)/(..)/(....).*" "\\3\\2\\1" ${RESULT} ${${RESULT}})
    ELSE (WIN32)
        MESSAGE(SEND_ERROR "date not implemented")
        SET(${RESULT} 000000)
    ENDIF (WIN32)
ENDMACRO (TODAY) 

TODAY(DATE)


set(VERSION_STRING ${DATE})

# Overwrite version major if callflow.version found
if(EXISTS "../callflow.version")
  file (STRINGS "callflow.version" VERSION_STRING)
endif()

message(STATUS "*** Will build version ${VERSION_STRING} ***")

# BINDIR
# Perhaps redundant, but nice to have the if structure around as an example
if(UNIX)
  set(BINDIR "${CMAKE_INSTALL_PREFIX}/bin")
elseif(APPLE)
  set(BINDIR "bin")
elseif(WIN32)
  set(BINDIR "bin")
endif()

message(STATUS " --> Will install BIN file to ${BINDIR}")

# MANDIR
set(MANDIR "${CMAKE_INSTALL_PREFIX}/share/man/")
message(STATUS " --> Will install MAN file to ${MANDIR}")

# DOCDIR
if(NOT DEFINED DOCDIR)
  set(DOCDIR "${CMAKE_INSTALL_PREFIX}/share/doc/${PROJECT_NAME}")
endif()
add_definitions("-DDOCDIR=\\\"${DOCDIR}\\\"")
message(STATUS " --> Will install DOC files to ${DOCDIR}")

# CONFDIR
if(NOT DEFINED CONFDIR)
	set(CONFDIR "${CMAKE_INSTALL_PREFIX}/etc/${PROJECT_NAME}")
endif()
add_definitions("-DCONFDIR=\\\"${CONFDIR}\\\"")
message(STATUS " --> Will install CONF files to ${CONFDIR}")

# SHAREDIR
set(SHAREDIR "${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}/")
add_definitions("-DSHAREDIR=\\\"${SHAREDIR}\\\"")
message(STATUS " --> Will install callflow files to ${SHAREDIR}")

#
# Which folders to install
#
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
  LICENSE
  README.md
  DESTINATION "${DOCDIR}"
)

# If the cmake version includes cpack, use it
if(EXISTS "${CMAKE_ROOT}/Modules/CPack.cmake")
  set(CPACK_PACKAGE_EXECUTABLES callflow)
  set(CPACK_DEBIAN_PACKAGE_MAINTAINER "callflow")
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

