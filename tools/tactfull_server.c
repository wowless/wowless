/*
 * tactfull-server: HTTP/1.1 tactless proxy over a unix domain socket.
 *
 * API:
 *   GET /health                          -> 200 OK (liveness; does not reset
 * idle timer) GET /{product}/{hash}/name/{path}    -> 200 + bytes | 404 GET
 * /{product}/{hash}/fdid/{n}       -> 200 + bytes | 404
 *
 * The server maintains a pool of open tactless handles keyed by
 * product/hash.  Each entry expires after EXPIRY_S seconds of idle.
 * The server itself exits after EXPIRY_S seconds without a real request.
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

#include "tactless.h"

#define SOCKET_PATH "tactfull.sock"
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

static void send_response(int fd, const unsigned char *body, size_t blen,
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
    hlen =
        snprintf(hdr, sizeof(hdr),
                 "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection: "
                 "%s\r\n\r\n",
                 conn);
  }
  send_all(fd, hdr, hlen);
  if (body && blen > 0) {
    send_all(fd, (const char *)body, blen);
  }
}

/* ---------- request dispatch ------------------------------------------ */

/*
 * Parse /{product}/{hash}/name/{filepath}
 *    or /{product}/{hash}/fdid/{n}
 * Returns 1 on success, 0 on bad path.
 */
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

static void dispatch(int fd, const char *path, int plen, int close_after) {
  /* /health: respond 200 but don't reset last_request */
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
  unsigned char *data;
  if (is_fdid) {
    data = tactless_get_fdid(t, atoi(key), &size);
  } else {
    data = tactless_get_name(t, key, &size);
  }

  send_response(fd, data, size, close_after);
  free(data);
}

/* ---------- connection state ------------------------------------------ */

struct conn {
  int fd;
  char buf[RBUF_SIZE];
  int len;
  time_t last_active;
};

static void conn_close(struct conn *c) {
  close(c->fd);
  c->fd = -1;
  c->len = 0;
}

static void conn_process(struct conn *c) {
  int space = RBUF_SIZE - c->len;
  if (space == 0) {
    conn_close(c);
    return;
  }
  ssize_t n = recv(c->fd, c->buf + c->len, space, 0);
  if (n <= 0) {
    conn_close(c);
    return;
  }
  c->len += n;
  c->last_active = time(NULL);

  while (c->fd >= 0) {
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

/* ---------- main ------------------------------------------------------- */

int main(void) {
  int listen_fd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (listen_fd < 0) {
    perror("socket");
    return 1;
  }

  unlink(SOCKET_PATH);

  struct sockaddr_un addr;
  memset(&addr, 0, sizeof(addr));
  addr.sun_family = AF_UNIX;
  strncpy(addr.sun_path, SOCKET_PATH, sizeof(addr.sun_path) - 1);

  if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    if (errno == EADDRINUSE) {
      close(listen_fd);
      return 0; /* another server won the race */
    }
    perror("bind");
    close(listen_fd);
    return 1;
  }

  if (listen(listen_fd, 16) < 0) {
    perror("listen");
    close(listen_fd);
    return 1;
  }

  last_request = time(NULL);

  struct conn conns[MAX_CONNS];
  for (int i = 0; i < MAX_CONNS; i++) {
    conns[i].fd = -1;
  }

  time_t last_sweep = time(NULL);

  for (;;) {
    struct pollfd fds[1 + MAX_CONNS];
    int cidx[1 + MAX_CONNS];
    int nfds = 0;

    fds[nfds] = (struct pollfd){.fd = listen_fd, .events = POLLIN};
    cidx[nfds] = -1;
    nfds++;

    time_t now = time(NULL);
    for (int i = 0; i < MAX_CONNS; i++) {
      if (conns[i].fd < 0) {
        continue;
      }
      if (now - conns[i].last_active > KEEPALIVE_TIMEOUT_S) {
        conn_close(&conns[i]);
        continue;
      }
      fds[nfds] = (struct pollfd){.fd = conns[i].fd, .events = POLLIN};
      cidx[nfds] = i;
      nfds++;
    }

    poll(fds, nfds, POLL_MS);
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
        conn_process(&conns[cidx[fi]]);
      }
    }
  }

  for (int i = 0; i < MAX_CONNS; i++) {
    if (conns[i].fd >= 0) {
      conn_close(&conns[i]);
    }
  }
  close(listen_fd);
  unlink(SOCKET_PATH);

  for (int i = 0; i < MAX_POOL; i++) {
    if (pool[i].handle) {
      tactless_close(pool[i].handle);
    }
  }

  return 0;
}
