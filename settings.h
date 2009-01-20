#ifndef _SETTINGS_H_
#define _SETTINGS_H_

#define DB_KEY_BOOT_OPTION	"1"
#define DB_KEY_VIDEO_MODE	"2"

int db_database_init(void);

int db_database_close(void);

int db_database_get(char *key, u_int32_t *val);

int db_database_set(char *key, u_int32_t val);

#endif
