#include <string.h>

#include "lauxlib.h"
#include "lua.h"

#define VARIANT_STANDARD 0
#define VARIANT_URL_SAFE 1

#define INV 0xff
#define PAD 0xfe

static const char enc_standard[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const char enc_urlsafe[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

/* clang-format off */
static const unsigned char dec_standard[256] = {
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0x00 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0x10 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, 62,INV,INV,INV, 63, /* 0x20 */
   52, 53, 54, 55, 56, 57, 58, 59, 60, 61,INV,INV,INV,PAD,INV,INV, /* 0x30 */
  INV,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, /* 0x40 */
   15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,INV,INV,INV,INV,INV, /* 0x50 */
  INV, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, /* 0x60 */
   41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,INV,INV,INV,INV,INV, /* 0x70 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0x80 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0x90 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xa0 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xb0 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xc0 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xd0 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xe0 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xf0 */
};

static const unsigned char dec_urlsafe[256] = {
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0x00 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0x10 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, 62,INV,INV, /* 0x20 */
   52, 53, 54, 55, 56, 57, 58, 59, 60, 61,INV,INV,INV,PAD,INV,INV, /* 0x30 */
  INV,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, /* 0x40 */
   15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,INV,INV,INV,INV, 63, /* 0x50 */
  INV, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, /* 0x60 */
   41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,INV,INV,INV,INV,INV, /* 0x70 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0x80 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0x90 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xa0 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xb0 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xc0 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xd0 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xe0 */
  INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV,INV, /* 0xf0 */
};
/* clang-format on */

static const char encode_usage[] =
    "Usage: local output = C_EncodingUtil.EncodeBase64(source [, variant])";
static const char decode_usage[] =
    "Usage: local output = C_EncodingUtil.DecodeBase64(source [, variant])";

static int encodingutil_EncodeBase64(lua_State *L) {
  size_t srclen;
  const char *src = lua_tolstring(L, 1, &srclen);
  if (!src) {
    return luaL_argerror(L, 1, encode_usage);
  }
  int variant = (int)luaL_optnumber(L, 2, VARIANT_STANDARD);
  if (variant != VARIANT_STANDARD && variant != VARIANT_URL_SAFE) {
    return luaL_argerror(L, 2, encode_usage);
  }
  const char *alpha = variant == VARIANT_URL_SAFE ? enc_urlsafe : enc_standard;
  size_t outlen = ((srclen + 2) / 3) * 4;
  char *out = lua_newuserdata(L, outlen ? outlen : 1);
  size_t i = 0, o = 0;
  while (i + 3 <= srclen) {
    unsigned int b = ((unsigned char)src[i] << 16) |
                     ((unsigned char)src[i + 1] << 8) |
                     (unsigned char)src[i + 2];
    out[o++] = alpha[(b >> 18) & 0x3f];
    out[o++] = alpha[(b >> 12) & 0x3f];
    out[o++] = alpha[(b >> 6) & 0x3f];
    out[o++] = alpha[b & 0x3f];
    i += 3;
  }
  if (srclen - i == 1) {
    unsigned int b = (unsigned char)src[i] << 16;
    out[o++] = alpha[(b >> 18) & 0x3f];
    out[o++] = alpha[(b >> 12) & 0x3f];
    out[o++] = '=';
    out[o++] = '=';
  } else if (srclen - i == 2) {
    unsigned int b =
        ((unsigned char)src[i] << 16) | ((unsigned char)src[i + 1] << 8);
    out[o++] = alpha[(b >> 18) & 0x3f];
    out[o++] = alpha[(b >> 12) & 0x3f];
    out[o++] = alpha[(b >> 6) & 0x3f];
    out[o++] = '=';
  }
  lua_pushlstring(L, out, o);
  return 1;
}

static int encodingutil_DecodeBase64(lua_State *L) {
  size_t srclen;
  const char *src = lua_tolstring(L, 1, &srclen);
  if (!src) {
    return luaL_argerror(L, 1, decode_usage);
  }
  int variant = (int)luaL_optnumber(L, 2, VARIANT_STANDARD);
  if (variant != VARIANT_STANDARD && variant != VARIANT_URL_SAFE) {
    return luaL_argerror(L, 2, decode_usage);
  }
  const unsigned char *dec =
      variant == VARIANT_URL_SAFE ? dec_urlsafe : dec_standard;
  size_t outlen = (srclen / 4) * 3 + 3;
  char *out = lua_newuserdata(L, outlen);
  if (srclen % 4 != 0) {
    lua_pushliteral(L, "");
    return 1;
  }
  size_t o = 0;
  size_t i = 0;
  size_t blocks = srclen / 4;
  for (size_t b = 0; b < blocks; b++, i += 4) {
    unsigned char c[4];
    for (int j = 0; j < 4; j++) {
      c[j] = dec[(unsigned char)src[i + j]];
    }
    if (c[0] == INV || c[1] == INV || c[2] == INV || c[3] == INV ||
        c[0] == PAD || c[1] == PAD) {
      lua_pushliteral(L, "");
      return 1;
    }
    unsigned int v = ((unsigned int)c[0] << 18) | ((unsigned int)c[1] << 12);
    out[o++] = (char)(v >> 16);
    if (c[2] != PAD) {
      v |= (unsigned int)c[2] << 6;
      out[o++] = (char)((v >> 8) & 0xff);
      if (c[3] != PAD) {
        v |= c[3];
        out[o++] = (char)(v & 0xff);
      }
    }
  }
  lua_pushlstring(L, out, o);
  return 1;
}

static int make_module(lua_State *L) {
  lua_newtable(L);
  lua_pushcfunction(L, encodingutil_EncodeBase64);
  lua_setfield(L, -2, "C_EncodingUtil.EncodeBase64");
  lua_pushcfunction(L, encodingutil_DecodeBase64);
  lua_setfield(L, -2, "C_EncodingUtil.DecodeBase64");
  return 1;
}

int luaopen_wowless_modules_encodingutil(lua_State *L) {
  lua_pushcfunction(L, make_module);
  return 1;
}
