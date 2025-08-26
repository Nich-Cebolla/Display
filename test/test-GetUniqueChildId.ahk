
#include C:\Users\Shared\001_Repos\Display\lib\Win32.ahk

if t() {
    OutputDebug('GetUniqueChildId failed.`n')
}

t() {
    g := gui()
    loop 5 {
        g.add('button')
    }
    try {
        id := GetUniqueChildId(g.hwnd)
        return 0
    }
    return 1
}
