; Step 1:
; Copy this document to your project directory / your lib folder, then open the copy and work on that one.

; Step 2:
; Adjust this #include statement to point to the "Display" directory.
#include ..

; Step 3:
; Comment out any files which your project is not going to use. There are no external dependencies.

#include src

#include ControlTextExtent.ahk
#include dComboBoxFilter.ahk
#include dGui.ahk
#include dLv.ahk
#include dMon.ahk
#include Dpi.ahk
#include dTab.ahk
#include Lv.ahk
#include SelectFontIntoDc.ahk
#include Tab.ahk
#include Text.ahk
#include Window.ahk
#include WrapText.ahk

; --------------------
; Step 4:
; Adjust global variables.
; These are some global variables that are intended to be adjusted according to project needs.
; You should #include this project configuration at the top of your script to ensure `Display_SetConstants`
; is called before the auto-execute section reaches your projet code. Or, call `Display_SetConstants`
; directly.
; --------------------
Display_SetConstants(force := false) {
    global
    if IsSet(Display_constants_set) && !force {
        return
    }
    Display_DefaultEncoding := 'cp1200'
    ; The following is required by the library.
    BASE_DPI := DllCall('GetDpiForSystem', 'uint')

    ; The following are used as default values by various functions. You can modify these to fit
    ; the needs of the project.

    /**
     * @var - This is used by src\Dpi.ahk and src\dGui.ahk.
     */
    DPI_AWARENESS_CONTEXT_DEFAULT := -4
    /**
     * @var - This is used by src\dGui.ahk.
     */
    DPI_CHANGED_DPI_AWARENESS_CONTEXT := -4

    /**
     * @description - Defines the initial font size used when creating a `dGui` object.
     *
     * Comment this out if not using src\dGui.ahk.
     *
     * Default = 10
     *
     * @memberof dGui
     * @type {Integer}
     */
    dGui.InitialFontSize := 10

    /**
     * @description - Regarding the built-in dpi change handler, {@link dGui.ResizeByText} specifies
     * which control types are resized using an alternative method. The alternative method ensures that
     * the control's bounding rectangle's edges maintain their size and position relative to the
     * control's text content's bounding rectangle. This is the logic:
     * 1. Measure the control's text content before scaling the font size.
     * 2. Scale the font size.
     * 3. Measure the control's text content again.
     * 4. Adjust the control's height by multiplying its current height by the ratio
     *    `NewTextHeight / OldTextHeight`.
     * 5. Adjust the control's width by multiplying its current width by the ratio
     *    `NewTextWidth / OldTextWidth`.
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
     *
     * Comment this out if not using src\dGui.ahk.
     *
     * Default = `["Button", "Edit", "Link", "StatusBar", "Text"]`
     *
     * @memberof dGui
     * @type {Array|Boolean}
     */
    dGui.ResizeByText := ['Button', 'Edit', 'Link', 'StatusBar', 'Text']

    /**
     * @description - An amount of padding to add to the width of newly created `dGui.Edit`,
     * `dGui.Link`, and `dGui.Text` controls. The padding is only added when both of the following
     * are true:
     * - The "-VScroll" option was not used.
     * - The text content contains one or more "`r`n".
     *
     * Comment this out if not using src\dGui.ahk.
     *
     * Default = 1
     *
     * @memberof dGui
     * @type {Integer}
     */
    dGui.ScrollbarPadding := 1

    ; Comment this out if not using src\dGui.ahk.
    dGui.Initialize()

    /**
     * @description - When true, the monitors are ordered by their relative position. See the
     * parameter hint above {@link dMon.GetOrder} for more information.
     *
     * Comment this out if not using src\dMon.ahk.
     *
     * Default = true
     *
     * @memberof dMon
     * @type {Boolean|Object}
     */
    dMon.UseOrderedMonitors := true

    Display_constants_set := true
}

Display_SetConstants()
