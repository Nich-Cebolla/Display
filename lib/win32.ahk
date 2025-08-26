
GetUniqueChildId(parentHwnd) {
    lParam := Buffer(8 + A_PtrSize)
    cb := CallbackCreate(_EnumChildProc)
    NumPut(
        'uint', Random(1, 4294967295)
      , 'uint', 0
      , 'ptr', DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'user32', 'ptr'), 'astr', 'GetDlgCtrlID', 'ptr')
      , lParam
      , 0
    )
    loop 100 { ; 100 is arbitrary
        DllCall('EnumChildWindows', 'ptr', parentHwnd, 'ptr', cb, 'ptr', lParam)
        if !NumGet(lParam, 4, 'uint') {
            CallbackFree(cb)
            return NumGet(lParam, 0, 'uint')
        }
        NumPut('uint', Random(1, 4294967295), 'uint', 0, lParam, 0)
    }
    CallbackFree(cb)
    throw Error('Failed to create a unique id.', -1)

    _EnumChildProc(childHwnd, lParam) {
        if DllCall(NumGet(lParam, 8, 'ptr'), 'ptr', childHwnd, 'int') = NumGet(lParam, 0, 'uint') {
            NumPut('uint', 1, lParam, 4)
            return 0
        }
        return 1
    }
}
