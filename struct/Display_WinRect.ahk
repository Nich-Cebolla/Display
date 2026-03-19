
class Display_WinRect extends Display_Rect {
    static __New() {
        this.DeleteProp('__New')
        Display_WinRect_SetConstants()
    }
    /**
     * @param {Integer} [Hwnd = 0] - The window handle.
     * @param {Integer} [Flag = 0] - A flag that determines what function is called when
     * measuring the window's dimensions.
     * - 0 : `GetWindowRect`
     * - 1 : `GetClientRect`
     * - 2 : `DwmGetWindowAttribute` passing DWMWA_EXTENDED_FRAME_BOUNDS to dwAttribute.
     *   See {@link https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmgetwindowattribute}.
     * - 3 : `GetWindowRect` is called, then `ScreenToClient` is called for both coordinates using
     *   the parent window's client area for the conversion. If `Hwnd` is a control's window handle,
     *   this would be the same as calling
     *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#GetPos Gui.Control.Prototype.GetPos}.
     * - 4 : `GetWindowRect` is called for both the window and its parent window, then it calculates
     *   the position of the window relative to the top-left corner of the parent window's display
     *   area (including non-client area).
     *
     * Some controls / windows will cause `DwmGetWindowAttribute` to throw an error.
     *
     * For more information see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect}.
     */
    __New(Hwnd := 0, Flag := 0) {
        this.Size := 16
        this.Flag := Flag
        if this.Hwnd := Hwnd {
            this()
        }
    }
    Call(*) {
        switch this.Flag, 0 {
            case 0:
                if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
            case 1:
                if !DllCall(g_user32_GetClientRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
            case 2:
                if HRESULT := DllCall(g_dwmapi_DwmGetWindowAttribute, 'ptr', this.Hwnd, 'uint', 9, 'ptr', this.Ptr, 'uint', 16, 'uint') {
                    throw OSError('``DwmGetWindowAttribute`` failed.', , 'HRESULT: ' Format('{:X}', HRESULT))
                }
            case 3:
                hwndParent := DllCall(g_user32_GetParent, 'ptr', this.Hwnd, 'ptr') || this.Hwnd
                if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
                if !DllCall(g_user32_ScreenToClient, 'ptr', hwndParent, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
                if !DllCall(g_user32_ScreenToClient, 'ptr', hwndParent, 'ptr', this.Ptr + 8, 'int') {
                    throw OSError()
                }
            case 4:
                hwndParent := DllCall(g_user32_GetParent, 'ptr', this.Hwnd, 'ptr') || this.Hwnd
                if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
                wrc := Display_WinRect(hwndParent, 0)
                this.l -= wrc.l
                this.r -= wrc.l
                this.t -= wrc.t
                this.b -= wrc.t
        }
    }
    Apply(InsertAfter := 0, Flags := 0) {
        return DllCall(g_user32_SetWindowPos, 'ptr', this.Hwnd, 'ptr', InsertAfter, 'int', this.L, 'int', this.T, 'int', this.W, 'int', this.H, 'uint', Flags, 'int')
    }
    GetPos(&X?, &Y?, &W?, &H?) {
        this()
        X := this.L
        Y := this.T
        W := this.W
        H := this.H
    }
    MapPoints(wrc, points) {
        return DllCall(g_user32_MapWindowPoints, 'ptr', this.Hwnd, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', points, 'uint', points.Size / 8, 'int')
    }
    Move(X?, Y?, W?, H?, InsertAfter := 0, Flags := 0) {
        this()
        if IsSet(X) {
            this.L := X
        }
        if IsSet(Y) {
            this.T := Y
        }
        if IsSet(W) {
            this.W := W
        }
        if IsSet(H) {
            this.H := H
        }
        if !DllCall(g_user32_SetWindowPos, 'ptr', this.Hwnd, 'ptr', InsertAfter, 'int', this.L, 'int', this.T, 'int', this.W, 'int', this.H, 'uint', Flags, 'int') {
            throw OSError()
        }
    }
}

Display_WinRect_SetConstants(force := false) {
    global
    if IsSet(Display_WinRect_constants_set) {
        if !force {
            return
        }
    } else {
        if !IsSet(g_dwmapi_DwmGetWindowAttribute) {
            g_dwmapi_DwmGetWindowAttribute := 0
        }
        if !IsSet(g_user32_GetClientRect) {
            g_user32_GetClientRect := 0
        }
        if !IsSet(g_user32_GetParent) {
            g_user32_GetParent := 0
        }
        if !IsSet(g_user32_GetWindowRect) {
            g_user32_GetWindowRect := 0
        }
        if !IsSet(g_user32_MapWindowPoints) {
            g_user32_MapWindowPoints := 0
        }
        if !IsSet(g_user32_ScreenToClient) {
            g_user32_ScreenToClient := 0
        }
        if !IsSet(g_user32_SetWindowPos) {
            g_user32_SetWindowPos := 0
        }
    }

    Display_Window_LibraryToken := LibraryManager(
        'dwmapi', [
            'DwmGetWindowAttribute'
        ],
        'user32', [
            'GetClientRect',
            'GetParent',
            'GetWindowRect',
            'MapWindowPoints',
            'ScreenToClient',
            'SetWindowPos'
        ]
    )

    Display_WinRect_constants_set := true
}
