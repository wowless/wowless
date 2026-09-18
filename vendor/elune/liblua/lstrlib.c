/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#include <ctype.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <utf8.h>

#define lstrlib_c
#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

/* macro to `unsign' a character */
#define uchar(c) ((unsigned char) (c))

static int str_len (lua_State *L) {
    size_t l;
    luaL_checklstring(L, 1, &l);
    lua_pushinteger(L, l);
    return 1;
}

static ptrdiff_t posrelat (ptrdiff_t pos, size_t len) {
    /* relative string position: negative means back from end */
    if (pos < 0) {
        pos += (ptrdiff_t) len + 1;
    }
    return (pos >= 0) ? pos : 0;
}

static int str_sub (lua_State *L) {
    size_t l;
    const char *s = luaL_checklstring(L, 1, &l);
    ptrdiff_t start = posrelat(luaL_checkinteger(L, 2), l);
    ptrdiff_t end = posrelat(luaL_optinteger(L, 3, -1), l);
    if (start < 1) {
        start = 1;
    }
    if (end > (ptrdiff_t) l) {
        end = (ptrdiff_t) l;
    }
    if (start <= end) {
        lua_pushlstring(L, s + start - 1, end - start + 1);
    } else {
        lua_pushliteral(L, "");
    }
    return 1;
}

static int str_reverse (lua_State *L) {
    size_t l;
    luaL_Buffer b;
    const char *s = luaL_checklstring(L, 1, &l);
    luaL_buffinit(L, &b);
    while (l--) {
        luaL_addchar(&b, s[l]);
    }
    luaL_pushresult(&b);
    return 1;
}

static int str_lower (lua_State *L) {
    size_t l;
    size_t i;
    luaL_Buffer b;
    const char *s = luaL_checklstring(L, 1, &l);
    luaL_buffinit(L, &b);
    for (i = 0; i < l; i++) {
        luaL_addchar(&b, tolower(uchar(s[i])));
    }
    luaL_pushresult(&b);
    return 1;
}

static int str_upper (lua_State *L) {
    size_t l;
    size_t i;
    luaL_Buffer b;
    const char *s = luaL_checklstring(L, 1, &l);
    luaL_buffinit(L, &b);
    for (i = 0; i < l; i++) {
        luaL_addchar(&b, toupper(uchar(s[i])));
    }
    luaL_pushresult(&b);
    return 1;
}

static int str_rep (lua_State *L) {
    size_t l;
    luaL_Buffer b;
    const char *s = luaL_checklstring(L, 1, &l);
    int n = luaL_checkint(L, 2);
    luaL_buffinit(L, &b);
    while (n-- > 0) {
        luaL_addlstring(&b, s, l);
    }
    luaL_pushresult(&b);
    return 1;
}

static int str_byte (lua_State *L) {
    size_t l;
    const char *s = luaL_checklstring(L, 1, &l);
    ptrdiff_t posi = posrelat(luaL_optinteger(L, 2, 1), l);
    ptrdiff_t pose = posrelat(luaL_optinteger(L, 3, posi), l);
    int n;
    int i;
    if (posi <= 0) {
        posi = 1;
    }
    if ((size_t) pose > l) {
        pose = l;
    }
    if (posi > pose) {
        return 0; /* empty interval; return no values */
    }
    n = (int) (pose - posi + 1);
    if (posi + n <= pose) { /* overflow? */
        luaL_error(L, "string slice too long");
    }
    luaL_checkstack(L, n, "string slice too long");
    for (i = 0; i < n; i++) {
        lua_pushinteger(L, uchar(s[posi + i - 1]));
    }
    return n;
}

static int str_char (lua_State *L) {
    int n = lua_gettop(L); /* number of arguments */
    int i;
    luaL_Buffer b;
    luaL_buffinit(L, &b);
    for (i = 1; i <= n; i++) {
        int c = luaL_checkint(L, i);
        luaL_argcheck(L, uchar(c) == c, i, "invalid value");
        luaL_addchar(&b, uchar(c));
    }
    luaL_pushresult(&b);
    return 1;
}

static int writer (lua_State *L, const void *b, size_t size, void *B) {
    (void) L;
    luaL_addlstring((luaL_Buffer *) B, (const char *) b, size);
    return 0;
}

static int str_dump (lua_State *L) {
    luaL_Buffer b;
    luaL_checktype(L, 1, LUA_TFUNCTION);
    lua_settop(L, 1);
    luaL_buffinit(L, &b);
    if (lua_dump(L, writer, &b) != 0) {
        luaL_error(L, "unable to dump given function");
    }
    luaL_pushresult(&b);
    return 1;
}

/*
** {======================================================
** PATTERN MATCHING
** =======================================================
*/

#define CAP_UNFINISHED (-1)
#define CAP_POSITION (-2)

typedef struct MatchState {
    const char *src_init; /* init of source string */
    const char *src_end; /* end (`\0') of source string */
    lua_State *L;
    int level; /* total number of captures (finished or unfinished) */
    struct {
        const char *init;
        ptrdiff_t len;
    } capture[LUA_MAXCAPTURES];
} MatchState;

#define L_ESC '%'
#define SPECIALS "^$*+?.([%-"

static int check_capture (MatchState *ms, int l) {
    l -= '1';
    if (l < 0 || l >= ms->level || ms->capture[l].len == CAP_UNFINISHED) {
        return luaL_error(ms->L, "invalid capture index");
    }
    return l;
}

static int capture_to_close (MatchState *ms) {
    int level = ms->level;
    for (level--; level >= 0; level--) {
        if (ms->capture[level].len == CAP_UNFINISHED) {
            return level;
        }
    }
    return luaL_error(ms->L, "invalid pattern capture");
}

static const char *classend (MatchState *ms, const char *p) {
    switch (*p++) {
        case L_ESC: {
            if (*p == '\0') {
                luaL_error(ms->L, "malformed pattern (ends with '%%')");
            }
            return p + 1;
        }
        case '[': {
            if (*p == '^') {
                p++;
            }
            do { /* look for a `]' */
                if (*p == '\0') {
                    luaL_error(ms->L, "malformed pattern (missing ']')");
                }
                if (*(p++) == L_ESC && *p != '\0') {
                    p++; /* skip escapes (e.g. `%]') */
                }
            } while (*p != ']');
            return p + 1;
        }
        default: {
            return p;
        }
    }
}

static int match_class (int c, int cl) {
    int res;
    switch (tolower(cl)) {
        case 'a':
            res = isalpha(c);
            break;
        case 'c':
            res = iscntrl(c);
            break;
        case 'd':
            res = isdigit(c);
            break;
        case 'l':
            res = islower(c);
            break;
        case 'p':
            res = ispunct(c);
            break;
        case 's':
            res = isspace(c);
            break;
        case 'u':
            res = isupper(c);
            break;
        case 'w':
            res = isalnum(c);
            break;
        case 'x':
            res = isxdigit(c);
            break;
        case 'z':
            res = (c == 0);
            break;
        default:
            return (cl == c);
    }
    return (islower(cl) ? res : !res);
}

static int matchbracketclass (int c, const char *p, const char *ec) {
    int sig = 1;
    if (*(p + 1) == '^') {
        sig = 0;
        p++; /* skip the `^' */
    }
    while (++p < ec) {
        if (*p == L_ESC) {
            p++;
            if (match_class(c, uchar(*p))) {
                return sig;
            }
        } else if ((*(p + 1) == '-') && (p + 2 < ec)) {
            p += 2;
            if (uchar(*(p - 2)) <= c && c <= uchar(*p)) {
                return sig;
            }
        } else if (uchar(*p) == c) {
            return sig;
        }
    }
    return !sig;
}

static int singlematch (int c, const char *p, const char *ep) {
    switch (*p) {
        case '.':
            return 1; /* matches any char */
        case L_ESC:
            return match_class(c, uchar(*(p + 1)));
        case '[':
            return matchbracketclass(c, p, ep - 1);
        default:
            return (uchar(*p) == c);
    }
}

static const char *match (MatchState *ms, const char *s, const char *p);

static const char *matchbalance (MatchState *ms, const char *s, const char *p) {
    if (*p == 0 || *(p + 1) == 0) {
        luaL_error(ms->L, "unbalanced pattern");
    }
    if (*s != *p) {
        return NULL;
    } else {
        int b = *p;
        int e = *(p + 1);
        int cont = 1;
        while (++s < ms->src_end) {
            if (*s == e) {
                if (--cont == 0) {
                    return s + 1;
                }
            } else if (*s == b) {
                cont++;
            }
        }
    }
    return NULL; /* string ends out of balance */
}

static const char *max_expand (MatchState *ms, const char *s, const char *p, const char *ep) {
    ptrdiff_t i = 0; /* counts maximum expand for item */
    while ((s + i) < ms->src_end && singlematch(uchar(*(s + i)), p, ep)) {
        i++;
    }
    /* keeps trying to match with the maximum repetitions */
    while (i >= 0) {
        const char *res = match(ms, (s + i), ep + 1);
        if (res) {
            return res;
        }
        i--; /* else didn't match; reduce 1 repetition to try again */
    }
    return NULL;
}

static const char *min_expand (MatchState *ms, const char *s, const char *p, const char *ep) {
    for (;;) {
        const char *res = match(ms, s, ep + 1);
        if (res != NULL) {
            return res;
        } else if (s < ms->src_end && singlematch(uchar(*s), p, ep)) {
            s++; /* try with one more repetition */
        } else {
            return NULL;
        }
    }
}

static const char *start_capture (MatchState *ms, const char *s, const char *p, int what) {
    const char *res;
    int level = ms->level;
    if (level >= LUA_MAXCAPTURES) {
        luaL_error(ms->L, "too many captures");
    }
    ms->capture[level].init = s;
    ms->capture[level].len = what;
    ms->level = level + 1;
    if ((res = match(ms, s, p)) == NULL) { /* match failed? */
        ms->level--; /* undo capture */
    }
    return res;
}

static const char *end_capture (MatchState *ms, const char *s, const char *p) {
    int l = capture_to_close(ms);
    const char *res;
    ms->capture[l].len = s - ms->capture[l].init; /* close capture */
    if ((res = match(ms, s, p)) == NULL) { /* match failed? */
        ms->capture[l].len = CAP_UNFINISHED; /* undo capture */
    }
    return res;
}

static const char *match_capture (MatchState *ms, const char *s, int l) {
    size_t len;
    l = check_capture(ms, l);
    len = ms->capture[l].len;
    if ((size_t) (ms->src_end - s) >= len && memcmp(ms->capture[l].init, s, len) == 0) {
        return s + len;
    } else {
        return NULL;
    }
}

static const char *match (MatchState *ms, const char *s, const char *p) {
init: /* using goto's to optimize tail recursion */
    switch (*p) {
        case '(': { /* start capture */
            if (*(p + 1) == ')') { /* position capture? */
                return start_capture(ms, s, p + 2, CAP_POSITION);
            } else {
                return start_capture(ms, s, p + 1, CAP_UNFINISHED);
            }
        }
        case ')': { /* end capture */
            return end_capture(ms, s, p + 1);
        }
        case L_ESC: {
            switch (*(p + 1)) {
                case 'b': { /* balanced string? */
                    s = matchbalance(ms, s, p + 2);
                    if (s == NULL) {
                        return NULL;
                    }
                    p += 4;
                    goto init; /* else return match(ms, s, p+4); */
                }
                case 'f': { /* frontier? */
                    const char *ep;
                    char previous;
                    p += 2;
                    if (*p != '[') {
                        luaL_error(ms->L, "missing '[' after '%%f' in pattern");
                    }
                    ep = classend(ms, p); /* points to what is next */
                    previous = (s == ms->src_init) ? '\0' : *(s - 1);
                    if (matchbracketclass(uchar(previous), p, ep - 1) || !matchbracketclass(uchar(*s), p, ep - 1)) {
                        return NULL;
                    }
                    p = ep;
                    goto init; /* else return match(ms, s, ep); */
                }
                default: {
                    if (isdigit(uchar(*(p + 1)))) { /* capture results (%0-%9)? */
                        s = match_capture(ms, s, uchar(*(p + 1)));
                        if (s == NULL) {
                            return NULL;
                        }
                        p += 2;
                        goto init; /* else return match(ms, s, p+2) */
                    }
                    goto dflt; /* case default */
                }
            }
        }
        case '\0': { /* end of pattern */
            return s; /* match succeeded */
        }
        case '$': {
            if (*(p + 1) == '\0') { /* is the `$' the last char in pattern? */
                return (s == ms->src_end) ? s : NULL; /* check end of string */
            } else {
                goto dflt;
            }
        }
        default:
        dflt : { /* it is a pattern item */
            const char *ep = classend(ms, p); /* points to what is next */
            int m = s < ms->src_end && singlematch(uchar(*s), p, ep);
            switch (*ep) {
                case '?': { /* optional */
                    const char *res;
                    if (m && ((res = match(ms, s + 1, ep + 1)) != NULL)) {
                        return res;
                    }
                    p = ep + 1;
                    goto init; /* else return match(ms, s, ep+1); */
                }
                case '*': { /* 0 or more repetitions */
                    return max_expand(ms, s, p, ep);
                }
                case '+': { /* 1 or more repetitions */
                    return (m ? max_expand(ms, s + 1, p, ep) : NULL);
                }
                case '-': { /* 0 or more repetitions (minimum) */
                    return min_expand(ms, s, p, ep);
                }
                default: {
                    if (!m) {
                        return NULL;
                    }
                    s++;
                    p = ep;
                    goto init; /* else return match(ms, s+1, ep); */
                }
            }
        }
    }
}

static const char *lmemfind (const char *s1, size_t l1, const char *s2, size_t l2) {
    if (l2 == 0) {
        return s1; /* empty strings are everywhere */
    } else if (l2 > l1) {
        return NULL; /* avoids a negative `l1' */
    } else {
        const char *init; /* to search for a `*s2' inside `s1' */
        l2--; /* 1st char will be checked by `memchr' */
        l1 = l1 - l2; /* `s2' cannot be found after that */
        while (l1 > 0 && (init = (const char *) memchr(s1, *s2, l1)) != NULL) {
            init++; /* 1st char is already checked */
            if (memcmp(init, s2 + 1, l2) == 0) {
                return init - 1;
            } else { /* correct `l1' and `s1' to try again */
                l1 -= init - s1;
                s1 = init;
            }
        }
        return NULL; /* not found */
    }
}

static void push_onecapture (MatchState *ms, int i, const char *s, const char *e) {
    if (i >= ms->level) {
        if (i == 0) { /* ms->level == 0, too */
            lua_pushlstring(ms->L, s, e - s); /* add whole match */
        } else {
            luaL_error(ms->L, "invalid capture index");
        }
    } else {
        ptrdiff_t l = ms->capture[i].len;
        if (l == CAP_UNFINISHED) {
            luaL_error(ms->L, "unfinished capture");
        }
        if (l == CAP_POSITION) {
            lua_pushinteger(ms->L, ms->capture[i].init - ms->src_init + 1);
        } else {
            lua_pushlstring(ms->L, ms->capture[i].init, l);
        }
    }
}

static int push_captures (MatchState *ms, const char *s, const char *e) {
    int i;
    int nlevels = (ms->level == 0 && s) ? 1 : ms->level;
    luaL_checkstack(ms->L, nlevels, "too many captures");
    for (i = 0; i < nlevels; i++) {
        push_onecapture(ms, i, s, e);
    }
    return nlevels; /* number of strings pushed */
}

static int str_find_aux (lua_State *L, int find) {
    size_t l1;
    size_t l2;
    const char *s = luaL_checklstring(L, 1, &l1);
    const char *p = luaL_checklstring(L, 2, &l2);
    ptrdiff_t init = posrelat(luaL_optinteger(L, 3, 1), l1) - 1;
    if (init < 0) {
        init = 0;
    } else if ((size_t) (init) > l1) {
        init = (ptrdiff_t) l1;
    }
    if (find && (lua_toboolean(L, 4) || /* explicit request? */
                 strpbrk(p, SPECIALS) == NULL)) { /* or no special characters? */
        /* do a plain search */
        const char *s2 = lmemfind(s + init, l1 - init, p, l2);
        if (s2) {
            lua_pushinteger(L, s2 - s + 1);
            lua_pushinteger(L, s2 - s + l2);
            return 2;
        }
    } else {
        MatchState ms;
        int anchor = (*p == '^') ? (p++, 1) : 0;
        const char *s1 = s + init;
        ms.L = L;
        ms.src_init = s;
        ms.src_end = s + l1;
        do {
            const char *res;
            ms.level = 0;
            if ((res = match(&ms, s1, p)) != NULL) {
                if (find) {
                    lua_pushinteger(L, s1 - s + 1); /* start */
                    lua_pushinteger(L, res - s); /* end */
                    return push_captures(&ms, NULL, 0) + 2;
                } else {
                    return push_captures(&ms, s1, res);
                }
            }
        } while (s1++ < ms.src_end && !anchor);
    }
    lua_pushnil(L); /* not found */
    return 1;
}

static int str_find (lua_State *L) {
    return str_find_aux(L, 1);
}

static int str_match (lua_State *L) {
    return str_find_aux(L, 0);
}

static int gmatch_aux (lua_State *L) {
    MatchState ms;
    size_t ls;
    const char *s = lua_tolstring(L, lua_upvalueindex(1), &ls);
    const char *p = lua_tostring(L, lua_upvalueindex(2));
    const char *src;
    ms.L = L;
    ms.src_init = s;
    ms.src_end = s + ls;
    for (src = s + (size_t) lua_tointeger(L, lua_upvalueindex(3)); src <= ms.src_end; src++) {
        const char *e;
        ms.level = 0;
        if ((e = match(&ms, src, p)) != NULL) {
            lua_Integer newstart = e - s;
            if (e == src) {
                newstart++; /* empty match? go at least one position */
            }
            lua_pushinteger(L, newstart);
            lua_replace(L, lua_upvalueindex(3));
            return push_captures(&ms, src, e);
        }
    }
    return 0; /* not found */
}

static int str_gmatch (lua_State *L) {
    luaL_checkstring(L, 1);
    luaL_checkstring(L, 2);
    lua_settop(L, 2);
    lua_pushinteger(L, 0);
    lua_pushcclosure(L, gmatch_aux, 3);
    return 1;
}

static int str_gfind (lua_State *L) {
    return luaL_error(L, "'string.gfind' was renamed to 'string.gmatch'");
}

static void add_s (MatchState *ms, luaL_Buffer *b, const char *s, const char *e) {
    size_t l;
    size_t i;
    const char *news = lua_tolstring(ms->L, 3, &l);
    for (i = 0; i < l; i++) {
        if (news[i] != L_ESC) {
            luaL_addchar(b, news[i]);
        } else {
            i++; /* skip ESC */
            if (!isdigit(uchar(news[i]))) {
                luaL_addchar(b, news[i]);
            } else if (news[i] == '0') {
                luaL_addlstring(b, s, e - s);
            } else {
                push_onecapture(ms, news[i] - '1', s, e);
                luaL_addvalue(b); /* add capture to accumulated result */
            }
        }
    }
}

static void add_value (MatchState *ms, luaL_Buffer *b, const char *s, const char *e) {
    lua_State *L = ms->L;
    switch (lua_type(L, 3)) {
        case LUA_TNUMBER:
        case LUA_TSTRING: {
            add_s(ms, b, s, e);
            return;
        }
        case LUA_TFUNCTION: {
            int n;
            lua_pushvalue(L, 3);
            n = push_captures(ms, s, e);
            lua_call(L, n, 1);
            break;
        }
        case LUA_TTABLE: {
            push_onecapture(ms, 0, s, e);
            lua_gettable(L, 3);
            break;
        }
    }
    if (!lua_toboolean(L, -1)) { /* nil or false? */
        lua_pop(L, 1);
        lua_pushlstring(L, s, e - s); /* keep original text */
    } else if (!lua_isstring(L, -1)) {
        luaL_error(L, "invalid replacement value (a %s)", luaL_typename(L, -1));
    }
    luaL_addvalue(b); /* add result to accumulator */
}

static int str_gsub (lua_State *L) {
    size_t srcl;
    const char *src = luaL_checklstring(L, 1, &srcl);
    const char *p = luaL_checkstring(L, 2);
    int tr = lua_type(L, 3);
    int max_s = luaL_optint(L, 4, (int) srcl + 1);
    int anchor = (*p == '^') ? (p++, 1) : 0;
    int n = 0;
    MatchState ms;
    luaL_Buffer b;
    luaL_argcheck(L, tr == LUA_TNUMBER || tr == LUA_TSTRING || tr == LUA_TFUNCTION || tr == LUA_TTABLE, 3,
                  "string/function/table expected");
    luaL_buffinit(L, &b);
    ms.L = L;
    ms.src_init = src;
    ms.src_end = src + srcl;
    while (n < max_s) {
        const char *e;
        ms.level = 0;
        e = match(&ms, src, p);
        if (e) {
            n++;
            add_value(&ms, &b, src, e);
        }
        if (e && e > src) { /* non empty match? */
            src = e; /* skip it */
        } else if (src < ms.src_end) {
            luaL_addchar(&b, *src++);
        } else {
            break;
        }
        if (anchor) {
            break;
        }
    }
    luaL_addlstring(&b, src, ms.src_end - src);
    luaL_pushresult(&b);
    lua_pushinteger(L, n); /* number of substitutions */
    return 2;
}

/* }====================================================== */

/* maximum size of each formatted item (> len(format('%99.99f', -1e308))) */
#define MAX_ITEM 512
/* maximum size of each format specification (such as '%-099.99d') */
#define MAX_FORMAT 20

static void addquoted (lua_State *L, luaL_Buffer *b, int arg) {
    size_t l;
    const char *s = luaL_checklstring(L, arg, &l);
    luaL_addchar(b, '"');
    while (l--) {
        switch (*s) {
            case '"':
            case '\\':
            case '\n': {
                luaL_addchar(b, '\\');
                luaL_addchar(b, *s);
                break;
            }
            case '\r': {
                luaL_addlstring(b, "\\r", 2);
                break;
            }
            case '\0': {
                luaL_addlstring(b, "\\000", 4);
                break;
            }
            default: {
                luaL_addchar(b, *s);
                break;
            }
        }
        s++;
    }
    luaL_addchar(b, '"');
}

static const char *scanarg (const char *strfrmt, int *arg) {
    const char *p = strfrmt;
    int n = -1;

    if (isdigit(uchar(*p))) {
        n = ((*p++) - '0');
    }
    if (isdigit(uchar(*p))) {
        n = (n * 10) + ((*p++) - '0');
    }

    if (*p++ == '$' && n >= 0) { /* n < 0 if no digits parsed */
        *arg = n + 1;
    } else {
        p = strfrmt;
    }

    return p;
}

static const char *scanformat (lua_State *L, const char *strfrmt, const char *strfrmt_end, char *form) {
    const int MAX_MATCH_LEN = MAX_FORMAT - 4;
    const char *initf = strfrmt;

    struct MatchState ms;
    ms.L = L;
    ms.src_init = strfrmt;
    ms.src_end = strfrmt_end;
    ms.level = 0;

    strfrmt = match(&ms, initf, "[-+ #0]*(%d*)%.?(%d*)");

    if (ms.capture[0].len > 2 || ms.capture[1].len > 2 || (strfrmt - initf) > MAX_MATCH_LEN) {
        luaL_error(L, "invalid format (width or precision too long)");
    }

    *(form++) = '%';
    strncpy(form, initf, strfrmt - initf + 1);
    form += strfrmt - initf + 1;
    *form = '\0';
    return strfrmt;
}

static void addintlen (char *form) {
    size_t l = strlen(form);
    char spec = form[l - 1];
    strcpy(form + l - 1, "l");
    form[l] = spec;
    form[l + 1] = '\0';
}

static int str_format (lua_State *L) {
    int arg = 1;
    size_t sfl;
    const char *strfrmt = luaL_checklstring(L, arg, &sfl);
    const char *strfrmt_end = strfrmt + sfl;
    luaL_Buffer b;
    luaL_buffinit(L, &b);
    while (strfrmt < strfrmt_end) {
        if (*strfrmt != L_ESC) {
            luaL_addchar(&b, *strfrmt++);
        } else if (*++strfrmt == L_ESC) {
            luaL_addchar(&b, *strfrmt++); /* %% */
        } else { /* format item */
            char form[MAX_FORMAT]; /* to store the format (`%...') */
            char buff[MAX_ITEM]; /* to store the formatted item */
            ++arg;
            strfrmt = scanarg(strfrmt, &arg);
            strfrmt = scanformat(L, strfrmt, strfrmt_end, form);
            switch (*strfrmt++) {
                case 'c': {
                    sprintf(buff, form, (int) luaL_checknumber(L, arg));
                    break;
                }
                case 'd':
                case 'i': {
                    long num = lua_tolong(L, arg);
                    addintlen(form);
                    sprintf(buff, form, num);
                    break;
                }
                case 'o':
                case 'u':
                case 'x':
                case 'X': {
                    lua_Number num = luaL_checknumber(L, arg);
                    addintlen(form);
                    sprintf(buff, form, (unsigned long) num);
                    break;
                }
                case 'e':
                case 'E':
                case 'f':
                case 'g':
                case 'G': {
                    sprintf(buff, form, (double) luaL_checknumber(L, arg));
                    break;
                }
                case 'F': {
                    form[strlen(form) - 1] = 'f';
                    sprintf(buff, form, (double) luaL_checknumber(L, arg));
                    break;
                }
                case 'q': {
                    addquoted(L, &b, arg);
                    continue; /* skip the 'addsize' at the end */
                }
                case 's': {
                    size_t l;
                    const char *s = luaL_checklstring(L, arg, &l);
                    if (!strchr(form, '.') && l >= 100) {
                        /* no precision and string is too long to be formatted; keep original string */
                        lua_pushvalue(L, arg);
                        luaL_addvalue(&b);
                        continue; /* skip the `addsize' at the end */
                    } else {
                        sprintf(buff, form, s);
                        break;
                    }
                }
                default: { /* also treat cases `pnLlh' */
                    return luaL_error(L, "invalid option in `format'");
                }
            }
            luaL_addlstring(&b, buff, strlen(buff));
        }
    }
    luaL_pushresult(&b);
    return 1;
}

static int str_concat (lua_State *L) {
    lua_concat(L, lua_gettop(L));
    return 1;
}

static int str_trim (lua_State *L) {
    size_t slen;
    const char *str = luaL_checklstring(L, 1, &slen);
    const char *delim = luaL_optstring(L, 2, " \r\n\t");

    const char *begin = str;
    const char *end = str + slen;

    while (begin < end && strchr(delim, *begin)) {
        ++begin;
    }

    while (end >= begin && strchr(delim, *end)) {
        --end;
    }

    lua_pushlstring(L, begin, end - begin + 1);
    return 1;
}

static int str_split (lua_State *L) {
    const char *delim = luaL_checkstring(L, 1);
    const char *str = luaL_checklstring(L, 2, NULL);
    const char *end = str + strlen(str);
    int limit = luaL_optint(L, 3, 0);
    int count = 0;

    lua_settop(L, 2);

    /* Note; use of "str <= end" below is intentional as we consider the null
     * terminator as part of the string. */

    if (!limit || limit > 1) {
        while (str <= end) {
            size_t len = strcspn(str, delim);
            luaL_checkstack(L, count + 1, "strsplit()");
            lua_pushlstring(L, str, len);
            str += len + 1;
            ++count;

            if (count == (limit - 1)) {
                break;
            }
        }
    }

    /* push remainder of string */
    if (str <= end) {
        luaL_checkstack(L, count + 1, "strsplit()");
        lua_pushstring(L, str);
        ++count;
    }

    return count;
}

static int str_splittable (lua_State *L) {
    int nres = str_split(L);
    int tidx = lua_absindex(L, -(nres + 1));

    lua_createtable(L, nres, 0);
    lua_replace(L, tidx);

    for (; nres > 0; --nres) {
        lua_rawseti(L, tidx, nres);
    }

    return 1;
}

static int str_join (lua_State *L) {
    size_t seplen;
    const char *separator = luaL_checklstring(L, 1, &seplen);
    const int pieces = lua_gettop(L) - 1;

    if (pieces <= 1 || seplen == 0) {
        lua_concat(L, pieces);
    } else {
        luaL_Buffer buf;
        luaL_buffinit(L, &buf);

        for (int i = 1; i <= pieces; ++i) {
            luaL_addstring(&buf, luaL_checkstring(L, i + 1));

            if (i < pieces) {
                luaL_addlstring(&buf, separator, seplen);
            }
        }

        luaL_pushresult(&buf);
    }

    return 1;
}

static int strcmputf8i (lua_State *L) {
    const char *str1 = luaL_checkstring(L, 1);
    const char *str2 = luaL_checkstring(L, 2);

    int res = utf8casecmp(str1, str2);

    if (res > 1) {
        res = 1;
    } else if (res < -1) {
        res = -1;
    }

    lua_pushinteger(L, res);
    return 1;
}

static int strlenutf8 (lua_State *L) {
    const char *str = luaL_checkstring(L, 1);

    lua_pushinteger(L, utf8len(str));
    return 1;
}

/**
 * Table library registration
 */

static const luaL_Reg strlib_shared[] = {
    { "byte", str_byte },
    { "char", str_char },
    { "find", str_find },
    { "format", str_format },
    { "gfind", str_gfind },
    { "gmatch", str_gmatch },
    { "gsub", str_gsub },
    { "len", str_len },
    { "lower", str_lower },
    { "match", str_match },
    { "rep", str_rep },
    { "reverse", str_reverse },
    { "sub", str_sub },
    { "upper", str_upper },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

static const luaL_Reg strlib_lua[] = {
    { "dump", str_dump },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

static const luaL_Reg strlib_global[] = {
    { "strcmputf8i", strcmputf8i },
    { "strconcat", str_concat },
    { "strjoin", str_join },
    { "strlenutf8", strlenutf8 },
    { "strsplit", str_split },
    { "strsplittable", str_splittable },
    { "strtrim", str_trim },
    /* clang-format off */
    { NULL, NULL },
    /* clang-format on */
};

static void createmetatable (lua_State *L) {
    lua_createtable(L, 0, 1); /* create metatable for strings */
    lua_pushliteral(L, ""); /* dummy string */
    lua_pushvalue(L, -2);
    lua_setmetatable(L, -2); /* set string metatable */
    lua_pop(L, 1); /* pop dummy string */
    lua_pushvalue(L, -2); /* string library... */
    lua_setfield(L, -2, "__index"); /* ...is the __index metamethod */
    lua_pop(L, 1); /* pop metatable */
}

LUALIB_API int luaopen_string (lua_State *L) {
    luaL_register(L, "_G", strlib_global);
    luaL_register(L, LUA_STRLIBNAME, strlib_shared);
    luaL_setfuncs(L, strlib_lua, 0);
    createmetatable(L);
    return 1;
}

LUALIB_API int luaopen_elune_string (lua_State *L) {
    /* open string library */
    luaL_getsubtable(L, LUA_ENVIRONINDEX, LUA_STRLIBNAME);
    luaL_setfuncs(L, strlib_shared, 0);

    /* open global functions */
    lua_pushvalue(L, LUA_ENVIRONINDEX);
    luaL_setfuncs(L, strlib_global, 0);

    lua_pushvalue(L, LUA_GLOBALSINDEX);
    if (lua_rawequal(L, -2, -1)) { /* loading into global environment? */
        lua_pop(L, 2); /* pop global and environment tables */
        createmetatable(L); /* install string metatable */
    } else {
        lua_pop(L, 2);
    }

    return 1;
}
