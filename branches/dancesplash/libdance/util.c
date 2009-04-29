#include <stdio.h>
#include <sys/stat.h>

int db_file_exists(char *file)
{
    struct stat st;
    
    if (stat(file, &st))
	return 0;

    return 1;
}
