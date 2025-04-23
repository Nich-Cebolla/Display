
; For other Gui-related functions that aren't part of this library, check out these:
; Align.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
; GuiResizer.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
; MenuBarConstructor.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MenuBarConstructor.ahk
; FillStr.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FillStr.ahk

/**

This document seeks to accomplish these tasks:
- Provide an overview of what is available within this library.
- Notify you of changes to built-in classes and methods that this library might invoke.
- Guide you through choosing what options your project will use and how to enable them, and
disable others your project does not need.

This is a work in progress and will change frequently while I finish it. If you use this
library in a project, do not use your git clone directory for the project. I will break things
as I release updates.

*/

; Step 1: Copy this document to your project folder then open the copy and work on that one.

; Step 2: Selecting source files
; Adjust the top #Include statements to point to the "Display" directories.
; Then comment out any files which your project is not going to use.
; When finished, try running this file and see if you get any unset variable warnings
; then adjust as needed.

#Include Display_DefaultConfig.ahk

#Include ..\lib
#Include Display_ComboBox.ahk
#Include Display_Dpi.ahk
#Include Display_Gui.ahk
#Include Display_Lib.ahk
#Include Display_SetThreadDpiAwareness__Call.ahk

#Include ..\src
#Include Display_dMon.ahk
#Include Display_dGui.ahk
#Include Display_dScrollbar.ahk
#Include Display_dtext.ahk
#Include Display_dWin.ahk
#Include Display_dLv.ahk

#Include ..\struct
#Include Display_RectBase.ahk
#Include Display_Rect.ahk
#Include Display_Point.ahk
#Include Display_NumberArray.ahk
#Include Display_LOGFONT.ahk

#Include ..\definitions
#Include Display_Define_ComboBox.ahk
#Include Display_Define_Dpi.ahk
#Include Display_Define_Font.ahk
#Include Display_Define_Scrollbar.ahk
#Include Display_Define_Windows.ahk

; Step 3: Selecting options
; Delete the /* below and work your way through the various options
; These pertain to `dGui` and functions that are related to WM_DPICHANGED, the other
; parts of this library don't have configuration options.

/**
 * @var {Integer} DPI_AWARENESS_CONTEXT_DEFAULT - The default DPI awareness context used by
 * various functions.
 */
DPI_AWARENESS_CONTEXT_DEFAULT := DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2

/**
 * @var {Integer} MDT_DEFAULT - The default DPI type used by various functions.
 */
MDT_DEFAULT := MDT_EFFECTIVE_DPI

/**
 * @property {Boolean} dMon.UseOrderedMonitors - When true, the monitors are ordered by their
 * coordinates. See the parameter hint above `dMon.GetOrder` for more information.
 */
if IsSet(dMon) {
   dMon.UseOrderedMonitors := false
}


/**
 * @class
 * @description - The configuration object for the `Display` library, containing
 * configuration items for `dGui` and functions which handle `WM_DPICHANGED` messages.
 * Properties marked "**Required**" must use the default value to use the built-in WM_DPICHANGED
 * handlers.
 */
class DisplayConfig {

    /**
     * @property {Boolean|Array} DisplayConfig.ExcludeNewControlSetFont - **Required** Default = false <br>
     * Controls which `Gui.Control` types have the `SetFont` method overridden. If false,
     * all control types have their `SetFont` method overridden. If an array, all control
     * types except those listed will have their `SetFont` method overridden. If true, no
     * control types have their `SetFont` method overridden.
     */
    static ExcludeNewControlSetFont := false

    /**
     * @property {Boolean} DisplayConfig.NewGuiSetFont - **Required** Default = true <br>
     * Controls whether `Gui.Prototype.SetFont` is overridden. The new SetFont method is
     * `GUI_SETFONT`, located in lib\Display_Gui.ahk. The new method scales font size according
     * to dpi, handles some extra tasks required for WM_DPICHANGED to work correctly, and also
     * allows you to define multiple font families in a single SetFont call as a comma-separated
     * list of font family names (see {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm} for
     * information about using multiple font family names).
     */
    static NewGuiSetFont := true

    /**
     * @property {Boolean} DisplayConfig.NewGuiCall - **Required** Default = true <br>
     * Controls whether `Gui.Call` is overridden. The new Call method is `GUI_CALL`, located in
     * lib\Display_Gui.ahk. The new method handles the initialization of several additional properties
     * required for this library's built-in WM_DPICHANGED handler. It also allows an `ExtendedParams`
     * parameter as an optional parameter. `ExtendedParams` can be an object with zero or more
     * of { MarginX, MarginY, BackColor, MenuBar, Name, OptFont, FontFamily }.
     */
    static NewGuiCall := true

    /**
     * @property {Boolean} DisplayConfig.NewGuiAdd - **Required** Default = true <br>
     * Controls whether `Gui.Prototype.Add` is overridden. The new method is `GUI_ADD`, located
     * in lib\Display_Gui.ahk. The new method handles the in
     */
    static NewGuiAdd := true

    /**
     * @property {Boolean|Array} DisplayConfig.ExcludeNewGuiAddType - When false, all control types
     * have their associated `Gui.Prototype.Add<Type>` method overridden (to call the new
     * `Gui.Prototype.Add` method). When an array, all control types except those listed will
     * have the `Gui.Prototype.Add<Type>` method overridden. When true, no control types
     * have their associated `Gui.Prototype.Add<Type>` method overridden.
     */
    static ExcludeNewGuiAddType := false

    /**
     * @property {Boolean|Array} DisplayConfig.DpiExcludeControls - When false, all controls
     * are processed by the dpi change handler. Else, an array of control types to exclude from
     * processing. This is implemented by creating a `Gui.<Ctrl Type>.Prototype.DpiExclude` property for
     * the control type. You can change the value of the property at any any time for any control
     * prototype to toggle the behavior.
     * @example
     *  ; I want to custom handle dpi scaling for ListView controls, so I do not want the built-in
     *  ; handler to process them.
     *  DisplayConfig.DpiExcludeControls := ['ListView']
     *  ; or
     *  Gui.ListView.Prototype.DpiExclude := true
     * @
     * You can also set this on an individual control.
     * @example
     *  G := Gui('-DPIScale +Resize')
     *  MainEdit := G.Add('Edit', 'w800 r50 vmain')
     *  MainEdit.DpiExclude := true
     * @
     */
    static DpiExcludeControls := false

    /**
     * @property {Boolean} DisplayConfig.DefaultExcludeGui - When true, the property
     * `Gui.Prototype.DpiExclude` is set to true, causing all `GUI_HANDLEDPICHANGE` function calls
     * to return immediately. Gui windows must be opted-in by setting the property to false on
     * that Gui instance. When false, the built-in DPI change handler is activated for all Gui
     * windows without any additional code from you. Use this option if you would prefer to
     * selectively enable DPI handling at an individual window level.
     * @example
     *  G := Gui('-DPIScale +Resize')
     *  G.DpiExclude := false
     * @
     */
    static DefaultExcludeGui := false

    /**
     * @property {Map|Boolean} DisplayConfig.ControlGetTextExtent  - If true, the library adds a
     * method `GetTextExtent` to Gui controls. The method measures the control's text in pixels.
     * The function objects are in lib\Display_ControlTextExtent.ahk.
     */
    static ControlGetTextExtent := true

    /**
     * @property {Array|Boolean} DisplayConfig.ResizeByText - Controls which control types are resized
     * using the function `GUI_CONTROL_RESIZE_BY_TEXT`. For controls not included in this list,
     * they will be resized using `dGui.ControlDpiChangeHelper.Prototype.Adjust`. To set all controls
     * to be resized using `dGui.ControlDpiChangeHelper.Prototype.Adjust`, set this to `false`.
     */
    static ResizeByText := ['Button', 'CheckBox', 'ComboBox', 'DDl', 'Edit', 'GroupBox', 'Radio'
                          , 'StatusBar', 'Tab', 'Text']

    /**
     * @property {Boolean} DisplayConfig.GuiToggle - When true, the method `Toggle` is added to
     * `Gui.Prototype`. The function object is `GUI_TOGGLE` locatated in lib\Display_Gui.ahk.
     */
    static GuiToggle := true

    /**
     * @property {Boolean} DisplayConfig.GuiCallWith_S - When true, the method `__Call` is added to
     * `Gui.Prototype`. The function object is `SetThreadDpiAwareness__Call` located in
     * lib\Display_SetThreadDpiAwareness__Call.ahk. It enables the usage of the "_S" suffix when
     * calling gui object methods, e.g. `GuiObj.Move_S`. When called with "_S",
     * `DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT_DEFAULT, 'ptr')`
     * is called before calling the intended method.
     */
    static GuiCallWith_S := true

    /**
     * @property {Boolean} DisplayConfig.ContrlCallWith_S - When true, the method `__Call` is added
     * to `Gui.Control.Prototype`. This is the same as the above, but for controls.
     */
    static ControlCallWith_S := true

    /**
     * @property {Boolean} DisplayConfig.GuiDpiGetter - When true, the dynamic property `Dpi`
     * is added to `Gui.Prototype`. The property will return the value returned by `GetDpiForWindow`
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiforwindow}
     */
    static GuiDpiGetter := true

    /**
     * @property {Boolean} DisplayConfig.ControlDpiGetter - When true, the dynamic property `Dpi`
     * is added to `Gui.Control.Prototype`. The property will return the value returned by `GetDpiForWindow`
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiforwindow}
     */
    static ControlDpiGetter := true

}

; Call here or anywhere else in your code
if IsSet(dGui) {
   dGui.Initialize()
}


/*
ActiveX
Button
CheckBox
ComboBox
Control
Custom
DateTime
DDL
Edit
GroupBox
Hotkey
Link
List
ListBox
ListView
MonthCal
Pic
Progress
Radio
Slider
StatusBar
Tab
Tab2
Tab3
Text
TreeView
UpDown
*/
