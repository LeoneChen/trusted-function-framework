#include "kafl_hc.h"
#include <string>

#include "./sgx_trts.h"

#include "tee/common/error.h"
#include "tee/common/type.h"

#include "./kubetee_t.h"

#ifdef __cplusplus
extern "C" {
#endif

TeeErrorCode ecall_GetRand(uint8_t* rand, uint32_t len) {
    LogEnter(__func__);
  return TEE_ERROR_CODE(sgx_read_rand(rand, len));
}

#ifdef __cplusplus
}
#endif
