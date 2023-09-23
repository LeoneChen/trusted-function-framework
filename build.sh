#!/usr/bin/env bash

THISDIR="$(dirname $0)"
BUILDDIR="$THISDIR/build"

OPT_BUILD_MODE=PreRelease
OPT_SGX_HW_MODE=HW
OPT_VERBOSE=0
OPT_WITHOUT_LOG=0
OPT_WITH_SAMPLES=0


EXIT_ERROR() {
    echo "$@" >&2
    exit 1
}

do_clean() {
    echo "remove $BUILDDIR ..."
    rm -rf $BUILDDIR
}

do_compile() {
    local sgx_build_mode=${1:-"Debug"}
    local sgx_hw_mode=${2:-"HW"}
    local sgx_hw="ON"
    local build_samples="OFF"
    local feature_la="OFF"
    local without_log="OFF"
    local verbose_opt=""

    [ "$sgx_hw_mode" != "HW" ] && sgx_hw="OFF"
    [ "$OPT_VERBOSE" -eq 1 ] && verbose_opt="VERBOSE=1"
    [ "$OPT_WITHOUT_LOG" -eq 1 ] && without_log="ON"
    [ "$OPT_WITH_SAMPLES" -eq 1 ] && build_samples="ON"

    mkdir -p $BUILDDIR && cd $BUILDDIR && \
    cmake -DSGX_HW=$sgx_hw \
          -DSGX_MODE=$sgx_build_mode \
          -DBUILD_SAMPLES=$build_samples \
          -DWITHOUT_LOG=$without_log \
          ../ && \
    make $verbose_opt -j$(nproc)
}

show_help() {
    cat <<EOF
Usage: ${0} [options]

Options:
    --build         Specify the build types in Debug|PreRelease|Release
                    The default build type is ${OPT_BUILD_MODE}
    --mode          Specify the SGX mode in SIM/HW, default mode is ${OPT_SGX_HW_MODE}.
    --clean         Clean all build stuffs
    --without-log   Disable all log messages
    -v              Show gcc command in detail when build
    -h|--help       Show this help menu
EOF
}

ARGS=`getopt -o vh -l help,clean,build:,mode:,without-log,with-samples -- "$@"`
[ $? != 0 ] && EXIT_ERROR "Invalid Arguments ..."
eval set -- "$ARGS"
while true ; do
    case "$1" in
        -h|--help)      show_help ; exit 0 ;;
        -v)             OPT_VERBOSE=1 ;        shift 1 ;;
        --build)        OPT_BUILD_MODE="$2" ;  shift 2 ;;
        --mode)         OPT_SGX_HW_MODE="$2" ; shift 2 ;;
        --clean)        OPT_DO_CLEAN=1 ;       shift 1 ;;
        --with-samples) OPT_WITH_SAMPLES=1 ;   shift 1 ;;
        --without-log)  OPT_WITHOUT_LOG=1 ;    shift 1 ;;
        --)             shift ; break ;;
        *)              EXIT_ERROR "Internal error!" ;;
    esac
done

if [ "$OPT_DO_CLEAN" == 1 ] ; then
    do_clean
else
    do_compile "$OPT_BUILD_MODE" "$OPT_SGX_HW_MODE"
fi
exit $?
# ~/SGXSan/Tool/GetLayout.sh -d build/enclave_service CMakeFiles/enclave_service.dir/trusted/trusted_enclave_service.cpp.o CMakeFiles/enclave_service.dir/__/tproto/enclave_service.pb.cc.o CMakeFiles/enclave_service-edlobj.dir/enclave_service_t.c.o /mnt/hdd/sgx-evaluate/sgxfuzz/Enclaves/trusted-function-framework/build/out/libtkubetee.a /mnt/hdd/sgx-evaluate/sgxfuzz/Enclaves/trusted-function-framework/build/out/libtprotobuf.a /opt/intel/sgxsdk/lib64/libsgx_tstdc.a /opt/intel/sgxsdk/lib64/libsgx_tcxx.a /opt/intel/sgxsdk/lib64/libsgx_tkey_exchange.a /opt/intel/sgxsdk/lib64/libsgx_tcrypto.a /opt/intel/sgxsdk/lib64/libsgx_tservice.a /opt/intel/sgxsdk/lib64/libsgx_pthread.a /opt/intel/sgxssl/lib64/libsgx_tsgxssl_crypto.a /opt/intel/sgxsdk/lib64/libsgx_trts.a /opt/intel/sgxssl/lib64/libsgx_tsgxssl.a
