#import <Foundation/Foundation.h>
#import <substrate.h>


#define DEBUG 1
#if DEBUG
# define DEBUGLOG(fmt, ...) \
    NSLog((@"[InlineAsm] [Line %d]: "  fmt), __LINE__, ##__VA_ARGS__)
#else
# define DEBUGLOG(...)
#endif /* DEBUG */


unsigned long (*OriginalGetTouchCount)();
unsigned long HookGetTouchCount(){

    unsigned long reg_x0 = 0;

    // read register
    __asm__ volatile(
            "mov %[RegX0], x0 \t\n"
            :[RegX0]"=r"(reg_x0)
            );
    DEBUGLOG(@"after read, x0 = %lx", reg_x0);

    // write register
    __asm__ volatile(
        "mov x0, %[RegX0] \t\n"
        :
        :[RegX0]"r"(reg_x0)
    );
    DEBUGLOG(@"after write, x0 = %lx", reg_x0);

    return OriginalGetTouchCount();
}


static void __attribute__((constructor)) constructor() {

    // symbol is export
    void* GetTouchCount_addr = (void *)MSFindSymbol(NULL, "__Z13GetTouchCountv");
    MSHookFunction(GetTouchCount_addr, (void *)HookGetTouchCount, (void **)&OriginalGetTouchCount);
    DEBUGLOG(@"Hook GetTouchCount in %p", GetTouchCount_addr);

    // symbol not export
    /*
    MSImageRef module_base = MSGetImageByName("/var/containers/Bundle/Application/2F94F520-F201-4E8A-A583-C29BD1DB2646/ProductName.app/ProductName");
    unsigned long Func_addr = (unsigned long)module_base - 0x100000000 + 0x1006584B8;
    MSHookFunction((void *)Func_addr, (void *)HookGetTouchCount, (void **)&OriginalGetTouchCount);
    DEBUGLOG(@"Hook Func in 0x%lx", Func_addr);
    */
}








