/* Licensed under the terms of the MIT License; see full copyright information
 * in the "LICENSE" file or at <http://www.lua.org/license.html> */

#define luac_c
#define LUA_CORE

#include "lua.h"

#include "ldebug.h"
#include "ldo.h"
#include "lfunc.h"
#include "lmanip.h"
#include "lmem.h"
#include "lobject.h"
#include "lopcodes.h"
#include "lstring.h"
#include "lundump.h"

#include "lauxlib.h"

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PROGNAME "luac" /* default program name */
#define OUTPUT PROGNAME ".out" /* default output file */

static int listing = 0; /* list bytecodes? */
static int dumping = 1; /* dump bytecodes? */
static int stripping = 0; /* strip debug information? */
static char Output[] = { OUTPUT }; /* default output file name */
static const char *output = Output; /* actual output file name */
static const char *progname = PROGNAME; /* actual program name */

static void printfunction (const Proto *f, int full);

static void fatal (const char *message) {
    fprintf(stderr, "%s: %s\n", progname, message);
    exit(EXIT_FAILURE);
}

static void cannot (const char *what) {
    fprintf(stderr, "%s: cannot %s %s: %s\n", progname, what, output, strerror(errno));
    exit(EXIT_FAILURE);
}

static void usage (const char *message) {
    if (*message == '-') {
        fprintf(stderr, "%s: unrecognized option '%s'\n", progname, message);
    } else {
        fprintf(stderr, "%s: %s\n", progname, message);
    }

    fprintf(stderr,
            "usage: %s [options] [filenames].\n"
            "Available options are:\n"
            "  -        process stdin\n"
            "  -l       list\n"
            "  -o name  output to file 'name' (default is \"%s\")\n"
            "  -p       parse only\n"
            "  -s       strip debug information\n"
            "  -v       show version information\n"
            "  --       stop handling options\n",
            progname, Output);

    exit(EXIT_FAILURE);
}

#define IS(s) (strcmp(argv[i], s) == 0)

static int doargs (int argc, char *argv[]) {
    int i;
    int version = 0;

    if (argv[0] != NULL && *argv[0] != 0) {
        progname = argv[0];
    }

    for (i = 1; i < argc; i++) {
        if (*argv[i] != '-') { /* end of options; keep it */
            break;
        } else if (IS("--")) { /* end of options; skip it */
            ++i;
        }

        if (version) {
            ++version;
            break;
        } else if (IS("-")) { /* end of options; use stdin */
            break;
        } else if (IS("-l")) { /* list */
            ++listing;
        } else if (IS("-o")) { /* output file */
            output = argv[++i];

            if (output == NULL || *output == 0) {
                usage("'-o' needs argument");
            }

            if (IS("-")) {
                output = NULL;
            }
        } else if (IS("-p")) { /* parse only */
            dumping = 0;
        } else if (IS("-s")) { /* strip debug information */
            stripping = 1;
        } else if (IS("-v")) { /* show version */
            ++version;
        } else { /* unknown option */
            usage(argv[i]);
        }

        if (i == argc && (listing || !dumping)) {
            dumping = 0;
            argv[--i] = Output;
        }

        if (version) {
            printf("%-10s %s\n", LUA_RELEASE, LUA_COPYRIGHT);
            printf("%-10s %s\n", ELUNE_RELEASE, ELUNE_COPYRIGHT);

            if (version == (argc - 1)) {
                exit(EXIT_SUCCESS);
            }
        }
    }

    return i;
}

#define toproto(L, i) (clvalue(L->top + (i))->l.p)

static const Proto *combine (lua_State *L, int n) {
    if (n == 1) {
        return toproto(L, -1);
    } else {
        int i;
        int pc;
        Proto *f = luaF_newproto(L);
        setptvalue2s(L, L->top, f);
        incr_top(L);

        f->source = luaS_newliteral(L, "=(" PROGNAME ")");
        f->maxstacksize = 1;
        pc = 2 * n + 1;
        f->code = luaM_newvector(L, pc, Instruction);
        f->sizecode = pc;
        f->p = luaM_newvector(L, n, Proto *);
        f->sizep = n;
        pc = 0;

        for (i = 0; i < n; i++) {
            f->p[i] = toproto(L, i - n - 1);
            f->code[pc++] = CREATE_ABx(OP_CLOSURE, 0, i);
            f->code[pc++] = CREATE_ABC(OP_CALL, 0, 1, 1);
        }

        f->code[pc++] = CREATE_ABC(OP_RETURN, 0, 1, 0);
        return f;
    }
}

static int writer (lua_State *L, const void *p, size_t size, void *u) {
    lua_unused(L);
    return (fwrite(p, size, 1, (FILE *) u) != 1) && (size != 0);
}

struct Smain {
    int argc;
    char **argv;
};

static int pmain (lua_State *L) {
    struct Smain *s = (struct Smain *) lua_touserdata(L, 1);
    int argc = s->argc;
    char **argv = s->argv;
    const Proto *f;
    int i;

    if (!lua_checkstack(L, argc)) {
        fatal("too many input files");
    }

    for (i = 0; i < argc; i++) {
        const char *filename = IS("-") ? NULL : argv[i];
        if (luaL_loadfile(L, filename) != 0) {
            fatal(lua_tostring(L, -1));
        }
    }

    f = combine(L, argc);
    if (listing) {
        printfunction(f, (listing > 1));
    }

    if (dumping) {
        FILE *D = (output == NULL) ? stdout : fopen(output, "wb");

        if (D == NULL) {
            cannot("open");
        }

        lua_lock(L);
        luaU_dump(L, f, writer, D, stripping);
        lua_unlock(L);

        if (ferror(D)) {
            cannot("write");
        }

        if (fclose(D)) {
            cannot("close");
        }
    }
    return 0;
}

extern int main (int argc, char *argv[]) {
    lua_State *L;
    struct Smain s;
    int i = doargs(argc, argv);

    argc -= i;
    argv += i;

    if (argc <= 0) {
        usage("no input files given");
    }

    L = luaL_newstate();

    if (L == NULL) {
        fatal("not enough memory for state");
    }

    s.argc = argc;
    s.argv = argv;

    if (lua_cpcall(L, pmain, &s) != 0) {
        fatal(lua_tostring(L, -1));
    }

    lua_close(L);
    return EXIT_SUCCESS;
}

/**
 * Print infrastructure
 */

#define Sizeof(x) ((int) sizeof(x))
#define VOID(p) ((const void *) (p))

static void printstring (const TString *ts) {
    const char *s = getstr(ts);
    size_t n = ts->tsv.len;
    size_t i;

    putchar('"');

    for (i = 0; i < n; i++) {
        int c = s[i];

        switch (c) {
            case '"':
                printf("\\\"");
                break;
            case '\\':
                printf("\\\\");
                break;
            case '\a':
                printf("\\a");
                break;
            case '\b':
                printf("\\b");
                break;
            case '\f':
                printf("\\f");
                break;
            case '\n':
                printf("\\n");
                break;
            case '\r':
                printf("\\r");
                break;
            case '\t':
                printf("\\t");
                break;
            case '\v':
                printf("\\v");
                break;
            default:
                if (isprint((unsigned char) c)) {
                    putchar(c);
                } else {
                    printf("\\%03u", (unsigned char) c);
                }
        }
    }

    putchar('"');
}

static void printconstant (const Proto *f, int i) {
    const TValue *o = &f->k[i];
    switch (ttype(o)) {
        case LUA_TNIL:
            printf("nil");
            break;
        case LUA_TBOOLEAN:
            printf(bvalue(o) ? "true" : "false");
            break;
        case LUA_TNUMBER:
            printf(LUA_NUMBER_FMT, nvalue(o));
            break;
        case LUA_TSTRING:
            printstring(rawtsvalue(o));
            break;
        default: /* cannot happen */
            printf("? type=%d", ttype(o));
            break;
    }
}

static void printcode (const Proto *f) {
    const Instruction *code = f->code;
    int n = f->sizecode;
    int pc;

    for (pc = 0; pc < n; pc++) {
        Instruction i = code[pc];
        OpCode o = GET_OPCODE(i);
        int a = GETARG_A(i);
        int b = GETARG_B(i);
        int c = GETARG_C(i);
        int bx = GETARG_Bx(i);
        int sbx = GETARG_sBx(i);
        int line = getfuncline(f, pc);

        printf("\t%d\t", pc + 1);

        if (line > 0) {
            printf("[%d]\t", line);
        } else {
            printf("[-]\t");
        }

        printf("%-9s\t", luaP_opnames[o]);

        switch (getOpMode(o)) {
            case iABC:
                printf("%d", a);

                if (getBMode(o) != OpArgN) {
                    printf(" %d", ISK(b) ? (-1 - INDEXK(b)) : b);
                }

                if (getCMode(o) != OpArgN) {
                    printf(" %d", ISK(c) ? (-1 - INDEXK(c)) : c);
                }

                break;
            case iABx:
                if (getBMode(o) == OpArgK) {
                    printf("%d %d", a, (-1 - bx));
                } else {
                    printf("%d %d", a, bx);
                }

                break;
            case iAsBx:
                if (o == OP_JMP) {
                    printf("%d", sbx);
                } else {
                    printf("%d %d", a, sbx);
                }

                break;
        }

        switch (o) {
            case OP_LOADK:
                printf("\t; ");
                printconstant(f, bx);
                break;
            case OP_GETUPVAL:
            case OP_SETUPVAL:
                printf("\t; %s", (f->sizeupvalues > 0) ? getstr(f->upvalues[b]) : "-");
                break;
            case OP_GETGLOBAL:
            case OP_SETGLOBAL:
                printf("\t; %s", svalue(&f->k[bx]));
                break;
            case OP_GETTABLE:
            case OP_SELF:
                if (ISK(c)) {
                    printf("\t; ");
                    printconstant(f, INDEXK(c));
                }
                break;
            case OP_SETTABLE:
            case OP_ADD:
            case OP_SUB:
            case OP_MUL:
            case OP_DIV:
            case OP_POW:
            case OP_EQ:
            case OP_LT:
            case OP_LE:
                if (ISK(b) || ISK(c)) {
                    printf("\t; ");
                    if (ISK(b)) {
                        printconstant(f, INDEXK(b));
                    } else {
                        printf("-");
                    }

                    printf(" ");
                    if (ISK(c)) {
                        printconstant(f, INDEXK(c));
                    } else {
                        printf("-");
                    }
                }
                break;
            case OP_JMP:
            case OP_FORLOOP:
            case OP_FORPREP:
                printf("\t; to %d", (sbx + pc + 2));
                break;
            case OP_CLOSURE:
                printf("\t; %p", VOID(f->p[bx]));
                break;
            case OP_SETLIST:
                if (c == 0) {
                    printf("\t; %d", (int) code[++pc]);
                } else {
                    printf("\t; %d", c);
                }
                break;
            default:
                break;
        }

        printf("\n");
    }
}

#define SS(x) (x == 1) ? "" : "s"
#define S(x) x, SS(x)

static void printheader (const Proto *f) {
    const char *s = getstr(f->source);

    if (*s == '@' || *s == '=') {
        s++;
    } else if (*s == LUA_SIGNATURE[0]) {
        s = "(bstring)";
    } else {
        s = "(string)";
    }

    printf("\n%s <%s:%d,%d> (%d instruction%s, %d bytes at %p)\n", (f->linedefined == 0) ? "main" : "function", s,
           f->linedefined, f->lastlinedefined, S(f->sizecode), /* expands to two args */
           f->sizecode * Sizeof(Instruction), VOID(f));

    printf("%d%s param%s, %d slot%s, %d upvalue%s, ", f->numparams, f->is_vararg ? "+" : "", SS(f->numparams),
           S(f->maxstacksize), /* expands to two args */
           S(f->nups) /* expands to two args */
    );

    printf("%d local%s, %d constant%s, %d function%s\n", S(f->sizelocvars), /* expands to two args */
           S(f->sizek), /* expands to two args */
           S(f->sizep) /* expands to two args */
    );
}

static void printconstants (const Proto *f) {
    int n = f->sizek;
    int i;

    printf("constants (%d) for %p:\n", n, VOID(f));

    for (i = 0; i < n; i++) {
        printf("\t%d\t", i + 1);
        printconstant(f, i);
        printf("\n");
    }
}

static void printlocals (const Proto *f) {
    int n = f->sizelocvars;
    int i;

    printf("locals (%d) for %p:\n", n, VOID(f));

    for (i = 0; i < n; i++) {
        const char *name = getstr(f->locvars[i].varname);
        int startpc = f->locvars[i].startpc + 1;
        int endpc = f->locvars[i].endpc + 1;

        printf("\t%d\t%s\t%d\t%d\n", i, name, startpc, endpc);
    }
}

static void printupvalues (const Proto *f) {
    int n = f->sizeupvalues;
    int i;

    printf("upvalues (%d) for %p:\n", n, VOID(f));

    if (f->upvalues == NULL) {
        return;
    }

    for (i = 0; i < n; i++) {
        printf("\t%d\t%s\n", i, getstr(f->upvalues[i]));
    }
}

static void printfunction (const Proto *f, int full) {
    int n = f->sizep;
    int i;

    printheader(f);
    printcode(f);

    if (full) {
        printconstants(f);
        printlocals(f);
        printupvalues(f);
    }

    for (i = 0; i < n; i++) {
        printfunction(f->p[i], full);
    }
}
