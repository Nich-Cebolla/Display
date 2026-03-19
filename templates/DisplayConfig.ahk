
; Step 1 / 5
; Copy this document to your project directory / your lib folder, then open the copy and work on that one.

; Step 2 / 5
; Adjust this #include statement to point to the "Display" directory.
#include ..

; Step 3 / 5
; Comment out any files which your project is not going to use.

; Internally, most files have an #include statement for its own dependencies, so a file may still
; end up in your project even if you comment it out here. Check the top of each individual file to
; review their dependencies.

; LibraryManager.ahk, Logfont.ahk, and Rect.ahk are exceptions. Though they are required by various
; scripts, no individual file #includes them. This is because these are external libraries that have
; been bundled with this project. If implementing the Display library in an existing project that
; already uses these libraries, you can comment out the #include statement here to avoid a duplicate
; declaration error.

; If using dGui - there's no need to use dLv, dTab, Lv, or Tab because dGui has the same methods
; just in a different package.

; If not using dGui - dLv and Lv offer the same functions; dLv is in written as a class whereas Lv is
; a list of functions. The same applies to dTab and Tab. Use dLv or Lv, but not both. And use dTab
; or Tab, but not both.

#include src
#include ComboBoxFilter.ahk
#include ControlFitText.ahk
#include ControlTextExtent.ahk
#include dGui.ahk
; #include dLv.ahk
#include dMon.ahk
#include Dpi.ahk
; #include dTab.ahk
#include FilterStrings.ahk
#include FontGroup.ahk
; #include Lv.ahk
#include SelectFontIntoDc.ahk
; #include Tab.ahk
#include Text.ahk
#include Window.ahk
#include WrapText.ahk

; https://github.com/Nich-Cebolla/AutoHotkey-Logfont/ - v1.0.2
; Required by src\FontGroup.ahk and src\ControlFitText.ahk
#include Logfont.ahk

; Required
#include lib.ahk
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/LibraryManager.ahk
#include LibraryManager.ahk
; https://github.com/Nich-Cebolla/AutoHotkey-Rect/ - v1.0.1
#include Rect.ahk



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
    ; Comment this out if not using src\dGui.ahk.
    Display_dGui_SetConstants()
    ; Comment this out if not using src\dMon.ahk.
    Display_dMon_SetConstants()
    ; Comment this out if not using src\Window.ahk
    Display_Window_SetConstants()
    ; Comment this out if not using src\Logfont.ahk
    Logfont_SetConstants()

    Rect_SetConstants()

    /**
     * @var {String} - This is used by struct\Display_TcItemW.ahk
     * when getting / setting struct members that are strings. Don't change this unless you have
     * a reason for doing so.
     */
    Display_DefaultEncoding := 'cp1200'

    Display_SetConstants()

    Display_initialized := true
}

; Step 5 / 5
; Call Display_Initialize. Either put the `#include DisplayConfig.ahk` at the top of your code,
; or move this function call somewhere where it's sure to be executed.
Display_Initialize()
