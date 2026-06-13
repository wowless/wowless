/*
 * Minimal HTTP/1.1 server over a unix domain socket with keep-alive.
 * Exports one Lua function:
 *   serve(socket_path, handler, idle_handler, idle_interval_seconds)
 *     handler(path) -> string|nil
 *     idle_handler() -> bool  (false = shut down)
 */

#include <errno.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <time.h>
#include <unistd.h>

#include "lauxlib.h"
#include "lua.h"

#define MAX_CONNS 64
#define RBUF_SIZE 65536
#define KEEPALIVE_TIMEOUT_S 30
#define POLL_INTERVAL_MS 1000

struct conn {
  int fd;
  char buf[RBUF_SIZE];
  int len;
  time_t last_active;
};

static int send_all(int fd, const char *data, size_t len) {
  while (len > 0) {
    ssize_t n = send(fd, data, len, 0);
    if (n <= 0) {
      return -1;
    }
    data += n;
    len -= n;
  }
  return 0;
}

static int find_headers_end(const char *buf, int len) {
  for (int i = 0; i <= len - 4; i++) {
    if (buf[i] == '\r' && buf[i + 1] == '\n' && buf[i + 2] == '\r' &&
        buf[i + 3] == '\n') {
      return i + 4;
    }
  }
  return -1;
}

static const char *parse_path(const char *buf, int hend, int *plen) {
  if (strncmp(buf, "GET ", 4) != 0) {
    return NULL;
  }
  const char *p = buf + 4;
  const char *e = (const char *)memchr(p, ' ', buf + hend - p);
  if (!e) {
    return NULL;
  }
  *plen = e - p;
  return p;
}

static int has_connection_close(const char *buf, int hend) {
  const char *p = buf;
  const char *end = buf + hend;
  while (p < end) {
    const char *nl = (const char *)memchr(p, '\n', end - p);
    if (!nl) {
      break;
    }
    if ((nl - p) >= 17 && strncasecmp(p, "connection: close", 17) == 0) {
      return 1;
    }
    p = nl + 1;
  }
  return 0;
}

static void send_response(int fd, const char *body, size_t blen, int close) {
  char hdr[256];
  const char *conn = close ? "close" : "keep-alive";
  int hlen;
  if (body) {
    hlen = snprintf(hdr, sizeof(hdr),
                    "HTTP/1.1 200 OK\r\nContent-Length: %zu\r\nConnection: "
                    "%s\r\n\r\n",
                    blen, conn);
  } else {
    hlen =
        snprintf(hdr, sizeof(hdr),
                 "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection: "
                 "%s\r\n\r\n",
                 conn);
  }
  send_all(fd, hdr, hlen);
  if (body && blen > 0) {
    send_all(fd, body, blen);
  }
}

static void close_conn(struct conn *c) {
  close(c->fd);
  c->fd = -1;
  c->len = 0;
}

static void process_conn(lua_State *L, struct conn *c, int handler_ref) {
  int space = RBUF_SIZE - c->len;
  if (space == 0) {
    close_conn(c);
    return;
  }
  ssize_t n = recv(c->fd, c->buf + c->len, space, 0);
  if (n <= 0) {
    close_conn(c);
    return;
  }
  c->len += n;
  c->last_active = time(NULL);

  while (c->fd >= 0) {
    int hend = find_headers_end(c->buf, c->len);
    if (hend < 0) {
      break;
    }

    int path_len = 0;
    const char *path = parse_path(c->buf, hend, &path_len);
    int do_close = has_connection_close(c->buf, hend);

    if (!path) {
      const char *bad =
          "HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\nConnection: "
          "close\r\n\r\n";
      send_all(c->fd, bad, strlen(bad));
      close_conn(c);
      break;
    }

    lua_rawgeti(L, LUA_REGISTRYINDEX, handler_ref);
    lua_pushlstring(L, path, path_len);
    if (lua_pcall(L, 1, 1, 0) != 0) {
      fprintf(stderr, "tactfull: handler error: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
      send_response(c->fd, NULL, 0, do_close);
    } else {
      size_t blen = 0;
      const char *body = NULL;
      if (lua_isstring(L, -1)) {
        body = lua_tolstring(L, -1, &blen);
      }
      send_response(c->fd, body, blen, do_close);
      lua_pop(L, 1);
    }

    int remaining = c->len - hend;
    if (remaining > 0) {
      memmove(c->buf, c->buf + hend, remaining);
    }
    c->len = remaining;

    if (do_close) {
      close_conn(c);
    }
  }
}

static int call_idle(lua_State *L, int idle_ref) {
  lua_rawgeti(L, LUA_REGISTRYINDEX, idle_ref);
  if (lua_pcall(L, 0, 1, 0) != 0) {
    fprintf(stderr, "tactfull: idle error: %s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
    return 0;
  }
  int cont = lua_toboolean(L, -1);
  lua_pop(L, 1);
  return cont;
}

static int tactfull_serve(lua_State *L) {
  const char *socket_path = luaL_checkstring(L, 1);
  luaL_checktype(L, 2, LUA_TFUNCTION);
  luaL_checktype(L, 3, LUA_TFUNCTION);
  int idle_interval = (int)luaL_optnumber(L, 4, 60);

  lua_pushvalue(L, 2);
  int handler_ref = luaL_ref(L, LUA_REGISTRYINDEX);
  lua_pushvalue(L, 3);
  int idle_ref = luaL_ref(L, LUA_REGISTRYINDEX);

  int listen_fd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (listen_fd < 0) {
    return luaL_error(L, "socket: %s", strerror(errno));
  }

  unlink(socket_path);

  struct sockaddr_un addr;
  memset(&addr, 0, sizeof(addr));
  addr.sun_family = AF_UNIX;
  strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path) - 1);

  if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    int e = errno;
    close(listen_fd);
    if (e == EADDRINUSE) {
      /* Another server won the race; exit cleanly. */
      return 0;
    }
    return luaL_error(L, "bind: %s", strerror(e));
  }

  if (listen(listen_fd, 16) < 0) {
    close(listen_fd);
    return luaL_error(L, "listen: %s", strerror(errno));
  }

  struct conn conns[MAX_CONNS];
  for (int i = 0; i < MAX_CONNS; i++) {
    conns[i].fd = -1;
  }

  time_t last_idle = time(NULL);

  for (;;) {
    struct pollfd fds[1 + MAX_CONNS];
    int conn_idx[1 + MAX_CONNS];
    int nfds = 0;

    fds[nfds] = (struct pollfd){.fd = listen_fd, .events = POLLIN};
    conn_idx[nfds] = -1;
    nfds++;

    time_t now = time(NULL);
    for (int i = 0; i < MAX_CONNS; i++) {
      if (conns[i].fd < 0) {
        continue;
      }
      if (now - conns[i].last_active > KEEPALIVE_TIMEOUT_S) {
        close_conn(&conns[i]);
        continue;
      }
      fds[nfds] = (struct pollfd){.fd = conns[i].fd, .events = POLLIN};
      conn_idx[nfds] = i;
      nfds++;
    }

    int r = poll(fds, nfds, POLL_INTERVAL_MS);

    now = time(NULL);

    if (now - last_idle >= idle_interval) {
      last_idle = now;
      if (!call_idle(L, idle_ref)) {
        break;
      }
    }

    if (r <= 0) {
      continue;
    }

    for (int fi = 0; fi < nfds; fi++) {
      if (!(fds[fi].revents & (POLLIN | POLLHUP | POLLERR))) {
        continue;
      }

      if (conn_idx[fi] < 0) {
        /* listen fd */
        int fd = accept(listen_fd, NULL, NULL);
        if (fd < 0) {
          continue;
        }
        int placed = 0;
        for (int i = 0; i < MAX_CONNS; i++) {
          if (conns[i].fd < 0) {
            conns[i] = (struct conn){.fd = fd, .len = 0, .last_active = now};
            placed = 1;
            break;
          }
        }
        if (!placed) {
          close(fd);
        }
      } else {
        process_conn(L, &conns[conn_idx[fi]], handler_ref);
      }
    }
  }

  for (int i = 0; i < MAX_CONNS; i++) {
    if (conns[i].fd >= 0) {
      close_conn(&conns[i]);
    }
  }
  close(listen_fd);
  unlink(socket_path);

  luaL_unref(L, LUA_REGISTRYINDEX, handler_ref);
  luaL_unref(L, LUA_REGISTRYINDEX, idle_ref);
  return 0;
}

int luaopen_tools_tactfull_http(lua_State *L) {
  lua_pushcfunction(L, tactfull_serve);
  return 1;
}
