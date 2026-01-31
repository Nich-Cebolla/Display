
Display_CreateTestControl(
    HwndGui
    , ExStyle := 0x08000000 ; WS_EX_NOACTIVATE
    , Style := 0x40000000 | 0x08000000 ; WS_CHILD | WS_DISABLED
    , ClassName := 'Static'
    , WindowName := 0
    , X := 0, Y := 0, W := 1, H := 1
    , hMenu := 0
    , hInstance := 0
    , Param := 0
) {
    rc := Display_Rect()
    if !DllCall('GetClientRect', 'ptr', HwndGui, 'ptr', rc, 'int') {
        throw OSError()
    }
    return DllCall(
        'CreateWindowExW'
      , 'uint', ExStyle
      , 'ptr', ClassName is Number ? ClassName : StrPtr(ClassName)
      , 'ptr', WindowName is Number ? WindowName : StrPtr(WindowName)
      , 'uint', Style
      , 'int', X + rc.L
      , 'int', Y + rc.T
      , 'int', W
      , 'int', H
      , 'ptr', HwndGui
      , 'ptr', hMenu
      , 'ptr', hInstance
      , 'ptr', Param
    )
}
Display_FormatText_AOrAn(text) {
    if InStr('AEIOU', SubStr(text, 1, 1)) {
        return 'an ' text
    } else {
        return 'a ' text
    }
}

__Display_Warning_DuplicateFunctionality(cls) {
    name := SubStr(cls.Prototype.__Class, InStr(cls.Prototype.__Class, '.', , , -1) + 1)
    OutputDebug('Display: Your project uses both ``dGui`` and ``' name '``, which offer the '
    'same functionality. When one is in use, the other should be disabled (comment-out '
    '``#include ' name '.ahk`` or ``#include dGui.ahk`` in DisplayConfig.ahk).`n')
}
