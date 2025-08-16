
; For other Gui-related functions that aren't part of this library, check out these:
; Align.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
; GuiResizer.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
; MenuBarConstructor.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MenuBarConstructor.ahk
; FillStr.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FillStr.ahk

/*
   This is a work in progress and will change frequently while I finish it. If you use this
   library in a project, do not use your git clone directory for the project. I will break things
   as I release updates. I recommend these steps for using the repo:

   - Clone the repo: `git clone https://github.com/Nich-Cebolla/Display`

   - Make a copy of the directory

   - Prepare a copy of this configuration template to place in your lib folder
   (see https://www.autohotkey.com/docs/v2/Scripts.htm#lib)
   By having this configuration file in your lib folder, whenever you want to use this
   in one of your scripts, you can simply write `#include <DisplayConfig>` (assuming you named the
   file "DisplayConfig.ahk". This is convenient for testing and development, and for quick personal
   scripts where optimization isn't a concern. But for production code or code one intends to share,
   it would be best to to create a dedicated configuration file for the project and keep that in the
   project directory.

   - When you pull updates to the repository, before copying those updates you should test any scripts
   that use "Display" to see if an update breaks the script. I'm pretty close to calling this project
   "done"; when I release this officially breaking changes will be rare and when they occur I will
   include migration instructions.
*/

; *************************************************************************************************
; There are 8 steps to prepare your configuation file.

; Step 1:
; Copy this document to your project directory then open the copy and work on that one.

; Step 2:
; Adjust the top #include statement to point to the "Display" directory.

; Step 3:
; Comment out any files which your project is not going to use.
; --------------------


#include ..     ; adjust this statement to point to the "Display" directory

#include lib
#include ComboBox.ahk
#include ControlTextExtent.ahk  ; Requires IntegerArray.ahk
#include Dpi.ahk
#include FilterWords.ahk
#include Tab.ahk                ; Requires Rect.ahk
#include Text.ahk               ; Requires IntegerArray.ahk

#include ..\src
#include ControlFitText.ahk     ; Requires Logfont.ahk
#include dGui.ahk               ; Requires Rect.ahk
#include dLv.ahk
#include dMon.ahk               ; Requires Rect.ahk
#include dTab.ahk               ; Requires Rect.ahk
#include dWin.ahk               ; Requires Rect.ahk
#include SelectFontIntoDc.ahk
#include WrapText.ahk

; --------------------
; Step 4:
; (This step only needs to be completed once)
; If you are using any files which require an external library as indicated above,
; clone the needed library/libraries. You then need to create a file in your lib folder
; (https://www.autohotkey.com/docs/v2/Scripts.htm#lib)
; that has an #include statement that points to the local copy of the script(s). This allows you to
; use that script in any project using the `#include <FileName>` syntax without filling up your
; lib folder with a bunch of README documents and other secondary documents that are typically
; included in Github repositories. This also has the benefit of not needing to update multiple
; local copies when pulling updates.
;
; IntegerArray.ahk: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/IntegerArray.ahk
; Logfont.ahk: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/Logfont.ahk
; Rect.ahk: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/Rect.ahk
;
; If you would prefer not to use the lib folder, run the file "config\ExternalLibraryDownloader.ahk"

; Step 5:
; Adjust global variables.
; These are some global variables that are intended to be adjusted according to project needs.
; --------------------

/**
 * @var {Integer} MDT_DEFAULT - The default DPI type used by various functions. This is used by
 * "dMon.ahk". To learn how it affects the functions which use it, refer to this page:
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/ne-shellscalingapi-monitor_dpi_type}.
 */
; MDT_DEFAULT := MDT_EFFECTIVE_DPI

/**
 * @var {Integer} DPI_AWARENESS_CONTEXT_DEFAULT - The default DPI awareness context used by
 * various functions. This is used by "Dpi.ahk", "MetaSetThreadDpiAwareness.ahk", "dMon.ahk",
 * and "dWin.ahk". To learn how it affects the functions which use it, refer to this page:
 * {@link https://learn.microsoft.com/en-us/windows/win32/hidpi/dpi-awareness-context}.
 */
; DPI_AWARENESS_CONTEXT_DEFAULT := DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2

/**
 * @var {Integer} DPI_CHANGED_DPI_AWARENESS_CONTEXT - The DPI awareness context used by the built-in
 * `WM_DPICHANGED` handler. This is used by "dGui.ahk".
 */
; DPI_CHANGED_DPI_AWARENESS_CONTEXT := DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2

; --------------------
; Step 6:
; Select "dMon.ahk" options.
; If you are not using "dMon.ahk", skip this step.
; --------------------

/**
 * @property {Boolean} dMon.UseOrderedMonitors - When true, the monitors are ordered by their
 * coordinates. See the parameter hint above {@link dMon.GetOrder} for more information. Leave
 * commented out if not using "dMon.ahk".
 * You can also set `dMon.UseOrderedMonitors` with an object with property : value pairs, where
 * the properties are names of the `dMon.GetOrder` parameters, to adjust what parameters are used
 * when getting a `dMon` object with `dMon[index]` notation.
 */
; dMon.UseOrderedMonitors := true

; --------------------
; Step 6:
; Select "dGui.ahk" options.
; If you are not using "dGui.ahk", skip steps 6 and 7.
; --------------------

/**
 * @property {Integer} dGui.ScrollbarPadding -
 * Default = 1
 * An amount of padding to add to the width of newly created `dGui.Edit`, `dGui.Link`, and `dGui.Text`
 * controls. The padding is also used by `GetControlTextExtentPadding`. The padding is only added
 * when both of the following are true:
 * - The "-VScroll" option was not used.
 * - The text content contains one or more "`r`n".
 */
; dGui.ScrollbarPadding := 1

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
  * types are resized using the change in font size. This is the logic:
  * 1. Measure the control's text content before scaling the font size.
  * 2. Scale the font size.
  * 3. Measure the control's text content again.
  * 4. Adjust the control's height by multiplying its current height by the ratio
  * `NewTextHeight / OldTextHeight`.
  * 5. Adjust the control's width by multiplying its current width by the ratio
  * `NewTextWidth / OldTextWidth`.
  *
  * Resizing controls with the above logic preserves the relative position of the control's text
  * content to the control's borders, maintaining a more consistent appearance when the moving
  * the window into a different dpi context.
  *
  * There are some considerations to keep in mind:
  * - If the control's text content is empty, then the process would evaluate no change in text
  * size because the size is 0x0. The built-in handler will default back to scaling the control
  * by dpi ratio, but this carries the risk of presenting an inconistent experience for the user.
  * - If the controls around the control are being resized by dpi ratio, then the relative positions
  * shared by the controls might change, causing an inconsistent display.
  *
  * The best approach to handling dpi changes is to write a handler function specific to the indidual
  * ui. The built-in handler is not an ideal solution
  *
  * the function `ControlResizeByText`. For controls not included in this
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

; --------------------
; Step 7:
; Call dGui.Initialize().
; If you are not using "dGui.ahk', skip this step. Call here or anywhere else in your code. If calling
; `dGui.Initialize()` in your external code, ensure it is somewhere after the `#include ProjectConfig.ahk`
; statement. You can call `dGui.Initialize()` again at any time to adjust any options on-the-fly.
; --------------------

; dGui.Initialize()

; *************************************************************************************************




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

