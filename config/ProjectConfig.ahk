
; For other Gui-related functions that aren't part of this library, check out these:
; Align.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
; GuiResizer.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
; MenuBarConstructor.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MenuBarConstructor.ahk
; FillStr.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FillStr.ahk

/*

This document seeks to accomplish these tasks:
- Notify you of changes to built-in classes and methods that this library might invoke.
- Guide you through choosing what options your project will use and how to enable them, and
disable others your project does not need.

This is a work in progress and will change frequently while I finish it. If you use this
library in a project, do not use your git clone directory for the project. I will break things
as I release updates.

*/

; Step 1: Copy this document to your project folder then open the copy and work on that one.

; Step 2: Pointing to the correct directories
; Adjust the top #include statements to point to the "Display" directories.
; By "top #include statements", I mean the ones at the top of each block
; e.g. "#include DefaultConfig.ahk" should be changed to "..\..\path\to\Display\config\DefaultConfig.ahk"
; and "#include ..\lib" should be changed to "#include ..\..\path\to\Display\lib"
; You can use absolute paths if necessary / more appropriate for your project

; Step 3: Selecting source files
; Comment out any files which your project is not going to use.
; When finished, try running this file and see if you get any unset variable warnings
; then adjust as needed.

; Note that the definition files and struct files are #included where needed, so you don't need to worry about those.
; You can still #include a struct file or definition file if your project will use one outside of the context
; of this library, so I included those but all commented out to make this easy.

#include DefaultConfig.ahk

#include ..\lib
#include ComboBox.ahk
#include Dpi.ahk
; #include Lib.ahk not currently in use
#include Text.ahk
#include SetThreadDpiAwareness__Call.ahk

#include ..\src
#include dMon.ahk
#include dGui.ahk
; #include dScrollbar.ahk ; not working
#include dWin.ahk
#include dLv.ahk
#include DpiChangeHelpers.ahk

; #include ..\definitions
; #include Define-ComboBox.ahk
; #include Define-Dpi.ahk
; #include Define-Font.ahk
; #include Define-Scrollbar.ahk
; #include Define-Windows.ahk

; #include ..\struct
; #include IntegerArray.ahk
; #include LOGFONT.ahk
; #include Point.ahk
; #include Rect.ahk
; #include RectBase.ahk
; #include SIZE.ahk
; #include WINDOWINFO.ahk

; Step 3: Selecting options
; Delete the /* below and work your way through the various options

/**
 * @property {Boolean} dMon.UseOrderedMonitors - When true, the monitors are ordered by their
 * coordinates. See the parameter hint above {@link dMon.GetOrder} for more information.
 */
if IsSet(dMon) {
   dMon.UseOrderedMonitors := true
}

; The remaining options pertain to `dGui` and functions that are related to WM_DPICHANGED

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
 * @classdesc - The configuration object for the `Display` library, containing
 * configuration items for `dGui` and functions which handle `WM_DPICHANGED` messages.
 * Properties marked "**Required**" must use the default value to use the built-in WM_DPICHANGED
 * handlers.
 */
class DisplayConfig {

    ; This information pertains to both gui and control `SetFont` methods. The new `SetFont` methods
    ; scale font size according to dpi, handle some extra tasks required for the built-in dpi change
    ; handler to work correctly, and also allow you to define multiple font families in a single
    ; SetFont call as a comma-separated list of font family names (see https://www.autohotkey.com/docs/v2/lib/Gui.htm
    ; for information about using multiple font family names).
    ; The function definitions are located in lib\Gui.ahk.
    /**
     * @property {Boolean|Array} DisplayConfig.OverrideControlSetFont - **Required**
     * Default = true
     * If true, `Gui.Control.Prototype.SetFont` is overridden with `ControlSetFont`.
     */
    static OverrideControlSetFont := true

    /**
     * @property {Boolean} DisplayConfig.OverrideGuiSetFont - **Required**
     * Default = true
     * If true, `Gui.Prototype.SetFont` is overridden with `GuiSetFont`.
     */
    static OverrideGuiSetFont := true

    /**
     * @property {Boolean} DisplayConfig.OverrideGuiAdd - **Required**
     * Default = true
     * If true, `Gui.Prototype.Add` is overridden with `GuiAdd`. The new method has these changes:
     * - Initializes `CtrlObj.DpiChangeHelper` with a `ControlDpiChangeHelper` object, necessary
     * for some functionality related to the built-in WM_DPICHANGED handler.
     * - Increments `GuiObj.Count++`.
     *
     * This also overrides the `Gui.Prototype.Add<Type>` methods.
     *
     * The original `Gui.Prototype.Add` method is still available from `dGui.GuiAdd`, just pass the
     * gui object as the first parameter.
     */
    static OverrideGuiAdd := true

    /**
     * @property {Boolean|Array} DisplayConfig.ControlIncludeByDefault -
     * Default = true
     * When true, all controls are processed by the built-in dpi change handler by default.
     *
     * You can also set it to an array of control types as strings to specify a subset of control
     * types which will be processed by the built-in dpi change handler by default.
     *
     * You can also set it to `false` to exclude all controls from being processed by the built-in
     * dpi change handler by default.
     *
     * This feature is implemented by creating a `Gui.Control.Prototype.DpiExclude` property.
     *
     * When an array of type strings, the library sets `Gui.Control.Prototype.DpiExclude := true`
     * and then for each type in the array sets `Gui.<Ctrl Type>.Prototype.DpiExclude := false`.
     *
     * In both cases, you can change the value of the property at any any time to toggle the behavior.
     * @example
     * ; To exclude ListView controls from being processed by the built-in dpi change handler.
     *  Gui.ListView.Prototype.DpiExclude := true
     * ; To exclude all controls from being processed by default.
     *  Gui.Control.Prototype.DpiExclude := true
     * ; To later include all controls from being processed by default (except ListView controls, per
     * ; the above setting).
     *  Gui.Control.Prototype.DpiExclude := false
     * @
     * You can also set this on an individual control.
     * @example
     *  G := Gui('-DPIScale +Resize')
     *  MainEdit := G.Add('Edit', 'w800 r50 vmain')
     *  MainEdit.DpiExclude := true
     * @
     */
    static ControlIncludeByDefault := true

    /**
     * @property {Map|Boolean} DisplayConfig.GetTextExtent -
     * Default = true
     * When `true`, the library adds a method `GetTextExtent` to Gui controls. The method measures
     * the control's text in pixels, returning a `SIZE` object.
     * The function definitions are in lib\ControlTextExtent.ahk.
     * The following control types are affected by `DisplayConfig.ControlGetTextExtent`:
     * Button, CheckBox, DateTime, Edit, GroupBox, Hotkey, Link, ComboBox, DDL, ListBox, Tab, Tab2,
     * Tab3, ListView, Radio, StatusBar, Text, TreeView
     */
    static GetTextExtent := true

    /**
     * @property {Boolean} DisplayConfig.GetTextExtentEx -
     * Default = true
     * When `true`, the library adds a method `GetTextExtentEx` to Gui controls. See the function
     * definition for details about the function. The function definitions are in
     * lib\ControlTextExtent.ahk.
     * The following control types are affected by `DisplayConfig.ControlGetTextExtentEx`:
     * Button, CheckBox, DateTime, Edit, GroupBox, Hotkey, Link, ComboBox, DDL, ListBox, Tab, Tab2,
     * Tab3, ListView, Radio, StatusBar, Text, TreeView
     */
    static GetTextExtentEx := true

    /**
     * @property {Boolean} DisplayConfig.GuiCount - **Required**
     * Default = true
     * When `true`, the library adds the property `GuiObj.Count`, which is incremented each time
     * a control is added.
     */
    static GuiCount := true

    /**
     * @property {Boolean} DisplayConfig.GuiDpiExclude - **Required**
     * Default = true
     * When `true`, the library adds the property `Gui.Prototype.DpiExclude := 0`. To exclude any
     * individual window from being altered by the built-in dpi change handler, set the window's
     * `DpiExclude` property to a nonzero value.
     */
    static GuiDpiExclude := true

    /**
     * @property {Boolean} DisplayConfig.HandleDpiChanged - **Required**
     * Default = true
     * When `true`, the library adds a method `Gui.Control.Prototype.HandleDpiChanged`. The function
     * definition is `ControlResizeByDpiRatio` in lib\Gui.ahk.
     */
    static HandleDpiChanged := true

    /**
     * @property {Array|Boolean} DisplayConfig.ResizeByText -
     * Default = ['Button', 'Edit', 'Link', 'StatusBar', 'Text']
     *
     * Regarding the built-in dpi change handler, `DisplayConfig.ResizeByText` specifies which control
     * types are resized using the function `ControlResizeByText`. For controls not included in this
     * list, they will be resized using `ControlResizeByDpiRatio`. To set all controls to be resized
     * using `ControlResizeByDpiRatio`, set this to `false`.
     *
     * Using this option requires that `DisplayConfig.GetTextExtent == true` and
     * `DisplayConfig.ControlHandleDpiChanged == true`.
     *
     * The way resizing by text works is similar to resizing by the dpi ratio. Typically when we
     * resize controls in response to a dpi change, we refactor the size as a ratio of the system
     * dpi to the current dpi, then apply the new dpi as a ratio of new dpi to system dpi. One
     * challenge with this approach is that font size does not scale the same way physical size
     * scales, and so the ratio of non-text-area to text-area for a control will change.
     *
     * When resizing by text area, instead of using the dpi ratio, the built-in dpi change handler
     * measures the font's current size, then scales the font according to the dpi change, then
     * measures the font again, and that ratio is used to scale the area of the control. This
     * preserves the ratio of non-text-area to text-area within any given control, but then carries
     * the consequence of causing an inconsistent ratio of control-area to gui-window-area. Which
     * approach is better than the other depends on the needs of the application and how much work
     * one is willing to put into dealing with these eventualities. Generally I would recommend
     * trying out both and seeing which one better fits the layout.
     *
     * The following control types are currently incompatible with `ControlResizeByText` due to
     * requiring special handling: ActiveX, Custom, ListBox, ListView, MonthCal, Pic, Progress,
     * Slider, TreeView, UpDown.
     */
    static ResizeByText := ['Button', 'Edit', 'Link', 'StatusBar', 'Text']

    /**
     * @property {Object} DisplayConfig.ControlOffset - Needs more work, not currently in use.
     */
    ; static ControlOffset := {
    ;      ActiveX:     { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Button:      { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , CheckBox:    { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , ComboBox:    { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Control:     { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Custom:      { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , DateTime:    { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , DDL:         { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Edit:        { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , GroupBox:    { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Hotkey:      { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Link:        { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , List:        { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , ListBox:     { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , ListView:    { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , MonthCal:    { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Pic:         { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Progress:    { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Radio:       { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Slider:      { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , StatusBar:   { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Tab:         { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Tab2:        { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Tab3:        { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , Text:        { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , TreeView:    { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;    , UpDown:      { X: 0, Y: 0, W: 2, H: 2, F: 0 }
    ;  }

    /**
     * @property {Boolean} DisplayConfig.GuiToggle -
     * Default = true
     * When true, the method `Toggle` is added to `Gui.Prototype`. The function is `GuiToggle`
     * located in lib\Gui.ahk.
     */
    static GuiToggle := true


    ; For the "CallWith_S" options, the function used is `SetThreadDpiAwareness__Call` located in
    ; lib\SetThreadDpiAwareness__Call.ahk. It enables the usage of the "_S" suffix when calling gui
    ; or control methods, e.g. `GuiObj.Move_S`. When called with "_S", the function first sets the
    ; dpi awareness context to DPI_AWARENESS_CONTEXT_DEFAULT, then calls the intended method. For
    ; an explanation of why this is beneficial, see https://www.autohotkey.com/docs/v2/misc/DPIScaling.htm#Workarounds
    /**
     * @property {Boolean} DisplayConfig.GuiCallWith_S - When true, the method `__Call` is added to
     * `Gui.Prototype`.
     */
    static GuiCallWith_S := true

    /**
     * @property {Boolean} DisplayConfig.ControlCallWith_S - When true, the method `__Call` is added
     * to `Gui.Control.Prototype`.
     */
    static ControlCallWith_S := true

    /**
     * @property {Boolean} DisplayConfig.GuiDpi - When true, the dynamic property `Dpi`
     * is added to `Gui.Prototype`. The property will return the value returned by `GetDpiForWindow`
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiforwindow}
     */
    static GuiDpi := true

    /**
     * @property {Boolean} DisplayConfig.ControlDpi - When true, the dynamic property `Dpi`
     * is added to `Gui.Control.Prototype`. The property will return the value returned by `GetDpiForWindow`
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdpiforwindow}
     */
    static ControlDpi := true

}

; Call here or anywhere else in your code
if IsSet(dGui) {
   dGui.Initialize()
}


/*
This is a list of built-in control types
ActiveX
Button
CheckBox
ComboBox
Custom
DateTime
DDL
Edit
GroupBox
Hotkey
Link
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
