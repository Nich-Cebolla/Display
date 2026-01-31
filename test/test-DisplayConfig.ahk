; Step 1:
; Copy this document to your project directory / your lib folder, then open the copy and work on that one.

; Step 2:
; Adjust this #include statement to point to the "Display" directory.
#include ..

#include src\core
#include lib.ahk

; Step 3:
; Comment out any files which your project is not going to use. There are no external dependencies.

#include ..\

#include ControlTextExtent.ahk
#include ComboBoxFilter.ahk
#include dGui.ahk
#include ControlFitText.ahk
; #include dLv.ahk
#include dMon.ahk
#include Dpi.ahk
; #include dTab.ahk
; #include Lv.ahk
#include SelectFontIntoDc.ahk
; #include Tab.ahk
#include Text.ahk
#include Window.ahk
#include WrapText.ahk

; --------------------
; Step 4:
; Adjust global variables.
; These are some global variables that are intended to be adjusted according to project needs.
; You should #include this project configuration at the top of your script to ensure `Display_Initialize`
; is called before the auto-execute section reaches your projet code. Or, call `Display_Initialize`
; directly.
; --------------------
Display_Initialize(force := false) {
    global
    if IsSet(Display_initialized) && !force {
        return
    }
    Display_DefaultEncoding := 'cp1200'
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
     * @description - Defines the initial font size used when creating a {@link dGui} object.
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
     * @description - An amount of padding to add to the width of newly created `dGui.Edit`,
     * `dGui.Link`, and `dGui.Text` controls. The padding is only added when both of the following
     * are true:
     * - The "-VScroll" option was not used.
     * - The text content contains one or more "`r`n" (CRLF).
     *
     * Comment this out if not using src\dGui.ahk.
     *
     * Default = 1
     *
     * @memberof dGui
     * @type {Integer}
     */
    dGui.ScrollbarPadding := 1

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

    Display_initialized := true
}

Display_Initialize()
