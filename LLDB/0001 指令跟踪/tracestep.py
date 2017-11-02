#!/usr/bin/python
#coding:utf-8

import lldb

g_logpath_format = "/Users/zhiyuanlu/Documents/tracestep.{0}.txt"
g_fd = None 
g_stop_addr = 0


# 获取寄存器信息
def getRegisters(frame):
    d = {}
    registerSet = frame.GetRegisters() # Returns an SBValueList.
    for regs in registerSet:
        if 'general purpose registers' in regs.GetName().lower():
            GPRs = regs
            break
        else:
            GPRs = []

    for reg in GPRs:
        d[reg.GetName().lower()] = reg

    return d


# 单步
def step():
    lldb.debugger.HandleCommand('stepi')
        

# 记录信息
def record():
    global g_fd

    target = lldb.debugger.GetSelectedTarget()
    process = target.GetProcess()
    thread = process.GetSelectedThread()
    frame = thread.GetSelectedFrame()
    regs = getRegisters(frame)
    x0 = regs['x0'].unsigned
    x1 = regs['x1'].unsigned
    x2 = regs['x2'].unsigned
    x3 = regs['x3'].unsigned
    x4 = regs['x4'].unsigned
    x5 = regs['x5'].unsigned
    x6 = regs['x6'].unsigned
    x7 = regs['x7'].unsigned
    pc = regs['pc'].unsigned

    lldb.debugger.HandleCommand('register read pc')
    g_fd.write("pc = {}, x0 = {}, x1 = {}, x2 = {}, x3 = {}, x4 = {}, x5 = {}, x6 = {}, x7 = {}\n".format(hex(pc), hex(x0), hex(x1), hex(x2), hex(x3), hex(x4), hex(x5), hex(x6), hex(x7)))


# 判断是否结束 
def isContinue():
    global g_stop_addr
    target = lldb.debugger.GetSelectedTarget()
    process = target.GetProcess()
    thread = process.GetSelectedThread()
    frame = thread.GetSelectedFrame()
    regs = getRegisters(frame)
    pc_addr = regs['pc'].unsigned
    if pc_addr != g_stop_addr:
        return True
    else:
        return False

       
# tracestep
def tracestep(debugger, command, result, internal_dict):
    global g_logpath
    global g_fd
    global g_stop_addr

    if not command:
        print 'Please input the stop address! (addr must be hex), eg:tracestep 0x1234'
        return

    g_stop_addr = int(command,16)

    logpath = g_logpath_format.format(hex(g_stop_addr))
    g_fd = open(logpath, "w")
    while(isContinue()):
        step()
        record()
        isContinue()
    g_fd.close()


# And the initialization code to add your commands 
# 'command script import tracestep.py' : 给lldb中增加脚本文件tracestep.py
def __lldb_init_module(debugger, internal_dict):
    # 'command script add tracestep' : 给lldb增加一个'tracestep'命令
    # '-f tracestep.tracestep' : 该命令调用了tracestep文件的tracestep函数
    debugger.HandleCommand('command script add tracestep -f tracestep.tracestep')
    print 'The "tracestep" python command has been installed and is ready for use.'
