cmake_minimum_required(VERSION 2.8)

include(yong_injector/injector.cmake)

yong_project(tiff C)
set(TIFF_VERSION "v4.0.3")

include(CheckLibraryExists)
include(CheckLanguage)
include(cmake/autoconf_utility.cmake)
ac_init("LibTIFF Software"
  "${TIFF_VERSION}"
  "tiff@lists.maptools.org"
  "tiff")

#We don't need to add math library to all targets
if (NOT (WIN32 OR APPLE))
  check_library_exists(m sin "" HAVE_LIBM)
  if (HAVE_LIBM)
    set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} m)
  endif()
endif()

# Check for header files.
ac_check_headers("assert.h"
  "fcntl.h"
  "inttypes.h"
  "io.h"
  "limits.h"
  "malloc.h"
  "search.h"
  "string.h"
  "sys/time.h"
  "sys/types.h"
  "unistd.h"
  )

# Checks for typedefs,structures, and compiler characteristics.
ac_c_const()
ac_c_inline()
ac_c_bigendian()
ac_type_off_t()
ac_type_size_t()
ac_header_time()
ac_struct_tm()

# Obtain size of build-in types
ac_check_sizeof("signed short")
ac_check_sizeof("unsigned short")
ac_check_sizeof("signed int")
ac_check_sizeof("unsigned int")
ac_check_sizeof("signed long")
ac_check_sizeof("unsigned long")
ac_check_sizeof("signed long long")
ac_check_sizeof("unsigned long long")
ac_check_sizeof("unsigned char *")

# Signed 8-bit type
set(TIFF_INT8_T "signed char")

# Unsigned 8-bit type
set(TIFF_UINT8_T "unsigned char")

# Signed 16-bit type
set(TIFF_INT16_T "signed short")

# Unsigned 16-bit type
set(TIFF_UINT16_T "unsigned short")

# Checking for signed 32-bit type
if(SIZEOF_SIGNED_INT EQUAL 4)
  set(INT32_T      "signed int")
  set(INT32_FORMAT "\"%d\"")
elseif(SIZEOF_SIGNED_LONG EQUAL 4)
  set(INT32_T      "signed long")
  set(INT32_FORMAT "\"%ld\"")
endif()
if (MSVC)
  set(INT32_T "__int32")
endif()
# Signed 32-bit type
set(TIFF_INT32_T "${INT32_T}")
# Signed 32-bit type formatter
set(TIFF_INT32_FORMAT "${INT32_FORMAT}")

# Checking for unsigned 32-bit type
if(SIZEOF_UNSIGNED_INT EQUAL 4)
  set(UINT32_T      "unsigned int")
  set(UINT32_FORMAT "\"%u\"")
elseif(SIZEOF_UNSIGNED_LONG EQUAL 4)
  set(UINT32_T      "unsigned long")
  set(UINT32_FORMAT "\"%lu\"")
endif()
if (MSVC)
  set(UINT32_T "unsigned __int32")
endif()
# Unigned 32-bit type
set(TIFF_UINT32_T "${UINT32_T}")
# Unigned 32-bit type formatter
set(TIFF_UINT32_FORMAT "${UINT32_FORMAT}")

# Checking for signed 64-bit type
if(SIZEOF_SIGNED_LONG EQUAL 8)
  set(INT64_T "signed long")
  set(INT64_FORMAT "\"%ld\"")
elseif(SIZEOF_SIGNED_LONG_LONG EQUAL 8)
  set(INT64_T "signed long long")
  if (WIN32)
    # MinGW32 understands 'long long', but uses printf from WIN32 CRT
    set(INT64_FORMAT="\"%I64d\"")
  else()
    set(INT64_FORMAT="\"%lld\"")
  endif()
endif()
if (MSVC)
  set(INT64_T "__int64")
endif()
# Signed 64-bit type
set(TIFF_INT64_T "${INT64_T}")
# Signed 64-bit type formatter
set(TIFF_INT64_FORMAT "${INT64_FORMAT}")

# Checking for unsigned 64-bit type
if(SIZEOF_UNSIGNED_LONG EQUAL 8)
  set(UINT64_T "unsigned long")
  set(UINT64_FORMAT "\"%lu\"")
elseif(SIZEOF_UNSIGNED_LONG_LONG EQUAL 8)
  set(UINT64_T "unsigned long long")
  if (WIN32)
    # MinGW32 understands 'unsigned long long', but uses printf from WIN32 CRT
    set(UINT64_FORMAT "\"%I64u\"")
  else()
    set(UINT64_FORMAT "\"%llu\"")
  endif()
endif()
if (MSVC)
  set(UINT64_T "unsigned __int64")
endif()
# Unsigned 64-bit type
set(TIFF_UINT64_T "${UINT64_T}")
# Unsigned 64-bit type formatter
set(TIFF_UINT64_FORMAT "${UINT64_FORMAT}")

# Determine TIFF equivalent of ssize_t
set(SIZEOF_UNSIGNED_CHAR_P ${CMAKE_SIZEOF_VOID_P})
if(NOT MSVC)
  if(SIZEOF_SIGNED_LONG EQUAL CMAKE_SIZEOF_VOID_P)
    set(SSIZE_T "signed long")
    set(SSIZE_FORMAT "\"%ld\"")
  elseif(SIZEOF_SIGNED_LONG_LONG EQUAL CMAKE_SIZEOF_VOID_P)
    set(SSIZE_T "signed long long")
    set(SSIZE_FORMAT "\"%lld\"")
  endif()
else()
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(SSIZE_T "__int64")
    set(SSIZE_FORMAT "\"%I64d\"")
  else()
    set(SSIZE_T "__int32")
    set(SSIZE_FORMAT "\"%d\"")
  endif()
endif()
# Signed size type
set(TIFF_SSIZE_T "${SSIZE_T}")
# Signed size type formatter
set(TIFF_SSIZE_FORMAT "${SSIZE_FORMAT}")

# Determine the type to use for the difference between two pointers.
# We will default to the POSIX ptrdiff_t if it is available, but will
# be prepared for the case when it is not.
ac_check_type(ptrdiff_t)
if (NOT HAVE_PTRDIFF_T)
  set(PTRDIFF_T "${SSIZE_T}")
  set(PTRDIFF_FORMAT "${SSIZE_FORMAT}")
else()
  set(PTRDIFF_T "ptrdiff_t")
  set(PTRDIFF_FORMAT "\"%ld\"")
endif()

# Pointer difference type
set(TIFF_PTRDIFF_T "${PTRDIFF_T}")
# Pointer difference type formatter
set(TIFF_PTRDIFF_FORMAT "${PTRDIFF_FORMAT}")

# Some compilers (IBM VisualAge) has these types defined, so check it here:
if (HAVE_INTTYPES_H)
  set(CHECK_PRELUDE "#\ninclude <inttypes.h>\n\n")
endif()
ac_check_types("int8;int16;int32" "${CHECK_PRELUDE}")

# Checks for library functions
ac_check_funcs("floor"
  "isascii"
  "memmove"
  "memset"
  "mmap"
  "pow"
  "setmode"
  "sqrt"
  "strchr"
  "strrchr"
  "strstr"
  "strtol"
  "strtoull")

# Check the native cpu bit order
if (WORDS_BIGENDIAN)
  set(HOST_FILLORDER FILLORDER_MSB2LSB)
  message(STATUS "Checking native cpu bit order... msb2lsb")
else()
  set(HOST_FILLORDER FILLORDER_LSB2MSB)
  message(STATUS "Checking native cpu bit order... lsb2msb")
endif()

# Set the floating point format
# FIXME: write appropriate test.
set(HAVE_IEEEFP 1)

# Support large files.
ac_sys_largefile()

# Macro for defining option
macro(tiff_option name desc default)
  yong_option(TIFF_${name} "${desc}" ${default})
  if (TIFF_${name})
    set(${name} 1)
  else ()
    unset(${name})
  endif()
endmacro()

# Macro for defining dep option
macro(tiff_dep_option name hash define desc default)
  string(TOUPPER "${name}" uname)
  yong_option(TIFF_${define} "${desc}" "${default}")
  if (TIFF_${define})
    set(${define} 1)
    yong_add_dependence(tiff tiff
      DEPENDENT_PROJECT ${name}
      COMMIT_HASH ${hash}
      DEPENDENT_LIBS ${name})
  else ()
    unset(${define})
  endif()
endmacro()

if (WIN32)
  option(TIFF_WINMODE_CONSOLE "Check if reports errors to stderr" ON)
  option(TIFF_WINMODE_WINDOWED "Check if reports errors via MessageBox()" OFF)
  option(TIFF_USE_WIN_CRT_LIB "Check if use Windows Common RunTime Library instead of Windows specific system calls." ON)
endif()

if (MSVC)
  if (TIFF_USE_WIN_CRT_LIB)
    set(SYSDEP_SOURCE "libtiff/tif_win32.c")
  else ()
    set(SYSDEP_SOURCE "libtiff/tif_unix.c")
  endif()
elseif(UNIX)
  set(SYSDEP_SOURCE "libtiff/tif_unix.c")
endif()

set(TIFF_SOURCES
  libtiff/tif_aux.c
  libtiff/tif_close.c
  libtiff/tif_codec.c
  libtiff/tif_color.c
  libtiff/tif_compress.c
  libtiff/tif_dir.c
  libtiff/tif_dirinfo.c
  libtiff/tif_dirread.c
  libtiff/tif_dirwrite.c
  libtiff/tif_dumpmode.c
  libtiff/tif_error.c
  libtiff/tif_extension.c
  libtiff/tif_fax3.c
  libtiff/tif_fax3sm.c
  libtiff/tif_getimage.c
  libtiff/tif_jbig.c
  libtiff/tif_jpeg.c
  libtiff/tif_jpeg_12.c
  libtiff/tif_ojpeg.c
  libtiff/tif_flush.c
  libtiff/tif_luv.c
  libtiff/tif_lzw.c
  libtiff/tif_next.c
  libtiff/tif_open.c
  libtiff/tif_packbits.c
  libtiff/tif_pixarlog.c
  libtiff/tif_predict.c
  libtiff/tif_print.c
  libtiff/tif_read.c
  libtiff/tif_stream.cxx
  libtiff/tif_swab.c
  libtiff/tif_strip.c
  libtiff/tif_thunder.c
  libtiff/tif_tile.c
  libtiff/tif_version.c
  libtiff/tif_warning.c
  libtiff/tif_write.c
  libtiff/tif_zip.c
  ${SYSDEP_SOURCE})

if (WIN32 AND BUILD_SHARED_LIBS)
  set(TIFF_SOURCES ${TIFF_SOURCES} libtiff/libtiff.def)
endif()

yong_add_library(tiff 
  SOURCES ${TIFF_SOURCES})

tiff_option("CCITT_SUPPORT" "Support for CCITT Group 3 & 4 algorithms" ON)
tiff_option("PACKBITS_SUPPORT" "Support for Macintosh PackBits algorithm" ON)
tiff_option("LZW_SUPPORT" "Support for LZW algorithm" ON)
tiff_option("THUNDER_SUPPORT" "Support for ThunderScan 4-bit RLE algorithm" ON)
tiff_option("NEXT_SUPPORT" "Support for NeXT 2-bit RLE algorithm" ON)
tiff_option("LOGLUV_SUPPORT" "Support for LogLuv high dynamic range encoding" ON)
tiff_option("MDI_SUPPORT" "Support for Microsoft Document Imaging format" ON)

tiff_dep_option("zlib" 04ad1c7e937d2835c1c54c50bec9cfaa4f43a1c8
                ZIP_SUPPORT "Support Deflate compression" ON)
if (ZIB_SUPPORT)
  tiff_option("PIXARLOG_SUPPORT" "Support for Pixar log-format algorithm (requires Zlib)" ON)
endif()

tiff_dep_option("jpeg_turbo" c5f46459881c068960fae0d2257cd907e917f8cc
                JPEG_SUPPORT  "Support for JPEG compression" ON)
if (JPEG_SUPPORT)
  tiff_option("OJPEG_SUPPORT" "Support for Old JPEG compression (read only)" ON)
endif()

# Not complete yet,don't set it on.
#tiff_dep_option("jbig" JBIG_SUPPORT "Support for JBIG-KIT" OFF)

# Not complete yet,don't set it on.
#tiff_dep_option("lzma" LZMA_SUPPORT "Support for LZMA2 compression" OFF)

# Check CXX support
check_language(CXX)
if (CMAKE_CXX_COMPILER)
  set(CXX_SUPPORT 1)
else()
  unset(CXX_SUPPORT)
endif()

if (WIN32)
  if (TIFF_WINMODE_WINDOWED)
    add_definitions(-DTIF_PLATFORM_WINDOWED)
    target_link_libraries(tiff user32.lib)
  else()
    add_definitions(-DTIF_PLATFORM_CONSOLE)
  endif()

  if (TIFF_USE_WIN_CRT_LIB)
    add_definitions(-DAVOID_WIN32_FILEIO)
  else()
    add_definitions(-DUSE_WIN32_FILEIO)
  endif()
endif()

#TODO X Athena Widgets staff

# Orthogonal Features

yong_option(TIFF_STRIPCHOPING "Support for strip chopping (whether or not to convert single-strip uncompressed images to mutiple strips of specified size to reduce memory usage)" ON)
if (TIFF_STRIPCHOPING)
  yong_set_cache(TIFF_STRIP_SIZE_DEFAULT 8192 CACHE STRING "Default size of the strip in bytes(when strip chopping enabled)")
  set(STRIPCHOP_DEFAULT "TIFF_STRIPCHOP")
  set(STRIP_SIZE_DEFAULT ${TIFF_STRIP_SIZE_DEFAULT})
endif()

tiff_option("DEFER_STRILE_LOAD" "Deferred strip/tile offset/size loading(experimental)" OFF)
tiff_option("CHUNKY_STRIP_READ_SUPPORT" "Reading large strips in chunks for TIFFReadScanline() (experimental)" OFF)
tiff_option("SUBIFD_SUPPORT" "Support for SubIFD tag (330)" ON)
tiff_option("DEFAULT_EXTRASAMLE_AS_ALPHA" "The RGBA interface will treat a fourth sample with no EXTRASAMPLE_ value as being ASSOCALPHA.Many packages produce RGBA files but don't mark the alpha properly" ON)
tiff_option("CHECK_JPEG_YCBCR_SUBSAMPLING" "Pick up YCbCr subsampling info from the JPEG data stream to support files lacking the tag" ON)

configure_file("libtiff/tif_config.h.cmake.in" "tif_config.h")
configure_file("libtiff/tiffconf.h.cmake.in" "tiffconf.h")

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/libtiff"
  "${CMAKE_CURRENT_BINARY_DIR}")

file(GLOB TIFF_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/libtiff/*.h")
set(TIFF_HEADERS ${TIFF_HEADERS}
  "${CMAKE_CURRENT_BINARY_DIR}/tif_config.h"
  "${CMAKE_CURRENT_BINARY_DIR}/tiffconf.h")
yong_install_header_files(tiff ${TIFF_HEADERS})

yong_add_library_end(tiff)

yong_project_end()
