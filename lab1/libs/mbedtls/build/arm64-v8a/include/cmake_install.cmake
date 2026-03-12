# Install script for directory: /Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "TRUE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/Users/aleksandrpalkin/Library/Android/sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/mbedtls" TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/aes.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/aria.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/asn1.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/asn1write.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/base64.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/bignum.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/block_cipher.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/build_info.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/camellia.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ccm.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/chacha20.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/chachapoly.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/check_config.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/cipher.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/cmac.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/compat-2.x.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/config_adjust_legacy_crypto.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/config_adjust_legacy_from_psa.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/config_adjust_psa_from_legacy.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/config_adjust_psa_superset_legacy.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/config_adjust_ssl.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/config_adjust_x509.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/config_psa.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/constant_time.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ctr_drbg.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/debug.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/des.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/dhm.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ecdh.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ecdsa.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ecjpake.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ecp.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/entropy.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/error.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/gcm.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/hkdf.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/hmac_drbg.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/lms.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/mbedtls_config.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/md.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/md5.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/memory_buffer_alloc.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/net_sockets.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/nist_kw.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/oid.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/pem.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/pk.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/pkcs12.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/pkcs5.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/pkcs7.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/platform.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/platform_time.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/platform_util.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/poly1305.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/private_access.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/psa_util.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ripemd160.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/rsa.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/sha1.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/sha256.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/sha3.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/sha512.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ssl.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ssl_cache.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ssl_ciphersuites.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ssl_cookie.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/ssl_ticket.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/threading.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/timing.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/version.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/x509.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/x509_crl.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/x509_crt.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/mbedtls/x509_csr.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/psa" TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/build_info.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_adjust_auto_enabled.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_adjust_config_dependencies.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_adjust_config_key_pair_types.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_adjust_config_synonyms.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_builtin_composites.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_builtin_key_derivation.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_builtin_primitives.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_compat.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_config.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_driver_common.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_driver_contexts_composites.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_driver_contexts_key_derivation.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_driver_contexts_primitives.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_extra.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_legacy.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_platform.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_se_driver.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_sizes.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_struct.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_types.h"
    "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/mbedtls/include/psa/crypto_values.h"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/aleksandrpalkin/AndroidStudioProjects/libs/mbedtls/build/arm64-v8a/include/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
