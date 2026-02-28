
#include __ControlGetTextExtentEx_Process.ahk
#include ControlFitText.ahk
#include LibraryManager.ahk
#include ..\struct
#include Display_IntegerArray.ahk
#include Display_Rect.ahk
#include Display_Point.ahk
#include Display_TcItemW.ahk

class dGui extends Gui {
    static __New() {
        global GuiControlSetFont := Gui.Control.Prototype.SetFont
        , GuiSetFont := Gui.Prototype.SetFont
        , GuiControlMove := Gui.Control.Prototype.Move
        , GuiMove := Gui.Prototype.Move
        global g_user32_BeginDeferWindowPos
        , g_user32_DeferWindowPos
        , g_user32_EndDeferWindowPos
        , g_user32_GetDpiForSystem
        , g_user32_GetDpiForWindow
        , g_user32_GetWindowRect
        , g_user32_IsWindowVisible
        , g_gdi32_GetTextExtentPoint32W
        , g_gdi32_GetTextExtentExPointW
        , BASE_DPI
        this.DeleteProp('__New')
        g_user32_BeginDeferWindowPos :=
        g_user32_DeferWindowPos :=
        g_user32_EndDeferWindowPos :=
        g_user32_GetDpiForSystem :=
        g_user32_GetDpiForWindow :=
        g_user32_GetWindowRect :=
        g_user32_IsWindowVisible :=
        g_gdi32_GetTextExtentPoint32W :=
        g_gdi32_GetTextExtentExPointW := 0
        this.libraryToken := LibraryManager(
            'user32', [
                'BeginDeferWindowPos',
                'DeferWindowPos',
                'EndDeferWindowPos',
                'GetDpiForSystem',
                'GetDpiForWindow',
                'GetWindowRect',
                'IsWindowVisible'
            ],
            'gdi32', [
                'GetTextExtentPoint32W',
                'GetTextExtentExPointW'
            ]
        )
        if !IsSet(BASE_DPI) {
            BASE_DPI := DllCall(g_user32_GetDpiForSystem, 'uint')
        }
        this.InitialFontSize := 10
        proto := this.Prototype
        proto.ToggleCallbackBefore :=
        proto.ToggleCallbackAfter :=
        proto.EventHandler :=
        ''
        proto.Count := 0
        proto.CachedDpi := BASE_DPI
    }
    /**
     * @description - Defines a function to call before and/or after {@link dGui.Prototype.Toggle}.
     * Also see {@link dGui.Prototype.SetToggleCallback}. The functions defined here will apply to
     * all {@link dGui} objects (that have not defined the respective own properties).
     *
     * Also see {@link dGui.Prototype.SetToggleCallback}.
     *
     * The function should accept up to three parameters:
     * 1. **{dGui}** - The {@link dGui} object.
     * 2. **{Integer}** - If the `Value` parameter of {@link dGui.Prototype.Toggle} is set, `Value`.
     *    Else, this parameter will receive 1 if the window is about to be shown (it is currently hidden),
     *    or 0 if the window is about to be hidden.
     * 3. **{String}** - The value of the `Options` parameter of {@link dGui.Prototype.Toggle}.
     *
     * Set `CallbackBefore` or `CallbackAfter` to zero or an empty string to delete a previously
     * defined callback.
     *
     * @param {*} [CallbackBefore] - A callable object to call at the beginning of {@link dGui.Prototype.Toggle}.
     * @param {*} [CallbackAfter] - A callable object to call at the end of {@link dGui.Prototype.Toggle}.
     */
    static SetToggleCallback(CallbackBefore?, CallbackAfter?) {
        proto := this.Prototype
        if IsSet(CallbackBefore) {
            if CallbackBefore {
                proto.ToggleCallbackBefore := CallbackBefore
            } else if proto.HasOwnProp('ToggleCallbackBefore') {
                proto.DeleteProp('ToggleCallbackBefore')
            }
        }
        if IsSet(CallbackAfter) {
            if CallbackAfter {
                proto.ToggleCallbackAfter := CallbackAfter
            } else if proto.HasOwnProp('ToggleCallbackAfter') {
                proto.DeleteProp('ToggleCallbackAfter')
            }
        }
    }
    /**
     * @description - Creates the {@link dGui} window.
     * @param {String} [Opt] - The first parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Call Gui.Call}.
     * @param {String} [Title] - The second parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Call Gui.Call}.
     * @param {String} [EventHandler] - The third parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Call Gui.Call}. If `EventHandler` is
     * set, a reference to `EventHandler` is cached on property {@link dGui#EventHandler}.
     * @param {Object} [ExtendedOptions] - An object that defines additional options. The object can
     * have zero or more of { BackColor, FontName, MarginX, MarginY, MenuBar, Name, OptFont }.
     * If `ExtendedOptions.OptFont` is not set, or if it does not contain a size value, the font size
     * is set to {@link dGui.InitialFontSize}, which is typically defined in the DisplayConfig.ahk.
     * @returns {dGui} - The new {@link dGui} object.
     */
    __New(Opt?, Title?, EventHandler?, ExtendedOptions?) {
        super.__New(Opt ?? unset, Title ?? unset, EventHandler ?? unset)
        if IsSet(ExtendedOptions) {
            for Prop in ['MarginX', 'MarginY', 'BackColor', 'MenuBar', 'Name'] {
                if HasProp(ExtendedOptions, Prop) {
                    this.%Prop% := ExtendedOptions.%Prop%
                }
            }
            if HasProp(ExtendedOptions, 'OptFont') {
                if InStr(ExtendedOptions.OptFont, 's') {
                    this.SetFont(ExtendedOptions.OptFont, HasProp(ExtendedOptions, 'FontName') ? ExtendedOptions.FontName : '')
                } else {
                    this.SetFont(ExtendedOptions.OptFont ' s' this.BaseFontSize, HasProp(ExtendedOptions, 'FontName') ? ExtendedOptions.FontName : '')
                }
            } else if HasProp(ExtendedOptions, 'FontName') {
                this.SetFont('s' this.BaseFontSize, ExtendedOptions.FontName)
            } else {
                this.SetFontSize(this.BaseFontSize)
            }
        } else {
            this.SetFontSize(this.BaseFontSize)
        }
        if IsSet(EventHandler) {
            this.EventHandler := EventHandler
        }
        this.Count := 0
        this.CachedDpi := this.Dpi
    }
    /**
     * @param {String} CtrlType - The control type.
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text =""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Control}
     */
    Add(CtrlType, Options := '', Text := '') {
        this.Count++
        result := dGui.Control.Prototype.__New.Call(super.Add(CtrlType, Options, Text), Options, Text)
        return result
    }

    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.ActiveX}
     */
    AddActiveX(Options := '', Text := '') => this.Add('ActiveX', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Button}
     */
    AddButton(Options := '', Text := '') => this.Add('Button', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.CheckBox}
     */
    AddCheckBox(Options := '', Text := '') => this.Add('CheckBox', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.ComboBox}
     */
    AddComboBox(Options := '', Text := '') => this.Add('ComboBox', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Custom}
     */
    AddCustom(Options := '', Text := '') => this.Add('Custom', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.DateTime}
     */
    AddDateTime(Options := '', Text := '') => this.Add('DateTime', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.DDL}
     */
    AddDDL(Options := '', Text := '') => this.Add('DDL', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Edit}
     */
    AddEdit(Options := '', Text := '') => this.Add('Edit', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.GroupBox}
     */
    AddGroupBox(Options := '', Text := '') => this.Add('GroupBox', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Hotkey}
     */
    AddHotkey(Options := '', Text := '') => this.Add('Hotkey', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Link}
     */
    AddLink(Options := '', Text := '') => this.Add('Link', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.ListBox}
     */
    AddListBox(Options := '', Text := '') => this.Add('ListBox', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.ListView}
     */
    AddListView(Options := '', Text := '') => this.Add('ListView', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.MonthCal}
     */
    AddMonthCal(Options := '', Text := '') => this.Add('MonthCal', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Pic}
     */
    AddPic(Options := '', Text := '') => this.Add('Pic', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Progress}
     */
    AddProgress(Options := '', Text := '') => this.Add('Progress', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Radio}
     */
    AddRadio(Options := '', Text := '') => this.Add('Radio', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Slider}
     */
    AddSlider(Options := '', Text := '') => this.Add('Slider', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.StatusBar}
     */
    AddStatusBar(Options := '', Text := '') => this.Add('StatusBar', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Tab}
     */
    AddTab(Options := '', Text := '') => this.Add('Tab', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Tab}
     */
    AddTab2(Options := '', Text := '') => this.Add('Tab2', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Tab}
     */
    AddTab3(Options := '', Text := '') => this.Add('Tab3', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.Text}
     */
    AddText(Options := '', Text := '') => this.Add('Text', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.TreeView}
     */
    AddTreeView(Options := '', Text := '') => this.Add('TreeView', Options, Text)
    /**
     * @param {String} [Options = ""] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @param {String|String[]} [Text = ""] - The value to pass to the `Text` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Add Gui.Prototype.Add}.
     * @returns {dGui.UpDown}
     */
    AddUpDown(Options := '', Text := '') => this.Add('UpDown', Options, Text)

    /**
     * @description - Deletes {@link dGui#ToggleCallbackBefore} and/or
     * {@link dGui#ToggleCallbackAfter}
     *
     * @param {Boolean} [CallbackBefore = true] - If true, deletes {@link dGui#ToggleCallbackBefore}.
     * @param {Boolean} [CallbackAfter = true] - If true, deletes {@link dGui#ToggleCallbackAfter}.
     */
    DeleteToggleCallback(CallbackBefore := true, CallbackAfter := true) {
        if CallbackBefore && this.HasOwnProp('ToggleCallbackBefore') {
            this.DeleteProp('ToggleCallbackBefore')
        }
        if CallbackAfter && this.HasOwnProp('ToggleCallbackAfter') {
            this.DeleteProp('ToggleCallbackAfter')
        }
    }
    /**
     * @description - Resizes the gui window to contain the entirety of the specified control.
     * The width of the window is set to `<control's right coordinate> + dGuiObj.MarginX + PaddingX`.
     * The height of the window is set to `<control's bottom coordinate> + dGuiObj.MarginY + PaddingY`.
     * @param {dGui.Control} Ctrl - The control object.
     * @param {Integer} [PaddingX = 0] - The padding to add to the x-coordinate.
     * @param {Integer} [PaddingY = 0] - The padding to add to the y-coordinate.
     * @param {VarRef} [OutWidth] - A variable that receives the new width.
     * @param {VarRef} [OutHeight] - A variable that receives the new height.
     */
    FitControl(Ctrl, PaddingX := 0, PaddingY := 0, &OutWidth?, &OutHeight?) {
        Ctrl.GetPos(&x, &y, &w, &h)
        OutWidth := x + w + this.MarginX + PaddingX
        OutHeight := y + h + this.MarginY + PaddingY
        this.Show('w' OutWidth ' h' OutHeight (this.Visible ? '' : ' Hide'))
    }
    /**
     * @description - Sets {@link dGui#BaseFontSize} without changing the gui's current font size.
     * @param {Integer} FontSize - The new value.
     */
    SetBaseFontSize(FontSize) {
        this.DefineProp('BaseFontSize', { Value: FontSize })
    }
    /**
     * @description - Sets the font options for subsequently created controls. There are three
     * related methods which have different behavior with respect to the font size option, if included:
     * - {@link dGui.Prototype.SetFont} (this method) - Caches the unmodified input font size
     *   and passes the unmodified input font size to
     *   {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}.
     * - {@link dGui.Prototype.SetFontScaled} - Caches the unmodified input font size
     *   and passes the scaled font size to `Gui.Prototype.SetFont` as
     *   `<value> * <window's dpi> / BASE_DPI`.
     * - {@link dGui.Prototype.SetFontScaled2} - Caches the scaled font size as
     *   `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
     *   `Gui.Prototype.SetFont`.
     *
     * This caches the font size as {@link dGui#BaseFontSize}.
     *
     * @param {String} [Options] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}.
     *
     * Each option is either a single letter immediately followed by a value,
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
     * @param {String|String[]} [FontName] - In contrast with
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}, the
     * `FontName` parameter of {@link dGui.Prototype.SetFont} allows multiple font names to be defined
     * in one function call. `FontName` here can be a single name, a comma-delimited list of names,
     * or an array of names.
     *
     * The following is copied from the AHK documentation:
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
    SetFont(Options?, FontName?) {
        if IsSet(Options) {
            if RegExMatch(Options, '(?<=[sS])[\d.]+', &match) {
                this.DefineProp('BaseFontSize', { Value: match[0] })
            }
            super.SetFont(Options)
        }
        if IsSet(FontName) {
            if IsObject(FontName) {
                for name in FontName {
                    super.SetFont(, name)
                }
            } else {
                for name in StrSplit(FontName, ',') {
                    if name {
                        super.SetFont(, name)
                    }
                }
            }
        }
    }
    /**
     * @description - Sets the font options for subsequently created controls. There are three
     * related methods which have different behavior with respect to the font size option, if included:
     * - {@link dGui.Prototype.SetFont} - Caches the unmodified input font size
     *   and passes the unmodified input font size to
     *   {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}.
     * - {@link dGui.Prototype.SetFontScaled} (this method) - Caches the unmodified input font size
     *   and passes the scaled font size to `Gui.Prototype.SetFont` as
     *   `<value> * <window's dpi> / BASE_DPI`.
     * - {@link dGui.Prototype.SetFontScaled2} - Caches the scaled font size as
     *   `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
     *   `Gui.Prototype.SetFont`.
     *
     * This caches the font size as {@link dGui#BaseFontSize}.
     *
     * @param {String} [Options] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}.
     *
     * Each option is either a single letter immediately followed by a value,
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
     * @param {String|String[]} [FontName] - In contrast with
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}, the
     * `FontName` parameter of {@link dGui.Prototype.SetFont} allows multiple font names to be defined
     * in one function call. `FontName` here can be a single name, a comma-delimited list of names,
     * or an array of names.
     *
     * The following is copied from the AHK documentation:
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
    SetFontScaled(Options?, FontName?) {
        if IsSet(Options) {
            if RegExMatch(Options, '([^sS]*)[sS]([\d.]+)(.*)', &match) {
                this.DefineProp('BaseFontSize', { Value: match[2] })
                super.SetFont(match[1] 's' this.BaseFontSizeScaled match[3])
            } else {
                super.SetFont(Options)
            }
        }
        if IsSet(FontName) {
            if IsObject(FontName) {
                for name in FontName {
                    super.SetFont(, name)
                }
            } else {
                for name in StrSplit(FontName, ',') {
                    if name {
                        super.SetFont(, name)
                    }
                }
            }
        }
    }
    /**
     * @description - Sets the font options for subsequently created controls. There are three
     * related methods which have different behavior with respect to the font size option, if included:
     * - {@link dGui.Prototype.SetFont} - Caches the unmodified input font size
     *   and passes the unmodified input font size to
     *   {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}.
     * - {@link dGui.Prototype.SetFontScaled} - Caches the unmodified input font size
     *   and passes the scaled font size to `Gui.Prototype.SetFont` as
     *   `<value> * <window's dpi> / BASE_DPI`.
     * - {@link dGui.Prototype.SetFontScaled2} (this method) - Caches the scaled font size as
     *   `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
     *   `Gui.Prototype.SetFont`.
     *
     * This caches the font size as {@link dGui#BaseFontSize}.
     *
     * @param {String} [Options] - The value to pass to the `Options` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}.
     *
     * Each option is either a single letter immediately followed by a value,
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
     * @param {String|String[]} [FontName] - In contrast with
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}, the
     * `FontName` parameter of {@link dGui.Prototype.SetFont} allows multiple font names to be defined
     * in one function call. `FontName` here can be a single name, a comma-delimited list of names,
     * or an array of names.
     *
     * The following is copied from the AHK documentation:
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
    SetFontScaled2(Options?, FontName?) {
        if IsSet(Options) {
            if RegExMatch(Options, '([^sS]*)[sS]([\d.]+)(.*)', &match) {
                this.DefineProp('BaseFontSize', { Value: match[2] * BASE_DPI / this.Dpi })
                super.SetFont(match[1] 's' this.BaseFontSizeScaled match[3])
            } else {
                super.SetFont(Options)
            }
        }
        if IsSet(FontName) {
            if IsObject(FontName) {
                for name in FontName {
                    super.SetFont(, name)
                }
            } else {
                for name in StrSplit(FontName, ',') {
                    if name {
                        super.SetFont(, name)
                    }
                }
            }
        }
    }
    /**
     * @description - Sets the font size for subsequently created controls. There are three
     * related methods which have different behavior:
     * - {@link dGui.Prototype.SetFontSize} (this method) - Caches the unmodified input font size
     *   and passes the unmodified input font size to
     *   {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}.
     * - {@link dGui.Prototype.SetFontSizeScaled} - Caches the unmodified input font
     *   size and passes the scaled font size to `Gui.Prototype.SetFont` as
     *   `<value> * <window's dpi> / BASE_DPI`.
     * - {@link dGui.Prototype.SetFontSizeScaled2} - Caches the scaled font size as
     *   `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
     *   `Gui.Prototype.SetFont`.
     *
     * This caches the font size as {@link dGui#BaseFontSize}.
     *
     * @param {Integer} FontSize - The new font size.
     */
    SetFontSize(FontSize) {
        this.DefineProp('BaseFontSize', { Value: FontSize })
        super.SetFont('s' FontSize)
    }
    /**
     * @description - Sets the font size for subsequently created controls. There are three
     * related methods which have different behavior:
     * - {@link dGui.Prototype.SetFontSize} - Caches the unmodified input font size
     *   and passes the unmodified input font size to
     *   {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}.
     * - {@link dGui.Prototype.SetFontSizeScaled} (this method) - Caches the unmodified input font
     *   size and passes the scaled font size to `Gui.Prototype.SetFont` as
     *   `<value> * <window's dpi> / BASE_DPI`.
     * - {@link dGui.Prototype.SetFontSizeScaled2} - Caches the scaled font size as
     *   `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
     *   `Gui.Prototype.SetFont`.
     *
     * This caches the font size as {@link dGui#BaseFontSize}.
     *
     * @param {Integer} FontSize - The new font size.
     */
    SetFontSizeScaled(FontSize) {
        this.DefineProp('BaseFontSize', { Value: FontSize })
        super.SetFont('s' this.BaseFontSizeScaled)
    }
    /**
     * @description - Sets the font size for subsequently created controls. There are three
     * related methods which have different behavior:
     * - {@link dGui.Prototype.SetFontSize} - Caches the unmodified input font size
     *   and passes the unmodified input font size to
     *   {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#SetFont Gui.Prototype.SetFont}.
     * - {@link dGui.Prototype.SetFontSizeScaled} - Caches the unmodified input font
     *   size and passes the scaled font size to `Gui.Prototype.SetFont` as
     *   `<value> * <window's dpi> / BASE_DPI`.
     * - {@link dGui.Prototype.SetFontSizeScaled2} (this method) - Caches the scaled font size as
     *   `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
     *   `Gui.Prototype.SetFont`.
     *
     * This caches the font size as {@link dGui#BaseFontSize}.
     *
     * @param {Integer} FontSize - The new font size.
     */
    SetFontSizeScaled2(FontSize) {
        this.DefineProp('BaseFontSize', { Value: FontSize * BASE_DPI / this.Dpi })
        super.SetFont('s' this.BaseFontSizeScaled)
    }
    /**
     * @description - Defines a function to call before and/or after {@link dGui.Prototype.Toggle}.
     * Also see {@link dGui.SetToggleCallback}.
     *
     * The function should accept up to three parameters:
     * 1. **{dGui}** - The {@link dGui} object.
     * 2. **{Integer}** - If the `Value` parameter of {@link dGui.Prototype.Toggle} is set, `Value`.
     *    Else, this parameter will receive 1 if the window is about to be shown (it is currently hidden),
     *    or 0 if the window is about to be hidden.
     * 3. **{String}** - The value of the `Options` parameter of {@link dGui.Prototype.Toggle}.
     *
     * If your code has called {@link dGui.SetToggleCallback} (or otherwise defined
     * {@link dGui.Prototype.ToggleCallbackBefore} or {@link dGui.Prototype.ToggleCallbackAfter}),
     * you can set `CallbackBefore` or `CallbackAfter` to zero or an empty string to prevent
     * any function from being called, respectively. This is different from calling
     * {@link dGui.Prototype.DeleteToggleCallback}, which will delete the specified own properties,
     * thus allowing the relevant property on the prototype to be used instead.
     *
     * @param {*} [CallbackBefore] - A callable object to call at the beginning of {@link dGui.Prototype.Toggle}.
     * @param {*} [CallbackAfter] - A callable object to call at the end of {@link dGui.Prototype.Toggle}.
     */
    SetToggleCallback(CallbackBefore?, CallbackAfter?) {
        if IsSet(CallbackBefore) {
            this.ToggleCallbackBefore := CallbackBefore
        }
        if IsSet(CallbackAfter) {
            this.ToggleCallbackAfter := CallbackAfter
        }
    }
    /**
     * @description - Toggles the window's visibility.
     *
     * See {@link dGui.SetToggleCallback} and {@link dGui.Prototype.SetToggleCallback}.
     *
     * @param {Boolean} [Value] - Set this to specify a value instead of toggling it. A nonzero value
     * will display the window. Zero or an empty string will hide it.
     * @param {String} [Options = ""] - Any options to pass to
     * {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Show Gui.Prototype.Show}.
     */
    Toggle(Value?, Options := '') {
        if !IsSet(Value) {
            Value := !DllCall(g_user32_IsWindowVisible, 'ptr', this.Hwnd, 'int')
        }
        if this.ToggleCallbackBefore {
            this.ToggleCallbackBefore.Call(this, Value, Options)
        }
        if Value {
            this.Show(Options)
        } else {
            this.Show(Options (InStr(Options, 'Hide') ? '' : ' Hide'))
        }
        if this.ToggleCallbackAfter {
            this.ToggleCallbackAfter.Call(this, Value, Options)
        }
    }

    BaseFontSize {
        Get => dGui.InitialFontSize
        Set => this.DefineProp('BaseFontSize', { Value: Value })
    }
    BaseFontSizeScaled => this.BaseFontSize * this.Dpi / BASE_DPI
    Dpi => DllCall(g_user32_GetDpiForWindow, 'ptr', this.Hwnd, 'int')
    Visible {
        Get => DllCall(g_user32_IsWindowVisible, 'ptr', this.Hwnd, 'int')
        Set => Value ? this.Show() : this.Hide()
    }

    class Control extends Gui.Control {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.BaseX := proto.BaseY := proto.BaseW := proto.BaseH := 0
        }
        /**
         * @description - Instantiates the {@link dGui.Control} object. This is expected to be called
         * from {@link dGui.Prototype.Add}.
         * @param {String} Options - The value passed to the parameter `Options` of {@link dGui.Prototype.Add}.
         * @param {String|String[]} Text - The value passed to the parameter `Text` of {@link dGui.Prototype.Add}.
         */
        __New(Options, Text) {
            ObjSetBase(this, dGui.%this.Type%.Prototype)
            super.SetFont('s' this.BaseFontSizeScaled)
            this.UpdateBaseRect()
            return this
        }
        /**
         * @description - Resizes the control to fit its text contents.
         *
         * Valid control types: ActiveX (possibly), Button, CheckBox, ComboBox, Custom (possibly), Edit,
         * Radio, Text.
         * @param {Integer} [PaddingX = 0] - A number of pixels to add to the width.
         * @param {Integer} [PaddingY = 0] - A number of pixels to add to the height.
         * @param {Boolean} [UpdateBaseRect = true] - If true, calls
         * {@link dGui.Control.Prototype.UpdateBaseRect}.
         * @param {VarRef} [OutWidth] - A variable that will receive the width as integer.
         * @param {VarRef} [OutHeight] - A variable that will receive the height as integer.
         */
        FitText(PaddingX := 0, PaddingY := 0, UpdateBaseRect := true, &OutWidth?, &OutHeight?) {
            ControlFitText(this, PaddingX, PaddingY, , &OutWidth, &OutHeight)
            if UpdateBaseRect {
                this.UpdateBaseRect()
            }
        }
        /**
         * @description - Calls
         * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-GetTextExtentPoint32Ww GetTextExtentPoint32W}
         * to get the height and width in pixels of the string contents of a Gui control. If the
         * "Text" property returns multiple lines of text, the lines are split at each CRLF and each
         * substring is measured individually.
         * @param {VarRef} [OutWidth] - A variable that will receive the greatest horizontal extent
         * of each line as integer.
         * @param {VarRef} [OutHeight] - A variable that will receive the text's total vertical extent
         * as integer.
         */
        GetTextExtent(&OutWidth?, &OutHeight?) {
            sz := Display_Size()
            context := SelectFontIntoDc(this.Hwnd)
            if InStr(this.Text, '`r`n') {
                OutWidth := OutHeight := 0
                hdc := context.hdc
                padding := ControlFitText.TextExtentPadding(this)
                for line in StrSplit(this.Text, '`r`n') {
                    if line {
                        if DllCall(
                            'Gdi32.dll\GetTextExtentPoint32W'
                          , 'ptr', hdc
                          , 'ptr', StrPtr(line)
                          , 'int', StrLen(line)
                          , 'ptr', sz
                          , 'int'
                        ) {
                            OutHeight += sz.H + padding.LinePadding
                            OutWidth := Max(OutWidth, sz.W)
                        } else {
                            context()
                            throw OSError()
                        }
                    } else {
                        OutHeight += padding.LineHeight + padding.LinePadding
                    }
                }
                OutHeight -= padding.LinePadding
            } else {
                if DllCall(
                    'Gdi32.dll\GetTextExtentPoint32W'
                  , 'ptr', context.hdc
                  , 'wstr', this.Text
                  , 'int', StrLen(this.Text)
                  , 'ptr', sz
                  , 'int'
                ) {
                    OutHeight := sz.H
                    OutWidth := sz.W
                } else {
                    context()
                    throw OSError()
                }
            }
            context()
        }
        /**
         * @description - Calls `GetTextExtentExPointW` using the control as context.
         *
         * This function is only appropriate for single-line strings.
         *
         * You can use this in two general ways.
         *
         * Leave `MaxExtent` 0: `OutExtentPoints` will receive an  {@link Display_IntegerArray} object, which will be a
         * buffer object containing the partial extent points of every character in the string. Said another
         * way, the integers in the array will be a cumulative representation of how wide the string is up
         * to that character, in pixels. E.g. "H" is 3 pixels wide, "He" is 6 pixels wide, "Hel" is 8 pixels
         * wide, etc. `OutCharacterFit` is not measured in this usage of the function, and will receive 0.
         *
         * Set `MaxExtent` with a maximum width in pixels: `OutCharacterFit` is assigned the maximum
         * number of characters in the string that can fit `MaxExtent` pixels without going over.
         * `OutExtentPoints` is assigned an  {@link Display_IntegerArray} object, but in this case it only contains the
         * partial extent points up to `OutCharacterFit` number of characters.
         * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-GetTextExtentExPointWa}
         *
         * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
         * for further details.
         * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
         * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
         * @param {VarRef} [OutExtentPoints] - A variable that will receive an  {@link Display_IntegerArray}. See the
         * function description for further details.
         * @returns {Display_Size}
         */
        GetTextExtentEx(MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
            return __ControlGetTextExtentEx_Process(this.Hwnd, StrPtr(this.Text), StrLen(this.Text), MaxExtent, &OutCharacterFit, &OutExtentPoints)
        }
        /**
         * @description - Moves the control and sets {@link dGui.Control#BaseX}, {@link dGui.Control#BaseY},
         * {@link dGui.Control#BaseW}, and/or {@link dGui.Control#BaseH} with the values. There are
         * three related methods which have different behavior:
         * - {@link dGui.Control.Prototype.MoveEx} (this method) - Caches the unmodified input
         *   values and passes the unmodified input values to
         *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#Move Gui.Control.Prototype.Move}.
         * - {@link dGui.Control.Prototype.MoveExScaled} - Caches the unmodified
         *   input values and passes the scaled values to `Gui.Control.Prototype.Move` as
         *   `<value> * <window's dpi> / BASE_DPI`.
         * - {@link dGui.Control.Prototype.MoveExScaled2} - Caches the scaled values
         *   as `<value> * BASE_DPI / <window's dpi>` and passes the unmodified values to
         *   `Gui.Control.Prototype.Move`.
         *
         * @param {Integer} [X] - The X coordinate.
         * @param {Integer} [Y] - The Y coordinate.
         * @param {Integer} [W] - The width.
         * @param {Integer} [H] - The height.
         */
        MoveEx(X?, Y?, W?, H?) {
            this.Move(
                IsSet(X) ? (this.BaseX := X) : unset
              , IsSet(Y) ? (this.BaseY := Y) : unset
              , IsSet(W) ? (this.BaseW := W) : unset
              , IsSet(H) ? (this.BaseH := H) : unset
            )
        }
        /**
         * @description - Moves the control and sets {@link dGui.Control#BaseX}, {@link dGui.Control#BaseY},
         * {@link dGui.Control#BaseW}, and/or {@link dGui.Control#BaseH} with the values. There are
         * three related methods which have different behavior:
         * - {@link dGui.Control.Prototype.MoveEx} - Caches the unmodified input
         *   values and passes the unmodified input values to
         *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#Move Gui.Control.Prototype.Move}.
         * - {@link dGui.Control.Prototype.MoveExScaled} (this method) - Caches the unmodified
         *   input values and passes the scaled values to `Gui.Control.Prototype.Move` as
         *   `<value> * <window's dpi> / BASE_DPI`.
         * - {@link dGui.Control.Prototype.MoveExScaled2} - Caches the scaled values
         *   as `<value> * BASE_DPI / <window's dpi>` and passes the unmodified values to
         *   `Gui.Control.Prototype.Move`.
         *
         * @param {Integer} [X] - The X coordinate.
         * @param {Integer} [Y] - The Y coordinate.
         * @param {Integer} [W] - The width.
         * @param {Integer} [H] - The height.
         */
        MoveExScaled(X?, Y?, W?, H?) {
            ratio := this.Dpi / BASE_DPI
            this.Move(
                IsSet(X) ? (this.BaseX := X) * ratio : unset
              , IsSet(Y) ? (this.BaseY := Y) * ratio : unset
              , IsSet(W) ? (this.BaseW := W) * ratio : unset
              , IsSet(H) ? (this.BaseH := H) * ratio : unset
            )
        }
        /**
         * @description - Moves the control and sets {@link dGui.Control#BaseX}, {@link dGui.Control#BaseY},
         * {@link dGui.Control#BaseW}, and/or {@link dGui.Control#BaseH} with the values. There are
         * three related methods which have different behavior:
         * - {@link dGui.Control.Prototype.MoveEx} - Caches the unmodified input
         *   values and passes the unmodified input values to
         *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#Move Gui.Control.Prototype.Move}.
         * - {@link dGui.Control.Prototype.MoveExScaled} - Caches the unmodified
         *   input values and passes the scaled values to `Gui.Control.Prototype.Move` as
         *   `<value> * <window's dpi> / BASE_DPI`.
         * - {@link dGui.Control.Prototype.MoveExScaled2} (this method) - Caches the scaled values
         *   as `<value> * BASE_DPI / <window's dpi>` and passes the unmodified values to
         *   `Gui.Control.Prototype.Move`.
         *
         * @param {Integer} [X] - The X coordinate.
         * @param {Integer} [Y] - The Y coordinate.
         * @param {Integer} [W] - The width.
         * @param {Integer} [H] - The height.
         */
        MoveExScaled2(X?, Y?, W?, H?) {
            ratio := BASE_DPI / this.Dpi
            if IsSet(X) {
                this.BaseX := X * ratio
            }
            if IsSet(Y) {
                this.BaseY := Y * ratio
            }
            if IsSet(W) {
                this.BaseW := W * ratio
            }
            if IsSet(H) {
                this.BaseH := H * ratio
            }
            this.Move(X ?? unset, Y ?? unset, W ?? unset, H ?? unset)
        }
        /**
         * @description - Sets {@link dGui.Control#BaseFontSize} without changing the control's
         * current font size.
         * @param {Integer} FontSize - The new value.
         */
        SetBaseFontSize(FontSize) {
            this.DefineProp('BaseFontSize', { Value: FontSize })
        }
        /**
         * @description - Sets {@link dGui.Control#BaseX}, {@link dGui.Control#BaseY},
         * {@link dGui.Control#BaseW}, and/or {@link dGui.Control#BaseH} without changing the
         * control's current dimensions.
         * @param {Integer} [BaseX] - The X coordinate.
         * @param {Integer} [BaseY] - The Y coordinate.
         * @param {Integer} [BaseW] - The width.
         * @param {Integer} [BaseH] - The height.
         */
        SetBaseRect(BaseX?, BaseY?, BaseW?, BaseH?) {
            if IsSet(BaseX) {
                this.BaseX := BaseX
            }
            if IsSet(BaseY) {
                this.BaseY := BaseY
            }
            if IsSet(BaseW) {
                this.BaseW := BaseW
            }
            if IsSet(BaseH) {
                this.BaseH := BaseH
            }
        }
        /**
         * @description - Sets the font options for the control. There are three related methods
         * which have different behavior with respect to the font size option, if included:
         * - {@link dGui.Control.Prototype.SetFont} (this method) - Caches the unmodified input font
         *   size and passes the unmodified input font size to
         *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont}.
         * - {@link dGui.Control.Prototype.SetFontScaled} - Caches the unmodified input
         *   font size and passes the scaled font size to `Gui.Control.Prototype.SetFont` as
         *   `<value> * <window's dpi> / BASE_DPI`.
         * - {@link dGui.Control.Prototype.SetFontScaled2} - Caches the scaled font
         *   size as `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
         *   `Gui.Prototype.SetFont`.
         *
         * This caches the font size as {@link dGui.Control#BaseFontSize}.
         *
         * @param {String} [Options] - The value to pass to the `Options` parameter of
         * {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont}.
         *
         * Each option is either a single letter immediately followed by a value,
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
         * @param {String|String[]} [FontName] - In contrast with
         * {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont},
         * the `FontName` parameter of {@link dGui.Control.Prototype.SetFont} allows multiple font
         * names to be defined in one function call. `FontName` here can be a single name, a
         * comma-delimited list of names, or an array of names.
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
        SetFont(Options?, FontName?) {
            if IsSet(Options) {
                if RegExMatch(Options, '(?<=[sS])[\d.]+', &match) {
                    this.DefineProp('BaseFontSize', { Value: match[0] })
                }
                super.SetFont(Options)
            }
            if IsSet(FontName) {
                if IsObject(FontName) {
                    for name in FontName {
                        super.SetFont(, name)
                    }
                } else {
                    for name in StrSplit(FontName, ',') {
                        if name {
                            super.SetFont(, name)
                        }
                    }
                }
            }
        }
        /**
         * @description - Sets the font options for the control. There are three related methods
         * which have different behavior with respect to the font size option, if included:
         * - {@link dGui.Control.Prototype.SetFont} - Caches the unmodified input font
         *   size and passes the unmodified input font size to
         *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont}.
         * - {@link dGui.Control.Prototype.SetFontScaled} (this method) - Caches the unmodified input
         *   font size and passes the scaled font size to `Gui.Control.Prototype.SetFont` as
         *   `<value> * <window's dpi> / BASE_DPI`.
         * - {@link dGui.Control.Prototype.SetFontScaled2} - Caches the scaled font
         *   size as `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
         *   `Gui.Prototype.SetFont`.
         *
         * This caches the font size as {@link dGui.Control#BaseFontSize}.
         *
         * @param {String} [Options] - The value to pass to the `Options` parameter of
         * {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont}.
         *
         * Each option is either a single letter immediately followed by a value,
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
         * @param {String|String[]} [FontName] - In contrast with
         * {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont},
         * the `FontName` parameter of {@link dGui.Control.Prototype.SetFont} allows multiple font
         * names to be defined in one function call. `FontName` here can be a single name, a
         * comma-delimited list of names, or an array of names.
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
        SetFontScaled(Options?, FontName?) {
            if IsSet(Options) {
                if RegExMatch(Options, '([^sS]*)[sS]([\d.]+)(.*)', &match) {
                    this.DefineProp('BaseFontSize', { Value: match[2] })
                    super.SetFont(match[1] 's' this.BaseFontSizeScaled match[3])
                } else {
                    super.SetFont(Options)
                }
            }
            if IsSet(FontName) {
                if IsObject(FontName) {
                    for name in FontName {
                        super.SetFont(, name)
                    }
                } else {
                    for name in StrSplit(FontName, ',') {
                        if name {
                            super.SetFont(, name)
                        }
                    }
                }
            }
        }
        /**
         * @description - Sets the font options for the control. There are three related methods
         * which have different behavior with respect to the font size option, if included:
         * - {@link dGui.Control.Prototype.SetFont} - Caches the unmodified input font
         *   size and passes the unmodified input font size to
         *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont}.
         * - {@link dGui.Control.Prototype.SetFontScaled} - Caches the unmodified input
         *   font size and passes the scaled font size to `Gui.Control.Prototype.SetFont` as
         *   `<value> * <window's dpi> / BASE_DPI`.
         * - {@link dGui.Control.Prototype.SetFontScaled2} (this method) - Caches the scaled font
         *   size as `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
         *   `Gui.Prototype.SetFont`.
         *
         * This caches the font size as {@link dGui.Control#BaseFontSize}.
         *
         * @param {String} [Options] - The value to pass to the `Options` parameter of
         * {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont}.
         *
         * Each option is either a single letter immediately followed by a value,
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
         * @param {String|String[]} [FontName] - In contrast with
         * {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont},
         * the `FontName` parameter of {@link dGui.Control.Prototype.SetFont} allows multiple font
         * names to be defined in one function call. `FontName` here can be a single name, a
         * comma-delimited list of names, or an array of names.
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
        SetFontScaled2(Options?, FontName?) {
            if IsSet(Options) {
                if RegExMatch(Options, '([^sS]*)[sS]([\d.]+)(.*)', &match) {
                    this.DefineProp('BaseFontSize', { Value: match[2] * BASE_DPI / this.Dpi })
                    super.SetFont(match[1] 's' this.BaseFontSizeScaled match[3])
                } else {
                    super.SetFont(Options)
                }
            }
            if IsSet(FontName) {
                if IsObject(FontName) {
                    for name in FontName {
                        super.SetFont(, name)
                    }
                } else {
                    for name in StrSplit(FontName, ',') {
                        if name {
                            super.SetFont(, name)
                        }
                    }
                }
            }
        }
        /**
         * @description - Sets the font size for the control. There are three related methods which
         * have different behavior:
         * - {@link dGui.Control.Prototype.SetFontSize} (this method) - Caches the unmodified input
         *   font size and passes the unmodified input font size to
         *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont}.
         * - {@link dGui.Control.Prototype.SetFontSizeScaled} - Caches the unmodified
         *   input font size and passes the scaled font size to `Gui.Control.Prototype.SetFont` as
         *   `<value> * <window's dpi> / BASE_DPI`.
         * - {@link dGui.Control.Prototype.SetFontSizeScaled2} - Caches the scaled font
         *   size as `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
         *   `Gui.Control.Prototype.SetFont`.
         *
         * This caches the font size as {@link dGui.Control#BaseFontSize}.
         *
         * @param {Integer} FontSize - The new font size.
         */
        SetFontSize(FontSize) {
            this.DefineProp('BaseFontSize', { Value: FontSize })
            super.SetFont('s' FontSize)
        }
        /**
         * @description - Sets the font size for the control. There are three related methods which
         * have different behavior:
         * - {@link dGui.Control.Prototype.SetFontSize} - Caches the unmodified input
         *   font size and passes the unmodified input font size to
         *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont}.
         * - {@link dGui.Control.Prototype.SetFontSizeScaled} (this method) - Caches the unmodified
         *   input font size and passes the scaled font size to `Gui.Control.Prototype.SetFont` as
         *   `<value> * <window's dpi> / BASE_DPI`.
         * - {@link dGui.Control.Prototype.SetFontSizeScaled2} - Caches the scaled font
         *   size as `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
         *   `Gui.Control.Prototype.SetFont`.
         *
         * This caches the font size as {@link dGui.Control#BaseFontSize}.
         *
         * @param {Integer} FontSize - The new font size.
         */
        SetFontSizeScaled(FontSize) {
            this.DefineProp('BaseFontSize', { Value: FontSize })
            super.SetFont('s' this.BaseFontSizeScaled)
        }
        /**
         * @description - Sets the font size for the control. There are three related methods which
         * have different behavior:
         * - {@link dGui.Control.Prototype.SetFontSize} - Caches the unmodified input
         *   font size and passes the unmodified input font size to
         *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#SetFont Gui.Control.Prototype.SetFont}.
         * - {@link dGui.Control.Prototype.SetFontSizeScaled} - Caches the unmodified
         *   input font size and passes the scaled font size to `Gui.Control.Prototype.SetFont` as
         *   `<value> * <window's dpi> / BASE_DPI`.
         * - {@link dGui.Control.Prototype.SetFontSizeScaled2} (this method) - Caches the scaled font
         *   size as `<value> * BASE_DPI / <window's dpi>` and passes the unmodified font size to
         *   `Gui.Control.Prototype.SetFont`.
         *
         * This caches the font size as {@link dGui.Control#BaseFontSize}.
         *
         * @param {Integer} FontSize - The new font size.
         */
        SetFontSizeScaled2(FontSize) {
            this.DefineProp('BaseFontSize', { Value: FontSize * BASE_DPI / this.Dpi })
            super.SetFont('s' this.BaseFontSizeScaled)
        }
        /**
         * @description - Changes the control's text and adjusts the control's dimensions to fit
         * the text content.
         * @param {String} Str - The string.
         * @param {Integer} [PaddingX = 0] - Additional pixels added to the control's width.
         * @param {Integer} [PaddingY = 0] - Additional pixels added to the control's height.
         * @param {Boolean} [UpdateBaseRect = true] - If true, calls
         * {@link dGui.Control.Prototype.UpdateBaseRect}.
         * @param {VarRef} [OutWidth] - A variable that will receive the width as integer.
         * @param {VarRef} [OutHeight] - A variable that will receive the height as integer.
         */
        SetTextEx(Str, PaddingX := 0, PaddingY := 0, UpdateBaseRect := true, &OutWidth?, &OutHeight?) {
            switch Type(Str), 0 {
                case 'String': ; do nothing
                default:
                    if IsObject(Str) {
                        throw TypeError('Expected a String.', , Type(Str))
                    } else {
                        Str := String(Str)
                    }
            }
            Str := this.Text := RegExReplace(Str, '\R', '`r`n', &count)
            if count {
                ControlFitText(this, PaddingX, PaddingY, , &OutWidth, &OutHeight)
            } else {
                sz := Display_Size()
                context := SelectFontIntoDc(this.Hwnd)
                if !DllCall(g_gdi32_GetTextExtentPoint32W, 'ptr', context.hdc, 'ptr', StrPtr(Str), 'int', StrLen(Str), 'ptr', sz, 'int') {
                    context()
                    throw OSError()
                }
                context()
                this.Move(, , OutWidth := sz.W + PaddingX, H ?? unset)
            }
            if UpdateBaseRect {
                this.UpdateBaseRect()
            }
        }
        /**
         * @description - Changes the control's text and adjusts the control's dimensions to fit
         * the text content. This performs the same action as {@link dGui.Control.Prototype.SetTextEx}.
         * @param {VarRef} Str - A variable containing the string.
         * @param {Integer} [PaddingX = 0] - Additional pixels added to the control's width.
         * @param {Integer} [PaddingY = 0] - Additional pixels added to the control's height.
         * @param {Boolean} [UpdateBaseRect = true] - If true, calls
         * {@link dGui.Control.Prototype.UpdateBaseRect}.
         * @param {VarRef} [OutWidth] - A variable that will receive the width as integer.
         * @param {VarRef} [OutHeight] - A variable that will receive the height as integer.
         */
        SetTextEx2(&Str, PaddingX := 0, PaddingY := 0, UpdateBaseRect := true, &OutWidth?, &OutHeight?) {
            switch Type(Str), 0 {
                case 'String': ; do nothing
                default:
                    if IsObject(Str) {
                        throw TypeError('Expected a String.', , Type(Str))
                    } else {
                        Str := String(Str)
                    }
            }
            Str := this.Text := RegExReplace(Str, '\R', '`r`n', &count)
            if count {
                ControlFitText(this, PaddingX, PaddingY, , &OutWidth, &OutHeight)
            } else {
                sz := Display_Size()
                context := SelectFontIntoDc(this.Hwnd)
                if !DllCall(g_gdi32_GetTextExtentPoint32W, 'ptr', context.hdc, 'ptr', StrPtr(Str), 'int', StrLen(Str), 'ptr', sz, 'int') {
                    context()
                    throw OSError()
                }
                context()
                this.Move(, , OutWidth := sz.W + PaddingX, H ?? unset)
            }
            if UpdateBaseRect {
                this.UpdateBaseRect()
            }
        }
        /**
         * @description - Sets {@link dGui.Control#BaseFontSize} as
         * `<current font size> * BASE_DPI / <window's dpi>`.
         */
        UpdateBaseFontSize() {
            this.DefineProp('BaseFontSize', { Value: Display_Logfont(this.Hwnd).FontSize * BASE_DPI / this.Dpi })
        }
        /**
         * @description - Sets {@link dGui.Control#BaseX}, {@link dGui.Control#BaseY},
         * {@link dGui.Control#BaseW}, and/or {@link dGui.Control#BaseH} with the control's
         * current dimensions scaled as `<value> * BASE_DPI / <window's dpi>`.
         */
        UpdateBaseRect() {
            this.GetPos(&x, &y, &w, &h)
            ratio := BASE_DPI / this.Dpi
            this.BaseX := x * ratio
            this.BaseY := y * ratio
            this.BaseW := w * ratio
            this.BaseH := h * ratio
        }
        BaseFontSize {
            Get => this.Gui.BaseFontSize
            Set => this.DefineProp('BaseFontSize', { Value: Value })
        }
        BaseFontSizeScaled => this.BaseFontSize * this.Dpi / BASE_DPI
        Dpi => DllCall(g_user32_GetDpiForWindow, 'ptr', this.Hwnd, 'int')
        TextEx {
            Get => this.Text
            Set => this.SetTextEx2(&value)
        }
    }

    ;@region CtrlTypes
    class ActiveX extends dGui.Control {
    }
    class Button extends dGui.Control {
    }
    class CheckBox extends dGui.Control {
    }
    class ComboBox extends dGui.List {
    }
    class Custom extends dGui.Control {
    }
    class DateTime extends dGui.Control {
        static __New() {
            this.DeleteProp('__New')
            this.Prototype.DefineProp('SetFormat', Gui.DateTime.Prototype.GetOwnPropDesc('SetFormat'))
        }
        SetFormat(dateFormat := 'ShortDate') {
        }
    }
    class DDL extends dGui.List {
    }
    class Edit extends dGui.Control {
    }
    class GroupBox extends dGui.Control {
    }
    class Hotkey extends dGui.Control {
    }
    class List extends dGui.Control {
        static __New() {
            this.DeleteProp('__New')
            this.Prototype.DefineProp('Add', Gui.List.Prototype.GetOwnPropDesc('Add'))
            this.Prototype.DefineProp('Choose', Gui.List.Prototype.GetOwnPropDesc('Choose'))
            this.Prototype.DefineProp('Delete', Gui.List.Prototype.GetOwnPropDesc('Delete'))
        }
        Add(Items*) {
        }
        Choose(Value := 0) {
        }
        Delete(Value?) {
        }
    }
    class Link extends dGui.Control {
        /**
         * @description - Gets the height and width in pixels of the string contents of a link control.
         * This version of the function is only appropriate for single-line strings.
         *
         * Since the content displayed by a link control is different than the string returned by its `Text`
         * property, this version of the function removes the anchor html tags from the string and only
         * measures the inner text.
         * @returns {Display_Size}
         */
        GetTextExtent() {
            context := SelectFontIntoDc(this.Hwnd)
            ; Remove the html anchor tags
            Text := RegExReplace(this.Text, '<.+?"[ \t]*>(.+?)</a>', '$1')
            ; Measure the text
            if DllCall(
                'Gdi32.dll\GetTextExtentPoint32W'
                , 'ptr', context.hdc
                , 'ptr', StrPtr(Text)
                , 'int', StrLen(Text)
                , 'ptr', sz := Display_Size()
                , 'int'
            ) {
                context()
                return sz
            } else {
                context()
                throw OSError()
            }
        }
        /**
         * @description - Calls `GetTextExtentExPointW` using the Link control as context.
         * Since the content displayed by a link control is different than the string returned by its `Text`
         * property, this version of the function removes the anchor html tags from the string and only
         * measures the inner text. See the parameter hint for {@link CtrlTextExtentExPoint} for full details.
         * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
         * for {@link ControlGetTextExtentEx} for further details.
         * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
         * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
         * @param {VarRef} [OutExtentPoints] - A variable that will receive an  {@link Display_IntegerArray}. See the function
         * description for {@link ControlGetTextExtentEx} for further details.
         * @returns {Display_Size}
         */
        GetTextExtentEx(MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
            Text := RegExReplace(this.Text, '<a\s*(?:href|id)=".+?">(.+?)</a>', '$1')
            return __ControlGetTextExtentEx_Process(this.Hwnd, StrPtr(Text), StrLen(Text), MaxExtent, &OutCharacterFit, &OutExtentPoints)
        }
    }
    class ListBox extends dGui.List {
        /**
         * @description - Gets the height and width in pixels of the string contents of a ListBox control.
         * This version of the function is only appropriate for single-line strings.
         *
         * When ListBox controls are created, one of the options available is `Multi`. When `Multi` is in use,
         * the `Text` property returns an array of selected items. This version of the function has an
         * optional `Index` parameter to allow you to specify which item to measure. When unset, all items
         * in the array are measured. If a listbox is created without the `Multi` option, the `Index`
         * property has no effect because the `Text` property will return a string.
         *
         * @param {Integer} [Index] - If an integer, the index of the item to measure. If unset, all items
         * returned by the `Text` property are measured.
         * @returns {Object[]} - An array of objects with properties { H, Index, W }.
         */
        GetTextExtent(Index?) {
            Result := []
            context := SelectFontIntoDc(this.Hwnd)
            if this.Text is Array {
                if IsSet(Index) {
                    _Proc()
                } else {
                    Index := 0
                    loop Result.Capacity := this.Text.Length {
                        ++Index
                        _Proc()
                    }
                }
            } else {
                ; Measure the text
                if DllCall(
                    g_gdi32_GetTextExtentPoint32W
                    , 'ptr', context.hdc
                    , 'ptr', StrPtr(this.Text)
                    , 'int', StrLen(this.Text)
                    , 'ptr', sz := Display_Size()
                    , 'int'
                ) {
                    sz.Index := this.Value
                    Result.Push(sz)
                } else {
                    throw OSError()
                }
            }
            context()
            return Result

            _Proc() {
                ; Measure the text
                if DllCall(
                    g_gdi32_GetTextExtentPoint32W
                    , 'ptr', context.hdc
                    , 'ptr', StrPtr(this.Text[Index])
                    , 'int', StrLen(this.Text[Index])
                    , 'ptr', sz := Display_Size()
                    , 'int'
                ) {
                    sz.Index := Index
                    Result.Push(sz)
                } else {
                    context()
                    throw OSError()
                }
            }
        }
        /**
         * @description - Calls `GetTextExtentExPointW` using the ListBox control as context. If the `ListBox`
         * has the `Multi` option active, use the `Index` parameter to specify which item to measure. If
         * the `ListBox` does not have the `Multi` option active, leave `Index` unset. See the parameter hint
         * for {@link CtrlTextExtentExPoint} for full details.
         * @param {Integer} [Index] - The index of the item to measure. Leave unset if the `ListBox` does
         * not have the `Multi` option active.
         * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
         * for {@link ControlGetTextExtentEx} for further details.
         * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
         * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
         * @param {VarRef} [OutExtentPoints] - A variable that will receive an  {@link Display_IntegerArray}.
         * See the function description for {@link ControlGetTextExtentEx} for further details.
         * @returns {Display_Size}
         */
        GetTextExtentEx(Index?, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
            if IsSet(Index) {
                return __ControlGetTextExtentEx_Process(this.Hwnd, StrPtr(this.Text[Index]), StrLen(this.Text[Index]), MaxExtent, &OutCharacterFit, &OutExtentPoints)
            } else {
                return __ControlGetTextExtentEx_Process(this.Hwnd, StrPtr(this.Text), StrLen(this.Text), MaxExtent, &OutCharacterFit, &OutExtentPoints)
            }
        }
    }
    class ListView extends dGui.Control {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            lvProto := Gui.ListView.Prototype
            proto.DefineProp('Add', lvProto.GetOwnPropDesc('Add'))
            proto.DefineProp('Delete', lvProto.GetOwnPropDesc('Delete'))
            proto.DefineProp('DeleteCol', lvProto.GetOwnPropDesc('DeleteCol'))
            proto.DefineProp('GetCount', lvProto.GetOwnPropDesc('GetCount'))
            proto.DefineProp('GetNext', lvProto.GetOwnPropDesc('GetNext'))
            proto.DefineProp('GetText', lvProto.GetOwnPropDesc('GetText'))
            proto.DefineProp('Insert', lvProto.GetOwnPropDesc('Insert'))
            proto.DefineProp('InsertCol', lvProto.GetOwnPropDesc('InsertCol'))
            proto.DefineProp('Modify', lvProto.GetOwnPropDesc('Modify'))
            proto.DefineProp('ModifyCol', lvProto.GetOwnPropDesc('ModifyCol'))
            proto.DefineProp('SetImageList', lvProto.GetOwnPropDesc('SetImageList'))
        }
        Add(Options := '', Values*) {
        }
        Delete(RowNumber?) {
        }
        DeleteCol() {
        }
        GetCount(Mode := '') {
        }
        GetNext(StartingRowNumber := 0, RowType := '') {
        }
        GetText(RowNumber, ColumnNumber := 1) {
        }
        /**
         * @description - Gets the height and width in pixels of the string contents of a ListView control.
         * This version of the function is only appropriate for single-line strings.
         *
         * This version of the function has `RowNumber` and `ColumnNumber` parameters to pass to the the
         * `GetText` method of the control.
         *
         * @param {Array|Integer} [RowNumber] - If an integer, the row number of the item to measure. If an
         * array, an array of row numbers as integers. Leave unset to get the Size for items from all rows.
         * @param {Array|Integer} [ColumnNumber] - If an integer, the column number of the item to measure.
         * If an array, an array of column numbers as integers. Leave unset to get the Size for items from
         * all columns.
         * @returns {Object[]} - An array of objects with properties { Column, H, Row, W }.
         */
        GetTextExtent(RowNumber?, ColumnNumber?) {
            context := SelectFontIntoDc(this.Hwnd)
            if !IsSet(RowNumber) {
                RowNumber := []
                loop RowNumber.Capacity := this.GetCount() {
                    RowNumber.Push(A_Index)
                }
            }
            if !IsSet(ColumnNumber) {
                ColumnNumber := []
                loop ColumnNumber.Capacity := this.GetCount('col') {
                    ColumnNumber.Push(A_Index)
                }
            }
            Result := []
            if IsObject(RowNumber) {
                if IsObject(ColumnNumber) {
                    Result.Capacity := RowNumber.Length * ColumnNumber.Length
                    for r in RowNumber {
                        for c in ColumnNumber {
                            _Proc(r, c)
                        }
                    }
                } else {
                    Result.Capacity := RowNumber.Length
                    c := ColumnNumber
                    for r in RowNumber {
                        _Proc(r, c)
                    }
                }
            } else {
                r := RowNumber
                if IsObject(ColumnNumber) {
                    Result.Capacity := ColumnNumber.Length
                    for c in ColumnNumber {
                        _Proc(r, c)
                    }
                } else {
                    c := ColumnNumber
                    _Proc(r, c)
                }
            }
            context()
            return Result

            _Proc(r, c) {
                ; Measure the text
                if DllCall(
                    'Gdi32.dll\GetTextExtentPoint32W'
                    , 'ptr', context.hdc
                    , 'ptr', StrPtr(this.GetText(r, c))
                    , 'int', StrLen(this.GetText(r, c))
                    , 'ptr', sz := Display_Size()
                ) {
                    sz.Row := r
                    sz.Column := c
                    Result.Push(sz)
                } else {
                    context()
                    throw OSError()
                }
            }
        }
        /**
         * @description - Calls `GetTextExtentExPointW` using the ListView control as context. This version of
         * the function has `RowNumber` and `ColumnNumber` parameters to pass to the ListView's `GetText`
         * method. See the parameter hint for {@link CtrlTextExtentExPoint} for full details.
         * @param {Array|Integer} RowNumber - The row number of the item to measure.
         * @param {Array|Integer} ColumnNumber - The column number of the item to measure.
         * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
         * for {@link ControlGetTextExtentEx} for further details.
         * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
         * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
         * @param {VarRef} [OutExtentPoints] - A variable that will receive an  {@link Display_IntegerArray}. See the function
         * description for {@link ControlGetTextExtentEx} for further details.
         * @returns {Display_Size}
         */
        GetTextExtentEx(RowNumber, ColumnNumber, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
            text := this.GetText(RowNumber, ColumnNumber)
            return __ControlGetTextExtentEx_Process(this.Hwnd, StrPtr(text), StrLen(text), MaxExtent, &OutCharacterFit, &OutExtentPoints)
        }
        Insert(RowNumber, Options := '', Values*) {
        }
        InsertCol(ColumnNumer?, Options?, ColumnTitle?) {
        }
        Modify(RowNumber, Options := '', NewCol*) {
        }
        ModifyCol(ColumnNumber?, Options?, ColumnTitle?) {
        }
        SetImageList(ImageListId, IconType?) {
        }
        /**
         * @description - Adds one or more rows to the list-view using an array of arrays.
         * @param {Array[]} List - An array of arrays. Each nested array represents a row to be added. The
         * rows are added using the expression `this.Add(Opt, obj*)` where `obj` is a nested array.
         * @param {String} [Opt = ""] - A string containing options passed to
         * {@link https://www.autohotkey.com/docs/v2/lib/ListView.htm#Add Gui.ListView.Prototype.Add}.
         */
        AddListArray(List, Opt := '') {
            for obj in List {
                this.Add(Opt, obj*)
            }
        }
        /**
         * @description - Adds one or more rows to the list-view using an array of `Map` objects.
         * @param {Map[]} List - An array of `Map` objects. Each `Map` represents a row to be added. The `Map`
         * objects are expected to have items using keys that correspond with column headers. For each
         * column header, if the `Map` has an item with the same name, the item's value is added to
         * that column. If the `Map` does not have an item, the cell is empty.
         * @param {String} [Opt = ""] - A string containing options passed to
         * {@link https://www.autohotkey.com/docs/v2/lib/ListView.htm#Add Gui.ListView.Prototype.Add}.
         */
        AddListMap(List, Opt := '') {
            values := []
            headers := []
            loop values.Length := headers.Capacity := this.GetCount('Col') {
                headers.Push(this.GetText(0, A_Index))
            }
            for obj in List {
                for header in headers {
                    values[A_Index] := obj.Has(header) ? obj.Get(header) : ''
                }
                this.Add(Opt, values*)
            }
        }
        /**
         * @description - Adds one or more rows to the list-view using an array of `Object` objects.
         * @param {Object[]} List - An array of `Object` objects. Each `Object` represents a row to be added.
         * The `Object` objects are expected to have properties with the same name as the column headers.
         * For each column header, if the `Object` has a property with the same name, the property's value
         * is added to that column. If the `Object` does not have a property, the cell is empty.
         * @param {String} [Opt = ""] - A string containing options passed to
         * {@link https://www.autohotkey.com/docs/v2/lib/ListView.htm#Add Gui.ListView.Prototype.Add}.
         */
        AddListObject(List, Opt := '') {
            values := []
            headers := []
            loop values.Length := headers.Capacity := this.GetCount('Col') {
                headers.Push(this.GetText(0, A_Index))
            }
            for obj in List {
                for header in headers {
                    values[A_Index] := HasProp(obj, header) ? obj.%header% : ''
                }
                this.Add(Opt, values*)
            }
        }
        /**
         * @description - Enumerates the columns in the ListView control. You can call this in a `for` loop.
         * @example
         * for ColName in lv.Cols() {
         *     ; do work ...
         * }
         * @
         * @returns {Func} - An enumerator function that can be used to iterate over the columns.
         */
        Cols(*) {
            i := 0
            n := this.GetCount('Col')

            return _Enum

            _Enum(&ColName) {
                if ++i > n {
                    return 0
                }
                ColName := this.GetText(0, i)
                return 1
            }
        }
        /**
         * @description - Searches a list-view for a string.
         * @param {dGui.ListView} this - The `Gui.ListView` control.
         * @param {String} Text - The text to search for. The cell's contents must match `Text` in the
         * expression `this.GetText(RowIndex, ColIndex) = Text`.
         * @param {Integer|Integer[]} [Col] - If set, either an array of integers or just an integer, each
         * value representing the index of a column to search within. When searching, each row is iterated
         * and the indicated columns are all checked before moving on to the next row. If unset, all
         * columns are checked.
         * @returns {Integer} - If a match is found, the row number of the match. Else, an empty string.
         */
        Find(Text, Col?) {
            if IsSet(Col) {
                if !IsObject(Col) {
                    loop this.GetCount() {
                        if this.GetText(A_Index, Col) = Text {
                            return A_Index
                        }
                    }
                    return
                }
            } else {
                Col := []
                loop Col.Capacity := this.GetCount('Col') {
                    Col.Push(A_Index)
                }
            }
            i := 0
            loop this.GetCount() {
                ++i
                for k in Col {
                    if this.GetText(i, k) = Text {
                        return i
                    }
                }
            }
        }
        /**
         * @description - Iterates the rows in a list-view, passing a cell's text to a callback function.
         * When the function returns nonzero, the search ends and the row number is returned.
         *
         * @param {*} Callback - The callback function.
         *
         * Parameters:
         * 1. **{String}** - The cell's text.
         * 2. **{Integer}** - The column index.
         * 3. **{Integer}** - The row index.
         * 4. **{Gui.ListView}** - The `Gui.ListView` control.
         *
         * If the function returns zero or an empty string, the search proceeds. If the function returns
         * a nonzero value, the search ends.
         *
         * @param {Integer|Integer[]} [Col] - If set, either an array of integers or just an integer, each
         * value representing the index of a column to search within. When searching, each row is iterated
         * and the indicated columns are all checked before moving on to the next row. If unset, all
         * columns are checked.
         *
         * @returns {Integer} - If a match is found, the row number associated with the match. Else, an empty
         * string.
         */
        Rows(Callback, Col?) {
            if IsSet(Col) {
                if !IsObject(Col) {
                    loop this.GetCount() {
                        if Callback(this.GetText(A_Index, Col), Col, A_Index, this) {
                            return A_Index
                        }
                    }
                    return
                }
            } else {
                Col := []
                loop Col.Capacity := this.GetCount('Col') {
                    Col.Push(A_Index)
                }
            }
            i := 0
            loop this.GetCount() {
                ++i
                for k in Col {
                    if Callback(this.GetText(i, k), k, i, this) {
                        return i
                    }
                }
            }
        }
        /**
         * @description - Iterates the rows in the list-view using
         * {@link https://www.autohotkey.com/docs/v2/lib/ListView.htm#GetNext Gui.ListView.Prototype.GetNext}.
         * For each row, a callback function is called.
         *
         * @param {*} Callback - The callback function.
         *
         * Parameters:
         * 1. **{Integer}** - The row index.
         * 2. **{Gui.ListView}** - The `Gui.ListView` control.
         *
         * The function can return a nonzero value to end the process early.
         *
         * @param {String} [RowType = "C"] - One of the following:
         * - Blank or unset: Iterates the selected/highlighted rows.
         * - "C" or "Checked": Iterates the checked rows.
         * - "F" or "Focused": If a row is focused, calls `Callback` for that row. Else, does not call `Callback`.
         *
         * @param {Boolean} [Uncheck = true] - If true, and if `RowType` is "C" or "Checked",
         * {@link ListViewGetRows} unchecks the rows.
         *
         * @returns {Integer} - If `Callback` returns a nonzero value, the row number when that occurred. Else,
         * an empty string.
         */
        RowsEx(Callback, RowType := 'C', Uncheck := false) {
            i := 0
            if RowType {
                switch SubStr(RowType, 1, 1), 0 {
                    case 'C':
                        if Uncheck {
                            while i := this.GetNext(i, RowType) {
                                this.Modify(i, '-Check')
                                if Callback(i, this) {
                                    return i
                                }
                            }
                        } else {
                            return _Proc()
                        }
                    case 'F':
                        if i := this.GetNext(0, RowType) {
                            if Callback(i, this) {
                                return i
                            }
                        }
                    default: throw ValueError('Invalid row type.', , RowType)
                }
            } else {
                return _Proc()
            }

            return

            _Proc() {
                while i := this.GetNext(i, RowType) {
                    if Callback(i, this) {
                        return i
                    }
                }
            }
        }
    }
    class MonthCal extends dGui.Control {
    }
    class Pic extends dGui.Control {
    }
    class Progress extends dGui.Control {
    }
    class Radio extends dGui.Control {
    }
    class Slider extends dGui.Control {
    }
    class StatusBar extends dGui.Control {
        static __New() {
            this.DeleteProp('__New')
            this.Prototype.DefineProp('SetIcon', Gui.StatusBar.Prototype.GetOwnPropDesc('SetIcon'))
            this.Prototype.DefineProp('SetParts', Gui.StatusBar.Prototype.GetOwnPropDesc('SetParts'))
            this.Prototype.DefineProp('SetText', Gui.StatusBar.Prototype.GetOwnPropDesc('SetText'))
        }
        SetIcon(FileName, IconNumber := 1, PartNumber := 1) {
        }
        SetParts(Widths*) {
        }
        SetText(NewText, PartNumber := 1, Style := 0) {
        }
    }
    class Tab extends dGui.List {
        UseTab(Value := 0, ExactMatch := false) {
        }
        /**
         * @description - Calculates a tab control's display area given a window rectangle, or calculates
         * the window rectangle that would correspond to a specified display area.
         *
         * The display area is the area within which the tab's controls are visible. The window area is the
         * window's entire area, including tabs and margins.
         *
         * {@link https://learn.microsoft.com/en-us/windows/win32/controls/tcm-adjustrect}.
         *
         * @param {Integer} Operation - One of the following:
         * - 1 : `RectObj` represents the display area of the tab control; it will be modified to represent
         *   the corresponding window area.
         * - 0 : `RectObj` represents the window area of the tab control; it will be modified to represent
         *   the corresponding display area.
         *
         * @param {Display_Rect} RectObj - The {@link Display_Rect} object.
         */
        AdjustWindowRect(Operation, RectObj) {
            SendMessage(4904, Operation, RectObj, this.Hwnd, this.Gui.Hwnd) ; TCM_ADJUSTRECT
        }
        /**
         * @description - Delets all tabs.
         */
        DeleteAll() {
            return SendMessage(4873, 0, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_DELETEALLITEMS
        }
        /**
         * @param {Boolean} [Scope = false] - Flag that specifies the scope of the item deselection. If this
         * parameter is set to FALSE, all tab items will be reset. If it is set to TRUE, then all tab
         * items except for the one currently selected will be reset.
         */
        DeselectAll(Scope := false) {
            SendMessage(4914, Scope, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_DESELECTALL
        }
        /**
         * @description - The input is a display rectangle, and the output is the window rectangle
         * necessary for a tab control to have a display rectangle of the input dimensions.
         * @param {Display_Rect} rc - The display rectangle.
         * @returns {Display_Rect} - The window rectangle (same object with new values)
         */
        DisplayToWindow(rc) {
            SendMessage(4904, true, rc, this.Hwnd, this.Gui.Hwnd) ; TCM_ADJUSTRECT
            return rc
        }
        /**
         * @description - Returns the control's display rectangle relative to the parent window.
         * @returns {Display_Rect}
         */
        GetClientDisplayRect() {
            rc := Display_Rect()
            if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', rc, 'int') {
                throw OSError()
            }
            rc.ToClient(this.Gui.Hwnd, true)
            SendMessage(4904, false, rc, this.Hwnd, this.Gui.Hwnd) ; TCM_ADJUSTRECT
            return rc
        }
        /**
         * @description - Returns the control's window rectangle relative to the parent window.
         * @returns {Display_Rect}
         */
        GetClientWindowRect() {
            rc := Display_Rect()
            if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', rc, 'int') {
                throw OSError()
            }
            rc.ToClient(this.Gui.Hwnd, true)
            return rc
        }
        /**
         * @description - Returns the index of the item that has the focus in a tab control.
         * @returns {Integer}
         */
        GetCurFocus() {
            return SendMessage(4911, 0, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_GETCURFOCUS
        }
        /**
         * @description - Determines the currently selected tab in a tab control.
         * @returns {Integer} - Returns the index of the selected tab if successful, or -1 if no tab is
         * selected.
         */
        GetCurSel() {
            return SendMessage(4875, 0, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_GETCURSEL
        }
        /**
         * @description - Calculates the top-left corner of a tab control's display area relative to the
         * gui window.
         *
         * The display area is the area within which the tab's controls are visible.
         *
         * @param {VarRef} [OutTabRect] - A variable that will receive the {@link Display_Rect} object representing
         * the tab's display area that is generated by the function.
         *
         * @returns {Display_Point}
         */
        GetDisplayTopLeft(&OutTabRect?) {
            this.GetPos(&tabx, &taby, &tabw, &tabh)
            OutTabRect := Display_Rect(tabx, taby, tabw + tabx, taby + tabh)
            SendMessage(4904, false, OutTabRect, this.Hwnd, this.Gui.Hwnd) ; TCM_ADJUSTRECT
            return Display_Point(tabx + OutTabRect.l, taby + OutTabRect.t)
        }
        /**
         * @description - Retrieves the extended styles that are currently in use for the tab control.
         * @returns {Integer} - Returns a DWORD value that represents the extended styles currently in
         * use for the tab control. This value is a combination of tab control's extended styles.
         */
        GetExtendedStyle() {
            return SendMessage(4917, 0, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_GETEXTENDEDSTYLE
        }
        /**
         * @description - Retrieves the image list associated with a tab control.
         * @returns {Integer} - Returns the handle to the image list if successful, or NULL otherwise.
         */
        GetImageList() {
            return SendMessage(4866, 0, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_GETIMAGELIST
        }
        /**
         * @description - Retrieves the number of tabs in the tab control.
         * @returns {Integer} - Returns the number of items if successful, or zero otherwise.
         */
        GetItemCount() {
            return SendMessage(4868, 0, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_GETITEMCOUNT
        }
        /**
         * @description - Retrieves the bounding rectangle for a tab in a tab control.
         * @returns {Display_Rect}
         * @throws {OSError} - If the `SendMessage` call fails.
         */
        GetItemRect(Index) {
            rc := Display_Rect()
            if !SendMessage(4874, Index, rc, this.Hwnd, this.Gui.Hwnd) { ; TCM_GETITEMRECT
                throw OSError('Failed to get item rect.')
            }
            return rc
        }
        /**
         * @description - Retrieves the current number of rows of tabs in a tab control.
         * @returns {Integer} - The number of rows of tabs.
         */
        GetRowCount() {
            return SendMessage(4908, 0, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_GETROWCOUNT
        }
        /**
         * @description - Returns the control's display rectangle relative to the screen.
         * @returns {Display_Rect}
         */
        GetScreenDisplayRect() {
            rc := Display_Rect()
            if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', rc, 'int') {
                throw OSError()
            }
            SendMessage(4904, false, rc, this.Hwnd, this.Gui.Hwnd) ; TCM_ADJUSTRECT
            return rc
        }
        /**
         * @description - Returns the control's window rectangle relative to the screen.
         * @returns {Display_Rect}
         */
        GetScreenWindowRect() {
            rc := Display_Rect()
            if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', rc, 'int') {
                throw OSError()
            }
            return rc
        }
        /**
         * @description - Gets tab text.
         * @param {Integer} Index - The index of the tab for which to get the text.
         * @param {Integer} MaxChars - The maximum characters to copy to the buffer. This can be an
         * overestimate.
         * @returns {String} - The tab's text, or an empty string if the operation failed.
         */
        GetTabText(Index, MaxChars) {
            tcitem := Display_TcItemW(1, , , , MaxChars) ; TCIF_TEXT
            if SendMessage(4924, Index, tcitem.Ptr, this.Hwnd, this.Gui.Hwnd) { ; TCM_GETITEMW
                return tcitem.pszText
            } else {
                return ''
            }
        }
        /**
         * @description - The input values should represent the desired display area. This function
         * then calculates the window rectangle that will produce the display area. If any values
         * are unset, the control's current value is used.
         * @param {Integer} [X] - The x-coordinate.
         * @param {Integer} [Y] - The y-coordinate.
         * @param {Integer} [W] - The width.
         * @param {Integer} [H] - The height.
         * @returns {Display_Rect} - The window rectangle.
         */
        GetWindowRectFromDisplayRect(X?, Y?, W?, H?) {
            rc := Display_Rect()
            if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', rc, 'int') {
                throw OSError()
            }
            rc.ToClient(this.Gui.Hwnd, true)
            SendMessage(4904, false, rc, this.Hwnd, this.Gui.Hwnd) ; TCM_ADJUSTRECT
            if IsSet(X) {
                rc.X := X
            }
            if IsSet(Y) {
                rc.Y := Y
            }
            if IsSet(W) {
                rc.W := W
            }
            if IsSet(H) {
                rc.H := H
            }
            SendMessage(4904, true, rc, this.Hwnd, this.Gui.Hwnd) ; TCM_ADJUSTRECT
            return rc
        }
        /**
         * @description - Highlights a tab.
         * @param {Integer} Index - The index of the tab to highlight / remove higlighting.
         * @param {Boolean} [Value = true] - If true, activates the highlight state. If false, deactivates
         * the highlight state.
         * @returns {Integer} - 1 if successful, 0 if unsuccessful.
         */
        HighlightItem(Index, Value := true) {
            return SendMessage(4915, Index, (0 & 0xFFFF) << 16 | (Value & 0xFFFF), this.Hwnd, this.Gui.Hwnd) ; TCM_HIGHLIGHTITEM
        }
        /**
         * @description - Determines if a tab is at the input coordinate.
         * @param {Integer} X - The x-coordinate.
         * @param {Integer} Y - The y-coordinate.
         * @returns {Integer} - One of the following values:
         * - 1: The position is not over a tab.
         * - 2: The position is over a tab's icon.
         * - 4: The position is over a tab's text.
         * - 6: The position is over a tab but not over its icon or its text. For owner-drawn tab
         * controls, this value is specified if the position is anywhere over a tab.
         */
        HitTest(X, Y) {
            HitTest := Buffer(12)
            NumPut('int', X, 'int', Y, HitTest, 0)
            SendMessage(4877, 0, HitTest.ptr, this.Hwnd, this.Gui.Hwnd) ; TCM_HITTEST
            return NumGet(HitTest, 8, 'uint')
        }
        /**
         * @description - Removes an image from a tab control's image list.
         * @param {Integer} Index - The index of the image to remove.
         */
        RemoveImage(Index) {
            SendMessage(4906, Index, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_REMOVEIMAGE
        }
        /**
         * @description - Sets the focus to a specified tab in a tab control.
         * @param {Integer} Index - The index of the tab to focus.
         */
        SetCurFocus(Index) {
            SendMessage(4912, Index, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_SETCURFOCUS
        }
        /**
         * @description - Selects a tab in a tab control.
         * @param {Integer} Index - The index of the tab to select.
         */
        SetCurSel(Index) {
            SendMessage(4876, Index, 0, this.Hwnd, this.Gui.Hwnd) ; TCM_SETCURSEL
        }
        /**
         * @description - Sets an extended style on the tab control.
         * @param {Integer} Style - One of the following:
         * - 1: TCS_EX_FLATSEPARATORS
         * - 2: TCS_EX_REGISTERDROP
         * @param {Integer} Value - Either 1 or 0 to enable or clear the style, respectively.
         */
        SetExtendedStyle(Style, Value) {
            return SendMessage(4916, Style, Value, this.Hwnd, this.Gui.Hwnd) ; TCM_SETEXTENDEDSTYLE
        }
        /**
         * @description - Assigns an image list to a tab control.
         * {@link https://learn.microsoft.com/en-us/windows/win32/controls/tcm-setimagelist}
         * @param {Integer} Index - The index of the image to remove.
         * @returns {Integer} - Returns the handle to the previous image list, or NULL if there is no
         * previous image list.
         */
        SetImageList(Handle) {
            SendMessage(4867, 0, Handle, this.Hwnd, this.Gui.Hwnd) ; TCM_SETIMAGELIST
        }
        /**
         * @description - Sets the width and height of tabs in a fixed-width or owner-drawn tab control.
         * @param {Integer} Width - The width in pixels.
         * @param {Integer} Height - The height in pixels.
         * @param {VarRef} [OutOldWidth] - A variable that will receive the previous width in pixels
         * @param {VarRef} [OutOldHeight] - A variable that will receive the previous height in pixels
         */
        SetItemSize(Width, Height, &OutOldWidth?, &OutOldHeight?) {
            old := SendMessage(4905, 0, (Height & 0xFFFF) << 16 | (Width & 0xFFFF), this.Hwnd, this.Gui.Hwnd) ; TCM_SETITEMSIZE
            OutOldWidth := old & 0xFFFF
            OutOldHeight := (old >> 16)
        }
        /**
         * @description - Sets the minimum tab width.
         * @param {Integer} Width - The minimum tab width in pixels.
         * @returns {Integer} - The previous minimum tab width.
         */
        SetMinTabWidth(Width) {
            result := SendMessage(4913, 0, Width, this.Hwnd, this.Gui.Hwnd) ; TCM_SETMINTABWIDTH
            return result
        }
        /**
         * @description - Sets a tab's text.
         * @param {Integer} Index - The index of the tab which will have its text changed.
         * @param {String} NewText - The new text.
         * @returns {Integer} - 1 if successful, 0 otherwise.
         */
        SetTabText(Index, NewText) {
            tcitem := Display_TcItemW(1, , , NewText) ; TCIF_TEXT
            return SendMessage(4925, Index, tcitem.Ptr, this.Hwnd, this.Gui.Hwnd) ; TCM_SETITEMW
        }
        /**
         * @description - The input is a window rectangle, and the output is the display rectangle
         * area for a tab control with the input dimensions.
         * @param {Display_Rect} rc - The window rectangle. If unset, the control's current dimensions
         * are used.
         * @returns {Display_Rect} - The display rectangle (same object with new values)
         */
        WindowToDisplay(rc) {
            SendMessage(4904, false, rc, this.Hwnd, this.Gui.Hwnd) ; TCM_ADJUSTRECT
            return rc
        }
    }
    class Text extends dGui.Control {
    }
    class TreeView extends dGui.Control {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            tvProto := Gui.TreeView.Prototype
            proto.DefineProp('Add', tvProto.GetOwnPropDesc('Add'))
            proto.DefineProp('Delete', tvProto.GetOwnPropDesc('Delete'))
            proto.DefineProp('Get', tvProto.GetOwnPropDesc('Get'))
            proto.DefineProp('GetChild', tvProto.GetOwnPropDesc('GetChild'))
            proto.DefineProp('GetCount', tvProto.GetOwnPropDesc('GetCount'))
            proto.DefineProp('GetNext', tvProto.GetOwnPropDesc('GetNext'))
            proto.DefineProp('GetParent', tvProto.GetOwnPropDesc('GetParent'))
            proto.DefineProp('GetPrev', tvProto.GetOwnPropDesc('GetPrev'))
            proto.DefineProp('GetSelection', tvProto.GetOwnPropDesc('GetSelection'))
            proto.DefineProp('GetText', tvProto.GetOwnPropDesc('GetText'))
            proto.DefineProp('Modify', tvProto.GetOwnPropDesc('Modify'))
            proto.DefineProp('SetImageList', tvProto.GetOwnPropDesc('SetImageList'))
        }
        Add(Name, ParentItemId := 0, Options := '') {
        }
        Delete(ItemId?) {
        }
        Get(ItemId, Attribute) {
        }
        GetChild(ItemId) {
        }
        GetCount() {
        }
        GetNext(ItemId := 0, ItemType?) {
        }
        GetParent(ItemId) {
        }
        GetPrev(ItemId) {
        }
        GetSelection() {
        }
        GetText(ItemId) {
        }
        /**
         * @description - Gets the height and width in pixels of the string contents of a TreeView control.
         *
         * This version of the function has two usage options which depend on the value passed to `Count`.
         * {@link https://www.autohotkey.com/docs/v2/lib/TreeView.htm}.
         *
         * @param {Array|Integer} [Id = 0] - The id of the item to measure, or an array of ids. The ids are
         * passed to the `GetText` method. If `Id` is `0`, `TreeViewObj.GetChild(0)` is called, which returns
         * the top item in the TreeView.
         * @param {Integer} [Count] - If set, traverses the TreeView starting from `Id` for `Count`
         * items, or until the last item is measured. If `Count` is 0, all items after `Id`
         * are measured. If `Id` is an array, `Count` is ignored.
         * @returns {Object[]} - An array of objects with properties { Id, W, H }.
         */
        GetTextExtent(Id := 0, Count?) {
            context := SelectFontIntoDc(this.Hwnd)
            hdc := context.hdc
            Result := []
            if Id is Array {
                loop Result.Capacity := Id.Length {
                    _id := Id[A_Index]
                    _Proc()
                }
            } else {
                _id := Id || this.GetChild(0)
                _Proc()
                if IsSet(Count) {
                    loop Count || this.GetCount() {
                        if _id := this.GetNext(_id, 'F') {
                            _Proc()
                        } else {
                            break
                        }
                    }
                }
            }
            context()
            return Result

            _Proc() {
                ; Measure the text
                if DllCall(
                    'Gdi32.dll\GetTextExtentPoint32W'
                    , 'ptr', hdc
                    , 'ptr', StrPtr(this.GetText(_id))
                    , 'int', StrLen(this.GetText(_id))
                    , 'ptr', sz := Display_Size()
                    , 'int'
                ) {
                    sz.Id := _id
                    Result.Push(sz)
                } else {
                    context()
                    throw OSError()
                }
            }
        }
        /**
         * @description - Calls `GetTextExtentExPointW` using the TreeView control as context. This
         * version of the function has an `Id` parameter to pass to the TreeView's `GetText` method.
         * See the parameter hint for {@link CtrlTextExtentExPoint} for full details.
         * @param {Integer} [Id = 0] - The Id of the item to measure. If `Id` is `0`, the first item in the
         * TreeView is measured.
         * @param {Integer} [MaxExtent = 0] - The maximum width of the string. See the function description
         * for {@link ControlGetTextExtentEx} for further details.
         * @param {VarRef} [OutCharacterFit] - A variable that will receive the number of characters
         * that fit within `MaxExtent` pixels. If `MaxExtent` is 0, `OutCharacterFit` will be set to 0.
         * @param {VarRef} [OutExtentPoints] - A variable that will receive an  {@link Display_IntegerArray}. See the function
         * description for {@link ControlGetTextExtentEx} for further details.
         * @returns {Display_Size}
         */
        GetTextExtentEx(Id := 0, MaxExtent := 0, &OutCharacterFit?, &OutExtentPoints?) {
            text := this.GetText(Id || this.GetChild(0))
            return __ControlGetTextExtentEx_Process(this.Hwnd, StrPtr(text), StrLen(text), MaxExtent, &OutCharacterFit, &OutExtentPoints)
        }
        Modify(ItemId, Options := '', NewName?) {
        }
        SetImageList(ImageListId, IconType := 0) {
        }
    }
    class UpDown extends dGui.Control {
    }
    ;@endregion
}
