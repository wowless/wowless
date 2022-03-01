#include <ctype.h>
#include <string.h>

#include <lua.h>
#include <luaconf.h>
#include <lualib.h>
#include <lauxlib.h>

/* Lightly modified from lstrlib.c */

/* macro to `unsign' a character */
#define uchar(c)        ((unsigned char)(c))

#define L_ESC  '%'

/* maximum size of each formatted item (> len(format('%99.99f', -1e308))) */
#define MAX_ITEM 512
/* valid flags in a format specification */
#define FLAGS "-+ #0"
/*
** maximum size of each format specification (such as '%-099.99d')
** (+10 accounts for %99.99x plus margin of error)
*/
#define MAX_FORMAT (sizeof(FLAGS) + sizeof(LUA_INTFRMLEN) + 10)

static void addquoted(lua_State *L, luaL_Buffer *b, int arg) {
  size_t l;
  const char *s = luaL_checklstring(L, arg, &l);
  luaL_addchar(b, '"');
  while (l--) {
    switch (*s) {
      case '"': case '\\': case '\n': {
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

/*
 * wowless: support lua 4.0 style positional arguments.
 * One difference from lua 4.0: wow supports 2-digit positions.
 */
static const char *scanargnum(lua_State *L, const char *strfrmt, int *argnum) {
  const char *p = strfrmt;
  while (*p != '\0' && isdigit(*p)) p++;
  if (*p != '$')
    return strfrmt;
  if (p == strfrmt || (size_t)(p - strfrmt) > 2)
    luaL_error(L, "invalid format (bad positional specifier)");
  *argnum = *strfrmt++ - '0';
  if (*strfrmt != '$')
    *argnum = *argnum * 10 + *strfrmt++ - '0';
  (*argnum)++;  /* +1 to skip format string */
  return ++strfrmt;
}

static const char *scanformat(lua_State *L, const char *strfrmt, char *form, int *argnum) {
  const char *p = scanargnum(L, strfrmt, argnum);
  strfrmt = p;
  while (*p != '\0' && strchr(FLAGS, *p) != NULL) p++;  /* skip flags */
  if ((size_t)(p - strfrmt) >= sizeof(FLAGS))
    luaL_error(L, "invalid format (repeated flags)");
  if (isdigit(uchar(*p))) p++;  /* skip width */
  if (isdigit(uchar(*p))) p++;  /* (2 digits at most) */
  if (*p == '.') {
    p++;
    if (isdigit(uchar(*p))) p++;  /* skip precision */
    if (isdigit(uchar(*p))) p++;  /* (2 digits at most) */
  }
  if (isdigit(uchar(*p)))
    luaL_error(L, "invalid format (width or precision too long)");
  *(form++) = '%';
  strncpy(form, strfrmt, p - strfrmt + 1);
  form += p - strfrmt + 1;
  *form = '\0';
  return p;
}

static void addintlen(char *form) {
  size_t l = strlen(form);
  char spec = form[l - 1];
  strcpy(form + l - 1, LUA_INTFRMLEN);
  form[l + sizeof(LUA_INTFRMLEN) - 2] = spec;
  form[l + sizeof(LUA_INTFRMLEN) - 1] = '\0';
}

static int wowless_ext_format(lua_State *L) {
  int top = lua_gettop(L);
  int argidx = 1;
  size_t sfl;
  const char *strfrmt = luaL_checklstring(L, 1, &sfl);
  const char *strfrmt_end = strfrmt+sfl;
  luaL_Buffer b;
  luaL_buffinit(L, &b);
  while (strfrmt < strfrmt_end) {
    if (*strfrmt != L_ESC)
      luaL_addchar(&b, *strfrmt++);
    else if (*++strfrmt == L_ESC)
      luaL_addchar(&b, *strfrmt++);  /* %% */
    else { /* format item */
      char form[MAX_FORMAT];  /* to store the format (`%...') */
      char buff[MAX_ITEM];  /* to store the formatted item */
      int arg = ++argidx;
      strfrmt = scanformat(L, strfrmt, form, &arg);
      if (arg > top) {
        if (*strfrmt != 'd' && *strfrmt != 'i') {  /* wowless */
          luaL_argerror(L, arg, "no value");
        }
      }
      switch (*strfrmt++) {
        case 'c': {
          sprintf(buff, form, (int)luaL_checknumber(L, arg));
          break;
        }
        case 'd':  case 'i': {
          const lua_Number num = arg > top ? 0 : luaL_optnumber(L, arg, 0);  /* wowless */
          addintlen(form);
          sprintf(buff, form, (LUA_INTFRM_T)num);
          break;
        }
        case 'o':  case 'u':  case 'x':  case 'X': {
          const lua_Number num = luaL_checknumber(L, arg);
          addintlen(form);
          sprintf(buff, form, (unsigned LUA_INTFRM_T)num);
          break;
        }
        case 'e':  case 'E': case 'f':
        case 'F':  /* wowless */
        case 'g': case 'G': {
          sprintf(buff, form, (double)luaL_checknumber(L, arg));
          break;
        }
        case 'q': {
          addquoted(L, &b, arg);
          continue;  /* skip the 'addsize' at the end */
        }
        case 's': {
          size_t l;
          const char *s = luaL_checklstring(L, arg, &l);
          if (!strchr(form, '.') && l >= 100) {
            /* no precision and string is too long to be formatted;
               keep original string */
            lua_pushvalue(L, arg);
            luaL_addvalue(&b);
            continue;  /* skip the `addsize' at the end */
          }
          else {
            sprintf(buff, form, s);
            break;
          }
        }
        default: {  /* also treat cases `pnLlh' */
          return luaL_error(L, "invalid option " LUA_QL("%%%c") " to "
                               LUA_QL("format"), *(strfrmt - 1));
        }
      }
      luaL_addlstring(&b, buff, strlen(buff));
    }
  }
  luaL_pushresult(&b);
  return 1;
}

/* Lightly modified from ldblib.c. */

static lua_State *getthread (lua_State *L, int *arg) {
  if (lua_isthread(L, 1)) {
    *arg = 1;
    return lua_tothread(L, 1);
  }
  else {
    *arg = 0;
    return L;
  }
}

static const char *get_source (const lua_Debug *ar) {
  if (ar->source[0] == '@') {
    return ar->source + 1;
  } else {
    return ar->short_src;
  }
}

#define LEVELS1 120  /* size of the first part of the stack */
#define LEVELS2 10   /* size of the second part of the stack */

static int wowless_ext_traceback (lua_State *L) {
  int level;
  int firstpart = 1;  /* still before eventual `...' */
  int arg;
  lua_State *L1 = getthread(L, &arg);
  lua_Debug ar;
  if (lua_isnumber(L, arg+2)) {
    level = (int)lua_tointeger(L, arg+2);
    lua_pop(L, 1);
  }
  else
    level = (L == L1) ? 1 : 0;  /* level 0 may be this own function */
  if (lua_gettop(L) == arg)
    lua_pushliteral(L, "");
  else if (!lua_isstring(L, arg+1)) return 1;  /* message is not a string */
  else lua_pushliteral(L, "\n");
  lua_pushliteral(L, "stack traceback:");
  while (lua_getstack(L1, level++, &ar)) {
    if (level > LEVELS1 && firstpart) {
      /* no more than `LEVELS2' more levels? */
      if (!lua_getstack(L1, level+LEVELS2, &ar))
        level--;  /* keep going */
      else {
        lua_pushliteral(L, "\n\t...");  /* too many levels */
        while (lua_getstack(L1, level+LEVELS2, &ar))  /* find last levels */
          level++;
      }
      firstpart = 0;
      continue;
    }
    lua_pushliteral(L, "\n\t");
    lua_getinfo(L1, "Snl", &ar);
    lua_pushfstring(L, "%s:", get_source(&ar));
    if (ar.currentline > 0)
      lua_pushfstring(L, "%d:", ar.currentline);
    if (*ar.namewhat != '\0')  /* is there a name? */
        lua_pushfstring(L, " in function " LUA_QS, ar.name);
    else {
      if (*ar.what == 'm')  /* main? */
        lua_pushfstring(L, " in main chunk");
      else if (*ar.what == 'C' || *ar.what == 't')
        lua_pushliteral(L, " ?");  /* C function or tail call */
      else
        lua_pushfstring(L, " in function <%s:%d>",
                           get_source(&ar), ar.linedefined);
    }
    lua_concat(L, lua_gettop(L) - arg);
  }
  lua_concat(L, lua_gettop(L) - arg);
  return 1;
}

static struct luaL_Reg extlib[] = {
  {"format", wowless_ext_format},
  {"traceback", wowless_ext_traceback},
  {NULL, NULL}
};

int luaopen_wowless_ext(lua_State *L) {
  lua_newtable(L);
  luaL_register(L, NULL, extlib);
  return 1;
}
