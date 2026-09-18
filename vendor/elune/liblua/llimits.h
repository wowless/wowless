/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#ifndef llimits_h
#define llimits_h

#include "lua.h"

#include <limits.h>
#include <math.h>
#include <stddef.h>
#include <stdint.h>

/* Chars used as small naturals (so that `char' is reserved for characters). */
typedef unsigned char lu_byte;

/* Type to ensure maximum alignment. */
typedef struct {
    LUA_NUMBER d;
    void *p;
    LUA_INTEGER i;
} L_Umaxalign;

/* Result of a `usual argument conversion' over lua_Number. */
typedef LUAI_UACNUMBER l_uacNumber;

/* Type used for VM instructions. Must be an unsigned with (at least) 4 bytes;
 * see details in lopcodes.h. */
typedef uint_least32_t Instruction;

/* Integer maximums; these are subtracted for safety per original defines. */

#define LUA_SIZE_MAX ((size_t) (SIZE_MAX - 2))
#define LUA_PTRDIFF_MAX ((size_t) (PTRDIFF_MAX - 2))
#define LUA_INT_MAX ((int) (INT_MAX - 2))

/* Maximum stack for a Lua function */
#define LUAI_MAXSTACK 250
/* Minimum size for the string table (must be power of 2) */
#define LUAI_MINSTRTABSIZE 32
/* Minimum size for string buffer */
#define LUAI_MINBUFFER 32

/* Numeric operations */

#define luai_numadd(a, b) ((a) + (b))
#define luai_numsub(a, b) ((a) - (b))
#define luai_nummul(a, b) ((a) * (b))
#define luai_numdiv(a, b) ((a) / (b))
#define luai_nummod(a, b) ((a) -floor((a) / (b)) * (b))
#define luai_numpow(a, b) (pow(a, b))
#define luai_numunm(a) (-(a))
#define luai_numeq(a, b) ((a) == (b))
#define luai_numlt(a, b) ((a) < (b))
#define luai_numle(a, b) ((a) <= (b))
#define luai_numisnan(a) (fpclassify(a) == FP_NAN)

/* Lua state synchronization */

#define lua_lock(L) lua_nop()
#define lua_unlock(L) lua_nop()

#define luai_userstateopen(L) lua_unused((L))
#define luai_userstateclose(L) lua_unused((L))
#define luai_userstatethread(L, L1)                                                                                    \
    {                                                                                                                  \
        lua_unused((L));                                                                                               \
        lua_unused((L1));                                                                                              \
    }
#define luai_userstatefree(L) lua_unused((L))
#define luai_userstateresume(L, n)                                                                                     \
    {                                                                                                                  \
        lua_unused((L));                                                                                               \
        lua_unused((n));                                                                                               \
    }
#define luai_userstateyield(L, n)                                                                                      \
    {                                                                                                                  \
        lua_unused((L));                                                                                               \
        lua_unused((n));                                                                                               \
    }

#define luai_threadyield(L)                                                                                            \
    {                                                                                                                  \
        lua_unlock(L);                                                                                                 \
        lua_lock(L);                                                                                                   \
    }

/* Stack reallocation tests */
#ifndef HARDSTACKTESTS
#define condhardstacktests(x) lua_nop()
#else
#define condhardstacktests(x) x
#endif

/*
** conversion of pointer to integer
** this is for hashing only; there is no problem if the integer
** cannot hold the whole pointer value
*/
#define IntPoint(p) ((unsigned int) (size_t) (p))

/* internal assertions for in-house debugging */
#define check_exp(c, e) (e)
#define api_check luai_apicheck

#ifndef cast
#define cast(t, exp) ((t) (exp))
#endif
#define cast_byte(i) cast(lu_byte, (i))
#define cast_num(i) cast(lua_Number, (i))
#define cast_int(i) cast(int, (i))

#endif
