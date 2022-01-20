cmake_minimum_required(VERSION 3.13)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

if (${CMAKE_HOST_WIN32})
get_filename_component(CMAKE_C_COMPILER ${VALIANT_SOURCE_DIR}/third_party/toolchain-win/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-gcc.exe REALPATH CACHE)
get_filename_component(CMAKE_CXX_COMPILER ${VALIANT_SOURCE_DIR}/third_party/toolchain-win/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-g++.exe REALPATH CACHE)
get_filename_component(CMAKE_OBJCOPY ${VALIANT_SOURCE_DIR}/third_party/toolchain-win/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-objcopy.exe REALPATH CACHE)
get_filename_component(CMAKE_STRIP ${VALIANT_SOURCE_DIR}/third_party/toolchain-win/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-strip.exe REALPATH CACHE)
elseif(${CMAKE_HOST_APPLE})
get_filename_component(CMAKE_C_COMPILER ${VALIANT_SOURCE_DIR}/third_party/toolchain-mac/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-gcc REALPATH CACHE)
get_filename_component(CMAKE_CXX_COMPILER ${VALIANT_SOURCE_DIR}/third_party/toolchain-mac/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-g++ REALPATH CACHE)
get_filename_component(CMAKE_OBJCOPY ${VALIANT_SOURCE_DIR}/third_party/toolchain-mac/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-objcopy REALPATH CACHE)
get_filename_component(CMAKE_STRIP ${VALIANT_SOURCE_DIR}/third_party/toolchain-mac/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-strip REALPATH CACHE)
else()
get_filename_component(CMAKE_C_COMPILER ${VALIANT_SOURCE_DIR}/third_party/toolchain/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-gcc REALPATH CACHE)
get_filename_component(CMAKE_CXX_COMPILER ${VALIANT_SOURCE_DIR}/third_party/toolchain/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-g++ REALPATH CACHE)
get_filename_component(CMAKE_OBJCOPY ${VALIANT_SOURCE_DIR}/third_party/toolchain/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-objcopy REALPATH CACHE)
get_filename_component(CMAKE_STRIP ${VALIANT_SOURCE_DIR}/third_party/toolchain/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-strip REALPATH CACHE)
endif()

string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/" "" VALIANT_PREFIX "${VALIANT_SOURCE_DIR}")

execute_process(
    COMMAND ${CMAKE_C_COMPILER} -print-libgcc-file-name
    OUTPUT_VARIABLE CMAKE_FIND_ROOT_PATH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
get_filename_component(CMAKE_FIND_ROOT_PATH
    "${CMAKE_FIND_ROOT_PATH}" PATH
)
get_filename_component(CMAKE_FIND_ROOT_PATH
    "${CMAKE_FIND_ROOT_PATH}/.." REALPATH
)

message(STATUS "Toolchain prefix: ${CMAKE_FIND_ROOT_PATH}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

find_program(CMAKE_MAKE_PROGRAM make REQUIRED)
find_program(CMAKE_XXD_PROGRAM xxd REQUIRED)

set(COMMON_C_FLAGS
    "-Wall"
    "-Wno-psabi"
    "-mthumb"
    "-fno-common"
    "-ffunction-sections"
    "-fdata-sections"
    "-ffreestanding"
    "-fno-builtin"
    "-mapcs-frame"
    "--specs=nano.specs"
    "--specs=nosys.specs"
    "-u _printf_float"
)
if (VALIANT_BOARD_REVISION STREQUAL EVK)
    list(APPEND COMMON_C_FLAGS "-DBOARD_REVISION_EVK")
elseif (VALIANT_BOARD_REVISION STREQUAL P0)
    list(APPEND COMMON_C_FLAGS "-DBOARD_REVISION_P0")
elseif (VALIANT_BOARD_REVISION STREQUAL P1)
    list(APPEND COMMON_C_FLAGS "-DBOARD_REVISION_P1")
endif()
list(JOIN COMMON_C_FLAGS " " COMMON_C_FLAGS_STR)

set(COMMON_C_FLAGS_DEBUG
    "-g"
    "-u _printf_float"
    "-O0"
)
list(JOIN COMMON_C_FLAGS_DEBUG " " COMMON_C_FLAGS_DEBUG_STR)

set(COMMON_C_FLAGS_RELEASE
    "-g"
    "-Os"
)
list(JOIN COMMON_C_FLAGS_RELEASE " " COMMON_C_FLAGS_RELEASE_STR)

set(CM7_C_FLAGS
    "-mcpu=cortex-m7"
    "-mfloat-abi=hard"
    "-mfpu=fpv5-d16"
)
list(JOIN CM7_C_FLAGS " " CM7_C_FLAGS_STR)

set(COMMON_LINK_FLAGS
    "-Xlinker" "--defsym=__use_shmem__=1"
)
list(JOIN COMMON_LINK_FLAGS " " COMMON_LINK_FLAGS_STR)

set(CM7_LINK_FLAGS
    "-mcpu=cortex-m7"
    "-mfloat-abi=hard"
    "-mfpu=fpv5-d16"
)
list(JOIN CM7_LINK_FLAGS " " CM7_LINK_FLAGS_STR)

set(CM4_C_FLAGS
    "-mcpu=cortex-m4"
    "-mfloat-abi=hard"
    "-mfpu=fpv4-sp-d16"
)
list(JOIN CM4_C_FLAGS " " CM4_C_FLAGS_STR)

set(CM4_LINK_FLAGS
    "-mcpu=cortex-m4"
    "-mfloat-abi=hard"
    "-mfpu=fpv4-sp-d16"
)
list(JOIN CM4_LINK_FLAGS " " CM4_LINK_FLAGS_STR)

unset(CMAKE_C_FLAGS)
unset(CMAKE_C_FLAGS_DEBUG)
unset(CMAKE_C_FLAGS_RELEASE)
unset(CMAKE_CXX_FLAGS)
unset(CMAKE_CXX_FLAGS_DEBUG)
unset(CMAKE_CXX_FLAGS_RELEASE)
unset(CMAKE_EXE_LINKER_FLAGS)
set(CMAKE_C_FLAGS "${COMMON_C_FLAGS_STR} -std=gnu99" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_DEBUG "${COMMON_C_FLAGS_DEBUG_STR}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE "${COMMON_C_FLAGS_RELEASE_STR}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${COMMON_C_FLAGS_STR} -fno-rtti -fno-exceptions -std=gnu++14" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG "${COMMON_C_FLAGS_DEBUG_STR}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE "${COMMON_C_FLAGS_RELEASE_STR}" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "${COMMON_LINK_FLAGS_STR} -Xlinker --gc-sections -Xlinker -Map=output.map" CACHE STRING "" FORCE)

function(add_executable_m7)
    set(oneValueArgs LINKER_SCRIPT M4_EXECUTABLE)
    set(multiValueArgs DATA)
    cmake_parse_arguments(ADD_EXECUTABLE_M7 "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(LINKER_SCRIPT "-T${VALIANT_SOURCE_DIR}/libs/nxp/rt1176-sdk/MIMXRT1176xxxxx_cm7_ram.ld")
    if (ADD_EXECUTABLE_M7_LINKER_SCRIPT)
        set(LINKER_SCRIPT "-T${ADD_EXECUTABLE_M7_LINKER_SCRIPT}")
    endif ()
    if (ADD_EXECUTABLE_M7_M4_EXECUTABLE)
        set(M4_EXECUTABLE "${ADD_EXECUTABLE_M7_M4_EXECUTABLE}.obj")
        file(GENERATE OUTPUT ${ARGV0}.m4_executable CONTENT "${ADD_EXECUTABLE_M7_M4_EXECUTABLE}")
    endif ()
    add_executable(${ADD_EXECUTABLE_M7_UNPARSED_ARGUMENTS} ${M4_EXECUTABLE})
    target_compile_options(${ARGV0} PUBLIC ${CM7_C_FLAGS})
    target_link_options(${ARGV0} PUBLIC ${CM7_LINK_FLAGS} ${LINKER_SCRIPT})
    add_custom_command(TARGET ${ARGV0} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ihex ${ARGV0} image.hex
        DEPENDS ${ARGV0}
    )
    add_custom_command(TARGET ${ARGV0} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O srec ${ARGV0} image.srec
        DEPENDS ${ARGV0}
    )
    add_custom_command(TARGET ${ARGV0} POST_BUILD
        COMMAND ${CMAKE_STRIP} -s ${ARGV0} -o ${ARGV0}.stripped
        DEPENDS ${ARGV0}
    )
    file(GENERATE OUTPUT ${ARGV0}.libs CONTENT "$<TARGET_PROPERTY:${ARGV0},LINK_LIBRARIES>")

    foreach (file IN LISTS ADD_EXECUTABLE_M7_DATA)
        string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/" "" STRIPPED_FILE ${file})
        string(REGEX REPLACE "^${VALIANT_PREFIX}/" "" STRIPPED_FILE ${STRIPPED_FILE})
        configure_file(${file} ${CMAKE_BINARY_DIR}/${STRIPPED_FILE} COPYONLY)
    endforeach()
    list(TRANSFORM ADD_EXECUTABLE_M7_DATA REPLACE "^${CMAKE_SOURCE_DIR}/" "")
    list(TRANSFORM ADD_EXECUTABLE_M7_DATA REPLACE "^${VALIANT_PREFIX}/" "")
    file(GENERATE OUTPUT ${ARGV0}.data CONTENT "${ADD_EXECUTABLE_M7_DATA}")
endfunction()

function(add_library_m7)
    set(multiValueArgs DATA)
    cmake_parse_arguments(ADD_LIBRARY_M7 "" "" "${multiValueArgs}" ${ARGN})
    add_library(${ADD_LIBRARY_M7_UNPARSED_ARGUMENTS})

    get_target_property(type ${ARGV0} TYPE)
    if (NOT ${type} STREQUAL "INTERFACE_LIBRARY")
        target_compile_options(${ARGV0} PUBLIC ${CM7_C_FLAGS})
        target_link_options(${ARGV0} PUBLIC ${CM7_LINK_FLAGS})
        file(GENERATE OUTPUT ${ARGV0}.libs CONTENT "$<TARGET_PROPERTY:${ARGV0},LINK_LIBRARIES>")
    endif()

    foreach (file IN LISTS ADD_LIBRARY_M7_DATA)
        string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/" "" STRIPPED_FILE ${file})
        string(REGEX REPLACE "^${VALIANT_PREFIX}/" "" STRIPPED_FILE ${STRIPPED_FILE})
        configure_file(${file} ${CMAKE_BINARY_DIR}/${STRIPPED_FILE} COPYONLY)
    endforeach()
    list(TRANSFORM ADD_LIBRARY_M7_DATA REPLACE "^${CMAKE_SOURCE_DIR}/" "")
    list(TRANSFORM ADD_LIBRARY_M7_DATA REPLACE "^${VALIANT_PREFIX}/" "")
    file(GENERATE OUTPUT ${ARGV0}.data CONTENT "${ADD_LIBRARY_M7_DATA}")
endfunction()

function(add_executable_m4)
    set(multiValueArgs DATA)
    cmake_parse_arguments(ADD_EXECUTABLE_M4 "" "" "${multiValueArgs}" ${ARGN})
    add_executable(${ADD_EXECUTABLE_M4_UNPARSED_ARGUMENTS})
    target_compile_options(${ARGV0} PUBLIC ${CM4_C_FLAGS})
    target_link_options(${ARGV0} PUBLIC ${CM4_LINK_FLAGS} "-T${VALIANT_SOURCE_DIR}/libs/nxp/rt1176-sdk/MIMXRT1176xxxxx_cm4_ram.ld")
    string(REGEX REPLACE "-" "_" ARGV0_UNDERSCORED ${ARGV0})
    add_custom_command(TARGET ${ARGV0} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O binary ${ARGV0} ${ARGV0}.bin
        COMMAND ${CMAKE_OBJCOPY}
            -I binary
            --rename-section .data=.core1_code
            -O elf32-littlearm
            --redefine-sym _binary_${ARGV0_UNDERSCORED}_bin_start=m4_binary_start
            --redefine-sym _binary_${ARGV0_UNDERSCORED}_bin_end=m4_binary_end
            --redefine-sym _binary_${ARGV0_UNDERSCORED}_bin_size=m4_binary_size
            ${ARGV0}.bin ${ARGV0}.obj
        DEPENDS ${ARGV0}
        BYPRODUCTS ${ARGV0}.bin ${ARGV0}.obj
    )
    add_custom_command(OUTPUT ${ARGV0}.obj
        DEPENDS ${ARGV0}
    )
    file(GENERATE OUTPUT ${ARGV0}.libs CONTENT "$<TARGET_PROPERTY:${ARGV0},LINK_LIBRARIES>")

    foreach (file IN LISTS ADD_EXECUTABLE_M4_DATA)
        string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/" "" STRIPPED_FILE ${file})
        string(REGEX REPLACE "^${VALIANT_PREFIX}/" "" STRIPPED_FILE ${STRIPPED_FILE})
        configure_file(${file} ${CMAKE_BINARY_DIR}/${STRIPPED_FILE} COPYONLY)
    endforeach()
    list(TRANSFORM ADD_EXECUTABLE_M4_DATA REPLACE "^${CMAKE_SOURCE_DIR}/" "")
    list(TRANSFORM ADD_EXECUTABLE_M4_DATA REPLACE "^${VALIANT_PREFIX}/" "")
    file(GENERATE OUTPUT ${ARGV0}.data CONTENT "${ADD_EXECUTABLE_M4_DATA}")
endfunction()

function(add_library_m4)
    set(multiValueArgs DATA)
    cmake_parse_arguments(ADD_LIBRARY_M4 "" "" "${multiValueArgs}" ${ARGN})
    add_library(${ADD_LIBRARY_M4_UNPARSED_ARGUMENTS})

    get_target_property(type ${ARGV0} TYPE)
    if (NOT ${type} STREQUAL "INTERFACE_LIBRARY")
        target_compile_options(${ARGV0} PUBLIC ${CM4_C_FLAGS})
        target_link_options(${ARGV0} PUBLIC ${CM4_LINK_FLAGS})
        file(GENERATE OUTPUT ${ARGV0}.libs CONTENT "$<TARGET_PROPERTY:${ARGV0},LINK_LIBRARIES>")
    endif()

    foreach (file IN LISTS ADD_LIBRARY_M4_DATA)
        string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/" "" STRIPPED_FILE ${file})
        string(REGEX REPLACE "^${VALIANT_PREFIX}/" "" STRIPPED_FILE ${STRIPPED_FILE})
        configure_file(${file} ${CMAKE_BINARY_DIR}/${STRIPPED_FILE} COPYONLY)
    endforeach()
    list(TRANSFORM ADD_LIBRARY_M4_DATA REPLACE "^${CMAKE_SOURCE_DIR}/" "")
    list(TRANSFORM ADD_LIBRARY_M4_DATA REPLACE "^${VALIANT_PREFIX}/" "")
    file(GENERATE OUTPUT ${ARGV0}.data CONTENT "${ADD_LIBRARY_M4_DATA}")
endfunction()
