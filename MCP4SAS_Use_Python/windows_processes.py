"""Identify owned Windows descendants before requesting a graceful shutdown.

Creation times guard against terminating a PID that has since been reused.
No process names, command lines or account information leave these helpers.
"""
def identity(pid):
    import ctypes
    from ctypes import wintypes as w
    kernel=ctypes.WinDLL('kernel32',use_last_error=True)
    kernel.OpenProcess.argtypes=[w.DWORD,w.BOOL,w.DWORD];kernel.OpenProcess.restype=w.HANDLE
    kernel.CloseHandle.argtypes=[w.HANDLE];kernel.CloseHandle.restype=w.BOOL
    kernel.GetProcessTimes.argtypes=[w.HANDLE,*([ctypes.POINTER(w.FILETIME)]*4)]
    kernel.GetProcessTimes.restype=w.BOOL
    handle=kernel.OpenProcess(0x1000,False,pid)
    if not handle: return None
    try:
        times=[w.FILETIME() for _ in range(4)]
        if not kernel.GetProcessTimes(handle,*(ctypes.byref(t) for t in times)): return None
        return times[0].dwLowDateTime,times[0].dwHighDateTime
    finally: kernel.CloseHandle(handle)

def owned_tree(pid):
    import ctypes
    from ctypes import wintypes as w
    class Entry(ctypes.Structure):
        _fields_=[('dwSize',w.DWORD),('cntUsage',w.DWORD),('pid',w.DWORD),
                  ('heap',ctypes.c_size_t),('module',w.DWORD),('threads',w.DWORD),
                  ('parent',w.DWORD),('priority',w.LONG),('flags',w.DWORD),('name',w.WCHAR*260)]
    root_stamp=identity(pid)
    if root_stamp is None: return {}
    kernel=ctypes.WinDLL('kernel32',use_last_error=True)
    kernel.CreateToolhelp32Snapshot.argtypes=[w.DWORD,w.DWORD]
    kernel.CreateToolhelp32Snapshot.restype=w.HANDLE
    for function in (kernel.Process32FirstW,kernel.Process32NextW):
        function.argtypes=[w.HANDLE,ctypes.POINTER(Entry)];function.restype=w.BOOL
    kernel.CloseHandle.argtypes=[w.HANDLE];kernel.CloseHandle.restype=w.BOOL
    handle=kernel.CreateToolhelp32Snapshot(2,0)
    if handle==ctypes.c_void_p(-1).value: raise OSError('Cannot enumerate the owned Windows process tree')
    parents={}
    try:
        entry=Entry();entry.dwSize=ctypes.sizeof(entry)
        more=kernel.Process32FirstW(handle,ctypes.byref(entry))
        while more:
            parents[entry.pid]=entry.parent
            more=kernel.Process32NextW(handle,ctypes.byref(entry))
    finally: kernel.CloseHandle(handle)
    selected={pid}
    while True:
        children={child for child,parent in parents.items() if parent in selected}
        if children<=selected: break
        selected.update(children)
    root_ticks=(root_stamp[1]<<32)|root_stamp[0]
    return {child:stamp for child in selected if (stamp:=identity(child)) is not None
            and ((stamp[1]<<32)|stamp[0])>=root_ticks}
