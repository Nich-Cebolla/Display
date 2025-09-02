
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/RECT.ahk
#include <Rect>

#include ..\definitions
#include Define-Dpi.ahk
#include Define-Font.ahk
#include ..\src
#include dMon.ahk
#include ..\lib
#include MetaSetThreadDpiAwareness.ahk
#include ControlTextExtent.ahk
#include Dpi.ahk
#include Text.ahk

class dGui extends Gui {

    /**
     * @description - Creates the `dGui` window and initializes the properties required to use the
     * built-in `WM_DPICHANGED` handler. `dGui.Call` performs these actions:
     * - Creates the `dGui` object.
     * - Processes `ExtendedOptions`.
     * - Sets `dGuiObj.Count := 0`.
     * - Sets `dGuiObj.CachedDpi := dGuiObj.Dpi`.
     * @param {String} [Opt] - The first parameter of `Gui.Call`.
     * @param {String} [Title] - The second parameter of `Gui.Call`.
     * @param {String} [EventHandler] - The third parameter of `Gui.Call`.
     * @param {Object} [ExtendedOptions] - An object that defines additional options. The object can
     * have zero or more of { BackColor, FontName, MarginX, MarginY, MenuBar, Name, OptFont }.
     * If `ExtendedOptions.OptFont` is not set, or if it does not contain a size value, the font size
     * is set to the `InitialFontSize` value which can be set in your "ProjectConfig.ahk" options.
     * @returns {dGui} - The new `dGui` object.
     */
    static Call(Opt?, Title?, EventHandler?, ExtendedOptions?) {
        ObjSetBase(dGuiObj := Gui(Opt ?? unset, Title ?? unset, EventHandler ?? unset), this.Prototype)
        if IsSet(ExtendedOptions) {
            for Prop in ['MarginX', 'MarginY', 'BackColor', 'MenuBar', 'Name'] {
                if HasProp(ExtendedOptions, Prop) {
                    dGuiObj.%Prop% := ExtendedOptions.%Prop%
                }
            }
            if HasProp(ExtendedOptions, 'OptFont') {
                if InStr(ExtendedOptions.OptFont, 's') {
                    dGuiObj.SetFont(ExtendedOptions.OptFont)
                } else {
                    dGuiObj.__SetFont(ExtendedOptions.OptFont ' s' dGuiObj.FontSizeScaled)
                }
            } else {
                dGuiObj.__SetFont('s' dGuiObj.FontSizeScaled)
            }
            if HasProp(ExtendedOptions, 'FontName') {
                dGuiObj.SetFont(, ExtendedOptions.FontName)
            }
        } else {
            dGuiObj.__SetFont('s' dGuiObj.FontSizeScaled)
        }
        if IsSet(EventHandler) {
            dGuiObj.EventHandler := EventHandler
        }
        dGuiObj.Count := 0
        dGuiObj.CachedDpi := dGuiObj.Dpi
        return dGuiObj
    }

    static Initialize() {
        cProto := this.Control.Prototype
        Proto := this.Prototype
        gProto := Gui.Prototype
        gcProto := Gui.Control.Prototype

        (ClassList := []).Capacity := 30
        ; Programmatically getting a list of all built-in control types
        for Prop in dGui.OwnProps() {
            if dGui.%Prop% is Class {
                if Prop == 'Control' {
                    continue
                }
                ClassList.Push(dGui.%Prop%)
            }
        }

        ;@region ResizeByText
        if this.ResizeByText {
            list := this.ResizeByText.Clone()
            ByText := cProto.GetOwnPropDesc('__ResizeByText')
            ByDpi := cProto.GetOwnPropDesc('__ResizeByDpi')
            for Cls in ClassList {
                Cls.Prototype.DefineProp('HandleDpiChanged', ByDpi)
                for CtrlType in list {
                    if Cls.Prototype.__Class = CtrlType {
                        Cls.Prototype.DefineProp('HandleDpiChanged', ByText)
                        list.RemoveAt(A_Index)
                        continue 2
                    }
                }
            }
            for CtrlType in this.ResizeByText {
                dGui.%CtrlType%.Prototype.DefineProp('HandleDpiChanged', cProto.GetOwnPropDesc('__ResizeByText'))
            }
        }
        ;@endregion

        ;@region CtrlSetTextEx
        dGui.Text.Prototype.DefineProp('SetTextEx', { Call: ControlSetTextEx })
        dGui.Text.Prototype.DefineProp('TextEx', { Set: ControlSetTextEx })
        dGui.Edit.Prototype.DefineProp('SetTextEx', { Call: ControlSetTextEx })
        dGui.Edit.Prototype.DefineProp('TextEx', { Set: ControlSetTextEx })
        ;@endregion

        Proto.DefineProp('DpiExclude', { Value: false })
        Proto.DefineProp('DpiChangedCallbackBefore', { Value: false })
        Proto.DefineProp('DpiChangedCallbackAfter', { Value: false })
        Proto.DefineProp('ToggleCallbackBefore', { Value: false })
        Proto.DefineProp('ToggleCallbackAfter', { Value: false })
        Proto.DefineProp('DpiChangedCallbackBeforeActive', { Value: false })
        Proto.DefineProp('DpiChangedCallbackAfterActive', { Value: false })
        Proto.DefineProp('ToggleCallbackBeforeActive', { Value: false })
        Proto.DefineProp('ToggleCallbackAfterActive', { Value: false })
        this.DefineProp('__Call', { Call: MetaSetThreadDpiAwareness })
        Proto.DefineProp('__Call', { Call: MetaSetThreadDpiAwareness })
        cProto.DefineProp('__Call', { Call: MetaSetThreadDpiAwareness })
        Proto.DefineProp('__Add', gProto.GetOwnPropDesc('Add'))
        Proto.DefineProp('__SetFont', gProto.GetOwnPropDesc('SetFont'))
        cProto.DefineProp('__SetFont', gcProto.GetOwnPropDesc('SetFont'))
        TextExtentFuncs := Map(
            'ListBox', 'ControlGetTextExtent{}_LB'
            , 'Link', 'ControlGetTextExtent{}_Link'
            , 'ListView', 'ControlGetTextExtent{}_LV'
            , 'TreeView', 'ControlGetTextExtent{}_TV'
        )
        TextExtentFuncs.Default := 'ControlGetTextExtent{}'
        for CtrlType in ['Button', 'CheckBox', 'DateTime', 'Edit', 'GroupBox', 'Hotkey', 'Link'
        , 'ComboBox', 'DDL', 'ListBox', 'Tab', 'ListView', 'Radio', 'StatusBar', 'Text', 'TreeView'] {
            this.%CtrlType%.Prototype.DefineProp('GetTextExtent', { Call: %Format(TextExtentFuncs.Get(CtrlType), '')% })
            this.%CtrlType%.Prototype.DefineProp('GetTextExtentEx', { Call: %Format(TextExtentFuncs.Get(CtrlType), 'Ex')% })
        }
        Proto.DefineProp('BaseFontSize', { Value: this.InitialFontSize })

        methods := Map()
        for Prop in cProto.OwnProps() {
            methods.Set(Prop, cProto.GetOwnPropDesc(Prop))
        }
        methods.Delete('__Class')
        if methods.Has('Base') {
            methods.Delete('Base')
        }
        for Prop in this.OwnProps() {
            if this.%Prop% is Class {
                if Prop == 'Control' {
                    continue
                }
                _proto := this.%Prop%.Prototype
                for name, method in methods {
                    _proto.DefineProp(name, method)
                }
            }
        }
    }

    /**
     * @description - Defines a function to call before or after `dGui.Prototype.Toggle`. The
     * functions defined here will apply to all `dGui` objects that have not called their method
     * `dGui.Prototype.SetToggleCallback`.
     *
     * The callbacks can be any callable object, such as a function object, an object with a `Call`
     * property, or an object with a `__Call` property.
     *
     * The function should accept up to three parameters:
     * 1. The `dGui` object.
     * 2. If the `Value` parameter of `dGui.Prototype.Toggle` is set, `Value`. Else, this parameter
     * will receive 1 if the window is about to be shown (it is currently hidden), or 0 if the
     * window is about to be hidden.
     * 3. This must be optional. If a value is passed to the `Options` parameter of
     * `dGui.Prototype.Toggle`, this will receive the value. Else, this will be unset.
     *
     * Set `CallbackBefore` or `CallbackAfter` to zero or an empty string to disable a callback.
     *
     * @param {*} [CallbackBefore] - A callable object to call at the beginning of `dGui.Prototype.Toggle`.
     * @param {*} [CallbackAfter] - A callable object to call at the end of `dGui.Prototype.Toggle`.
     */
    static SetToggleCallback(CallbackBefore?, CallbackAfter?) {
        if IsSet(CallbackBefore) {
            this.Prototype.DefineProp('ToggleCallbackBefore', { Call: CallbackBefore })
            this.Prototype.ToggleCallbackBeforeActive := CallbackBefore ? 1 : 0
        }
        if IsSet(CallbackAfter) {
            this.Prototype.DefineProp('ToggleCallbackAfter', { Call: CallbackAfter })
            this.Prototype.ToggleCallbackAfterActive := CallbackAfter ? 1 : 0
        }
    }

    /**
     * @description - Calls `OnMessage` to set the `WM_DPICHANGED` message handler. The default
     * callback is the global function `HDpiChanged`, the built-in function for handling dpi changes.
     * @p
     * @param {*} [Callback = HDpiChanged] - A callable object that will be called when a `Gui` / `dGui`
     * window receives the `WM_DPICHANGED` message.
     */
    static SetDpiChangedHandler(MaxThreads, Callback := HDpiChanged) {
        OnMessage(WM_DPICHANGED, Callback, MaxThreads)
    }

    /**
     * @description - Defines a function to call before or after `dGui.Prototype.OnDpiChanged`. The
     * functions defined here will apply to all `dGui` objects that have not called their method
     * `dGui.Prototype.SetToggleCallback`.
     *
     * The function should accept up to three parameters:
     * 1. The `dGui` object.
     * 2. The new dpi value.
     * 3. The `DeferWindowPos` handle that is used to resize the controls.
     *
     * Set `CallbackBefore` or `CallbackAfter` to zero or an empty string to disable a callback.
     * Disabling a callback is not the same as deleting it. When a callback is disabled,
     * `dGuiObj.DpiChangedCallbackBefore`, `dGuiObj.DpiChangedCallbackBeforeActive`,
     * `dGuiObj.DpiChangedCallbackAfter`, and `dGuiObj.DpiChangedCallbackAfterActive` are all set with a
     * falsy value. If callbacks have been defined on `dGui.Prototype` by calling the static method
     * `dGui.SetDpiChangedCallback`, those will be ignored because the values are overridden by the
     * instance's own properties. Call `dGui.Prototype.DeleteDpiChangedCallback` to delete the own
     * properties so the prototype's callbacks can be called.
     *
     * @param {*} [CallbackBefore] - A callable object to call at the beginning of `dGui.Prototype.OnDpiChanged`.
     * @param {*} [CallbackAfter] - A callable object to call at the end of `dGui.Prototype.OnDpiChanged`.
     */
    static SetDpiChangedCallback(CallbackBefore?, CallbackAfter?) {
        if IsSet(CallbackBefore) {
            this.Prototype.DefineProp('DpiChangedCallbackBefore', { Call: CallbackBefore })
            this.Prototype.DpiChangedCallbackBeforeActive := CallbackBefore ? 1 : 0
        }
        if IsSet(CallbackAfter) {
            this.Prototype.DefineProp('DpiChangedCallbackAfter', { Call: CallbackAfter })
            this.Prototype.DpiChangedCallbackAfterActive := CallbackAfter ? 1 : 0
        }
    }

    static __New() {
        this.DeleteProp('__New')
        this.DefineProp('ResizeByText', { Value: ['Button', 'Edit', 'Link', 'StatusBar', 'Text'] })
        this.DefineProp('ControlIncludeByDefault', { Value: true })
        this.DefineProp('InitialFontSize', { Value: 10 })
    }

    Add(CtrlType, Options?, Text?) {
        Ctrl := this.__Add(CtrlType, Options ?? unset, Text ?? unset)
        if InStr(CtrlType, 'Tab') {
            ObjSetBase(Ctrl, dGui.Tab.Prototype)
        } else {
            ObjSetBase(Ctrl, dGui.%CtrlType%.Prototype)
        }
        Ctrl.DefineProp('BaseFontSize', { Value: Ctrl.Gui.BaseFontSize })
        fss := Ctrl.FontSizeScaled
        Ctrl.__SetFont('s' fss)
        Ctrl.DefineProp('__Rounding', { Value: { X: 0, Y: 0, W: 0, H: 0 } })
        this.Count++
        if !IsSet(Options) || !InStr(Options, '-vscroll') {
            switch Ctrl.Type, 0 {
                case 'Edit':
                    if InStr(Ctrl.Text, '`r`n') {
                        Ctrl.GetPos(, , &w)
                        Ctrl.Move(, , w + dGui.ScrollbarPadding)
                    }
            }
        }
        return Ctrl
    }

    AddActiveX(Options?, Text?) => this.Add('ActiveX', Options ?? unset, Text ?? unset)
    AddButton(Options?, Text?) => this.Add('Button', Options ?? unset, Text ?? unset)
    AddCheckBox(Options?, Text?) => this.Add('CheckBox', Options ?? unset, Text ?? unset)
    AddComboBox(Options?, Text?) => this.Add('ComboBox', Options ?? unset, Text ?? unset)
    AddCustom(Options?, Text?) => this.Add('Custom', Options ?? unset, Text ?? unset)
    AddDateTime(Options?, Text?) => this.Add('DateTime', Options ?? unset, Text ?? unset)
    AddDDL(Options?, Text?) => this.Add('DDL', Options ?? unset, Text ?? unset)
    AddEdit(Options?, Text?) => this.Add('Edit', Options ?? unset, Text ?? unset)
    AddGroupBox(Options?, Text?) => this.Add('GroupBox', Options ?? unset, Text ?? unset)
    AddHotkey(Options?, Text?) => this.Add('Hotkey', Options ?? unset, Text ?? unset)
    AddLink(Options?, Text?) => this.Add('Link', Options ?? unset, Text ?? unset)
    AddListBox(Options?, Text?) => this.Add('ListBox', Options ?? unset, Text ?? unset)
    AddListView(Options?, Text?) => this.Add('ListView', Options ?? unset, Text ?? unset)
    AddMonthCal(Options?, Text?) => this.Add('MonthCal', Options ?? unset, Text ?? unset)
    AddPic(Options?, Text?) => this.Add('Pic', Options ?? unset, Text ?? unset)
    AddProgress(Options?, Text?) => this.Add('Progress', Options ?? unset, Text ?? unset)
    AddRadio(Options?, Text?) => this.Add('Radio', Options ?? unset, Text ?? unset)
    AddSlider(Options?, Text?) => this.Add('Slider', Options ?? unset, Text ?? unset)
    AddStatusBar(Options?, Text?) => this.Add('StatusBar', Options ?? unset, Text ?? unset)
    AddTab(Options?, Text?) => this.Add('Tab', Options ?? unset, Text ?? unset)
    AddTab2(Options?, Text?) => this.Add('Tab2', Options ?? unset, Text ?? unset)
    AddTab3(Options?, Text?) => this.Add('Tab3', Options ?? unset, Text ?? unset)
    AddText(Options?, Text?) => this.Add('Text', Options ?? unset, Text ?? unset)
    AddTreeView(Options?, Text?) => this.Add('TreeView', Options ?? unset, Text ?? unset)
    AddUpDown(Options?, Text?) => this.Add('UpDown', Options ?? unset, Text ?? unset)

    /**
     * @description - Deletes the own properties related to the callback function, allowing
     * the callback function defined on the prototype to be used if one exists.
     *
     * @param {Boolean} [CallbackBefore = false] - If true, `dGuiObj.DpiChangedCallbackBefore` and
     * `dGuiObj.DpiChangedCallbackBeforeActive` are deleted.
     * @param {Boolean} [CallbackAfter = false] - If true, `dGuiObj.DpiChangedCallbackAfter` and
     * `dGuiObj.DpiChangedCallbackAfterActive` are deleted.
     */
    DeleteDpiChangedCallback(CallbackBefore := false, CallbackAfter := false) {
        if CallbackBefore {
            this.DeleteProp('DpiChangedCallbackBefore')
            this.DeleteProp('DpiChangedCallbackBeforeActive')
        }
        if CallbackAfter {
            this.DeleteProp('DpiChangedCallbackAfter')
            this.DeleteProp('DpiChangedCallbackAfterActive')
        }
    }
    /**
     * @description - Deletes the own properties related to the callback function, allowing
     * the callback function defined on the prototype to be used if one exists.
     *
     * @param {Boolean} [CallbackBefore = false] - If true, `dGuiObj.ToggleCallbackBefore` and
     * `dGuiObj.ToggleCallbackBeforeActive` are deleted.
     * @param {Boolean} [CallbackAfter = false] - If true, `dGuiObj.ToggleCallbackAfter` and
     * `dGuiObj.ToggleCallbackAfterActive` are deleted.
     */
    DeleteToggleCallback(CallbackBefore := false, CallbackAfter := false) {
        if CallbackBefore {
            this.DeleteProp('ToggleCallbackBefore')
            this.DeleteProp('ToggleCallbackBeforeActive')
        }
        if CallbackAfter {
            this.DeleteProp('ToggleCallbackAfter')
            this.DeleteProp('ToggleCallbackAfterActive')
        }
    }
    /**
     * @description - Enumerate a subset of controls.
     * @example
     *  ; Assume `dGuiObj` is already set with a `dGui` object.
     *  for Ctrl in dGuiObj.EnumerateControls('Button', 1) {
     *      Ctrl.GetPos(&x, &y)
     *      if x > 0 && y < 100 {
     *          Ctrl.Move(x * .85)
     *      }
     *  }
     * @
     * @param {String} CtrlType - The control type to enumerate, or a comma-delimited list of
     * control types, e.g. "Text,Button,Edit".
     * @param {Integer} VarCount - The number of variables used within the loop. 1 or 2.
     * - 1: Returns the control object to the parameter.
     * - 2: Returns the control name to the first parameter, and the control object to the second.
     * @returns {Func} - A function compatible with AHK loops.
     */
    EnumerateControl(CtrlType, VarCount) {
        List := []
        CtrlType := ',' CtrlType ','
        for Ctrl in this {
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

    FitControl(Ctrl, PaddingX := 0, PaddingY := 0) {
        if Ctrl is String {
            Ctrl := this[Ctrl]
        }
        Ctrl.GetPos(&x, &y, &w, &h)
        this.Show(Format('w{} h{}', x + w + this.MarginX + PaddingX, y + h + this.MarginY + PaddingY))
    }

    /**
     * @description - This is the core built-in method for resopnding to `WM_DPICHANGED` messages.
     * This method is called from the global function `HDpiChanged`. `HDpiChanged` must first be
     * set as the callback for `WM_DPICHANGED` messages, either in your external code, or by calling
     * `dGui.SetDpiChangedHandler`.
     *
     * The built-in `WM_DPICHANGED` handler performs the following actions. Individual control
     * objects that have a nonzero `Ctrl.DpiExclude` value are skipped. This list does not represent
     * the order of the actions.
     * - Resizes the `dGui` window to the system-recommended values provided by the `WM_DPICHANGED`
     * message.
     * - Scales the font size for the `dGui` window and its controls.
     * - Scales the control's dimensions. Some controls are scaled according to their text
     * content. Some controls are scaled using the dpi ratio. The types of controls which are
     * scaled using their text content can be changed in the configuration document.
     * - Calls the `DpiChangedCallbackBefore` and `DpiChangedCallbackAfter` functions.
     *
     * @param {Integer} NewDpi - The new dpi value.
     * @param {Integer} RectObj - The `Rect` object created from the `lParam` value.
     */
    OnDpiChanged(NewDpi) {
        hDwp := DllCall('BeginDeferWindowPos', 'int', this.Count, 'ptr')
        if this.DpiChangedCallbackBeforeActive {
            this.DpiChangedCallbackBefore(NewDpi, hDwp)
        }

        ; OutputDebug('`n---------`n`n')
        ; OutputDebug(Format('Before scaling (GUI):`nX == {:4} Y == {}`nW == {:4} H == {}`n', gx, gy, gw, gh))
        ; OutputDebug(Format('System recommended:`nX == {:4} Y == {}`nW == {:4} H == {}`n', RectObj.L, RectObj.T, RectObj.W, RectObj.H))
        ; OutputDebug(Format('Scaled directly:`nX == {:4} Y == {}`nW == {:4} H == {}`n', gx * DpiRatio, gy * DpiRatio, gw * DpiRatio, gh * DpiRatio))
        ; OutputDebug('BaseFontSize == ' this.BaseFontSize '`n')
        ; OutputDebug('DpiRatio = ' DpiRatio '`n')

        this.GetPos(&gx, &gy, &gw, &gh)
        DpiRatio := NewDpi / this.CachedDpi
        ; We cannot add the gui to the DeferWindowPos struct; its dimensions must be updated first.
        this.Move(gx * DpiRatio, gy * DpiRatio, gw * DpiRatio, gh * DpiRatio)
        for Ctrl in this {
            if Ctrl.DpiExclude {
                OutputDebug('`n' Ctrl.Name ' - DpiExclude - exiting loop.`n')
                continue
            }
            Ctrl.GetPos(&X, &Y, &W, &H)
            ; OutputDebug(Format('Before scaling:`nX == {:4} Y == {}`nW == {:4} H == {}`n', X, Y, W, H))
            dGui.Control.Prototype.__ResizeByDpi.Call(Ctrl, &X, &Y, &W, &H, NewDpi)
            ; Ctrl.HandleDpiChanged(&X, &Y, &W, &H, NewDpi)
            ; OutputDebug(Format('After scaling:`nX == {:4} Y == {}`nW == {:4} H == {}`n', X, Y, W, H))
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
            throw OSError()
        }
        this.__SetFont('s' (this.BaseFontSize * NewDpi / BASE_DPI))
        if this.DpiChangedCallbackAfterActive {
            this.DpiChangedCallbackAfter(NewDpi, hDwp)
        }
        this.CachedDpi := NewDpi
        ; OutputDebug('`nOld font size == ' (this.BaseFontSize * this.CachedDpi / BASE_DPI) '`nNew font size == ' (this.BaseFontSize * NewDpi / BASE_DPI) '`n')
    }

    /**
     * @description - Defines a function to call before or after `dGui.Prototype.OnDpiChanged`. The
     * callbacks can be any callable object, such as a function object, an object with a `Call`
     * property, or an object with a `__Call` property.
     *
     * The function should accept up to three parameters:
     * 1. The `dGui` object.
     * 2. The new dpi value.
     * 3. The `DeferWindowPos` handle that is used to resize the controls.
     *
     * Set `CallbackBefore` or `CallbackAfter` to zero or an empty string to disable a callback.
     * Disabling a callback is not the same as deleting it. When a callback is disabled,
     * `dGuiObj.DpiChangedCallbackBefore`, `dGuiObj.DpiChangedCallbackBeforeActive`,
     * `dGuiObj.DpiChangedCallbackAfter`, and `dGuiObj.DpiChangedCallbackAfterActive` are all set with a
     * falsy value. If callbacks have been defined on `dGui.Prototype` by calling the static method
     * `dGui.SetDpiChangedCallback`, those will be ignored because the values are overridden by the
     * instance's own properties. Call `dGui.Prototype.DeleteDpiChangedCallback` to delete the own
     * properties so the prototype's callbacks can be called.
     *
     * @param {*} [CallbackBefore] - A callable object to call at the beginning of `dGui.Prototype.OnDpiChanged`.
     * @param {*} [CallbackAfter] - A callable object to call at the end of `dGui.Prototype.OnDpiChanged`.
     */
    SetDpiChangedCallback(CallbackBefore?, CallbackAfter?) {
        if IsSet(CallbackBefore) {
            this.DefineProp('DpiChangedCallbackBefore', { Call: CallbackBefore })
            this.DpiChangedCallbackBeforeActive := CallbackBefore ? 1 : 0
        }
        if IsSet(CallbackAfter) {
            this.DefineProp('DpiChangedCallbackAfter', { Call: CallbackAfter })
            this.DpiChangedCallbackAfterActive := CallbackAfter ? 1 : 0
        }
    }

    /**
     * @description - `dGui.Prototype.SetFontSize` sets the font options for the gui, and if size is
     * included in `FontOpt`, scales the font size with the monitor's dpi and caches the base font
     * size value.
     * Parameter details copied from {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont}.
     *
     * @param {String} [OptFont] - The first parameter of `Gui.Prototype.SetFont`.
     *
     * Zero or more options. Each option is either a single letter immediately followed by a value,
     * or a single word. To specify more than one option, include a space between each. For example:
     * cBlue s12 bold.
     *
     * The following words are supported: bold, italic, strike, underline, and norm. Norm returns
     * the font to normal weight/boldness and turns off italic, strike, and underline (but it retains
     * the existing color and size). It is possible to use norm to turn off all attributes and then
     * selectively turn on others. For example, specifying norm italic would set the font to normal
     * then to italic.
     *
     * C: Color name (see color chart) or RGB value -- or specify the word Default to return to the
     * system's default color (black on most systems). Example values: cRed, cFFFFAA, cDefault.
     * Note: Buttons and status bars do not obey custom colors. Also, an individual control can be
     * created with a font color other than the current one by including the C option. For example:
     * MyGui.Add("Text", "cRed", "My Text").
     *
     * S: Size (in points). For example: s12 (specify decimal, not hexadecimal)
     *
     * W: Weight (boldness), which is a number between 1 and 1000 (400 is normal and 700 is bold).
     * For example: w600 (specify decimal, not hexadecimal)
     *
     * Q: Text rendering quality. For example: q3. Q should be followed by a number from the following table:
     *
     * |Number|   Windows Constant     | Description                                                |
     * |------|------------------------|------------------------------------------------------------|
     * | 0    | DEFAULT_QUALITY	       | Appearance of the font does not matter.|
     * | 1    | DRAFT_QUALITY	       | Appearance of the font is less important than when the PROOF_QUALITY value is used.|
     * | 2	  | PROOF_QUALITY	       | Character quality of the font is more important than exact matching of the logical-font attributes.|
     * | 3	  | NONANTIALIASED_QUALITY | Font is never antialiased, that is, font smoothing is not done.|
     * | 4	  | ANTIALIASED_QUALITY	   | Font is antialiased, or smoothed, if the font supports it and the size of the font is not too small or too large.|
     * | 5    | CLEARTYPE_QUALITY	   | If set, text is rendered (when possible) using ClearType antialiasing method.|
     *
     * @param {String} [FontName] - In contrast with `Gui.Prototype.SetFont`, the `FontName` parameter
     * of `dGui.Prototype.SetFont` allows multiple font names to be defined in one function call.
     * `FontName` here can be a comma-delimited list of font names. The following is copied from
     * the AHK documentation:
     *
     * FontName may be the name of any font, such as one from the font table. If FontName is omitted
     * or does not exist on the system, the previous font's typeface will be used (or if none, the
     * system's default GUI typeface). This behavior is useful to make a GUI window have a similar
     * font on multiple systems, even if some of those systems lack the preferred font. For example,
     * by using the following methods in order, Verdana will be given preference over Arial, which
     * in turn is given preference over MS Sans Serif:
     * @example
     * MyGui.SetFont(, "MS Sans Serif")
     * MyGui.SetFont(, "Arial")
     * MyGui.SetFont(, "Verdana")  ; Preferred font.
     * @
     */
    SetFont(OptFont?, FontName?) {
        if IsSet(OptFont) {
            if RegExMatch(OptFont, '(?<opt1>[^sS]*)[sS](?<n>[\d.]+)(?<opt2>.*)', &MatchFont) {
                this.DefineProp('BaseFontSize', { Value: MatchFont['n'] })
                this.__SetFont(MatchFont['opt1'] MatchFont['opt2'] ' s' this.FontSizeScaled)
            } else {
                this.__SetFont(OptFont)
            }
        }
        if IsSet(FontName) {
            for Name in StrSplit(FontName, ',') {
                if Name {
                    this.__SetFont(, Name)
                }
            }
        }
    }

    /**
     * @description - Use `dGui.Prototype.SetFontSize` when only changing the font size for slightly
     * better performance compared to `dGui.Prototype.SetFont`. This scales the font size with the
     * monitor's dpi and caches the base font size value. See the explanation at the top of the code
     * file "dGui.ahk" for details.
     * @param {Integer} FontSize - The new font size.
     */
    SetFontSize(FontSize) {
        this.DefineProp('BaseFontSize', { Value: FontSize })
        this.__SetFont('s' this.FontSizeScaled)
    }
    /**
     * @description - Defines a function to call before or after `dGui.Prototype.Toggle`. The
     * callbacks can be any callable object, such as a function object, an object with a `Call`
     * property, or an object with a `__Call` property.
     *
     * The function should accept up to three parameters:
     * 1. The `dGui` object.
     * 2. If the `Value` parameter of `dGui.Prototype.Toggle` is set, `Value`. Else, this parameter
     * will receive 1 if the window is about to be shown (it is currently hidden), or 0 if the
     * window is about to be hidden.
     * 3. This must be optional. If a value is passed to the `Options` parameter of
     * `dGui.Prototype.Toggle`, this will receive the value. Else, this will be unset.
     *
     * Set `CallbackBefore` or `CallbackAfter` to zero or an empty string to disable a callback.
     * Disabling a callback is not the same as deleting it. When a callback is disabled,
     * `dGuiObj.ToggleCallbackBefore`, `dGuiObj.ToggleCallbackBeforeActive`,
     * `dGuiObj.ToggleCallbackAfter`, and `dGuiObj.ToggleCallbackAfterActive` are all set with a
     * falsy value. If callbacks have been defined on `dGui.Prototype` by calling the static method
     * `dGui.SetToggleCallback`, those will be ignored because the values are overridden by the
     * instance's own properties. Call `dGui.Prototype.DeleteToggleCallback` to delete the own
     * properties so the prototype's callbacks can be called.
     *
     * @param {*} [CallbackBefore] - A callable object to call at the beginning of `dGui.Prototype.Toggle`.
     * @param {*} [CallbackAfter] - A callable object to call at the end of `dGui.Prototype.Toggle`.
     */
    SetToggleCallback(CallbackBefore?, CallbackAfter?) {
        if IsSet(CallbackBefore) {
            this.DefineProp('ToggleCallbackBefore', { Call: CallbackBefore })
            this.ToggleCallbackBeforeActive := CallbackBefore ? 1 : 0
        }
        if IsSet(CallbackAfter) {
            this.DefineProp('ToggleCallbackAfter', { Call: CallbackAfter })
            this.ToggleCallbackAfterActive := CallbackAfter ? 1 : 0
        }
    }

    /**
     * @description - Toggles the window's visibility. Also see {@link dGui#SetToggleCallback }
     * @param {Boolean} [Value] - Set this to specify a value instead of toggling it. A nonzero value
     * will display the window. A falsy value will hide it.
     * @param {String} [Options] - Any options to pass to `dGui.Prototype.Show`.
     * See {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Show}
     */
    Toggle(Value?, Options?) {
        if !IsSet(Value) {
            Value := DllCall('IsWindowVisible', 'Ptr', this.hWnd, 'int') ? 0 : 1
        }
        if this.ToggleCallbackBeforeActive {
            this.ToggleCallbackBefore(Value, Options ?? unset)
        }
        if Value {
            this.Show(Options ?? unset)
        } else {
            this.Hide()
        }
        if this.ToggleCallbackAfterActive {
            this.ToggleCallbackAfter(Value, Options ?? unset)
        }
    }

    Dpi => DllCall('GetDpiForWindow', 'ptr', this.hWnd, 'int')
    FontSizeScaled => Round(this.BaseFontSize * this.dpi / BASE_DPI, 0)
    Visible {
        Get => DllCall('IsWindowVisible', 'Ptr', this.hWnd, 'int')
        Set => Value ? this.Show() : this.Hide()
    }

    class Control extends Gui.Control {

        /**
         * @description - This method is used to get the dpi-adjusted position and size values for
         * a control using the dpi ratio. This method accounts for rounding to prevent drifting
         * controls.
         * @param {VarRef} X - The x coordinate of the control. This must contain the original
         * X value and will be modified to the scaled X value.
         * @param {VarRef} Y - The y coordinate of the control. This must contain the original
         * Y value and will be modified to the scaled Y value.
         * @param {VarRef} W - The width of the control. This must contain the original
         * W value and will be modified to the scaled W value.
         * @param {VarRef} H - The height of the control. This must contain the original
         * H value and will be modified to the scaled H value.
         * @param {Float} Ratio - New dpi / Previous dpi
         */
        ScaleMonoRatio(&X, &Y, &W, &H, DpiRatio, *) {
            if IsSet(X) {
                X := Round(NewX := (X + (this.__Rounding.X >= 0.5 ? this.__Rounding.X * -1 : this.__Rounding.X)) * DpiRatio, 0)
                this.__Rounding.X := NewX - Floor(NewX)
            }
            if IsSet(Y) {
                Y := Round(NewY := (Y + (this.__Rounding.Y >= 0.5 ? this.__Rounding.Y * -1 : this.__Rounding.Y)) * DpiRatio, 0)
                this.__Rounding.Y := NewY - Floor(NewY)
            }
            if IsSet(W) {
                W := Round(NewW := (W + (this.__Rounding.W >= 0.5 ? this.__Rounding.W * -1 : this.__Rounding.W)) * DpiRatio, 0)
                this.__Rounding.W := NewW - Floor(NewW)
            }
            if IsSet(H) {
                H := Round(NewH := (H + (this.__Rounding.H >= 0.5 ? this.__Rounding.H * -1 : this.__Rounding.H)) * DpiRatio, 0)
                this.__Rounding.H := NewH - Floor(NewH)
            }
        }

        /**
         * @description - This method is referred to as `DualRatio` in this documentation. `DualRatio`
         * is used to get the dpi-adjusted position and size values for a rectangle using different
         * ratios for the width and height. `DualRatio` accounts for rounding to prevent drifting
         * controls.
         *
         * `DualRatio` addresses the problem of non-linear text scaling leaving blank / empty space
         * within and around controls that primarily contain text. When scaling using only a dpi
         * ratio, there is often noticeable gaps between the text and the control's borders. The way
         * to handle this is to map the interface around the control's text contents, instead of
         * mapping the interface around the controls' relative position to one another.
         *
         * If you are using the built-in dpi changed handler, `DualRatio` is called for control types
         * specified by the `ResizeByText` configuration option.
         *
         * To call `DualRatio` from a function separate from the built-in dpi changed handler, you'll
         * want to either call `Ctrl.__ResizeByText` which will handle it for you, or follow the same
         * procedure in your external function. {@link dGui.Control#__ResizeByText}.
         * @param {VarRef} X - The x coordinate of the control. This must contain the original
         * X value and will be modified to the scaled X value.
         * @param {VarRef} Y - The y coordinate of the control. This must contain the original
         * Y value and will be modified to the scaled Y value.
         * @param {VarRef} W - The width of the control. This must contain the original
         * W value and will be modified to the scaled W value.
         * @param {VarRef} H - The height of the control. This must contain the original
         * H value and will be modified to the scaled H value.
         * @param {Float} WidthRatio - NewTextExtent / OriginalTextExtent.
         * @param {Float} HeightRatio - NewTextExtent / OriginalTextExtent.
         */
        ScaleDualRatio(&X, &Y, &W, &H, WidthRatio, HeightRatio) {
            if IsSet(X) {
                X := Round(NewX := (X + (this.__Rounding.X >= 0.5 ? this.__Rounding.X * -1 : this.__Rounding.X)) * WidthRatio, 0)
                this.__Rounding.X := NewX - Floor(NewX)
            }
            if IsSet(Y) {
                Y := Round(NewY := (Y + (this.__Rounding.Y >= 0.5 ? this.__Rounding.Y * -1 : this.__Rounding.Y)) * HeightRatio, 0)
                this.__Rounding.Y := NewY - Floor(NewY)
            }
            if IsSet(W) {
                W := Round(NewW := (W + (this.__Rounding.W >= 0.5 ? this.__Rounding.W * -1 : this.__Rounding.W)) * WidthRatio, 0)
                this.__Rounding.W := NewW - Floor(NewW)
            }
            if IsSet(H) {
                H := Round(NewH := (H + (this.__Rounding.H >= 0.5 ? this.__Rounding.H * -1 : this.__Rounding.H)) * HeightRatio, 0)
                this.__Rounding.H := NewH - Floor(NewH)
            }
        }

        /**
         * @description - `dGui.Prototype.SetFontSize` sets the font options for the control, and if
         * size is included in `FontOpt`, scales the font size with the monitor's dpi and caches the
         * base font size value.
         * {@link dGui#SetFont}
         * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont}
         * @param {String} [OptFont] - The font options.
         * @param {String} [FontName] - The font name, or a comma-delimited list of font names.
         */
        SetFont(OptFont?, FontName?) {
            if IsSet(OptFont) {
                if RegExMatch(OptFont, '(?<opt1>[^sS]*)[sS](?<n>[\d.]+)(?<opt2>.*)', &MatchFont) {
                    this.DefineProp('BaseFontSize', { Value: MatchFont['n'] })
                    this.__SetFont(MatchFont['opt1'] MatchFont['opt2'] ' s' this.FontSizeScaled)
                } else {
                    this.__SetFont(OptFont)
                }
            }
            if IsSet(FontName) {
                for Name in StrSplit(FontName, ',') {
                    if Name {
                        this.__SetFont(, Name)
                    }
                }
            }
        }

        __ResizeByDpi(&OutX, &OutY, &OutW, &OutH, NewDpi) {
            this.__SetFont('s' (this.BaseFontSize * NewDpi / BASE_DPI))
            this.ScaleMonoRatio(&OutX, &OutY, &OutW, &OutH, NewDpi / this.Gui.CachedDpi)
        }
        __ResizeByText(&OutX, &OutY, &OutW, &OutH, NewDpi) {
            sz1 := this.GetTextExtent()
            if !sz1.Width || !sz1.Height {
                ; OutputDebug('No text width or height. Resizing by dpi ratio.`n')
                dGui.Control.Prototype.__ResizeByDpi.Call(this, &OutX, &OutY, &OutW, &OutH, NewDpi)
                return
            }
            this.__SetFont('s' (this.BaseFontSize * NewDpi / BASE_DPI))
            sz2 := this.GetTextExtent()

            ; OutputDebug(Format('Size1.Width == {:4} Size1.HEIGHT == {}`nSize2.Width == {:4} Size2.Height == {}`n', sz1.Width, sz1.Height, sz2.Width, sz2.Height))

            ; Scale using the ratios defined by the change in the text's dimensions.
            this.ScaleMonoRatio(&OutX, &OutY, &OutW, &OutH, sz2.Width / sz1.Width, sz2.Height / sz1.Height)
        }

        Dpi => DllCall('GetDpiForWindow', 'ptr', this.hWnd, 'int')
        FontSizeScaled => Round(this.BaseFontSize * this.dpi / BASE_DPI, 0)
    }

    ;@region CtrlTypes
    class ActiveX extends Gui.ActiveX {
    }
    class Button extends Gui.Button {
    }
    class CheckBox extends Gui.CheckBox {
    }
    class ComboBox extends Gui.ComboBox {
    }
    class Custom extends Gui.Custom {
    }
    class DateTime extends Gui.DateTime {
    }
    class DDL extends Gui.DDL {
    }
    class Edit extends Gui.Edit {
    }
    class GroupBox extends Gui.GroupBox {
    }
    class Hotkey extends Gui.Hotkey {
    }
    class Link extends Gui.Link {
    }
    class ListBox extends Gui.ListBox {
    }
    class ListView extends Gui.ListView {
    }
    class MonthCal extends Gui.MonthCal {
    }
    class Pic extends Gui.Pic {
    }
    class Progress extends Gui.Progress {
    }
    class Radio extends Gui.Radio {
    }
    class Slider extends Gui.Slider {
    }
    class StatusBar extends Gui.StatusBar {
    }
    class Tab extends Gui.Tab {
    }
    class Text extends Gui.Text {
    }
    class TreeView extends Gui.TreeView {
    }
    class UpDown extends Gui.UpDown {
    }
    ;@endregion

}

HDpiChanged(wParam, lParam, Message, Hwnd) {
    dGuiObj := GuiFromHwnd(Hwnd)
    if !dGuiObj || dGuiObj.DpiExclude {
        return
    }
    DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_CHANGED_DPI_AWARENESS_CONTEXT, 'ptr')
    Critical(1)
    SendMessage(WM_SETREDRAW, false, 0, , Hwnd) ; Prevent window from being redrawn
    dGuiObj.OnDpiChanged(wParam & 0xFFFF)
    SendMessage(WM_SETREDRAW, true, 0, , Hwnd) ; Permit the window to be redrawn
    WinRedraw(Hwnd) ; Redraw the window
    Critical(0)
}
