# -*- coding:utf-8 -*-

import os
import sys
import re

PayloadProc = 0x0045DCC8 #1.24.4.6387

###############################################################
carsh_re = re.compile(r"\={78}[\s\S]*\-{78}")
war3_version_re = re.compile(r"Warcraft\ III\ \(build\ (?P<VERSION>[0-9]*)\)")
map_path_re = re.compile(r"Played (?P<MAP_PATH>.*)")
map_name_re = re.compile(r"([^\\]*\\)*(?P<MAP_NAME>[^\\]*)\.w3x")
stack_trace_re = re.compile(r"\-{40}[\s]*Stack Trace \(Using DBGHELP.DLL\)[\s]*\-{40}(?P<STACK_TRACE>[\s\S]*?)\-{40}")
loaded_modules_re = re.compile(r"\-{40}[\s]*Loaded Modules[\s]*\-{40}(?P<LOADED_MODULES>[\s\S]*?)\-{40}")
memory_dump_re = re.compile(r"\-{40}[\s]*Memory Dump[\s]*\-{40}(?P<MEMORY_DUMP>[\s\S]*?)\-{40}")
parse_loaded_modules_re = re.compile(r"0x(?P<BASE>[0-9A-Fa-f]{8})\ \-\ 0x[0-9A-Fa-f]{8}\ (?P<NAME>.*)")
parse_game_dll_re = re.compile(r"(\\|\/|\ )game\.dll")
parse_memory_dump_re = re.compile(r"(?P<ADDR>[0-9A-F]{2}\ [0-9A-F]{2}\ [0-9A-F]{2}\ [0-9A-F]{2})")
###############################################################
def conver_hexstringt(s):
    return int(s[9:11] + s[6:8] + s[3:5] + s[0:2], 16)   
###############################################################
def read_funclist():
    funclist = {}
    try:
        f  = file('funclist24e.txt', "r")
        try:
            for line in f:
                 funclist[line[0:8]] = line[9:-1]
        finally:
            f.close()
    except IOError:
        print '  ├-Fail To Load Function List！'
    return funclist
###############################################################
def read_carsh(buf):
    return carsh_re.search(buf).group()
###############################################################
def read_war3_version(buf):
    return int(war3_version_re.search(buf).group('VERSION'))
###############################################################
def read_map_path_and_name(buf):
    path = map_path_re.search(buf).group('MAP_PATH')
    name = map_name_re.match(path).group('MAP_NAME')
    return path, name
###############################################################
def read_stack_trace(buf):
    return stack_trace_re.search(buf).group('STACK_TRACE')
###############################################################
def read_loaded_modules(buf):
    return loaded_modules_re.search(buf).group('LOADED_MODULES')
###############################################################
def read_memory_dump(buf):
    return memory_dump_re.search(buf).group('MEMORY_DUMP')
###############################################################
def get_game_dll_base(buf):
    try:
        dll_list = read_loaded_modules(buf)
        while True:
            m = parse_loaded_modules_re.search(dll_list)
            if not m:
                break
            
            if parse_game_dll_re.search(m.group('NAME').lower()):
                return int(m.group('BASE'), 16)
            dll_list = dll_list[m.end():]
    except:
        pass
    #print '    ├-basic address of Game.dll not found- Using default value'
    return 0x6F000000
###############################################################
def get_addr_list(buf):
    addr_list = read_memory_dump(buf)
    while True:
        m = parse_memory_dump_re.search(addr_list)
        if not m:
            break
        addr_list = addr_list[m.end():]
        yield conver_hexstringt(m.group('ADDR'))
###############################################################
def get_hex_string(n):
    a = chr(n/256/256/256%256)
    b = chr(n/256/256%256)
    c = chr(n/256%256)
    d = chr(n%256)
    if (a.isalpha() or a.isdigit()) and (b.isalpha() or b.isdigit()) and (c.isalpha() or c.isdigit()) and (d.isalpha() or d.isdigit()):
        return '%08X(%s%s%s%s)' % (n, a, b, c, d)
    else:
        return '%08X' % n    

###############################################################
def parse_buf(buf, funclist, map_list):
    try:
        #print '  ├-Analyzing Crash Log...'
        buf = read_carsh(buf)
        #print '  ├-Loading War3 Version...'
        ver = read_war3_version(buf)
        #print '    ├-Version %d' % ver
        if ver != 6387:
            #print '    ├-Don`t Support this version(%d)！' % ver
            return
        path, name = read_map_path_and_name(buf)
        if name in map_list:
            map_list[name] = map_list[name] + 1
        else:
            map_list[name] = 1
        map_list['total'] = map_list['total'] + 1
        #print '  ├-Load Address of Game.dll ...'
        base = get_game_dll_base(buf)
        #print '    ├-Game.dll 0x%08X' % base
        #print '  ├-Parsing the Address....'
        #print '  └-=========================================='

        param = []
        found = False
        for addr_int in get_addr_list(buf):
            if found:
                param.append(addr_int)
            if addr_int > base:
                addr_int = addr_int-base
                if not found:
                    if addr_int == PayloadProc:
                        found = True
                else:                
                    if ('%08X' % addr_int) in funclist:
                        param_count = int(funclist['%08X' % addr_int][0:2])
                        s = '      Crashed Function Detected %s(' % funclist['%08X' % addr_int][3:]
                        for i in range(0, param_count):
                            s = s + get_hex_string(param[i]) + ', '
                        s = s + ')'
                        print s
                        print '      %s' % name
                        break
        #print '  ┌-=========================================='
        #print '  ├-Process finished.'
    except:
        #print '  ├-Crashed！'
        pass
###############################################################
def parse_file(filename, funclist, map_list):
    try:
        #print ' Load Crash Logs[%s]...' % filename
        f  = file(filename, "r")
        try:
            parse_buf(f.read(), funclist, map_list)
        finally:
            f.close()
    except IOError:
        #print '  ├-Fail To Load Dump Files！'
        pass
###############################################################
class Redirect:
    def __init__(self, stdout):
        self.stdout = stdout
        self.__f  = file('report.txt', "w")
    def __del__(self):
        self.__f.close()       
    def write(self, s):
        self.__f.write(s)
        self.stdout.write(s)
old_stdout = sys.stdout
sys.stdout = Redirect(sys.stdout)
###############################################################
def main():
    print 'Crash Parsing v0.0.2'
    print '    --by actboy168'
    print '================================================' 
    #print 'Load Function List...'
    funclist = read_funclist()
    #print '  ├-%d functions loaded' % len(funclist)
    path = 'Errors'
    map_list = {}
    map_list['total'] = 0
    for item in os.listdir(path):
        if os.path.splitext(item)[1] == '.txt':
            parse_file(os.path.join(path, item), funclist, map_list)   
    print '--End--'
    print 'total ' + str(map_list['total'])
    for k, v in map_list.items():
        if k != 'total':
            print str(v) + ' ' + k
###############################################################
if __name__ == "__main__":
    main()
