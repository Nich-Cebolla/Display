
class GuiH {

    static Initialize(Config?) {
        static ClassList := [], Indices := []
        if !IsSet(Config) {
            Config := {}
        }
        if IsSet(DisplayConfig) {
            ObjSetBase(Config := {}, DisplayConfig)
            ObjSetBase(DisplayConfig, Display_DefaultConfig)
        } else {
            ObjSetBase(Config, Display_DefaultConfig)
        }

                ; ExcludeNewControlSetFont
        __GUI_CONTROL_SETFONT := Gui.Control.Prototype.SetFont
        this.DefineProp('ControlSetFont', { Call: (Self, Ctrl, OptFont?, FontFamily?) => __GUI_CONTROL_SETFONT(Ctrl, OptFont ?? unset, FontFamily ?? unset) })

        if Config.ExcludeNewControlSetFont is Array {
            List := _CrossReferenceListInverse(Config.ExcludeNewControlSetFont)
            for Name in List {
                Gui.%Name%.Prototype.DefineProp('SetFont', { Call: GUI_CONTROL_SETFONT })
            }
        } else if !Config.ExcludeNewControlSetFont {
            Gui.Control.Prototype.DefineProp('SetFont', { Call: GUI_CONTROL_SETFONT })
        }

                ; ExcludeNewGuiSetFont
        __GUI_SETFONT := Gui.Prototype.SetFont
        this.DefineProp('SetFont', { Call: (Self, GuiObj, OptFont?, FontFamily?) => __GUI_SETFONT(GuiObj, OptFont ?? unset, FontFamily ?? unset) })
        if Config.NewGuiSetFont {
            Gui.Prototype.DefineProp('SetFont', { Call: GUI_SETFONT })
        }

                ; NewGuiCall
        __GUI_CALL := Gui.Call
        this.DefineProp('Gui_Call', { Call: (Self, GuiClass, OptGui?, Title?, EventHandler?) => __GUI_CALL(GuiClass, OptGui?, Title?, EventHandler?) })
        if Config.NewGuiCall {
            Gui.DefineProp('Call', { Call: GUI_CALL })
        }

                ; NewGuiAdd
        __GUI_ADD := Gui.Prototype.Add
        this.DefineProp('Gui_Add', { Call: (Self, GuiObj, Type?, OptControl?, Text?) => __GUI_ADD(GuiObj, Type?, OptControl?, Text?) })
        if Config.NewGuiAdd {
            Gui.Prototype.DefineProp('Add', { Call: GUI_ADD })
        }

                ; ExcludeNewGuiAddType
        if Config.ExcludeNewGuiAddType is Array {
            List := _CrossReferenceListInverse(Config.ExcludeNewGuiAddType)
            for t in List {
                Gui.Prototype.DefineProp('Add' t, { Call: GUI_ADD2.Bind(t) })
            }
            Flag_2 := Flag_3 := false
            Condition := Condition1 := (Name) => Name = 'Tab2' ? 2 : Name = 'Tab3' ? 3 : 0
            Condition2 := (Name) => Name = 'Tab2' ? 4 : 0
            Condition3 := (Name) => Name = 'Tab3' ? 5 : 0
            for Name in Config.ExcludeNewGuiAddType {
                switch Condition(Name) {
                    case 2:
                        Flag_2 := true
                        Condition := Condition3
                    case 3:
                        Flag_3 := true
                        Condition := Condition2
                    case 4:
                        Flag_2 := true
                        break
                    case 5:
                        Flag_3 := true
                        break
                }
            }
            if !Flag_2 {
                Gui.Prototype.DefineProp('AddTab2', { Call: GUI_ADD2.Bind('Tab2') })
            }
            if !Flag_3 {
                Gui.Prototype.DefineProp('AddTab3', { Call: GUI_ADD2.Bind('Tab3') })
            }
        } else if !Config.ExcludeNewGuiAddType {
            List := ClassList.Length ? ClassList : _GetClassList()
            for CtrlType in List {
                Gui.Prototype.DefineProp('Add' CtrlType, { Call: GUI_ADD2.Bind(CtrlType) })
            }
            Gui.Prototype.DefineProp('AddTab2', { Call: GUI_ADD2.Bind('Tab2') })
            Gui.Prototype.DefineProp('AddTab3', { Call: GUI_ADD2.Bind('Tab3') })
        }

                ; DpiExcludeControls
        if Config.DpiExcludeControls is Array {
            Gui.Control.Prototype.DefineProp('DpiExclude', { Value: false })
            for CtrlType in Config.DpiExcludeControls {
                Gui.%CtrlType%.Prototype.DefineProp('DpiExclude', { Value: true })
            }
        } else if Config.DpiExcludeControls {
            Gui.Control.Prototype.DefineProp('DpiExclude', { Value: true })
        } else {
            Gui.Control.Prototype.DefineProp('DpiExclude', { Value: false })
        }

                ; DefaultExcludeGui
        if Config.DefaultExcludeGui {
            Gui.Prototype.DefineProp('DpiExclude', { Value: true })
        } else {
            Gui.Prototype.DefineProp('DpiExclude', { Value: false })
        }
                ; GetTextExtent
        if Config.GetTextExtent {
            if Config.GetTextExtent is Map {
                for CtrlType, Function in Config.GetTextExtent {
                    Gui.%CtrlType%.Prototype.DefineProp('GetTextExtent', { Call: Function })
                }
            } else {
                throw TypeError('``DisplayConfig.GetTextExtent`` must be a Map.', -1, 'Current type: ' Type(Config.GetTextExtent))
            }
        }
                ; ResizeByText
        if Config.ResizeByText {
            if Config.ResizeByText is Array {
                for CtrlType in Config.ResizeByText {
                    Gui.%CtrlType%.Prototype.DefineProp('ResizeByText', { Call: GUI_CONTROL_RESIZE_BY_TEXT })
                }
            } else {
                throw TypeError('``DisplayConfig.ResizeByText`` must be an Array.', -1, 'Current type: ' Type(Config.ResizeByText))
            }
        }

        Gui.Prototype.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        Gui.Control.Prototype.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
        Gui.Prototype.DefineProp('Toggle', { Call: GUI_TOGGLE })
        Gui.Prototype.DefineProp('Dpi', { Get: (Self) => Mon.Dpi.Win(Self.Hwnd) })
        Gui.Control.Prototype.DefineProp('Dpi', { Get: (Self) => Mon.Dpi.Win(Self.Hwnd) })

        _CrossReferenceList(List) {
            Result := []
            if ClassList.Length {
                _LoopList()
            } else {
                _LoopGetList()
            }
            return Result

            _LoopGetList() {
                for Prop in Gui.OwnProps() {
                    if Gui.%Prop% is Class && InStr(Gui.%Prop%.Prototype.__Class, 'Gui.') {
                        Prop := StrSplit(Gui.%Prop%.Prototype.__Class, '.')[2]
                        ClassList.Push(Prop)
                        for Name in List {
                            if Prop = Name {
                                Result.Push(Name)
                                continue 2
                            }
                        }
                    }
                }
                loop Indices.Capacity := ClassList.Length {
                    Indices.Push(A_Index)
                }
            }
            _LoopList() {
                ind := Indices.Clone()
                for CtrlType in ClassList {
                    if !ind.length {
                        break
                    }
                    for i in ind {
                        if CtrlType = ClassList[ind[i]] {
                            Result.Push(CtrlType)
                            ind.RemoveAt(A_Index)
                            continue 2
                        }
                    }
                }
            }
        }
        _CrossReferenceListInverse(List) {
            Result := []
            if ClassList.Length {
                _LoopList()
            } else {
                _LoopGetList()
            }
            return Result

            _LoopGetList() {
                for Prop in Gui.OwnProps() {
                    if Gui.%Prop% is Class && InStr(Gui.%Prop%.Prototype.__Class, 'Gui.') {
                        Prop := StrSplit(Gui.%Prop%.Prototype.__Class, '.')[2]
                        ClassList.Push(Prop)
                        for Name in List {
                            if Prop = Name {
                                continue 2
                            }
                        }
                        Result.Push(Prop)
                    }
                }
                loop Indices.Capacity := ClassList.Length {
                    Indices.Push(A_Index)
                }
            }
            _LoopList() {
                ind := Indices.Clone()
                for CtrlType in ClassList {
                    if !ind.length {
                        break
                    }
                    for i in ind {
                        if CtrlType = ClassList[ind[i]] {
                            ind.RemoveAt(A_Index)
                            continue 2
                        }
                    }
                    Result.Push(CtrlType)
                }
            }
        }
        _GetClassList() {
            for Prop in Gui.OwnProps() {
                if Gui.%Prop% is Class && InStr(Gui.%Prop%.Prototype.__Class, 'Gui.') {
                    ClassList.Push(StrSplit(Gui.%Prop%.Prototype.__Class, '.')[2])
                }
            }
            return ClassList
        }
    }

    /**
     * @description - Contains the built-in `Gui.Prototype.SetFont` method.
     */
    static SetFont(*) {
        ; This is overridden in the `GuiH.__New()` method.
    }

    /**
     * @description - Contains the built-in `Gui.Control.Prototype.SetFont` method.
     */
    static ControlSetFont(*) {
        ; This is overridden in the `GuiH.__New()` method.
    }

    /**
     * @description - Matches with a `OptFont` string and returns the `RegExMatchInfo` object.
     * The object has these subcapture groups:
     * - opt1: The first part of the font string before the size.
     * - n: The font size, if present.
     * - opt2: The second part of the font string after the size, if the size is present and if
     * text is after the size.
     * @param {String} OptFont - The font string to match.
     * @returns {Object} - The `RegExMatchInfo` object.
     * @example
        OptFont := 's12 q5'
        if MatchFont := GuiH.GetMatchFont(OptFont) {
            MsgBox('Font size is ' MatchFont['n']) ; 12
            MsgBox('First part of options are ' MatchFont['opt1']) ; ''
            MsgBox('Second part of options are ' MatchFont['opt2']) ; " q5"
        }
     */
    static GetMatchFont(OptFont) {
        if RegExMatch(OptFont, '(?<opt1>[^s]*)[sS](?<n>\d+)(?<opt2>.*)', &MatchFont) {
            return MatchFont
        }
    }

    /**
     * @description - This is the core built-in method for resopnding to `WM_DPICHANGED` messages.
     * By default, this method is called from the global `GUI_HANDLEDPICHANGE` function after
     * calling `GuiH.SetDpiChangeHandler`. This method is called once. This method has these
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
     *   - Else, `DpiChangeHelper.Adjust` is called for that control. This adjusts the size and
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
        GuiObj.SetFont('s' GuiObj.DpiChangeHelper.FontSize, , NewDpi)
        hDwp := DllCall('BeginDeferWindowPos', 'int', GuiObj.Count, 'ptr')
        GuiObj.Move(
            NumGet(lParam, 0, 'int')
          , NumGet(lParam, 4, 'int')
          , NumGet(lParam, 8, 'int') - NumGet(lParam, 0, 'int')
          , NumGet(lParam, 12, 'int') - NumGet(lParam, 4, 'int')
        )
        DpiRatio := NewDpi / GuiObj.DpiChangeHelper.Dpi
        GuiObj.DpiChangeHelper.Dpi := NewDpi
        for Ctrl in GuiObj {
            if Ctrl.DpiExclude {
                continue
            }
            if HasMethod(Ctrl, 'ResizeByText') {
                Ctrl.GetPos(&x, &y, &w, &h)
                Ctrl.ResizeByText(NewDpi, DpiRatio, &X, &Y, &W, &H)
            } else {
                Ctrl.GetPos(&x, &y, &w, &h)
                Ctrl.SetFont('s' (Ctrl.DpiChangeHelper.FontSize), , NewDpi)
                Ctrl.DpiChangeHelper.Adjust(DpiRatio, &X, &Y, &W, &H)
            }
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
    }


    /**
     * @description - Calls `OnMessage(WM_DPICHANGED, Callback)` to set the `WM_DPICHANGED` message
     * handler. This method is called by `GuiH.SetDpiChangeHandler` and `Gui.Call`. The default
     * callback is `GUI_HANDLEDPICHANGE`, the primary built-in function for handling dpi changes.
     */
    static SetDpiChangeHandler(Callback := GUI_HANDLEDPICHANGE) {
        OnMessage(WM_DPICHANGED ?? 0x02E0, Callback)
    }


    /**
     * @description - An alternate method for creating a new Gui object. This method sets
     * some defaults, like the initial `Opt` values, and also has built-in `SetThreadDpiAwarenessContext`
     * to `-4` for initializing per-monitor dpi-aware windows. If the `EventHandler` is defined here,
     * it gets added to the Gui object on propert `EventHandler` (as well as passed to the constructor).
     * @param {String} [Opt='-DPIScale +Resize'] - The first parameter of `Gui.Call`.
     * @param {String} [Title] - The second parameter of `Gui.Call`.
     * @param {String} [EventHandler] - The third parameter of `Gui.Call`.
     * @param {String} [OptFont] - The first parameter of `Gui.Prototype.SetFont`.
     * @param {String} [FontFamily] - The second parameter of `Gui.Prototype.SetFont`.
     * @returns {Gui} - The new Gui object.
     */
    static Call(Opt := '-DPIScale +Resize', Title?, EventHandler?, OptFont?, FontFamily?) {
        DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
        G := Gui(Opt, Title ?? unset, EventHandler ?? unset)
        if IsSet(EventHandler) {
            G.EventHandler := EventHandler
        }
        if IsSet(OptFont) || IsSet(FontFamily) {
            G.SetFont(OptFont ?? unset, FontFamily ?? unset)
        }
        return G
    }

    /**
     * @description - Enumerate a specific control type of the controls in a Gui object.
     * @example
        for Ctrl in GuiH.EnumerateControls(G, 'Button', 1) {
            Ctrl.GetPos(&x, &y)
            if x > 0 && y < 100 {
                Ctrl.Move(x * .85)
            }
        }
     * @
     * @param {Gui} G - The Gui object to enumerate.
     * @param {String} CtrlType - The control type to enumerate.
     * @param {Integer} [VarCount] - The number of variables to return. 1 or 2.
     * - 1: Returns the control object.
     * - 2: Returns the control object and the control name.
     * @returns {Func} - A function compatible with AHK loops.
     */
    static EnumerateControl(G, CtrlType, VarCount := 2) {
        List := []
        for Ctrl in G {
            if Ctrl.Type = CtrlType
                List.Push(Ctrl)
        }
        i := 0
        if VarCount == 2
            return _Enumerate2
        else
            return _Enumerate1

        _Enumerate1(&Ctrl) {
            if ++i > List.Length
                return 0
            Ctrl := List[i]
            return 1
        }
        _Enumerate2(&Name, &Ctrl) {
            if ++i > List.Length
                return 0
            Ctrl := List[i]
            Name := Ctrl.Name
            return 1
        }
    }

    /**
     * @class
     * @description - An instance of this class is added to `Gui.Control` objects on property
     * `DpiChangeHelper`. This implements some necessary logic for correctly scaling and responding
     * to `WM_DPICHANGED`.
     */
    class ControlDpiChangeHelper {
        /**
         * @description - This method is used to create a new instance of the `ControlDpiChangeHelper`
         * class. This method is called by the `Gui.Control` constructor.
         * @param {Gui.Control} Ctrl - The control object to attach this helper to.
         * @returns {GuiH.ControlDpiChangeHelper} - The new instance of the `ControlDpiChangeHelper`.
         */
        __New(Ctrl) {
            Win.GetFontDetails(Ctrl.Hwnd, &FontSize)
            this.FontSize := FontSize
            this.Rounded := { X: 0, Y: 0, W: 0, H: 0, F: 0 }
            this.Offset := { X: 0, Y: 0, W: 2, H: 2, F: 0 }
            Ctrl.DefineProp('DpiChangeHelper', { Value: this })
        }

        /**
         * @description - This method is used to get the dpi-adjusted position and size values for
         * a control. This method is to be used when scaling controls by a dpi ratio. This method
         * prevents control drifting due to repeated rounding.
         * @param {Float} DpiRatio - The ratio of the new dpi to the old dpi.
         * @param {VarRef} [X] - The x coordinate of the control. This must contain the original
         * X value and will be modified to the scaled X value.
         * @param {VarRef} [Y] - The y coordinate of the control. This must contain the original
         * Y value and will be modified to the scaled Y value.
         * @param {VarRef} [W] - The width of the control. This must contain the original
         * W value and will be modified to the scaled W value.
         * @param {VarRef} [H] - The height of the control. This must contain the original
         * H value and will be modified to the scaled H value.
         */
        Adjust(DpiRatio, &X?, &Y?, &W?, &H?) {
            if IsSet(X) {
                X := Round(NewX := (X + (this.Rounded.X >= 0.5 ? this.Rounded.X*-1 : this.Rounded.X)) * DPIRatio, 0)
                this.Rounded.X := NewX - Floor(NewX)
            }
            if IsSet(Y) {
                Y := Round(NewY := (Y + (this.Rounded.Y >= 0.5 ? this.Rounded.Y*-1 : this.Rounded.Y)) * DPIRatio, 0)
                this.Rounded.Y := NewY - Floor(NewY)
            }
            if IsSet(W) {
                W := Round(NewW := (W + (this.Rounded.W >= 0.5 ? this.Rounded.W*-1 : this.Rounded.W)) * DPIRatio, 0)
                this.Rounded.W := NewW - Floor(NewW)
            }
            if IsSet(H) {
                H := Round(NewH := (H + (this.Rounded.H >= 0.5 ? this.Rounded.H*-1 : this.Rounded.H)) * DPIRatio, 0)
                this.Rounded.H := NewH - Floor(NewH)
            }
        }

        /**
         * @description - This method is used to get the dpi-adjusted position and size values for
         * a control. This method is to be used when scaling controls according to their text contents.
         * This method, when used in conjunction with text scaling functions, addresses the problem
         * of non-linear text scaling leaving blank / empty space within and around controls that
         * primarily contain text. When scaling using only a dpi ratio, there is often noticeable
         * gaps between the text and the control's borders. The way to handle this is to map the
         * interface around the control's text contents, instead of mapping the interface around
         * the controls' relative position to one another.
         * <br>
         * You don't need to call this method directly if you are using the built-in WM_DPICHANGED
         * family of functions. This method is called for any controls that are set by the
         * `DisplayConfig.ResizeByText` property. The default value sets this for controls which have
         * a simple `Text` property (e.g. no controls for which `Text` might return an array, or
         * for which `Text` does not return a string).
         * <br>
         * This library does not provide any methods for filling the extra space that your interface
         * gains from this process. Modern apps usually have a separate layouts defined to seamlessly
         * fill the extra space when the dpi changes.
         * <br>
         * This method performs these functions:
         * - Adjusts the size and position values according to the ratio of the a controls' new
         * text extent to its original text extent.
         * - Caches rounding to prevent control drifting.
         * - Applies the `Offset` values to the width and height, if the `Offset` has been defined
         * for the control / control type. The `Offset` can help fine-tune the size of a control
         * when direct scaling causes the control to be too large or too small.
         * <br>
         * @param {Float} WidthRatio - The ratio of: NewTextExtent / OriginalTextExtent.
         * @param {Float} HeightRatio - The ratio of: NewTextExtent / OriginalTextExtent.
         * @param {VarRef} [X] - The x coordinate of the control. This must contain the original
         * X value and will be modified to the scaled X value.
         * @param {VarRef} [Y] - The y coordinate of the control. This must contain the original
         * Y value and will be modified to the scaled Y value.
         * @param {VarRef} [W] - The width of the control. This must contain the original
         * W value and will be modified to the scaled W value.
         * @param {VarRef} [H] - The height of the control. This must contain the original
         * H value and will be modified to the scaled H value.
         */
        AdjustByText(WidthRatio, HeightRatio, &X?, &Y?, &W?, &H?) {
            if IsSet(X) {
                X := Round(NewX := (X + (this.Rounded.X >= 0.5 ? this.Rounded.X*-1 : this.Rounded.X)) * WidthRatio, 0) + this.Offset.X
                this.Rounded.X := NewX - Floor(NewX)
                this.Offset.X *= -1
            }
            if IsSet(Y) {
                Y := Round(NewY := (Y + (this.Rounded.Y >= 0.5 ? this.Rounded.Y*-1 : this.Rounded.Y)) * HeightRatio, 0) + this.Offset.Y
                this.Rounded.Y := NewY - Floor(NewY)
                this.Offset.Y *= -1
            }
            if IsSet(W) {
                W := Round(NewW := (W + (this.Rounded.W >= 0.5 ? this.Rounded.W*-1 : this.Rounded.W)) * WidthRatio, 0) + this.Offset.W
                this.Rounded.W := NewW - Floor(NewW)
                this.Offset.W *= -1
            }
            if IsSet(H) {
                H := Round(NewH := (H + (this.Rounded.H >= 0.5 ? this.Rounded.H*-1 : this.Rounded.H)) * HeightRatio, 0) + this.Offset.H
                this.Rounded.H := NewH - Floor(NewH)
                this.Offset.H *= -1
            }
        }
    }

    /**
     * @class
     * @description - An instance of this class is added to `Gui` objects on property
     * `DpiChangeHelper`. This implements some necessary logic for correctly scaling and responding
     * to `WM_DPICHANGED`.
     */
    class GuiDpiChangeHelper {
        /**
         * @description - This method is used to create a new instance of the `GuiDpiChangeHelper`
         * class. This method is called by the `Gui` constructor.
         * @param {Gui} GuiObj - The Gui object to attach this helper to.
         * @returns {GuiH.GuiDpiChangeHelper} - The new instance of the `GuiDpiChangeHelper`.
         */
        __New(GuiObj) {
            this.FontSize := 6
            this.Dpi := Mon.Dpi.Win(GuiObj.Hwnd)
            this.Rounded := { F: 0 }
            GuiObj.DefineProp('DpiChangeHelper', { Value: this })
        }
    }
}

