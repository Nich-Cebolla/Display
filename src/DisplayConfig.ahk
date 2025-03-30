
#Include Display_Define.ahk
#Include Display_DefaultConfig.ahk
#Include Display_SetThreadDpiAwareness__Call.ahk
#Include Display_Win.ahk
#Include Display_Gui.ahk
#Include Display_Helper.ahk
#Include Display_Mon.ahk
#Include Display_Point.ahk
#Include Display_Rect.ahk
#Include Display_Lib.ahk

; Call here or anywhere else in your code.
GuiH.Initialize()

; For other Gui-related functions that aren't part of this library, check out these:
; Align.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
; GuiResizer.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
; MenuBarConstructor.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MenuBarConstructor.ahk
; FillStr.ahk - https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FillStr.ahk



/**
 * @var {Integer} DPI_AWARENESS_CONTEXT_DEFAULT - The default DPI awareness context used by
 * various functions.
 */
DPI_AWARENESS_CONTEXT_DEFAULT := DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 ?? -4

/**
 * @var {Integer} MDT_DEFAULT - The default DPI type used by various functions.
 */
MDT_DEFAULT := MDT_EFFECTIVE_DPI ?? 0

/**
 * @property {Boolean} Mon.UseOrderedMonitors - When true, the monitors are ordered by their
 * coordinates. See the parameter hint above `Mon.GetOrder` for more information.
 */
if IsSet(Mon) {
    Mon.UseOrderedMonitors := false
}


/**
 * @class
 * @description - The configuration object for the `Display` library, primarily containing
 * configuration items for `GuiH` and functions which handle `WM_DPICHANGED` messages.
 * Properties marked "**Required**" must use the default value to use the built-in WM_DPICHANGED
 * handlers.
 */
class DisplayConfig {

    /**
     * @property {Boolean|Array} DisplayConfig.NewControlSetFont - **Required** <br>
     * Controls which `Gui.Control` types have the `SetFont` method overridden. If false,
     * all control types have their `SetFont` method overridden. If an array, all control
     * types except those listed will have their `SetFont` method overridden. If true, no
     * control types have their `SetFont` method overridden.
     */
    static ExcludeNewControlSetFont := false


    /**
     * @property {Boolean} DisplayConfig.NewGuiSetFont - **Required** <br>
     * Controls whether `Gui.Prototype.SetFont` is overridden.
     */
    static NewGuiSetFont := true

    /**
     * @property {Boolean} DisplayConfig.NewGuiCall - **Required** <br>
     * Controls whether `Gui.Call` is overridden.
     */
    static NewGuiCall := true

    /**
     * @property {Boolean} DisplayConfig.NewGuiAdd - **Required** <br>
     * Controls whether `Gui.Prototype.Add` is overridden.
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
     * processing. This is implemented by creating a `Gui.Control.Prototype.DpiExclude` property for
     * the control type. You can change the value of the property at any any time for any control
     * prototype to toggle the behavior.
     * @example
        ; I want to custom handle dpi scaling for ListView controls, so I do not want the built-in
        ; handler to process them.
        DisplayConfig.DpiExcludeControls := ['ListView']
        ; or
        Gui.ListView.Prototype.DpiExclude := true
     * @
     * You can also set this on an individual control.
     * @example
        G := Gui('-DPIScale +Resize')
        MainEdit := G.Add('Edit', 'w800 r50 vmain')
        MainEdit.DpiExclude := true
     * @
     */
    static DpiExcludeControls := false

    /**
     * @property {Boolean} DisplayConfig.DefaultExcludeGui - When true, the property
     * `Gui.Prototype.DpiExclude` is set to true, causing all `GUI_HANDLEDPICHANGE` function calls
     * to return immediately. Gui windows must be opted-in by setting it to false.
     */
    static DefaultExcludeGui := false

    static SetGetTextExtent() {
        M := this.GetTextExtent := Map()
        M.CaseSense := false
        M.Default := ''
        M.Set(
            'Link', GUI_CONTROL_TEXTEXTENT_LINK
          , 'ListBox', GUI_CONTROL_TEXTEXTENT_MULTI
          , 'ListView', GUI_CONTROL_TEXTEXTENT_LISTVIEW
          , 'TreeView', GUI_CONTROL_TEXTEXTENT_INDEX
          , 'Button', GUI_CONTROL_TEXTEXTENT_TEXT
          , 'CheckBox', GUI_CONTROL_TEXTEXTENT_TEXT
          , 'ComboBox', GUI_CONTROL_TEXTEXTENT_TEXT
          , 'DDl', GUI_CONTROL_TEXTEXTENT_TEXT
          , 'Edit', GUI_CONTROL_TEXTEXTENT_TEXT
          , 'GroupBox', GUI_CONTROL_TEXTEXTENT_TEXT
          , 'Radio', GUI_CONTROL_TEXTEXTENT_TEXT
          , 'StatusBar', GUI_CONTROL_TEXTEXTENT_TEXT
          , 'Tab', GUI_CONTROL_TEXTEXTENT_TEXT
          , 'Text', GUI_CONTROL_TEXTEXTENT_TEXT
        )
    }
    /**
     * @property {Map} DisplayConfig.GetTextExtent - Controls what function is called by each
     * control type's `GetTextExtent` method. There are currently only the options you see above.
     */
    static GetTextExtent := this.SetGetTextExtent()

    /**
     * @property {Array} DisplayConfig.ResizeByText - Controls what which control types are resized
     * using the function `GUI_CONTROL_RESIZE_BY_TEXT`. For controls not included in this list,
     * they will be resized using `GuiH.ControlDpiChangeHelper.Prototype.Adjust`.
     */
    ; static ResizeByText := ['Button', 'CheckBox', 'ComboBox', 'DDl', 'Edit', 'GroupBox', 'Radio'
    ;     , 'StatusBar', 'Tab', 'Text']

    static ResizeByText := false
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
