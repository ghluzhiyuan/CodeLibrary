#include <dirent.h> 


// define for compile
struct DIR {
};

/**
 * 打印目录了下的所有文件
 */
void *ShowAllFileInDir(const char * szPath) 
{
    struct DIR *pDir = NULL;
    pDir = opendir(szPath);
    if (pDir == NULL)
    {
        printf("pDir is NULL");
        return;
    }

    struct dirent *pstEnt;
    while ((pstEnt = readdir(pDir)) != NULL)
    {
        printf("pstEnt d_type = %X", pstEnt->d_type);
        printf("pstEnt filename = %s", pstEnt->d_name);
    }
}


void main()
{
    ShowAllFileInDir("/data/local/tmp/");
}


