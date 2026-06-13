/*
 * tactfull-server: HTTP/1.1 tactless proxy over TCP localhost.
 *
 * API:
 *   GET /health                          -> 200 OK (liveness; does not reset
 * idle timer) GET /{product}/{hash}/name/{path}    -> 200 + bytes | 404 GET
 * /{product}/{hash}/fdid/{n}       -> 200 + bytes | 404
 *
 * On startup the server writes its port to tactfull.port.
 * On exit it removes tactfull.port.
 *
 * The server maintains a pool of open tactless handles keyed by
 * product/hash.  Each entry expires after EXPIRY_S seconds of idle.
 * The server itself exits after EXPIRY_S seconds without a real request.
 */

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
typedef SOCKET sock_t;
typedef WSAPOLLFD poll_fd_t;
#define SOCK_INVALID INVALID_SOCKET
#define sock_close(s) closesocket(s)
#define sock_poll(fds, n, ms) WSAPoll((fds), (n), (ms))
#define strncasecmp _strnicmp
#pragma comment(lib, "ws2_32.lib")
#else
#include <netinet/in.h>
#include <poll.h>
#include <sys/socket.h>
#include <unistd.h>
typedef int sock_t;
typedef struct pollfd poll_fd_t;
#define SOCK_INVALID (-1)
#define sock_close(s) close(s)
#define sock_poll(fds, n, ms) poll((fds), (n), (ms))
#endif

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "tactless.h"

#define PORT_FILE "tactfull.port"
#define MAX_CONNS 64
#define MAX_POOL 64
#define RBUF_SIZE 65536
#define KEEPALIVE_TIMEOUT_S 30
#define EXPIRY_S 1800 /* 30 minutes */
#define POLL_MS 1000
#define KEY_MAX 160 /* product(64) + '/' + hash(64) + NUL */
#define PATH_MAX_LEN 512

/* ---------- connection pool ------------------------------------------- */

struct pool_entry {
  char key[KEY_MAX];
  tactless *handle;
  time_t last_used;
};

static struct pool_entry pool[MAX_POOL];
static time_t last_request;

static tactless *pool_get(const char *product, const char *hash) {
  char key[KEY_MAX];
  snprintf(key, sizeof(key), "%s/%s", product, hash);

  time_t now = time(NULL);

  for (int i = 0; i < MAX_POOL; i++) {
    if (!pool[i].handle || strcmp(pool[i].key, key) != 0) {
      continue;
    }
    if (now - pool[i].last_used > EXPIRY_S) {
      tactless_close(pool[i].handle);
      pool[i].handle = NULL;
      break;
    }
    pool[i].last_used = now;
    return pool[i].handle;
  }

  tactless *t = tactless_open(product, hash);
  if (!t) {
    return NULL;
  }

  /* find free slot, or evict LRU */
  int slot = 0;
  for (int i = 0; i < MAX_POOL; i++) {
    if (!pool[i].handle) {
      slot = i;
      break;
    }
    if (pool[i].last_used < pool[slot].last_used) {
      slot = i;
    }
  }
  if (pool[slot].handle) {
    tactless_close(pool[slot].handle);
  }
  strncpy(pool[slot].key, key, sizeof(pool[slot].key) - 1);
  pool[slot].key[sizeof(pool[slot].key) - 1] = '\0';
  pool[slot].handle = t;
  pool[slot].last_used = now;
  return t;
}

static void pool_sweep(time_t now) {
  for (int i = 0; i < MAX_POOL; i++) {
    if (pool[i].handle && now - pool[i].last_used > EXPIRY_S) {
      tactless_close(pool[i].handle);
      pool[i].handle = NULL;
    }
  }
}

/* ---------- HTTP helpers ----------------------------------------------- */

static int send_all(sock_t fd, const char *data, size_t len) {
  while (len > 0) {
    int chunk = (len > 65536) ? 65536 : (int)len;
    int n = send(fd, data, chunk, 0);
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

static const char *parse_method_path(const char *buf, int hend, int *plen) {
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

static void send_response(sock_t fd, const unsigned char *body, size_t blen,
                          int close_after) {
  char hdr[256];
  const char *conn = close_after ? "close" : "keep-alive";
  int hlen;
  if (body) {
    hlen = snprintf(hdr, sizeof(hdr),
                    "HTTP/1.1 200 OK\r\nContent-Length: %zu\r\nConnection: "
                    "%s\r\n\r\n",
                    blen, conn);
  } else {
    hlen = snprintf(hdr, sizeof(hdr),
                    "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection:"
                    " %s\r\n\r\n",
                    conn);
  }
  send_all(fd, hdr, hlen);
  if (body && blen > 0) {
    send_all(fd, (const char *)body, blen);
  }
}

/* ---------- request dispatch ------------------------------------------ */

static int parse_casc_path(const char *path, int plen, char *product,
                           char *hash, int *is_fdid, char *key) {
  if (plen < 1 || path[0] != '/') {
    return 0;
  }
  const char *p = path + 1;
  const char *end = path + plen;

  const char *s1 = (const char *)memchr(p, '/', end - p);
  if (!s1) {
    return 0;
  }
  int prdlen = s1 - p;
  if (prdlen <= 0 || prdlen >= 64) {
    return 0;
  }
  memcpy(product, p, prdlen);
  product[prdlen] = '\0';

  p = s1 + 1;
  const char *s2 = (const char *)memchr(p, '/', end - p);
  if (!s2) {
    return 0;
  }
  int hashlen = s2 - p;
  if (hashlen <= 0 || hashlen >= 64) {
    return 0;
  }
  memcpy(hash, p, hashlen);
  hash[hashlen] = '\0';

  p = s2 + 1;
  if (strncmp(p, "name/", 5) == 0) {
    *is_fdid = 0;
    int keylen = end - (p + 5);
    if (keylen <= 0 || keylen >= PATH_MAX_LEN) {
      return 0;
    }
    memcpy(key, p + 5, keylen);
    key[keylen] = '\0';
  } else if (strncmp(p, "fdid/", 5) == 0) {
    *is_fdid = 1;
    int keylen = end - (p + 5);
    if (keylen <= 0 || keylen >= 32) {
      return 0;
    }
    memcpy(key, p + 5, keylen);
    key[keylen] = '\0';
  } else {
    return 0;
  }
  return 1;
}

static void dispatch(sock_t fd, const char *path, int plen, int close_after) {
  if (plen == 7 && memcmp(path, "/health", 7) == 0) {
    send_response(fd, (const unsigned char *)"", 0, close_after);
    return;
  }

  char product[64], hash[64], key[PATH_MAX_LEN];
  int is_fdid = 0;
  if (!parse_casc_path(path, plen, product, hash, &is_fdid, key)) {
    const char *bad =
        "HTTP/1.1 400 Bad Request\r\nContent-Length: "
        "0\r\nConnection: close\r\n\r\n";
    send_all(fd, bad, strlen(bad));
    return;
  }

  tactless *t = pool_get(product, hash);
  if (!t) {
    send_response(fd, NULL, 0, close_after);
    return;
  }

  last_request = time(NULL);

  size_t size = 0;
  unsigned char *data = is_fdid ? tactless_get_fdid(t, atoi(key), &size)
                                : tactless_get_name(t, key, &size);

  send_response(fd, data, size, close_after);
  free(data);
}

/* ---------- connection state ------------------------------------------ */

struct conn {
  sock_t fd;
  char buf[RBUF_SIZE];
  int len;
  time_t last_active;
};

static void conn_close(struct conn *c) {
  sock_close(c->fd);
  c->fd = SOCK_INVALID;
  c->len = 0;
}

static void conn_process(struct conn *c) {
  int space = RBUF_SIZE - c->len;
  if (space == 0) {
    conn_close(c);
    return;
  }
  int n = recv(c->fd, c->buf + c->len, space, 0);
  if (n <= 0) {
    conn_close(c);
    return;
  }
  c->len += n;
  c->last_active = time(NULL);

  while (c->fd != SOCK_INVALID) {
    int hend = find_headers_end(c->buf, c->len);
    if (hend < 0) {
      break;
    }

    int plen = 0;
    const char *path = parse_method_path(c->buf, hend, &plen);
    int do_close = has_connection_close(c->buf, hend);

    if (!path) {
      const char *bad =
          "HTTP/1.1 400 Bad Request\r\nContent-Length: "
          "0\r\nConnection: close\r\n\r\n";
      send_all(c->fd, bad, strlen(bad));
      conn_close(c);
      break;
    }

    dispatch(c->fd, path, plen, do_close);

    int remaining = c->len - hend;
    if (remaining > 0) {
      memmove(c->buf, c->buf + hend, remaining);
    }
    c->len = remaining;

    if (do_close) {
      conn_close(c);
    }
  }
}

/* ---------- startup: check if a server already runs at saved port ------ */

static int port_alive(int port) {
  sock_t s = socket(AF_INET, SOCK_STREAM, 0);
  if (s == SOCK_INVALID) {
    return 0;
  }
  struct sockaddr_in addr;
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons((unsigned short)port);
  addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  int alive = 0;
  if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) == 0) {
    const char *req = "GET /health HTTP/1.0\r\n\r\n";
    send(s, req, (int)strlen(req), 0);
    char resp[16];
    int n = recv(s, resp, (int)sizeof(resp), 0);
    alive = (n >= 12 && memcmp(resp, "HTTP/1.1 200", 12) == 0);
  }
  sock_close(s);
  return alive;
}

/* ---------- main ------------------------------------------------------- */

int main(void) {
#ifdef _WIN32
  WSADATA wsa;
  if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0) {
    return 1;
  }
#endif

  /* If a server is already running at the saved port, exit cleanly. */
  FILE *pf = fopen(PORT_FILE, "r");
  if (pf) {
    int saved_port = 0;
    fscanf(pf, "%d", &saved_port);
    fclose(pf);
    if (saved_port > 0 && port_alive(saved_port)) {
#ifdef _WIN32
      WSACleanup();
#endif
      return 0;
    }
  }

  sock_t listen_fd = socket(AF_INET, SOCK_STREAM, 0);
  if (listen_fd == SOCK_INVALID) {
    perror("socket");
    return 1;
  }

  struct sockaddr_in addr;
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = 0; /* OS picks a free port */
  addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);

  if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    perror("bind");
    sock_close(listen_fd);
    return 1;
  }

  /* Retrieve the OS-assigned port and write it to the port file. */
  socklen_t addrlen = sizeof(addr);
  getsockname(listen_fd, (struct sockaddr *)&addr, &addrlen);
  int port = ntohs(addr.sin_port);

  pf = fopen(PORT_FILE, "w");
  if (!pf) {
    perror("fopen tactfull.port");
    sock_close(listen_fd);
    return 1;
  }
  fprintf(pf, "%d\n", port);
  fclose(pf);

  if (listen(listen_fd, 16) < 0) {
    perror("listen");
    sock_close(listen_fd);
    remove(PORT_FILE);
    return 1;
  }

  last_request = time(NULL);

  struct conn conns[MAX_CONNS];
  for (int i = 0; i < MAX_CONNS; i++) {
    conns[i].fd = SOCK_INVALID;
  }

  time_t last_sweep = time(NULL);

  for (;;) {
    poll_fd_t fds[1 + MAX_CONNS];
    int cidx[1 + MAX_CONNS];
    int nfds = 0;

    fds[nfds].fd = listen_fd;
    fds[nfds].events = POLLIN;
    fds[nfds].revents = 0;
    cidx[nfds] = -1;
    nfds++;

    time_t now = time(NULL);
    for (int i = 0; i < MAX_CONNS; i++) {
      if (conns[i].fd == SOCK_INVALID) {
        continue;
      }
      if (now - conns[i].last_active > KEEPALIVE_TIMEOUT_S) {
        conn_close(&conns[i]);
        continue;
      }
      fds[nfds].fd = conns[i].fd;
      fds[nfds].events = POLLIN;
      fds[nfds].revents = 0;
      cidx[nfds] = i;
      nfds++;
    }

    sock_poll(fds, nfds, POLL_MS);
    now = time(NULL);

    if (now - last_sweep >= 60) {
      last_sweep = now;
      pool_sweep(now);
      if (now - last_request >= EXPIRY_S) {
        break;
      }
    }

    for (int fi = 0; fi < nfds; fi++) {
      if (!(fds[fi].revents & (POLLIN | POLLHUP | POLLERR))) {
        continue;
      }

      if (cidx[fi] < 0) {
        sock_t fd = accept(listen_fd, NULL, NULL);
        if (fd == SOCK_INVALID) {
          continue;
        }
        int placed = 0;
        for (int i = 0; i < MAX_CONNS; i++) {
          if (conns[i].fd == SOCK_INVALID) {
            conns[i].fd = fd;
            conns[i].len = 0;
            conns[i].last_active = now;
            placed = 1;
            break;
          }
        }
        if (!placed) {
          sock_close(fd);
        }
      } else {
        conn_process(&conns[cidx[fi]]);
      }
    }
  }

  for (int i = 0; i < MAX_CONNS; i++) {
    if (conns[i].fd != SOCK_INVALID) {
      conn_close(&conns[i]);
    }
  }
  sock_close(listen_fd);
  remove(PORT_FILE);

  for (int i = 0; i < MAX_POOL; i++) {
    if (pool[i].handle) {
      tactless_close(pool[i].handle);
    }
  }

#ifdef _WIN32
  WSACleanup();
#endif
  return 0;
}
