list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
find_package(Protobuf REQUIRED)

file(GLOB COMMON_SRCS ${TOP_SRC_DIR}/common/*.cpp)
file(GLOB UTILS_SRCS ${TOP_SRC_DIR}/untrusted/utils/*.cpp)
file(GLOB CHALLENGER_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
file(GLOB PROTO_FILES ${TEE_TOP_DIR}/proto/*.proto)
PROTOBUF_GENERATE_CPP(PROTO_SRCS PROTO_HDRS ${CMAKE_BINARY_DIR}/uproto ${PROTO_FILES})

set(C_SRCS
    ${COMMON_SRCS}
    ${UTILS_SRCS}
    ${CHALLENGER_SRCS}
    ${TOP_SRC_DIR/untrusted/ra/untrusted_config.cpp}
    ${PROTO_HDRS}
)

add_library(challenger SHARED ${C_SRCS})
if(NOT KAFL_FUZZER)
set_target_properties(challenger PROPERTIES COMPILE_FLAGS "-fsanitize-coverage=inline-8bit-counters,bb,no-prune,pc-table,trace-cmp -fprofile-instr-generate -fcoverage-mapping")
endif()
target_include_directories(
    challenger PUBLIC
    ${TOP_SRC_DIR}
    ${TOP_SRC_DIR}/include
    ${TOP_SRC_DIR}/include/tee
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/uproto
    ${CMAKE_CURRENT_BINARY_DIR}
    ${SGX_INCLUDE_DIR}
    /usr/include/openssl/../
    ${TEE_TOP_DIR}/third_party/cppcodec
    ${TEE_TOP_DIR}/third_party/rapidjson/include
)
