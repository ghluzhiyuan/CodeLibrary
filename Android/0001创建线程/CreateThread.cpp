#include <Android/log.h>
#include <pthread.h>


/**
 * Android.mk文件中需添加 LOCAL_LDLIBS += -llog
 * 这样链接时才能通过
 * /
#define LOG_TAG "luzy"
#define LOGI(fmt, args...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, fmt, ##args);


/**
 * 起一个线程，当系统属性 target.pid 为当前进程时，打印log
 */
void *DumpThread(void *) 
{
    while(true)
    {
        sleep(3);

        char pszDumpPid[PROP_VALUE_MAX] = {0};
        __system_property_get("target.pid", pszDumpPid);

        int nDumpPid = 0;
        sscanf(pszDumpPid, "%d", &nDumpPid);

		int nSelfPid = getpid();
        if (nSelfPid == nDumpPid) 
        {
            LOGI("find target pid = %d \n", nDumpPid);
            break;
        }
    }

    return NULL;
}


void main()
{
	pthread_t threadId;
	pthread_create(&threadId, NULL, DumpThread, NULL);
}
