
; Step 1:
; Copy this document to your project directory / your lib folder, then open the copy and work on that one.

; Step 2:
; Adjust this #include statement to point to the "Display" directory.
#include ..

; Step 3:
; Comment out any files which your project is not going to use. Internally, each file has an #include
; statement for its own dependencies, so a file may still end up in your project even if you
; comment it out here. Check the top of each individual file to review their dependencies.

#include src
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

; Required
#include lib.ahk
#include LibraryManager.ahk

; --------------------
; Step 4:
; Adjust options.
; These are some options that are intended to be adjusted according to project needs.
; --------------------
Display_Initialize(force := false) {
    global
    if IsSet(Display_initialized) && !force {
        return
    }

    /**
     * @var {Integer} - This is used by src\dGui.ahk, but it can be helpful in other cases.
     */
    BASE_DPI := DllCall('GetDpiForSystem', 'uint')

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

    ; Comment this out if not using src\Dpi.ahk.
    Display_Dpi_SetConstants()

    /**
     * @var {String} - This is used by struct\Display_TcItemW.ahk and struct\Display_Logfont.ahk
     * when getting / setting struct members that are strings. Don't change this unless you have
     * a clear reason for doing so.
     */
    Display_DefaultEncoding := 'cp1200'

    Display_initialized := true
}

; Step 5
; Call Display_Initialize. Either put the `#include DisplayConfig.ahk` at the top of your code,
; or move this function call somewhere when it's sure to be executed.
Display_Initialize()
