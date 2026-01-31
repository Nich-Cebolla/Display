
__ControlGetTextExtentEx_Process(Hwnd, Ptr, len, MaxExtent, &OutCharacterFit?, &OutExtentPoints?) {
    context := SelectFontIntoDc(Hwnd)
    OutCharacterFit := 0
    OutExtentPoints := Display_IntegerArray(len)
    sz := Display_Size()
    if MaxExtent {
        if DllCall(
            g_gdi32_GetTextExtentExPointW
            , 'ptr', context.hdc
            , 'ptr', Ptr
            , 'int', len
            , 'int', MaxExtent
            , 'int*', &OutCharacterFit
            , 'ptr', OutExtentPoints
            , 'ptr', sz
            , 'ptr'
        ) {
            context()
            return sz
        } else {
            context()
            throw OSError()
        }
    } else {
        if DllCall(
            g_gdi32_GetTextExtentExPointW
            , 'ptr', context.hdc
            , 'ptr', Ptr
            , 'int', len
            , 'int', 0
            , 'ptr', 0
            , 'ptr', OutExtentPoints
            , 'ptr', sz
            , 'ptr'
        ) {
            context()
            return sz
        } else {
            context()
            throw OSError()
        }
    }
}
