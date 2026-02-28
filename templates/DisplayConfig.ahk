
; Step 1 / 5
; Copy this document to your project directory / your lib folder, then open the copy and work on that one.

; Step 2 / 5
; Adjust this #include statement to point to the "Display" directory.
#include ..

; Step 3 / 5
; Comment out any files which your project is not going to use. Internally, each file has an #include
; statement for its own dependencies, so a file may still end up in your project even if you
; comment it out here. Check the top of each individual file to review their dependencies.
; LibraryManager.ahk is an exception; though it is required, no individual file #includes it.
; If using dGui - there's no need to use dLv, dTab, Lv, or Tab because dGui has the same methods
; just in a different package.
; If not using dGui - dLv and Lv offer the same functions; dLv is in written as a class whereas Lv is
; a list of functions. The same applies to dTab and Tab. Use dLv or Lv, but not both. And use dTab
; or Tab, but not both.

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

; Step 4 / 5
; Adjust options.
; These are some options that are intended to be adjusted according to project needs.
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

; Step 5 / 5
; Call Display_Initialize. Either put the `#include DisplayConfig.ahk` at the top of your code,
; or move this function call somewhere where it's sure to be executed.
Display_Initialize()
