
/**
 * @description - Determines whether two DPI_AWARENESS_CONTEXT values are identical. A
 * DPI_AWARENESS_CONTEXT contains multiple pieces of information. For example, it includes both the
 * current and the inherited DPI_AWARENESS values. AreDpiAwarenessContextsEqual ignores informational
 * flags and determines if the values are equal. You can't use a direct bitwise comparison because
 * of these informational flags.
 * @param {Integer} DpiContextA - The first value to compare.
 * @param {Integer} [DpiContextB] - The second value to compare. If unset, uses the return value
 * from `GetThreadDpiAwarenessContext`.
 * @returns {Boolean} - 1 if true, else 0.
 */
AreDpiAwarenessContextsEqual(DpiContextA, DpiContextB?) {
    return DllCall('AreDpiAwarenessContextsEqual', 'ptr', DpiContextA, 'ptr', DpiContextB ?? GetThreadDpiAwarenessContext(), 'uint')
}

/**
 * @description - Gets a DPI_AWARENESS_CONTEXT handle for the specified process.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiawarenesscontextforprocess}
 * @param {Integer} [hProcess=0] - A handle to the process for which the DPI awareness context is
 * retrieved. If 0, the context is retrieved for the current process.
 * @returns {Integer} - The DPI_AWARENESS_CONTEXT for the specified process.
 */
GetDpiAwarenessContextForProcess(hProcess := 0) {
    return DllCall('GetDpiAwarenessContextForProcess', 'ptr', hProcess, 'ptr')
}


/**
 * @description - A DPI_AWARENESS_CONTEXT contains multiple pieces of information. For example, it
 * includes both the current and the inherited DPI_AWARENESS. This method retrieves the DPI_AWARENESS
 * from the structure.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getawarenessfromdpiawarenesscontext}
 * @param {Integer} DPI_AWARENESS_CONTEXT - The `DPI_AWARENESS_CONTEXT` from which to obtain the
 * DPI_AWARENESS.
 * @returns {Integer} - The DPI_AWARENESS value.
 */
GetAwarenessFromDpiAwarenessContext(DPI_AWARENESS_CONTEXT) {
    return DllCall('GetAwarenessFromDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'ptr')
}

/**
 * @description - DPI_AWARENESS_CONTEXT handles associated with values of
 * DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE and DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 will
 * return a value of 0 for their DPI. This is because the DPI of a per-monitor-aware window can
 * change, and the actual DPI cannot be returned without the window's HWND.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpifromdpiawarenesscontext}
 * @param {Integer} DPI_AWARENESS_CONTEXT - The DPI_AWARENESS_CONTEXT from which to obtain the
 * dpi.
 * @returns {Integer} - The dpi value.
 */
GetDpiFromDpiAwarenessContext(DPI_AWARENESS_CONTEXT) {
    return DllCall('GetDpiFromDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'uint')
}

/**
 * @description - This API is not DPI aware and should not be used if the calling thread is
 * per-monitor DPI aware. For the DPI-aware version of this API, see GetDpiForWindow. When you call
 * GetDpiForMonitor, you will receive different DPI values depending on the DPI awareness of the
 * calling application. DPI awareness is an application-level property usually defined in the
 * application manifest. For more information about DPI awareness values, see PROCESS_DPI_AWARENESS.
 * The following table indicates how the results will differ based on the PROCESS_DPI_AWARENESS
 * value of your application.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/nf-shellscalingapi-getdpiformonitor}
 * @param {Integer} Hmonitor - The handle of the monitor being queried.
 * @param {Integer} [DpiType=MDT_DEFAULT] - The type of DPI being queried. Possible values are from the
 * MONITOR_DPI_TYPE enumeration.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/ne-shellscalingapi-monitor_dpi_type}
 * @returns {Integer} - If succesful, the dpi for the monitor. If unsuccessful, an empty string.
 * An unsuccessful function call would be caused by an invalid parameter.
 */
GetDpiForMonitor(Hmonitor, DpiType := MDT_DEFAULT ?? 0) {
    if !DllCall('Shcore\GetDpiForMonitor', 'ptr'
    , Hmonitor, 'ptr', DpiType, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'uint') {
        return DpiX
    }
}

/**
 * @description - The return value will be dependent based upon the calling context. If the current
 * thread has a DPI_AWARENESS value of DPI_AWARENESS_UNAWARE, the return value will be 96. That is
 * because the current context always assumes a DPI of 96. For any other DPI_AWARENESS value, the
 * return value will be the actual system DPI. You should not cache the system DPI, but should use
 * GetDpiForSystem whenever you need the system DPI value.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiforsystem}
 * @returns {Integer} - The system DPI value.
 */
GetDpiForSystem() {
    return DllCall('GetDpiForSystem', 'uint')
}

/**
 * @description - Returns the dots per inch (dpi) value for the specified window.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiforwindow}
 * @param {Integer} hWnd - The window handle.
 * @returns {Integer} - The DPI for the window, which depends on the DPI_AWARENESS of the window.
 * - DPI_AWARENESS_UNAWARE - The base value of DPI is which is set to 96 (defined as `USER_DEFAULT_SCREEN_DPI`)
 * - DPI_AWARENESS_SYSTEM_AWARE - The system DPI
 * - DPI_AWARENESS_PER_MONITOR_AWARE - The DPI of the monitor where the window is located.
 */
GetDpiForWindow(hWnd) {
    return DllCall('GetDpiForWindow', 'ptr', hWnd, 'uint')
}

/**
 * @description - Retrieves the dots per inch (dpi) awareness of the specified process.
 * @param {VarRef} OutValue - A variable that will receive the PROCESS_DPI_AWARENESS.
 * @param {IntegeR} [hProcess=0] - Handle of the process that is being queried. If this parameter is
 * 0, the current process is queried.
 * @returns {Integer} - One of the following:
 * - S_OK (0) - The function successfully retrieved the DPI awareness of the specified process.
 * - E_INVALIDARG - The handle or pointer passed in is not valid.
 * - E_ACCESSDENIED - The application does not have sufficient privileges.
 */
GetProcessDpiAwareness(&OutValue, hProcess := 0) {
    return DllCall('Shcore\GetProcessDpiAwareness', 'ptr', hProcess, 'uint*', &OutValue := 0 'uint')
}

/**
 * @description - The return value will be dependent based upon the process passed as a parameter.
 * If the specified process has a DPI_AWARENESS value of DPI_AWARENESS_UNAWARE, the return value
 * will be 96. That is because the current context always assumes a DPI of 96. For any other
 * DPI_AWARENESS value, the return value will be the actual system DPI of the given process.
 * Identical to GetAwarenessFromDpiAwarenessContext(GetThreadDpiAwarenessContext());
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemdpiforprocess}
 * @param {Integer} [hProcess=0] - The handle to the process. If 0, this function retrieves the dpi
 * for the system.
 * @returns {Integer} - The dpi value.
 */
GetSystemDpiForProcess(hProcess := 0) {
    return DllCall('GetSystemDpiForProcess', 'ptr', hProcess, 'uint')
}

/**
 * @description - This method will return the latest DPI_AWARENESS_CONTEXT sent to
 * SetThreadDpiAwarenessContext. If SetThreadDpiAwarenessContext was never called for this thread,
 * then the return value will equal the default DPI_AWARENESS_CONTEXT for the process.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getthreaddpiawarenesscontext}
 * @returns {Integer} -  The thread's DPI_AWARENESS_CONTEXT.
 */
GetThreadDpiAwarenessContext() {
    return DllCall('GetThreadDpiAwarenessContext', 'ptr')
}

/**
 * @description - Returns the DPI_AWARENESS_CONTEXT associated with a window. The return value of
 * GetWindowDpiAwarenessContext is not affected by the DPI_AWARENESS of the current thread. It only
 * indicates the context of the window specified by the hwnd input parameter.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowdpiawarenesscontext}
 * @param {Integer} hWnd - The window handle.
 * @returns {Integer} - The window's DPI_AWARENESS_CONTEXT.
 */
GetWindowDpiAwarenessContext(hWnd) {
    return DllCall('GetWindowDpiAwarenessContext', 'ptr', hWnd, 'ptr')
}

/**
 * @description - IsValidDpiAwarenessContext determines the validity of any provided
 * DPI_AWARENESS_CONTEXT. You should make sure a context is valid before using
 * SetThreadDpiAwarenessContext to that context.
 * An input value of NULL is considered to be an invalid context and will result in a return value
 * of FALSE.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-isvaliddpiawarenesscontext}
 * @param {Integer} DPI_AWARENESS_CONTEXT - The DPI_AWARENESS_CONTEXT.
 * @returns {Boolean} - 1 if valid, else 0.
 */
IsValidDpiAwarenessContext(DPI_AWARENESS_CONTEXT) {
    return DllCall('IsValidDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'uint')
}

/**
 * @description - Use this API to change the DPI_AWARENESS_CONTEXT for the thread from the default
 * value for the app.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setthreaddpiawarenesscontext}
 * @param [DPI_AWARENESS_CONTEXT=DPI_AWARENESS_CONTEXT_DEFAULT] - Use the `DPI_AWARENESS_CONTEXT_DEFAULT`
 * global variable to define the default `DPI_AWARENESS_CONTEXT` for various functions, including
 * this one. If unset, this defaults to -4.
 * @returns {Integer} - If successful, returns the original thread `DPI_AWARENESS_CONTEXT`. If
 * unsuccessful, returns an empty string or 0.
 */
SetThreadDpiAwarenessContext(DPI_AWARENESS_CONTEXT := DPI_AWARENESS_CONTEXT_DEFAULT ?? -4) {
    if IsValidDpiAwarenessContext(DPI_AWARENESS_CONTEXT) {
        return DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'ptr')
    }
}


/**
 * @description - Toggles a window's visibility.
 * @param {Boolean} [Value] - Set this to specify a value instead of toggling it.
 */
GUI_TOGGLE(GuiObj, Value?) {
    if Value ?? DllCall('IsWindowVisible', 'Ptr', GuiObj.Hwnd) {
        GuiObj.Show()
    } else {
        GuiObj.Hide()
    }
}

/**
 * @description - A modified `SetFont` function that adjusts for dpi and caches the font value.
 * @param {String} [OptFont] - The first parameter of `Gui.Control.Prototype.SetFont`.
 * @param {String} [FontFamily] - The second parameter of `Gui.Control.Prototype.SetFont`.
 * @param {Integer} [Dpi] - The DPI value to use for the font size calculation. If unset, the
 * DPI is retrieved from the monitor where the control is located.
 * @returns {Integer} - If `OptFont` is set and contains a size value, the function returns the
 * adjusted font size. If the font size is not used, the function returns an empty string.
 */
GUI_CONTROL_SETFONT(Ctrl, OptFont?, FontFamily?, Dpi?) {
    if IsSet(OptFont) {
        if RegExMatch(OptFont, '(?<opt1>[^s]*)[sS](?<n>\d+)(?<opt2>.*)', &MatchFont) {
            if !IsSet(Dpi) {
                DllCall('Shcore\GetDpiForMonitor', 'ptr', DllCall('User32.dll\MonitorFromWindow', 'ptr', Ctrl.Hwnd, 'UInt', 0x00000000, 'Uptr'), 'UInt', 0, 'UInt*', &Dpi := 0, 'UInt*', &DpiY := 0, 'UInt')
            }
            NewFontSize := Round(MatchFont['n'] * Dpi / A_ScreenDpi, 0)
            Ctrl.DpiChangeHelper.FontSize := MatchFont['n']
            GuiH.ControlSetFont(Ctrl, MatchFont['opt1'] ' ' MatchFont['opt2'] ' s' NewFontSize)
            return Floor(NewFontSize)
        } else
            GuiH.ControlSetFont(Ctrl, OptFont)
    }
    if IsSet(FontFamily) {
        for Name in StrSplit(FontFamily, ',') {
            GuiH.ControlSetFont(Ctrl, , Name)
        }
    }
}

/**
 * @description - A modified `SetFont` function that adjusts for dpi and caches the font value.
 * @param {String} [OptFont] - The first parameter of `Gui.Prototype.SetFont`.
 * @param {String} [FontFamily] - The second parameter of `Gui.Control.Prototype.SetFont`.
 * @param {Integer} [Dpi] - The DPI value to use for the font size calculation. If unset, the
 * DPI is retrieved from the monitor where the control is located.
 * @returns {Integer} - If `OptFont` is set and contains a size value, the function returns the
 * adjusted font size. If the font size is not used, the function returns an empty string.
 */
GUI_SETFONT(GuiObj, OptFont?, FontFamily?, Dpi?) {
    if IsSet(OptFont) {
        if MatchFont := GuiH.GetMatchFont(OptFont) {
            NewFontSize := ((MatchFont['n'] + GuiObj.DpiChangeHelper.Rounded.F * (GuiObj.DpiChangeHelper.Rounded.F >= 0.5 ? -1 : 1)) * (Dpi ?? Mon.Dpi.Win(GuiObj.Hwnd)) / A_ScreenDpi)
            GuiObj.DpiChangeHelper.Rounded.F := NewFontSize - Floor(NewFontSize)
            GuiObj.DpiChangeHelper.FontSize := MatchFont['n']
            GuiH.SetFont(GuiObj, MatchFont['opt1'] ' ' MatchFont['opt2'] ' s' Floor(NewFontSize))
            return Floor(NewFontSize)
        } else
            GuiH.SetFont(GuiObj, OptFont)
    }
    if IsSet(FontFamily) {
        for Name in StrSplit(FontFamily, ',') {
            GuiH.SetFont(GuiObj, , Name)
        }
    }
}


GUI_HANDLEDPICHANGE(wParam, lParam, Message, Hwnd) {
    GuiObj := GuiFromHwnd(Hwnd)
    if !GuiObj || GuiObj.DpiExclude {
        return
    }
    DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
    Critical(1)
    GuiH.OnDpiChange(GuiObj, wParam & 0xFFFF, lParam)
    Critical(0)
}

/**
 * @description - A custom `Gui.Call` method that allows initializing with addiional properties
 * and also defines `DpiChangeHelper`.
 */
GUI_CALL(OptGui?, Title?, EventHandler?, ExtendedParams?) {
    G := GuiH.Gui_Call(OptGui ?? unset, Title ?? unset, EventHandler ?? unset)
    GuiH.GuiDpiChangeHelper(G)
    if IsSet(ExtendedParams) {
        for Prop in ['MarginX', 'MarginY', 'BackColor', 'MenuBar', 'Name'] {
            if HasProp(ExtendedParams, Prop) {
                G.%Prop% := ExtendedParams.%Prop%
            }
        }
        if HasProp(ExtendedParams, 'OptFont') {
            G.SetFont(ExtendedParams.OptFont)
        }
        if HasProp(ExtendedParams, 'FontFamily') {
            G.SetFont(, ExtendedParams.FontFamily)
        }
    }
    if IsSet(EventHandler) {
        G.EventHandler := EventHandler
    }
    G.Count := 0
    return G
}


/**
 * @description - A custom `Gui.Add` method that handles some initialization tasks required
 * by this library.
 */
GUI_ADD(GuiObj, ControlType, OptControl?, Text?, OptFont?, FontFamily?) {
    Ctrl := GuiH.Gui_Add(GuiObj, ControlType, OptControl ?? unset, Text ?? unset)
    GuiH.ControlDpiChangeHelper(Ctrl)
    if IsSet(OptFont) | IsSet(FontFamily) {
        Ctrl.SetFont(OptFont ?? unset, FontFamily ?? unset)
    }
    GuiObj.Count++
    Ctrl.__DpiExclude := false
    return Ctrl
}

; Needed to programmatically define the `GuiObj.Add<type>` methods.
GUI_ADD2(ControlType, GuiObj, OptControl?, Text?, OptFont?, FontFamily?) {
    return GUI_ADD(GuiObj, ControlType, OptControl ?? unset, Text ?? unset, OptFont ?? unset, FontFamliy ?? unset)
}

GUI_CONTROL_TEXTEXTENT_TEXT(Ctrl, &Width?, &Height?) {
    Win.GetTextExtentPoint32(Ctrl.Text, Ctrl.Hwnd, &Width, &Height)
}

GUI_CONTROL_TEXTEXTENT_INDEX(Ctrl, Index := 1, &Width?, &Height?) {
    Win.GetTextExtentPoint32(Ctrl.Text, Ctrl.Hwnd, &Width, &Height)
}

GUI_CONTROL_TEXTEXTENT_LINK(Ctrl, &Width?, &Height?) {
    Win.GetTextExtentPoint32(RegExReplace(Ctrl.Text, '<a\s*(?:href|id)=".+?">(.+?)</a>', '$1'), Ctrl.Hwnd, &Width, &Height)
}

GUI_CONTROL_TEXTEXTENT_MULTI(Ctrl, &Width?, &Height?) {
    if Text := Ctrl.Text is Array {
        Text[A_Index] := Win.GetTextExtentPoint32(Text[A_Index], Ctrl.Hwnd, &Width, &Height)
    }
    return Text
}

GUI_CONTROL_TEXTEXTENT_LISTVIEW(Ctrl, RowNumber := 1, Columnnumber := 1, &Width?, &Height?) {
    Win.GetTextExtentPoint32(Ctrl.GetText(RowNumber, ColumnNumber), Ctrl.Hwnd, &Width, &Height)
}

GUI_CONTROL_RESIZE_BY_TEXT(Ctrl, NewDpi, DpiRatio, &OutX?, &OutY?, &OutW?, &OutH?) {
    Ctrl.GetPos(&X, &Y, &W, &H)
    if !(hDC := DllCall('GetDC', 'Ptr', Ctrl.hwnd)) {
        return 1
    }
    hFont := SendMessage(0x0031,,, Ctrl.hwnd)
    ; Select the font into the DC
    if !DllCall("Gdi32\SelectObject", "Ptr", hDC, "Ptr", hFont, "Ptr") {
        return 2
    }
    ; Create buffer to store SIZE
    StrPut(Ctrl.Text, lpStr := Buffer(StrPut(Ctrl.Text, 'utf-16')), 'utf-16')
    ; Measure the text
    if !DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32', 'Ptr'
        , hDC, 'Ptr', lpStr, 'Int', StrLen(Ctrl.Text), 'Ptr', hSize := Buffer(8)) {
        return 3
    }
    DllCall('ReleaseDC', 'Ptr', Ctrl.hwnd, 'Ptr', hDC)
    Width1 := NumGet(hSize, 0, 'int')
    Height1 := NumGet(hSize, 4, 'int')

    ; Set scaled font.
    Ctrl.SetFont('s' Ctrl.DpiChangeHelper.FontSize, , NewDpi)
    hDC := DllCall('GetDC', 'Ptr', Ctrl.hwnd)
    hFont := SendMessage(0x0031,,, Ctrl.hwnd)
    if !DllCall("Gdi32\SelectObject", "Ptr", hDC, "Ptr", hFont, "Ptr") {
        return 4
    }
    ; Get new size.
    if !DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32', 'Ptr'
        , hDC, 'Ptr', lpStr, 'Int', StrLen(Ctrl.Text), 'Ptr', hSize := Buffer(8)) {
        return 5
    }
    DllCall('ReleaseDC', 'Ptr', Ctrl.hwnd, 'Ptr', hDC)
    Width2 := NumGet(hSize, 0, 'int')
    Height2 := NumGet(hSize, 4, 'int')
    ; Get scaled X and Y
    Ctrl.DpiChangeHelper.AdjustByText(Width2 / Width1, Height2 / Height1, &OutX := X, &OutY := Y, &OutW := W, &OutH := H)
}

GUI_CONTROL_DPI_EXCLUDE(Ctrl, Value) {
    if Value {
        Ctrl.Gui.Count--
    } else {
        Ctrl.Gui.Count++
    }
    Ctrl.DpiExclude := Value
}

/**
 * @description - The cursor must have been created by either the CreateCursor or the
 * CreateIconIndirect function, or loaded by either the LoadCursor or the LoadImage function. If
 * this parameter (hCursor) is NULL, the cursor is removed from the screen.
 */
SetCursor(hCursor?) {
    return DllCall('SetCursor', 'ptr', hCursor ?? 0, 'ptr')
}


WEBVIEW2_ONDPICHANGE(GuiObj, DpiRatio, GuiL, GuiT, GuiR, GuiB) {
    WvCtrl := GuiObj['WvCtrl']
    WvC := GuiObj.WvC
    WvCtrl.Move(
        X := GuiL + WvCtrl.EdgeOffsetL
      , Y := GuiT + WvCtrl.EdgeOffsetT
      , W := GuiR - WvCtrl.EdgeOffsetR - X
      , H := GuiB - WvCtrl.EdgeOffsetB - Y
    )
    rc := Rect.FromDimensions(X, Y, W, H)
    WvC.Bounds := rc
}

WEBVIEW2_FILL(WvCtrl) {
    Win.GetClientRect(WvCtrl.Gui.Hwnd, &rc)
    WvCtrl.Move(0, 0, rc.W, rc.H)
    WvCtrl.Gui.WvController.Bounds := rc
}
