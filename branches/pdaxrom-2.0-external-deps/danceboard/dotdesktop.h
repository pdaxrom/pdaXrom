#ifndef _DOTDESKTOP_H_
#define _DOTDESKTOP_H_

#include "board.h"

db_app *db_parse_desktop_file(char *file);
db_image *db_get_icon(char *name);

#endif
