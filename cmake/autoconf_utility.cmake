include(TestBigEndian)
include(CheckIncludeFile)
include(CheckCSourceCompiles)
include(CheckTypeSize)
include(CheckFunctionExists)
include(CheckCSourceRuns)

function(ac_init package version)
  list(LENGTH ARGN len)
  if (len GREATER 0)
    list(GET ARGN 0 bug_report)
    set(PACKAGE_BUGREPORT "\"${bug_report}\"" PARENT_SCOPE)
  endif()
  if (len GREATER 1)
    list(GET ARGN 1 tarname)
    set(PACKAGE "\"${tarname}\"" PARENT_SCOPE)
    set(PACKAGE_TARNAME "\"${tarname}\"" PARENT_SCOPE)
  endif()
  if (len GREATER 2)
    list(GET ARGN 2 url)
    set(PACKAGE_URL "\"${url}\"" PARENT_SCOPE)
  endif()
  set(PACKAGE_NAME "\"${package}\"" PARENT_SCOPE)
  set(PACKAGE_VERSION "\"${version}\"" PARENT_SCOPE)
  set(VERSION "\"${version}\"" PARENT_SCOPE)
  set(PACKAGE_STRING "\"${package} ${version}\"" PARENT_SCOPE)
endfunction()

macro(ac_check_headers)
  foreach(hdr ${ARGN})
    string(TOUPPER "${hdr}" uhdr)
    string(REPLACE "." "_" uhdr "${uhdr}")
    string(REPLACE "/" "_" uhdr "${uhdr}")
    check_include_file("${hdr}" CHECK_${uhdr})
    if (CHECK_${uhdr})
      set(HAVE_${uhdr} 1)
    else ()
      unset(HAVE_${uhdr})
    endif()
  endforeach()
endmacro()

# Check for the const keyword, defining "HAS_CONST_SUPPORT"
# If it does not have support, defines "const" to 0 in the parent scope
function(ac_c_const)
  check_c_source_compiles(
    "int main(int argc, char **argv){const int r = 0;return r;}"
    HAS_CONST_SUPPORT)
  if (NOT HAS_CONST_SUPPORT)
    set(const "" PARENT_SCOPE)
  endif()
endfunction()


# Inline keyword support. Defines "inline" in the parent scope to the
# compiler internal keyword for inline in C
function (ac_c_inline)
  if (MSVC)
    set (inline __inline)
  elseif(CMAKE_COMPILER_IS_GNUC)
    set (inline __inline__)
  endif()
  set(inline "${inline}" PARENT_SCOPE)
endfunction()

# Check for bigendian,defining "WORDS_BIGENDIAN" and "HOST_BIGENDIAN" in
# the parent scope
function (ac_c_bigendian)
  test_big_endian(bigendian)
  if (bigendian)
    set(WORDS_BIGENDIAN 1 PARENT_SCOPE)
    set(HOST_BIGENDIAN 1 PARENT_SCOPE)
  endif()
endfunction()

# Check for off_t, setting "off_t" in the parent scope
function(ac_type_off_t)
  check_type_size("off_t" OFF_T)
  if (NOT OFF_T)
    set(off_t "long int")
  endif()
  set(off_t ${off_t} PARENT_SCOPE)
endfunction()

# Check for size_t, setting "size_t" in the parent scope
function(ac_type_size_t)
  check_type_size("size_t" SIZE_T)
  if (NOT SIZE_T)
    set(size_t "unsigned int")
  endif()
  set(size_t ${size_t} PARENT_SCOPE)
endfunction()

# Check for if you can safely include both <sys/time.h> and <time.h>
function(ac_header_time)
  check_c_source_compiles(
    "#include <sys/time.h>\n#include <time.h>\nint main(int argc, char **argv) { return 0; }" 
    TIME_WITH_SYS_TIME)
  set(TIME_WITH_SYS_TIME ${TIME_WITH_SYS_TIME} PARENT_SCOPE)
endfunction()

# Define "TM_IN_SYS_TIME" to 1 if <sys/time.h> declares "struct tm"
function(ac_struct_tm)
  check_c_source_compiles(
    "#include <sys/time.h>\nint main(int argc, char **argv) { struct tm x; return 0; }"
    TM_IN_SYS_TIME
  )
  if (TM_IN_SYS_TIME)
    set (TM_IN_SYS_TIME 1 PARENT_SCOPE)
  endif()
endfunction()

# Obtain size of an 'type' and define as SIZEOF_TYPE
function (ac_check_sizeof typename)
  string(TOUPPER "SIZEOF_${typename}" varname)
        string(REPLACE " " "_" varname "${varname}")
  string(REPLACE "*" "p" varname "${varname}")
  check_type_size("${typename}" ${varname} BUILTIN_TYPES_ONLY)
  if(NOT ${varname})
    set(${varname} 0 PARENT_SCOPE)
  endif()
endfunction()

# Check if the type exists, defines HAVE_<type>
macro (ac_check_type typename)
  string(TOUPPER "${typename}" varname)
  string(REPLACE " " "_" varname "${varname}")
  string(REPLACE "*" "p" varname "${varname}")
  check_type_size("${typename}" ${varname})
endmacro()

# Verifies if each type on the list exists, using the given prelude
macro (ac_check_types type_list prelude)
  foreach(typename ${type_list})
    string(TOUPPER "HAVE_${typename}" varname)
    string(REPLACE " " "_" varname "${varname}")
    string(REPLACE "*" "p" varname "${varname}")
    check_c_source_compiles("${prelude}\n ${typename} foo;" ${varname})
  endforeach()
endmacro()

# Check if each func on the list exists
macro (ac_check_funcs)
  foreach(func ${ARGN})
    string(TOUPPER "${func}" ufunc)
    check_function_exists("${func}" HAVE_${ufunc})
  endforeach()
endmacro()


# Also from the mono sources, kind of implements AC_SYS_LARGEFILE
# And I know nothing about this...
function (ac_sys_largefile)
  check_c_source_runs("
#include <sys/types.h>
#define BIG_OFF_T (((off_t)1<<62)-1+((off_t)1<<62))
int main (int argc, char **argv) {
    int big_off_t=((BIG_OFF_T%2147483629==721) &&
                   (BIG_OFF_T%2147483647==1));
    return big_off ? 0 : 1;
}
" HAVE_LARGE_FILE_SUPPORT)

# Check if it makes sense to define _LARGE_FILES or _FILE_OFFSET_BITS
  if (HAVE_LARGE_FILE_SUPPORT)
    return()
  endif()
  
  set (_LARGE_FILE_EXTRA_SRC "
#include <sys/types.h>
int main (int argc, char **argv) {
  return sizeof(off_t) == 8 ? 0 : 1;
}
")
  check_c_source_runs ("#define _LARGE_FILES\n${_LARGE_FILE_EXTRA_SRC}" 
    HAVE_USEFUL_D_LARGE_FILES)
  if (NOT HAVE_USEFUL_D_LARGE_FILES)
    if (NOT DEFINED HAVE_USEFUL_D_FILE_OFFSET_BITS)
      set (SHOW_LARGE_FILE_WARNING TRUE)
    endif ()
    check_c_source_runs ("#define _FILE_OFFSET_BITS 64\n${_LARGE_FILE_EXTRA_SRC}"
      HAVE_USEFUL_D_FILE_OFFSET_BITS)
    if (HAVE_USEFUL_D_FILE_OFFSET_BITS)
      set (_FILE_OFFSET_BITS 64 PARENT_SCOPE)
    elseif (SHOW_LARGE_FILE_WARNING)
      message (WARNING "No 64 bit file support through off_t available.")
    endif ()
  else ()
    set (_LARGE_FILES 1 PARENT_SCOPE)
  endif ()
endfunction ()
