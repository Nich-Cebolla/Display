/**
 * @description - A custom `Gui.Add` method that handles some initialization tasks required
 * by this library.
 */
GUI_ADD(GuiObj, ControlType, OptControl?, Text?, OptFont?, FontFamily?) {
    Ctrl := dGui.Gui_Add(GuiObj, ControlType, OptControl ?? unset, Text ?? unset)
    dGui.ControlDpiChangeHelper(Ctrl)
    if IsSet(OptFont) | IsSet(FontFamily) {
        Ctrl.SetFont(OptFont ?? unset, FontFamily ?? unset)
    }
    GuiObj.Count++
    return Ctrl
}

/**
 * @description - Used to programmatically define to `Gui.Prototype.Add<Type>` methods.
 */
GUI_ADD2(ControlType, GuiObj, OptControl?, Text?, OptFont?, FontFamily?) {
    return GUI_ADD(GuiObj, ControlType, OptControl ?? unset, Text ?? unset, OptFont ?? unset, FontFamliy ?? unset)
}

/**
 * @description - A custom `Gui.Call` method that initializes properties needed for this library's
 * built-in WM_DPICHANGED handler. Also includes an extra parameter `ExtendedParams` which can
 * be an object with zero or more of { MarginX, MarginY, BackColor, MenuBar, Name, OptFont, FontFamily }
 * properties, to set those properties when the gui object is initialized.
 */
GUI_CALL(OptGui?, Title?, EventHandler?, ExtendedParams?) {
    G := dGui.Gui_Call(OptGui ?? unset, Title ?? unset, EventHandler ?? unset)
    dGui.GuiDpiChangeHelper(G)
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
    G.Count := 0
    return G
}

GUI_CONTROL_DPI_EXCLUDE(Ctrl, Value) {
    if Value {
        Ctrl.Gui.Count--
    } else {
        Ctrl.Gui.Count++
    }
    Ctrl.DpiExclude := Value
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
            dGui.ControlSetFont(Ctrl, MatchFont['opt1'] ' ' MatchFont['opt2'] ' s' NewFontSize)
            return Floor(NewFontSize)
        } else
            dGui.ControlSetFont(Ctrl, OptFont)
    }
    if IsSet(FontFamily) {
        for Name in StrSplit(FontFamily, ',') {
            dGui.ControlSetFont(Ctrl, , Name)
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
    dGui.OnDpiChange(GuiObj, wParam & 0xFFFF, lParam)
    Critical(0)
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
        if MatchFont := dGui.GetMatchFont(OptFont) {
            NewFontSize := ((MatchFont['n'] + GuiObj.DpiChangeHelper.Rounded.F * (GuiObj.DpiChangeHelper.Rounded.F >= 0.5 ? -1 : 1)) * (Dpi ?? _GetDpi()) / A_ScreenDpi)
            GuiObj.DpiChangeHelper.Rounded.F := NewFontSize - Floor(NewFontSize)
            GuiObj.DpiChangeHelper.FontSize := MatchFont['n']
            dGui.SetFont(GuiObj, MatchFont['opt1'] ' ' MatchFont['opt2'] ' s' Floor(NewFontSize))
            return Floor(NewFontSize)
        } else
            dGui.SetFont(GuiObj, OptFont)
    }
    if IsSet(FontFamily) {
        for Name in StrSplit(FontFamily, ',') {
            dGui.SetFont(GuiObj, , Name)
        }
    }
    _GetDpi() {
        if DllCall('Shcore\GetDpiForMonitor', 'ptr', DllCall('User32.dll\MonitorFromWindow', 'ptr', GuiObj.Hwnd, 'UInt', 0x00000000, 'Uptr'), 'UInt', 0, 'UInt*', &Dpi := 0, 'UInt*', &DpiY := 0, 'UInt') {
            throw OSError('Shcore\GetDpiForMonitor failed.', -1, A_LastError)
        }
        return Dpi
    }
}

/**
 * @description - Toggles a window's visibility.
 * @param {Boolean} [Value] - Set this to specify a value instead of toggling it.
 */
GUI_TOGGLE(GuiObj, Value?) {
    if Value ?? !DllCall('IsWindowVisible', 'Ptr', GuiObj.Hwnd) {
        GuiObj.Show()
    } else {
        GuiObj.Hide()
    }
}
