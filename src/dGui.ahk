
; Dependencies
#include ..\config\DefaultConfig.ahk

#include ..\definitions
#include Define-Dpi.ahk
#include Define-Font.ahk

#include ..\struct
#include SIZE.ahk
#include IntegerArray.ahk
#include LOGFONT.ahk
#include RectBase.ahk
#include RECT.ahk
#include POINT.ahk

#include ..\src
#include dDefaultOptions.ahk
#include DpiChangedHelpers.ahk
#include FontGroup.ahk
#include dMon.ahk

#include ..\lib
#include SetThreadDpiAwareness__Call.ahk
#include ControlTextExtent.ahk

class dGui extends Gui {

    /**
     * @description - An alternate method for creating a new Gui object. `dGui.Call` initializes the
     * properties required to use the built-in dpi changed handler. `dGui.Call` performs these actions:
     * - Creates the Gui object.
     * - Processes the `ExtendedParams` options.
     * - Sets `GuiObj.DpiChangedHelper` with a `GuiDpiChangedHelper` object.
     * - Sets `GuiObj.Font`
     * - Sets `GuiObj.Count := 0`.
     * @param {String} [Opt] - The first parameter of `Gui.Call`.
     * @param {String} [Title] - The second parameter of `Gui.Call`.
     * @param {String} [EventHandler] - The third parameter of `Gui.Call`.
     * @param {Object} [ExtendedParams] - An object that defines additional options. The object can
     * have zero or more of the { BackColor, MarginX, MarginY, MenuBar, Name, OptFont, FontName }
     * @returns {Gui} - The new Gui object.
     */
    static Call(Opt?, Title?, EventHandler?, ExtendedParams?) {
        ObjSetBase(G := Gui(Opt ?? unset, Title ?? unset, EventHandler ?? unset), this.Prototype)
        G.DpiHelper := GuiDpiHelper(G)
        if IsSet(ExtendedParams) {
            for Prop in ['MarginX', 'MarginY', 'BackColor', 'MenuBar', 'Name'] {
                if HasProp(ExtendedParams, Prop) {
                    G.%Prop% := ExtendedParams.%Prop%
                }
            }
            if HasProp(ExtendedParams, 'OptFont') {
                G.SetFont(ExtendedParams.OptFont)
            }
            if HasProp(ExtendedParams, 'FontName') {
                G.SetFont(, ExtendedParams.FontName)
            }
        }
        if IsSet(EventHandler) {
            G.EventHandler := EventHandler
        }
        G.Count := 0
        return G
    }

    static Initialize(Config?) {
        (ClassList := []).Capacity := 30
        ; Programmatically getting a list of all built-in control types
        for Prop in Gui.OwnProps() {
            if Gui.%Prop% is Class {
                ClassList.Push(Gui.%Prop%)
            }
        }
        if !IsSet(Config) {
            Config := {}
        }
        if IsSet(DisplayConfig) {
            ObjSetBase(DisplayConfig, DefaultConfig)
            ObjSetBase(Config, DisplayConfig)
        } else {
            ObjSetBase(Config, DefaultConfig)
        }

        ;@region ControlIncludeByDefault
        if Config.ControlIncludeByDefault is Array {
            Gui.Control.Prototype.DefineProp('DpiExclude', { Value: true })
            for CtrlType in Config.ControlIncludeByDefault {
                Gui.%CtrlType%.Prototype.DefineProp('DpiExclude', { Value: false })
            }
        } else if Config.ControlIncludeByDefault {
            Gui.Control.Prototype.DefineProp('DpiExclude', { Value: false })
        } else {
            Gui.Control.Prototype.DefineProp('DpiExclude', { Value: true })
        }
        ;@endregion

        ;@region GetTextExtent
        if Config.GetTextExtent {
            for CtrlType in [ 'Button', 'CheckBox', 'DateTime', 'Edit', 'GroupBox', 'Hotkey'
            , 'ComboBox', 'DDL', 'Tab', 'Radio', 'StatusBar', 'Text' ] {
                Gui.%CtrlType%.Prototype.DefineProp('GetTextExtent', { Call: ControlGetTextExtent })
            }
            Gui.ListBox.Prototype.DefineProp('GetTextExtent', { Call: ControlGetTextExtent_LB })
            Gui.Link.Prototype.DefineProp('GetTextExtent', { Call: ControlGetTextExtent_Link })
            Gui.ListView.Prototype.DefineProp('GetTextExtent', { Call: ControlGetTextExtent_LV })
            Gui.TreeView.Prototype.DefineProp('GetTextExtent', { Call: ControlGetTextExtent_TV })
        }
        ;@endregion

        ;@region GetTextExtentEx
        if Config.GetTextExtentEx {
            for CtrlType in [ 'Button', 'CheckBox', 'DateTime', 'Edit', 'GroupBox', 'Hotkey'
            , 'ComboBox', 'DDL', 'Tab', 'Radio', 'StatusBar', 'Text' ] {
                Gui.%CtrlType%.Prototype.DefineProp('GetTextExtentEx', { Call: ControlGetTextExtentEx })
            }
            Gui.ListBox.Prototype.DefineProp('GetTextExtentEx', { Call: ControlGetTextExtentEx_LB })
            Gui.Link.Prototype.DefineProp('GetTextExtentEx', { Call: ControlGetTextExtentEx_Link })
            Gui.ListView.Prototype.DefineProp('GetTextExtentEx', { Call: ControlGetTextExtentEx_LV })
            Gui.TreeView.Prototype.DefineProp('GetTextExtentEx', { Call: ControlGetTextExtentEx_TV })
        }
        ;@endregion

        ;@region HandleDpiChanged
        if Config.HandleDpiChanged {
            Gui.Control.Prototype.DefineProp('HandleDpiChanged', { Call: ControlResizeByDpiRatio })
        }
        ;@endregion

        ;@region ResizeByText
        if Config.ResizeByText {
            if !Config.GetTextExtent || !Config.HandleDpiChanged {
                throw ValueError('``ResizeByText`` requires the options ``GetTextExtent`` and ``HandleDpiChanged``.', -1)
            }
            for CtrlType in Config.ResizeByText {
                Gui.%CtrlType%.Prototype.DefineProp('HandleDpiChanged', { Call: ControlResizeByText })
            }
        }
        ;@endregion

        if Config.GuiToggle {
            Gui.Prototype.DefineProp('Toggle', { Call: GuiToggle })
        }
        if Config.GuiCallWith_S {
            Gui.Prototype.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        }
        if Config.ControlCallWith_S {
            Gui.Control.Prototype.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        }
        if Config.GuiDpi {
            Gui.Prototype.DefineProp('Dpi', { Get: (Self) => DllCall('GetDpiForWindow', 'ptr', Self.hWnd, 'int') })
        }
        if Config.ControlDpi {
            Gui.Control.Prototype.DefineProp('Dpi', { Get: (Self) => DllCall('GetDpiForWindow', 'ptr', Self.hWnd, 'int') })
        }
        if Config.GuiCount {
            Gui.Prototype.DefineProp('Count', { Value: 0 })
        }
        if Config.GuiDpiExclude {
            Gui.Prototype.DefineProp('DpiExclude', { Value: 0 })
        }
    }

    /**
     * @description - Matches with an `OptFont` string and returns the `RegExMatchInfo` object.
     * The object has these subcapture groups:
     * - opt1: The first part of the font string before the size.
     * - n: The font size, if present.
     * - opt2: The second part of the font string after the size, if the size is present and if
     * text is after the size.
     * @param {String} OptFont - The font string to match.
     * @returns {Object} - The `RegExMatchInfo` object.
     * @example
     *  OptFont := 's12 q5'
     *  if MatchFont := dGui.GetMatchFont(OptFont) {
     *      MsgBox('Font size is ' MatchFont['n']) ; 12
     *      MsgBox('First part of options are ' MatchFont['opt1']) ; ''
     *      MsgBox('Second part of options are ' MatchFont['opt2']) ; " q5"
     *  }
     */
    static GetMatchFont(OptFont) {
        if RegExMatch(OptFont, '(?<opt1>[^sS]*)[sS](?<n>\d+)(?<opt2>.*)', &MatchFont) {
            return MatchFont
        }
    }

    /**
     * @description - This is the core built-in method for resopnding to `WM_DPICHANGED` messages.
     * By default, this method is called from the global `GUI_HANDLEDPICHANGE` function after
     * calling `dGui.SetDpiChangeHandler`. This method is called once. This method has these
     * characteristics:
     * - `GUI_HANDLEDPICHANGE` sets the dpi thread awareness to -4 and calls `Critical(1)`, then
     * calls this method.
     * - The GuiObject that is subject to the dpi change is referenced, font adjusted, then size /
     * position adjusted.
     * - `BeginDeferWindowPos` is called to create a new window position object; all adjusted
     * values are passed to the window position object.
     * - The control objects are iterated, and adjusted in one of two ways:
     *   - If `HasMethod(CtrlObj, 'ResizeByText')` then that method is called for that control.
     * `ResizeByText` adjusts the control's size and position as a function of the ratio of new
     * text extent to original text extent of the control's contents.
     *   - Else, `DpiChangedHelper.Adjust` is called for that control. This adjusts the size and
     * position as a function of the dpi scale ratio.
     * - `EndDeferWindowPos` is called to apply the new window position object.
     * @param {Gui} GuiObj - The Gui object to adjust.
     * @param {Integer} NewDpi - The new dpi value.
     * @param {Integer} lParam - The lParam value from the `WM_DPICHANGED` message.
     */
    static OnDpiChange(GuiObj, NewDpi, lParam) {
        if HasMethod(GuiObj, 'OnDpiChange_Before') {
            GuiObj.OnDpiChange_Before(NewDpi, lParam)
        }
        GuiObj.SetFont('s' GuiObj.DpiChangedHelper.FontSize, , NewDpi)
        GuiObj.Move(
            NumGet(lParam, 0, 'int')
          , NumGet(lParam, 4, 'int')
          , NumGet(lParam, 8, 'int') - NumGet(lParam, 0, 'int')
          , NumGet(lParam, 12, 'int') - NumGet(lParam, 4, 'int')
        )
        hDwp := DllCall('BeginDeferWindowPos', 'int', GuiObj.Count, 'ptr')
        DpiRatio := NewDpi / GuiObj.DpiChangedHelper.Dpi
        for Ctrl in GuiObj {
            if Ctrl.DpiExclude {
                continue
            }
            Ctrl.HandleDpiChanged(NewDpi, DpiRatio, &X, &Y, &W, &H)
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', Ctrl.Hwnd
                , 'ptr', 0
                , 'int', X
                , 'int', Y
                , 'int', W
                , 'int', H
                , 'uint', 0x0004 | 0x0010 ; SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        GuiObj.DpiChangedHelper.Dpi := NewDpi
    }

    /**
     * @description - Accounts for the difference between the client area and the window area,
     * allowing you to set the width or height according to the desired client area. Though
     * the window does not need to be visible to call `dGui.GuiFitCtrl`, the window must have been
     * shown at least once at any time prior to calling `dGui.GuiFitCtrl`.
     * @param {Gui} GuiObj - The Gui object.
     * @param {Integer} [X] - X coordinate.
     * @param {Integer} [Y] - Y coordinate.
     * @param {Integer} [W] - Width.
     * @param {Integer} [H] - Height.
     */
    static GuiMoveEx(GuiObj, X?, Y?, W?, H?) {
        GuiObj.GetPos(, , &w1, &h1)
        GuiObj.GetClientPos(, , &w2, &h2)
        GuiObj.Move(X ?? unset, Y ?? unset, IsSet(W) ? W + w1 - w2 : unset, IsSet(H) ? H + h1 - h2 : unset)
    }

    /**
     * @description - Resizes a Gui window to fit a control completely in it's client area. Also
     * adds `GuiObj.MarginX` and `GuiObj.MarginY` to the x and y dimensions, respectively. Though
     * the window does not need to be visible to call `dGui.GuiFitCtrl`, the window must have been
     * shown at least once at any time prior to calling `dGui.GuiFitCtrl`.
     * @param {Gui.Control} Ctrl - The control to fit the window around.
     * @param {VarRef} [OutWidth] - A variable that will receive the new width.
     * @param {VarRef} [OutHeight] - A variable that will receive the new height.
     */
    static GuiFitCtrl(Ctrl, &OutW?, &OutH?) {
        G := Ctrl.Gui
        G.GetPos(, , , &h1)
        G.GetClientPos(, , , &h2)
        Ctrl.GetPos(&x, &y, &w, &h)
        G.Move(, , OutWidth := x + w + G.MarginX, OutHeight := y + h + G.MarginY + h1 - h2)
    }

    /**
     * @description - Calls `OnMessage(WM_DPICHANGED, Callback)` to set the `WM_DPICHANGED` message
     * handler. This method is called by `dGui.SetDpiChangeHandler` and `Gui.Call`. The default
     * callback is `GuiHandleDpiChanged`, the primary built-in function for handling dpi changes.
     */
    static SetDpiChangeHandler(Callback := GuiHandleDpiChanged) {
        OnMessage(WM_DPICHANGED, Callback)
    }

    /**
     * @description - Enumerate a specific control type of the controls in a Gui object.
     * @example
     *  for Ctrl in dGui.EnumerateControls(G, 'Button', 1) {
     *      Ctrl.GetPos(&x, &y)
     *      if x > 0 && y < 100 {
     *          Ctrl.Move(x * .85)
     *      }
     *  }
     * @
     * @param {Gui} G - The Gui object to enumerate.
     * @param {String} CtrlType - The control type to enumerate, or a comma-delimited list of
     * control types, e.g. "Text,Button,Edit".
     * @param {Integer} [VarCount] - The number of variables to return. 1 or 2.
     * - 1: Returns the control object.
     * - 2: Returns the control object and the control name.
     * @returns {Func} - A function compatible with AHK loops.
     */
    static EnumerateControl(G, CtrlType, VarCount := 2) {
        List := []
        CtrlType := ',' CtrlType ','
        for Ctrl in G {
            if InStr(CtrlType, ',' Ctrl.Type ',') {
                List.Push(Ctrl)
            }
        }
        i := 0
        return _Enum%VarCount%

        _Enum1(&Ctrl) {
            if ++i > List.Length
                return 0
            Ctrl := List[i]
            return 1
        }
        _Enum2(&Name, &Ctrl) {
            if ++i > List.Length
                return 0
            Ctrl := List[i]
            Name := Ctrl.Name
            return 1
        }
    }
    static __New() {
        if this.Prototype.__Class == 'dGui' {
            this.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        }
    }

    SetFont(OptFont?, FontName?) {
        if IsSet(OptFont) {

        }
    }
}

/**
 * @description - A custom `Gui.Add` method that handles some initialization tasks required
 * by this library's built-in dpi changed handler.
 */
GuiAdd(GuiObj, ControlType, OptControl?, Text?, OptFont?, FontFamily?) {
    Ctrl := GuiObj.Add(ControlType, OptControl ?? unset, Text ?? unset)
    ControlDpiChangedHelper(Ctrl)
    if IsSet(OptFont) | IsSet(FontFamily) {
        ControlSetFont(Ctrl, OptFont ?? unset, FontFamily ?? unset)
    }
    GuiObj.Count++
    return Ctrl
}

ControlResizeByText(Ctrl, NewDpi, DpiRatio, &OutX?, &OutY?, &OutW?, &OutH?) {
    Ctrl.GetPos(&X, &Y, &W, &H)
    sz := ControlGetTextExtent(Ctrl)
    Width1 := sz.Width
    Height1 := sz.Height

    ; Set scaled font.
    Ctrl.SetFont('s' Ctrl.DpiChangedHelper.FontSize, , NewDpi)
    sz := ControlGetTextExtent(Ctrl)
    ; Get scaled X and Y
    Ctrl.DpiChangedHelper.AdjustByText(sz.Width / Width1, sz.Height / Height1, &OutX := X, &OutY := Y, &OutW := W, &OutH := H)
}

ControlResizeByDpiRatio(Ctrl, NewDpi, DpiRatio, &OutX?, &OutY?, &OutW?, &OutH?) {
    Ctrl.GetPos(&OutX, &OutY, &OutW, &OutH)
    Ctrl.SetFont('s' Ctrl.DpiChangedHelper.FontSize, , NewDpi)
    Ctrl.DpiChangedHelper.Adjust(DpiRatio, &OutX, &OutY, &OutW, &OutH)
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
ControlSetFont(Ctrl, OptFont?, FontFamily?, Dpi?) {
    if IsSet(OptFont) {
        if RegExMatch(OptFont, '(?<opt1>[^s]*)[sS](?<n>[\d.]+)(?<opt2>.*)', &MatchFont) {
            if !IsSet(Dpi) {
                Dpi := DllCall('GetDpiForWindow', 'ptr', Ctrl.hWnd, 'int')
            }
            NewFontSize := Round(MatchFont['n'] * Ctrl.Gui.DpiChangedHelper.Dpi / Dpi, 0)
            Ctrl.DpiChangedHelper.FontSize := MatchFont['n']
            dGui.ControlSetFont(Ctrl, MatchFont['opt1'] ' ' MatchFont['opt2'] ' s' NewFontSize)
            return Floor(NewFontSize)
        } else {
            dGui.ControlSetFont(Ctrl, OptFont)
        }
    }
    if IsSet(FontFamily) {
        for Name in StrSplit(FontFamily, ',') {
            dGui.ControlSetFont(Ctrl, , Name)
        }
    }
}

GuiHandleDpiChanged(wParam, lParam, Message, Hwnd) {
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
GuiSetFont(GuiObj, OptFont?, FontFamily?, Dpi?) {
    if IsSet(OptFont) {
        if MatchFont := dGui.GetMatchFont(OptFont) {
            NewFontSize := ((MatchFont['n'] + GuiObj.DpiChangedHelper.Rounded.F * (GuiObj.DpiChangedHelper.Rounded.F >= 0.5 ? -1 : 1)) * (Dpi ?? _GetDpi()) / A_ScreenDpi)
            GuiObj.DpiChangedHelper.Rounded.F := NewFontSize - Floor(NewFontSize)
            GuiObj.DpiChangedHelper.FontSize := MatchFont['n']
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
GuiToggle(GuiObj, Value?) {
    if Value ?? !DllCall('IsWindowVisible', 'Ptr', GuiObj.Hwnd) {
        GuiObj.Show()
    } else {
        GuiObj.Hide()
    }
}
