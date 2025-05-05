
; Dependencies
#include ..\definitions
#include Define-Dpi.ahk

#include ..\struct
#include RectBase.ahk
#include RECT.ahk
#include POINT.ahk

#include ..\lib
#include SetThreadDpiAwareness__Call.ahk


/**
 * @class
 * @description - The `Mon` instance object provides an interface for making use of the `Hmon` values.
 * The main consideration for this object is with respect to the `dMon.SetOrder` function. AutoHotkey
 * does not have built-in usage for `Hmon` values, and so making use of `SetOrder` can be a but
 * cumbersome if one needs to retrieve a new buffer object each time. Using a `Mon` instance simplifies
 * the process, creating a disposable object that can be used and let to expire when the calling
 * function returns.
 */
class dMon extends RectBase {

    /**
     * @description
     * @param {Integer} Hmon - The monitor handle.
     * @returns {Mon} - The Mon instance object.
     */
    __New(Hmon) {
        this.Size := 40
        this.Hmon := Hmon
        NumPut('Uint', 40, this)
        if !DllCall('user32\GetMonitorInfo', 'ptr', Hmon, 'ptr', this) {
            throw Error('``GetMonitorInfo`` failed.', -1)
        }
    }

    static __Item[N := 1] {
        Get => this(this.FromIndex(N))
    }


    static __UseOrderedMonitors := false
    static UseOrderedMonitors {
        Get => this.__UseOrderedMonitors
        Set {
            this.__UseOrderedMonitors := Value
            if Value {
                if IsObject(Value) {
                    this.DefineProp('__Item', { Get: this.__Item_Get_Ordered_Params })
                } else {
                    this.DefineProp('__Item', { Get: this.__Item_Get_Ordered_Default })
                }
            } else {
                this.DefineProp('__Item', { Get: this.__Item_Get_NotOrdered })
            }
        }
    }


    ;@region FromDim
    /**
     * Gets the monitor handle using the dimensions of a rectangle.
     * @param {Integer} X - The x-coordinate of the Top-Left corner of the rectangle.
     * @param {Integer} Y - The y-coordinate of the Top-Left corner of the rectangle.
     * @param {Integer} W - The Width of the rectangle.
     * @param {Integer} H - The Height of the rectangle.
     * @returns {Integer} - The Hmon of the monitor to which the rectangle has the largest area
     * of intersection.
     */
    static FromDimensions(X, Y, W, H) => dMon.FromPos(X, Y, x+w, y+h)
    ;@endregion



    ;@region FromIndex
    /**
     * Gets the monitor handle using an index value.
     * @param {Integer} N - This index of the monitor as defined by the system settings.
     * @returns {Integer} - The Hmon of the monitor.
     */
    static FromIndex(N) {
        MonitorGet(N, &L, &T)
        return this.FromPoint(L, T)
    }
    ;@endregion



    ;@region FromMouse
    /**
     * @description - Gets the monitor handle using the position of the mouse pointer.
     * Note that the Dpi_AWARENESS_CONTEXT value impacts the Result of this function. If the mouse
     * is within a monitor that has a different Dpi than the system, the coordinates are adjusted.
     * The AHK `CoordMode` does not influence the value.
     * @param {VarRef} [OutX] - The variable to store the x-coordinate of the mouse pointer
     * @param {VarRef} [OutY] - The variable to store the y-coordinate of the mouse pointer
     * @returns {Integer} - The Hmon of the monitor that contains the mouse pointer.
     */
    static FromMouse(&OutX?, &OutY?) {
        if Result := DllCall('User32.dll\GetCursorPos', 'ptr', PT := Point(), 'int') {
            return DllCall('User32\MonitorFromPoint', 'ptr', PT.Value, 'uint', 0 , 'ptr')
        }
    }
    ;@endregion



    ;@region FromPoint
    /**
     * @description - Gets monitor handle from a coordinate pair.
     * @param {Integer} X - The x-coordinate of the point.
     * @param {Integer} Y - The y-coordinate of the point.
     * @returns {Integer} - The Hmon of the monitor that contains the point.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfrompoint}
     */
    static FromPoint(X, Y){
        return DllCall('User32\MonitorFromPoint', 'ptr', (X & 0xFFFFFFFF) | (Y << 32), 'uint', 0 , 'ptr')
    }
    ;@endregion



    ;@region FromRect
    /**
     * @description - Gets the monitor handle from a `Rect` object.
     * @param {Rect} RectObj - The `Rect` object.
     * @returns {Integer} - The Hmon of the monitor that contains the rectangle.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfromRect}
     */
    static FromRect(RectObj) {
        return DllCall('User32.dll\MonitorFromRect', 'ptr', RectObj, 'UInt', 0, 'Uptr')
    }
    ;@endregion



    ;@region FromPos
    /**
     * @description - Gets the monitor handle using a bounding rectangle.
     * @param {Integer} L - The Left edge of the rectangle.
     * @param {Integer} T - The Top edge of the rectangle.
     * @param {Integer} R - The Right edge of the rectangle.
     * @param {Integer} B - The Bottom edge of the rectangle.
     * @returns {Integer} - The Hmon of the monitor that contains the rectangle.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfromRect}
     */
    static FromPos(L, T, R, B) {
        return DllCall('User32.dll\MonitorFromRect', 'ptr', Rect(L, T, R, B), 'UInt', 0, 'Uptr')
    }
    ;@endregion



    ;@region FromWin
    /**
     * @description - Gets the monitor handle using a windows `Hwnd`.
     * @param {Integer} Hwnd - A window's `Hwnd`.
     * @returns {Integer} - The Hmon of the monitor that contains the window.
     * @see  {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfromwindow}
     */
    static FromWin(Hwnd) {
        return DllCall('User32.dll\MonitorFromWindow', 'ptr', Hwnd, 'UInt', 0x00000000, 'Uptr')
    }
    ;@endregion



    ;@region Dpi
    /**
     * @class
     * @description - Returns the DPI of the monitor using various input types.
     */
    class Dpi {
        static __New() {
            if this.Prototype.__Class == 'dMon.Dpi' {
                this.DefineProp('__Call', { Call: SetThreadDpiAwareness__Call })
            }
        }
        static Call(Hmon, DpiType := MDT_DEFAULT) {
            if !DllCall('Shcore\GetDpiForMonitor', 'ptr', Hmon, 'UInt', DpiType, 'UInt*', &DpiX := 0, 'UInt*', &DpiY := 0, 'UInt') {
                return DpiX
            }
        }
        static Pos(Left, Top, Right, Bottom, DpiType := MDT_DEFAULT) => dMon.Dpi(dMon.FromPos(Left, Top, Right, Bottom), DpiType)
        static Rect(RectObj, DpiType := MDT_DEFAULT) => dMon.Dpi(dMon.FromRect(RectObj), DpiType)
        static Dimensions(X, Y, W, H, DpiType := MDT_DEFAULT) => dMon.Dpi(dMon.FromDimensions(X, Y, W, H), DpiType)
        static Mouse(DpiType := MDT_DEFAULT) => dMon.Dpi(dMon.FromMouse(), DpiType)
        static Point(X, Y, DpiType := MDT_DEFAULT) => dMon.Dpi(dMon.FromPoint(X, Y), DpiType)
        static Win(Hwnd, DpiType := MDT_DEFAULT) => dMon.Dpi(dMon.FromWin(Hwnd), DpiType)
    }
    ;@endregion



    ;@region GetOrder
    /**
     * @description - Orders the display monitors according to the input values. The main benefit of
     * using this function is that it allows one to reference the monitors using a static index value.
     * Typically, when referring to a monitor using `MonitorGet`, the monitor which is referred to
     * by a given index depends on the display settings of the system, which may change if the
     * user adjusts the settings. When writing functions that depend on coordinates relative to an
     * arbitrary monitor, this behavior may or may not be preferable.
     * - Using the system settings' monitor index - At least on Windows 10+, but I believe on 7+
     * as well, we can choose which monitor is "1", "2", "3", etc from Settings > "Display Settings".
     * This changes what monitor is referenced by a given index when calling functions like
     * `MonitorGet`, irrespective of the monitors' position relative to other monitors. With one set
     * of settings, monitor 2 may be at coordinate (-1000, -1200), and later if the user changes
     * the settings, monitor 2 may be at coordinate (1980, -750).
     * - Using `UseOrderedMonitors` and `Mon[Index]` - `GetOrder` constructs an array of Hmon values,
     * ordering them according to the input parameters. Monitors are ordered as a function of their
     * position relative to one another. Example:
     *   - If the user has a three-monitor setup, where one monitor is physically to the left and
     * above the main display, and the third is physically to the right and above the main display,
     * `UseOrderedMonitors` allows your function to refer to a monitor by index where the index will
     * always refer to the main, top-left, or top-right monitor even if the user changes the system
     * settings (as long as monitors' relative positions do not change). This type of behavior
     * may be preferable for some; for others, the native behavior may be preferable.
     * <br><br>
     * Here are some examples to clarify what this function does: <br>
     * Say a user has three monitors, the primary monitor is the laptop display at the bottom, and
     * two external monitors adjacent to one another and above the laptop. When calling window
     * functions that move a window to a position relative to a monitor's boundaries, the function
     * needs a way to consistently refer to the monitors, so each monitor gets an index `1, 2, or 3`.
     * The user prefers the primary monitor to be 1, the left monitor to be 2, and the right monitor
     * to be 3. To accomplish this, call the function without parameters; the defaults will follow
     * this order.
     * @example
     *   ;  ____________
     *   ;  |    ||    |
     *   ;  ------------
     *   ;     ______
     *   ;     |    |
     *   ;     ------
     *   MoveWindowToRightHalf(MonitorIndex, Hwnd) {
     *       ; Get a new list every function call in case the user plugs in / removes a monitor.
     *       List := dMon.GetOrder()
     *       ; Get the `Mon` instance.
     *       MonUnit := Mon(List[MonitorIndex])
     *       ; Move, fitting the window in the right-half of the monitor's work area.
     *       WinMove(MonUnit.MidXW, MonUnit.TW, MonUnit.WW / 2, MonUnit.HW, Hwnd)
     *   }
     * @
     * Perhaps the user has three monitors where one is on top, and beneath it two adjacent monitors,
     * and they want the top monitor to be 1, and the right monitor to be 2, and the left monitor to
     * be 3.
     * @example
     *   ;     ______
     *   ;     |    |
     *   ;     ------
     *   ;  ____________
     *   ;  |    ||    |
     *   ;  ------------
     *   List := dMon.GetOrder('X', L2R := false, T2B := true, OriginIs1 := false)
     * @
     * Many people have a laptop but use an external monitor as their "primary", so it might be
     * more intuitive for them to have their "primary" monitor be referenced by index 1, instead of
     * the built-in display.
     * @example
     *   ; Left-most monitor would be 1. If two monitors both share the lowest X coordinate, the
     *   ; monitor with the lowest Y coordinate between the two would be 1.
     *   List := dMon.GetOrder(, , , OriginIs1 := false)
     * @
     * If your script is going to be frequently referring to a monitor using the ordered Hmon index,
     * you can set `dMon.UseOrderedMonitors` to true and get a new `Mon` instance using item notation
     * and the index. This uses the default values.
     * @example
     *   dMon.UseOrderedMonitors := true
     *   MonUnit := Mon[1] ; The primary monitor
     *   MonUnit := Mon[2] ; The top-left monitor
     * @
     * To use item notation with a different ordering schema, set `UseOrderedMonitors` to
     * an object with one or more properties that have the same name as the parameters you want
     * passed to `GetOrder`.
     * @example
     *   dMon.UseOrderedMonitors := { OriginIs1: false }
     *   MonUnit := Mon[1] ; The top-left monitor
     * @
     * @param {String} [Precedent='X'] - Determines which axis is primarily considered when ordering
     * the monitors. When comparing two monitors, if their positions along the precedent axis are
     * equal, then the alternate axis is compared and used to break the tie. Otherwise, only the
     * precedent axis is used for comparison.
     * - X: Check horizontal first.
     * - Y: Check vertical first.
     * @param {Boolean} [LeftToRight=true] - If true, the monitors are ordered in ascending order
     * along the X axis when the dimension along the X axis is compared.
     * @param {Boolean} [TopToBottom=true] - If true, the monitors are ordered in ascending order
     * along the Y axis when the dimension along the Y axis is compared.
     */
    static GetOrder(Precedent := 'X', LeftToRight := true, TopToBottom := true, OriginIs1 := true) {
        List := []
        Result := []
        loop Result.Capacity := List.Capacity := MonitorGetCount() {
            MonitorGet(A_Index, &L, &T)
            Unit := { L: L, T: T }
            if !L && !T && OriginIs1 {
                Temp := Unit
            } else {
                List.Push(Unit)
            }
        }
        Rect.Order(List, Precedent, LeftToRight, TopToBottom)
        if IsSet(Temp) {
            Result.Push(dMon.FromPoint(Temp.L, Temp.T))
        }
        for Item in List {
            Result.Push(dMon.FromPoint(Item.L, Item.T))
        }
        return Result
    }
    ;@endregion


    /**
     * @description - Enables the usage of two suffixes. To use a suffix, append to any class method
     * call an underscore followed by one or both of the following characters:
     * S - Calls `SetThreadDpiAwarenessContext` with the default value prior to the method call.
     * The value used is `DPI_AWARENESS_CONTEXT_DEFAULT`, a global variable. You can change it at
     * any time.
     * U - Returns a `Mon` instance using the return value from the method call, instead of returning
     * the `Hmon` value.
     * @example
     *  MonUnit := dMon.FromWin_SU(WinGetId('A'))
     *  MsgBox(MonUnit.LW) ; Left side of monitor's work area.
     *  MsgBox(MonUnit.Dpi) ; Dpi of monitor.
     * @
     */
    static __Call(Name, Params) {
        Split := StrSplit(Name, '_')
        if this.HasMethod(Split[1]) {
            if InStr(Split[2], 'S') {
                Result := DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT_DEFAULT, 'ptr')
            }
            if InStr(Split[2], 'U') {
                if Params.Length {
                    return this(this.%Split[1]%(Params*))
                } else {
                    return this(this.%Split[1]%())
                }
            } else {
                if Params.Length {
                    return this(this.%Split[1]%(Params*))
                } else {
                    return this(this.%Split[1]%())
                }
            }
        } else {
            throw PropertyError('Property not found.', -1, Name)
        }
    }


    GetPos(&X?, &Y?, &W?, &H?) {
        X := this.L
        Y := this.T
        W := this.W
        H := this.H
    }
    SplitW(Divisor) => Rect.Split(this.L, this.W, Divisor)
    SplitH(Divisor) => Rect.Split(this.T, this.H, Divisor)

    GetPosW(&X?, &Y?, &W?, &H?) {
        X := this.LW
        Y := this.TW
        W := this.WW
        H := this.HW
    }
    SplitWW(Divisor) => Rect.Split(this.LW, this.WW, Divisor)
    SplitHW(Divisor) => Rect.Split(this.TW, this.HW, Divisor)

    TL => Point(this.L, this.T)
    BR => Point(this.R, this.B)
    L => NumGet(this, 4, 'Int')
    X => NumGet(this, 4, 'Int')
    T => NumGet(this, 8, 'Int')
    Y => NumGet(this, 8, 'Int')
    R => NumGet(this, 12, 'Int')
    B => NumGet(this, 16, 'Int')
    W => this.R - this.L
    H => this.B - this.T
    MidX => (this.R - this.L) / 2
    MidY => (this.B - this.T) / 2
    Primary => NumGet(this, 36, 'Uint')
    TLW => Point(this.LW, this.TW)
    BRW => Point(this.RW, this.BW)
    LW => NumGet(this, 20, 'int')
    XW => NumGet(this, 20, 'Int')
    TW => NumGet(this, 24, 'int')
    YW => NumGet(this, 24, 'Int')
    RW => NumGet(this, 28, 'int')
    BW => NumGet(this, 32, 'int')
    WW => this.RW - this.LW
    HW => this.BW - this.TW
    MidXW => (this.RW - this.LW) / 2
    MidYW => (this.BW - this.TW) / 2
    Dpi => dMon.Dpi(this.Hmon)
    Dpi_Raw => dMon.Dpi(this.Hmon, MDT_RAW_DPI)
    Dpi_Angular => dMon.Dpi(this.Hmon, MDT_ANGULAR_DPI)


    static __Item_Get_NotOrdered(N) {
        return this(this.FromIndex(N))
    }

    static __Item_Get_Ordered_Default(N) {
        return this(this.GetOrder()[N])
    }

    static __GetOrderDefaultParams := { Precedent: 'X', LeftToRight: true, TopToBottom: true, OriginIs1: true}
    static __Item_Get_Ordered_Params(N) {
        ObjSetBase(Params := this.__UseOrderedMonitors, this.__GetOrderDefaultParams)
        return this(this.GetOrder(Params.Precedent, Params.LeftToRight, Params.TopToBottom, Params.OriginIs1)[N])
    }
}

