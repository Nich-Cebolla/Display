

/**
 * @description - See {@link https://learn.microsoft.com/en-us/windows/win32/hidpi/wm-dpichanged}.
 * @param {Integer} wParam - The HIWORD of the wParam contains the Y-axis value of the new dpi of
 * the window. The LOWORD of the wParam contains the X-axis value of the new DPI of the window. For
 * example, 96, 120, 144, or 192. The values of the X-axis and the Y-axis are identical for Windows
 * apps.
 * @param {Integer} RecommendedRect - A pointer to a RECT structure that provides a suggested size
 * and position of the current window scaled for the new DPI. The expectation is that apps will
 * reposition and resize windows based on the suggestions provided by lParam when handling this
 * message.
 * @param {Integer} Message - The message, WM_DPICHANGED (0x02E0).
 * @param {Integer} Hwnd - The handle to the gui window.
 */
OnDpiChanged(wParam, RecommendedRect, Message, Hwnd) {
    Critical(-1)
    guiObj := GuiFromHwnd(Hwnd)
    ; If using multiple guis, you can define a property "DpiExclude" on a gui object to direct
    ; the function to skip processing that gui.
    if !guiObj || (HasProp(guiObj, 'DpiExclude') && guiObj.DpiExclude) {
        return
    }
    DllCall(g_user32_SetThreadDpiAwarenessContext, 'ptr', -4, 'ptr')
    SendMessage(0x000B, false, 0, , Hwnd) ; WM_SETREDRAW
    newDpi := wParam & 0xFFFF
    ; BASE_DPI is typically defined in DisplayConfig.ahk.
    dpiRatio := newDpi / BASE_DPI
    ; Sets the window's dimensions to the recommended values.
    if !DllCall(
        g_user32_SetWindowPos
        , 'ptr', Hwnd
        , 'ptr', 0
        , 'int', NumGet(RecommendedRect, 0, 'int')
        , 'int', NumGet(RecommendedRect, 4, 'int')
        , 'int', NumGet(RecommendedRect, 8, 'int') - NumGet(RecommendedRect, 0, 'int')
        , 'int', NumGet(RecommendedRect, 12, 'int') - NumGet(RecommendedRect, 4, 'int')
        , 'uint', 0x0004 | 0x0010 ; SWP_NOZORDER | SWP_NOACTIVATE
        , 'int'
    ) {
        throw OSError()
    }

    ; dGui objects increment the "Count" property each time dGui.Prototype.Add is called (or any of
    ; the specific Add<Type> methods). If using this with a Gui object, replace guiObj.Count with
    ; something else. See
    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-begindeferwindowpos
    ; for guidance.
    if !(hdwp := DllCall(g_user32_BeginDeferWindowPos, 'int', guiObj.Count, 'ptr')) {
        throw OSError()
    }

    ; Add logic to resize / reposition controls. Use the DeferWindowPos snippet at the bottom of
    ; this file for each control.

    if !DllCall(g_user32_EndDeferWindowPos, 'ptr', hdwp, 'ptr') {
        throw OSError()
    }
    SendMessage(0x000B, true, 0, , Hwnd) ; WM_SETREDRAW
    guiObj.CachedDpi := newDpi
}

/*

    if !(hdwp := DllCall(
        g_user32_DeferWindowPos
        , 'ptr', hdwp
        , 'ptr', Ctrl.Hwnd
        , 'ptr', 0
        , 'int',  ; X
        , 'int',  ; Y
        , 'int',  ; W
        , 'int',  ; H
        , 'uint', 0x0004 | 0x0010 ; SWP_NOZORDER | SWP_NOACTIVATE
        , 'ptr'
    )) {
        throw OSError()
    }
