0、使python脚本在lldb中生效
command script import ~/Downloads/tracestep.py

1、记录pc到0x1000383a4之前，每一条指令的变化
tracestep 0x1000383a4


