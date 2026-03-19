
Display_SetConstants(force := false) {
    global
    if IsSet(Display_constants_set) {
        if !force {
            return
        }
    } else {
        if !IsSet(g_gdi32_GetTextExtentExPointW) {
            g_gdi32_GetTextExtentExPointW := 0
        }
        if !IsSet(g_gdi32_GetTextExtentPoint32W) {
            g_gdi32_GetTextExtentPoint32W := 0
        }
        if !IsSet(g_gdi32_SelectObject) {
            g_gdi32_SelectObject := 0
        }
        if !IsSet(g_msvcrt_memmove) {
            g_msvcrt_memmove := 0
        }
        if !IsSet(g_user32_CreateWindowExW) {
            g_user32_CreateWindowExW := 0
        }
        if !IsSet(g_user32_GetClientRect) {
            g_user32_GetClientRect := 0
        }
        if !IsSet(g_user32_GetDC) {
            g_user32_GetDC := 0
        }
        if !IsSet(g_user32_GetWindowRect) {
            g_user32_GetWindowRect := 0
        }
        if !IsSet(g_user32_ReleaseDC) {
            g_user32_ReleaseDC := 0
        }
    }
    Display_LibraryToken := LibraryManager(
        'gdi32', [
            'GetTextExtentExPointW',
            'GetTextExtentPoint32W',
            'SelectObject'
        ],
        'msvcrt', [ 'memmove' ],
        'user32', [
            'CreateWindowExW',
            'GetClientRect',
            'GetDC',
            'GetWindowRect',
            'ReleaseDC'
        ]
    )
    Display_constants_set := true
}

Display_FormatText_AOrAn(text) {
    if InStr('AEIOU', SubStr(text, 1, 1)) {
        return 'an ' text
    } else {
        return 'a ' text
    }
}

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
    rc := Rect()
    if !DllCall(g_user32_GetClientRect, 'ptr', HwndGui, 'ptr', rc, 'int') {
        throw OSError()
    }
    return DllCall(
        g_user32_CreateWindowExW
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

__Display_Warning_DuplicateFunctionality(cls) {
    name := SubStr(cls.Prototype.__Class, InStr(cls.Prototype.__Class, '.', , , -1) + 1)
    OutputDebug('Display: Your project uses both ``dGui`` and ``' name '``, which offer the '
    'same functionality. When one is in use, the other should be disabled (comment-out '
    '``#include ' name '.ahk`` or ``#include dGui.ahk`` in DisplayConfig.ahk).`n')
}
