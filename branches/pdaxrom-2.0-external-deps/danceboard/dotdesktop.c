#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>

#include "util.h"
#include "dotdesktop.h"

static char **get_themes_list(char *theme_name)
{
    char fname[512];
    char str[512];
    
    snprintf(fname, 512, "%s/icons/%s/index.theme", DATADIR, theme_name);
    FILE *f = fopen(fname, "rb");
    if (!f)
	return NULL;
	
    while (fgets(str, 512, f)) {
	if (!strncmp(str, "Inherits=", 9)) {
	}
    }
    fclose(f);
}

db_image *db_get_icon(char *name)
{
    db_image *icon;
    int sizes[] = {64, 48, 36, 32, 24, 16, 0};
    int sizes_index = 0;
    char *theme_name = strdup("Human");
    char *themes[] = {"hicolor", NULL};
    int themes_index = 0;
    char fname[512];
    char dirn[512];
    
    if (!strchr(name, '.'))
	sprintf(fname, "%s.png", name);
    else
	strcpy(fname, name);
		
    sprintf(dirn, "%s/pixmaps/%s", DATADIR, fname);
    fprintf(stderr, "icon %s\n", dirn);
    icon = db_image_load(dirn);
    
    if (icon)
	return icon;

    while (theme_name) {
	while (sizes[sizes_index]) {
	    char dir_tmp[512];
	    snprintf(dir_tmp, 512, "%s/icons/%s/%ix%i", DATADIR, theme_name, sizes[sizes_index], sizes[sizes_index]);

	    //fprintf(stderr, "check dir %s\n", dir_tmp);

	    if (db_file_exists(dir_tmp)) {
		DIR *dp;
		struct dirent *dir_entry;
		struct stat stat_info;
		if ((dp = opendir(dir_tmp)) != NULL) {
		    while((dir_entry = readdir(dp)) != NULL) {
			lstat(dir_entry->d_name, &stat_info);
			if (S_ISDIR(stat_info.st_mode)
			    && strcmp(dir_entry->d_name, ".") != 0
			    && strcmp(dir_entry->d_name, "..") != 0) {
			    char tmp[512];
			    snprintf(tmp, 512, "%s/%s/%s", dir_tmp, dir_entry->d_name, fname);
			
			    //fprintf(stderr, "check subdir %s\n", tmp);
			
			    if (db_file_exists(tmp)) {
				icon = db_image_load(tmp);
				if (icon) {
				    closedir(dp);
				    return icon;
				}
			    }
			}
		    }
		    closedir(dp);
		}
	    }
	    sizes_index++;
	}
	snprintf(dirn, 512, "%s/icons/%s/index.theme", DATADIR, theme_name);

	//fprintf(stderr, "check index.theme %s\n", dirn);

	free(theme_name);
	theme_name = NULL;

        FILE *f = fopen(dirn, "rb");
	if (f) {
	    char str[512];
	    
	    while (fgets(str, 512, f) > 0) {
		str[strlen(str) - 1] = 0;
		if (!strncmp(str, "Inherits=", 9)) {
		    char *p = strchr(str + 9, ',');
		    if (p)
			*p = 0;
		    theme_name = strdup(str + 9);
		    //fprintf(stderr, "Inherits %s\n", theme_name);
		    break;
		}
	    }
	    fclose(f);
	}
	
	if (!theme_name && themes[themes_index]) {
	    theme_name = strdup(themes[themes_index++]);
	}
	
	sizes_index = 0;
    }

    sprintf(dirn, "%s/app-install/icons/%s", DATADIR, fname);
    fprintf(stderr, "icon %s\n", dirn);
    icon = db_image_load(dirn);
    
    if (icon)
	return icon;

    return NULL;
}

db_app *db_parse_desktop_file(char *file)
{
    char buf[1024];
    
    FILE *f = fopen(file, "rb");
    if (!f)
	return NULL;

    db_app *app = (db_app *) malloc(sizeof(db_app));
    if (!app)
	return NULL;

    memset(app, 0, sizeof(db_app));

    while (fgets(buf, 1024, f)) {
	char *ptr = buf;
	
	ptr[strlen(ptr) - 1] = 0;
	
	while (isspace(*ptr))
	    ptr++;

	if (ptr[0] == 0)
	    continue;

	if (!strncmp(ptr, "Name=", 5) &&
	    !app->name)
	    app->name = strdup(ptr + 5);

	if (!strncmp(ptr, "Exec=", 5) &&
	    !app->exec)
	    app->exec = strdup(ptr + 5);
	
	if (!strncmp(ptr, "Icon=", 5) &&
	    !app->icon) {
	    char imgf[512];
	    
	    if (!strchr(ptr + 5, '.'))
		sprintf(imgf, "%s.png", ptr + 5);
	    else
		strcpy(imgf, ptr + 5);
		
	    app->icon = db_get_icon(imgf);
	    
	    if (!app->icon) {
		char dirn[512];
		sprintf(dirn, "%s/pixmaps/apple-red.png", DATADIR);
		fprintf(stderr, "icon %s\n", dirn);
		app->icon = db_image_load(dirn);
	    }
	    
	}
    }
    
    return app;
}
