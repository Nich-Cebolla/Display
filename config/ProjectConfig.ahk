
; For other Gui-related functions that aren't part of this library, check out these:
; Align.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
; GuiResizer.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
; MenuBarConstructor.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MenuBarConstructor.ahk
; FillStr.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FillStr.ahk

/*
   This is a work in progress and will change frequently while I finish it. If you use this
   library in a project, do not use your git clone directory for the project. I will break things
   as I release updates.
*/

; There are 7 steps in this document.

; Step 1:
; Copy this document to your project directory then open the copy and work on that one.

; Step 2:
; Adjust the top #include statements to point to the "Display" directories.
; "#include ..\lib" should be changed to "#include path\to\Display\lib"
; "#include ..\src" should be changed to "#include path\to\Display\src"

; Step 3:
; Comment out any files which your project is not going to use.

#include ..\lib
#include ComboBox.ahk
#include ControlTextExtent.ahk
#include Dpi.ahk
#include SetThreadDpiAwareness__Call.ahk
#include Text.ahk
#include Tab.ahk

#include ..\src
#include dGui.ahk
#include dLv.ahk
#include dMon.ahk
#include dTab.ahk
#include dWin.ahk
#include SelectFontIntoDc.ahk
#include WrapText.ahk
; #include dScrollbar.ahk not working

; Step 4:
; Adjust global variables
; These are some global variables that are intended to be adjusted according to project needs.

/**
 * @var {Integer} MDT_DEFAULT - The default DPI type used by various functions. This is used by
 * "dMon.ahk".
 */
; MDT_DEFAULT := MDT_EFFECTIVE_DPI

/**
 * @var {Integer} DPI_AWARENESS_CONTEXT_DEFAULT - The default DPI awareness context used by
 * various functions. This is used by "Dpi.ahk", "SetThreadDpiAwareness__Call.ahk", "dMon.ahk",
 * and "dWin.ahk".
 */
; DPI_AWARENESS_CONTEXT_DEFAULT := DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2

/**
 * @var {Integer} DPI_CHANGED_DPI_AWARENESS_CONTEXT - The DPI awareness context used by the built-in
 * `WM_DPICHANGED` handler. This is used by "dGui.ahk".
 */
; DPI_CHANGED_DPI_AWARENESS_CONTEXT := DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2


; Step 5:
; Selecting "dMon.ahk" options
; If you are not using "dMon.ahk", skip this step.

/**
 * @property {Boolean} dMon.UseOrderedMonitors - When true, the monitors are ordered by their
 * coordinates. See the parameter hint above {@link dMon.GetOrder} for more information. Leave
 * commented out if not using "dMon.ahk".
 * You can also set `dMon.UseOrderedMonitors` with an object with property : value pairs, where
 * the properties are names of the `dMon.GetOrder` parameters, to adjust what parameters are used
 * when getting a `dMon` object with `dMon[index]` notation.
 */
; dMon.UseOrderedMonitors := true

; Step 6:
; Selecting "dGui.ahk" options
; If you are not using "dGui.ahk", skip steps 6 and 7.

 /**
  * @property {Boolean|Array} dGui.ControlIncludeByDefault -
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
; dGui.ControlIncludeByDefault := true

 /**
  * @property {Array|Boolean} dGui.ResizeByText -
  * Default = ['Button', 'Edit', 'Link', 'StatusBar', 'Text']
  *
  * Regarding the built-in dpi change handler, `DisplayConfig.ResizeByText` specifies which control
  * types are resized using the function `ControlResizeByText`. For controls not included in this
  * list, they will be resized using `ControlResizeByDpiRatio`. To set all controls to be resized
  * using `ControlResizeByDpiRatio`, set this to `false`.
  *
  * Using this option requires that `DisplayConfig.GetTextExtent == true`.
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
  * The following control types are currently incompatible with `ControlResizeByText`: ActiveX,
  * Custom, ListBox, ListView, MonthCal, Pic, Progress, Slider, TreeView, UpDown.
  */
; dGui.ResizeByText := ['Button', 'Edit', 'Link', 'StatusBar', 'Text']

 /**
  * @property {Array|Boolean} dGui.InitialFontSize -
  * Defines the initial font size used when creating a `dGui` object.
  */
; dGui.InitialFontSize := 10

; Step 7:
; Call dGui.Initialize()
; If you are not using "dGui.ahk', skip this step. Call here or anywhere else in your code. If calling
; `dGui.Initialize()` in your external code, ensure it is somewhere after the `#include ProjectConfig.ahk`
; statement. You can call `dGui.Initialize()` again at any time to adjust any options on-the-fly.
; dGui.Initialize()




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
