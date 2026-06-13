/*
 * tactfull-server: HTTP tactless proxy using libmicrohttpd.
 *
 * API:
 *   GET /health                          -> 200 OK (liveness; does not reset
 *                                          idle timer)
 *   GET /{product}/{hash}/name/{path}    -> 200 + bytes | 404
 *   GET /{product}/{hash}/fdid/{n}       -> 200 + bytes | 404
 *
 * On startup the server writes its port to tactfull.port.
 * On exit it removes tactfull.port.
 *
 * The server maintains a pool of open tactless handles keyed by
 * product/hash.  Each entry expires after EXPIRY_S seconds of idle.
 */

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#define sleep_s(n) Sleep((n) * 1000)
#else
#include <unistd.h>
#define sleep_s(n) sleep(n)
#endif

#include <microhttpd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "tactless.h"

#define PORT_FILE "tactfull.port"
#define MAX_POOL 64
#define EXPIRY_S 1800 /* 30 minutes */
#define KEY_MAX 160   /* product(64) + '/' + hash(64) + NUL */
#define PATH_MAX_LEN 512

/* ---------- connection pool ------------------------------------------- */

struct pool_entry {
  char key[KEY_MAX];
  tactless *handle;
  time_t last_used;
};

static struct pool_entry pool[MAX_POOL];

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

/* ---------- URL parsing ------------------------------------------------ */

static int parse_casc_url(const char *url, char *product, char *hash,
                          int *is_fdid, char *key) {
  if (url[0] != '/') {
    return 0;
  }
  const char *p = url + 1;

  const char *s1 = strchr(p, '/');
  if (!s1) {
    return 0;
  }
  int prdlen = (int)(s1 - p);
  if (prdlen <= 0 || prdlen >= 64) {
    return 0;
  }
  memcpy(product, p, prdlen);
  product[prdlen] = '\0';

  p = s1 + 1;
  const char *s2 = strchr(p, '/');
  if (!s2) {
    return 0;
  }
  int hashlen = (int)(s2 - p);
  if (hashlen <= 0 || hashlen >= 64) {
    return 0;
  }
  memcpy(hash, p, hashlen);
  hash[hashlen] = '\0';

  p = s2 + 1;
  if (strncmp(p, "name/", 5) == 0) {
    *is_fdid = 0;
    const char *name = p + 5;
    int keylen = (int)strlen(name);
    if (keylen <= 0 || keylen >= PATH_MAX_LEN) {
      return 0;
    }
    memcpy(key, name, keylen + 1);
  } else if (strncmp(p, "fdid/", 5) == 0) {
    *is_fdid = 1;
    const char *num = p + 5;
    int keylen = (int)strlen(num);
    if (keylen <= 0 || keylen >= 32) {
      return 0;
    }
    memcpy(key, num, keylen + 1);
  } else {
    return 0;
  }
  return 1;
}

/* ---------- request handler ------------------------------------------- */

static enum MHD_Result handler(void *cls, struct MHD_Connection *connection,
                               const char *url, const char *method,
                               const char *version, const char *upload_data,
                               size_t *upload_data_size, void **req_cls) {
  (void)cls;
  (void)version;
  (void)upload_data;
  (void)upload_data_size;
  (void)req_cls;

  if (strcmp(method, "GET") != 0) {
    struct MHD_Response *r =
        MHD_create_response_from_buffer(0, (void *)"", MHD_RESPMEM_PERSISTENT);
    enum MHD_Result ret =
        MHD_queue_response(connection, MHD_HTTP_METHOD_NOT_ALLOWED, r);
    MHD_destroy_response(r);
    return ret;
  }

  if (strcmp(url, "/health") == 0) {
    struct MHD_Response *r =
        MHD_create_response_from_buffer(0, (void *)"", MHD_RESPMEM_PERSISTENT);
    enum MHD_Result ret = MHD_queue_response(connection, MHD_HTTP_OK, r);
    MHD_destroy_response(r);
    return ret;
  }

  char product[64], hash[64], key[PATH_MAX_LEN];
  int is_fdid = 0;
  struct MHD_Response *response;
  unsigned int status;

  if (!parse_casc_url(url, product, hash, &is_fdid, key)) {
    response =
        MHD_create_response_from_buffer(0, (void *)"", MHD_RESPMEM_PERSISTENT);
    status = MHD_HTTP_BAD_REQUEST;
  } else {
    tactless *t = pool_get(product, hash);
    if (!t) {
      response = MHD_create_response_from_buffer(0, (void *)"",
                                                 MHD_RESPMEM_PERSISTENT);
      status = MHD_HTTP_NOT_FOUND;
    } else {
      size_t size = 0;
      void *data = is_fdid ? (void *)tactless_get_fdid(t, atoi(key), &size)
                           : (void *)tactless_get_name(t, key, &size);
      if (!data) {
        response = MHD_create_response_from_buffer(0, (void *)"",
                                                   MHD_RESPMEM_PERSISTENT);
        status = MHD_HTTP_NOT_FOUND;
      } else {
        response =
            MHD_create_response_from_buffer(size, data, MHD_RESPMEM_MUST_FREE);
        status = MHD_HTTP_OK;
      }
    }
  }

  enum MHD_Result ret = MHD_queue_response(connection, status, response);
  MHD_destroy_response(response);
  return ret;
}

/* ---------- main ------------------------------------------------------- */

int main(void) {
  struct MHD_Daemon *daemon =
      MHD_start_daemon(MHD_USE_AUTO | MHD_USE_INTERNAL_POLLING_THREAD, 0, NULL,
                       NULL, &handler, NULL, MHD_OPTION_END);
  if (!daemon) {
    return 1;
  }

  const union MHD_DaemonInfo *info =
      MHD_get_daemon_info(daemon, MHD_DAEMON_INFO_BIND_PORT);
  if (!info) {
    MHD_stop_daemon(daemon);
    return 1;
  }
  unsigned short port = info->port;

  FILE *pf = fopen(PORT_FILE, "w");
  if (!pf) {
    perror("fopen " PORT_FILE);
    MHD_stop_daemon(daemon);
    return 1;
  }
  fprintf(pf, "%u\n", (unsigned)port);
  fclose(pf);

  for (;;) {
    sleep_s(60);
    pool_sweep(time(NULL));
  }

  MHD_stop_daemon(daemon);
  remove(PORT_FILE);

  for (int i = 0; i < MAX_POOL; i++) {
    if (pool[i].handle) {
      tactless_close(pool[i].handle);
    }
  }

  return 0;
}
