
#include ..\struct
#include Display_Point.ahk
#include Display_Rect.ahk

/**
 * @classdesc - `dMon` contains several functions for getting a monitor's handle. The `dMon`
 * instance objects are intended to be disposable objects that retrieve the details from "GetMonitorInfo"
 * and that expose methods and properties that simplify usage of that information.
 */
class dMon {
    static __New() {
        this.DeleteProp('__New')
        if !this.HasOwnProp('__UseOrderedMonitors') {
            this.UseOrderedMonitors := true
        }
    }
    /**
     * @description - Returns a {@link dMon} object using the dimensions of a rectangle.
     * @param {Integer} X - The x-coordinate of the Top-Left corner of the rectangle.
     * @param {Integer} Y - The y-coordinate of the Top-Left corner of the rectangle.
     * @param {Integer} W - The Width of the rectangle.
     * @param {Integer} H - The Height of the rectangle.
     * @returns {dMon} - The {@link dMon} of the monitor that shares the largest area of intersection
     * with the rectangle.
     */
    static FromDimensions(X, Y, W, H) => this(this.FromPos(X, Y, x+w, y+h))
    /**
     * @description - Gets the monitor handle using the dimensions of a rectangle.
     * @param {Integer} X - The x-coordinate of the Top-Left corner of the rectangle.
     * @param {Integer} Y - The y-coordinate of the Top-Left corner of the rectangle.
     * @param {Integer} W - The Width of the rectangle.
     * @param {Integer} H - The Height of the rectangle.
     * @returns {Integer} - The handle of the monitor that shares the largest area of intersection
     * with the rectangle.
     */
    static FromDimensionsH(X, Y, W, H) => this.FromPos(X, Y, x+w, y+h)
    /**
     * @description - Returns a {@link dMon} object using the monitor number assigned by the operating
     * system.
     * @param {Integer} N - The monitor number.
     * @returns {dMon}
     */
    static FromIndex(N) {
        MonitorGet(N, &L, &T)
        return this(this.FromPoint(L, T))
    }
    /**
     * @description - Gets the monitor handle using the monitor number assigned by the operating
     * system.
     * @param {Integer} N - The monitor number.
     * @returns {Integer} - The monitor handle.
     */
    static FromIndexH(N) {
        MonitorGet(N, &L, &T)
        return this.FromPoint(L, T)
    }
    /**
     * @description - Returns a {@link dMon} object using the position of the mouse pointer.
     * Note that the dpi awareness context value impacts the Result of this function. If the mouse
     * is within a monitor that has a different Dpi than the system, the coordinates are adjusted.
     * The AHK `CoordMode` does not influence the value.
     * @param {VarRef} [OutX] - The variable to store the x-coordinate of the mouse pointer
     * @param {VarRef} [OutY] - The variable to store the y-coordinate of the mouse pointer
     * @returns {dMon} - The {@link dMon} for the monitor that contains the mouse pointer.
     */
    static FromMouse(&OutX?, &OutY?) {
        if Result := DllCall('GetCursorPos', 'ptr', Pt := Display_Point(), 'int') {
            OutX := Pt.X
            OutY := Pt.Y
            return this(DllCall('MonitorFromPoint', 'ptr', Pt.Value, 'uint', 0 , 'ptr'))
        }
    }
    /**
     * @description - Gets the monitor handle using the position of the mouse pointer.
     * Note that the dpi awareness context value impacts the Result of this function. If the mouse
     * is within a monitor that has a different Dpi than the system, the coordinates are adjusted.
     * The AHK `CoordMode` does not influence the value.
     * @param {VarRef} [OutX] - The variable to store the x-coordinate of the mouse pointer
     * @param {VarRef} [OutY] - The variable to store the y-coordinate of the mouse pointer
     * @returns {Integer} - The handle of the monitor that contains the mouse pointer.
     */
    static FromMouseH(&OutX?, &OutY?) {
        if Result := DllCall('GetCursorPos', 'ptr', Pt := Display_Point(), 'int') {
            OutX := Pt.X
            OutY := Pt.Y
            return DllCall('MonitorFromPoint', 'ptr', Pt.Value, 'uint', 0 , 'ptr')
        }
    }
    /**
     * @description - Returns a {@link dMon} object using coordinate pair.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfrompoint}
     * @param {Integer} X - The x-coordinate of the point.
     * @param {Integer} Y - The y-coordinate of the point.
     * @returns {dMon} - The {@link dMon} for the monitor that contains the point.
     */
    static FromPoint(X, Y){
        return this(DllCall('MonitorFromPoint', 'ptr', (X & 0xFFFFFFFF) | (Y << 32), 'uint', 0 , 'ptr'))
    }
    /**
     * @description - Gets monitor handle from a coordinate pair.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfrompoint}
     * @param {Integer} X - The x-coordinate of the point.
     * @param {Integer} Y - The y-coordinate of the point.
     * @returns {Integer} - The handle of the monitor that contains the point.
     */
    static FromPointH(X, Y){
        return DllCall('MonitorFromPoint', 'ptr', (X & 0xFFFFFFFF) | (Y << 32), 'uint', 0 , 'ptr')
    }
    /**
     * @description - Returns a {@link dMon} object using a bounding rectangle.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfromRect}
     * @param {Integer} L - The Left edge of the rectangle.
     * @param {Integer} T - The Top edge of the rectangle.
     * @param {Integer} R - The Right edge of the rectangle.
     * @param {Integer} B - The Bottom edge of the rectangle.
     * @returns {dMon} - The {@link dMon} of the monitor that shares the largest area of intersection
     * with the rectangle.
     */
    static FromPos(L, T, R, B) {
        return DllCall('MonitorFromRect', 'ptr', Display_Rect(L, T, R, B), 'UInt', 0, 'Uptr')
    }
    /**
     * @description - Gets the monitor handle using a bounding rectangle.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfromRect}
     * @param {Integer} L - The Left edge of the rectangle.
     * @param {Integer} T - The Top edge of the rectangle.
     * @param {Integer} R - The Right edge of the rectangle.
     * @param {Integer} B - The Bottom edge of the rectangle.
     * @returns {Integer} - The handle of the monitor that shares the largest area of intersection
     * with the rectangle.
     */
    static FromPosH(L, T, R, B) {
        return DllCall('MonitorFromRect', 'ptr', Display_Rect(L, T, R, B), 'UInt', 0, 'Uptr')
    }
    /**
     * @description - Returns a {@link dMon} object using a {@link Display_Rect} object.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfromRect}
     * @param {Display_Rect} RectObj - The {@link Display_Rect} object.
     * @returns {dMon} - The {@link dMon} of the monitor that shares the largest area of intersection
     * with the rectangle.
     */
    static FromRect(RectObj) {
        return this(DllCall('MonitorFromRect', 'ptr', RectObj, 'UInt', 0, 'Uptr'))
    }
    /**
     * @description - Gets the monitor handle using a {@link Display_Rect} object.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfromRect}
     * @param {Display_Rect} RectObj - The {@link Display_Rect} object.
     * @returns {Integer} - The handle of the monitor that shares the largest area of intersection
     * with the rectangle.
     */
    static FromRectH(RectObj) {
        return DllCall('MonitorFromRect', 'ptr', RectObj, 'UInt', 0, 'Uptr')
    }
    /**
     * @description - Returns a {@link dMon} object using a window handle.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfromwindow}
     * @param {Integer} Hwnd - The window handle.
     * @returns {dMon} - The {@link dMon} for the monitor that shares the largest area of intersection
     * with the window.
     */
    static FromWin(Hwnd) {
        return this(DllCall('MonitorFromWindow', 'ptr', Hwnd, 'UInt', 0x00000000, 'Uptr'))
    }
    /**
     * @description - Gets the monitor handle using a window handle.
     * @see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfromwindow}
     * @param {Integer} Hwnd - The window handle.
     * @returns {Integer} - The handle of the monitor that shares the largest area of intersection
     * with the window.
     */
    static FromWinH(Hwnd) {
        return DllCall('MonitorFromWindow', 'ptr', Hwnd, 'UInt', 0x00000000, 'Uptr')
    }
    /**
     * @description - Returns a {@link dMon} object.
     * @param {Integer} [N = 1] - The monitor number as assigned by the operating system.
     * @returns {dMon}
     */
    static Get(N := 1, *) {
        return this.FromIndex(N)
    }
    /**
     * @description - Returns an integer representing 1 pixel to the right of the right-most edge
     * of all displays.
     * @returns {Integer}
     */
    static GetNonvisiblePosition() {
        r := 0
        loop MonitorGetCount() {
            MonitorGet(, , &_r)
            r := Max(r, _r)
        }
        return r + 1
    }
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
     * - Using `UseOrderedMonitors` and `dMon[Index]` - `GetOrder` constructs an array of {@link dMon}
     * objects, ordering them according to the input parameters. Monitors are ordered as a function of
     * their position relative to one another. Example:
     *   - If the user has a three-monitor setup, where one monitor is physically to the left and
     * above the main display, and the third is physically to the right and above the main display,
     * `UseOrderedMonitors` allows your function to refer to a monitor by index where the index will
     * always refer to the main, top-left, or top-right monitor even if the user changes the system
     * settings (as long as monitors' relative positions do not change). This type of behavior
     * may be preferable for some; for others, the native behavior may be preferable.
     *
     * Here are some examples to clarify what this function does:
     *
     * Say a user has three monitors, the primary monitor is the laptop display at the bottom, and
     * two external monitors adjacent to one another and above the laptop. When calling window
     * functions that move a window to a position relative to a monitor's boundaries, the function
     * needs a way to consistently refer to the monitors, so each monitor gets an index `1, 2, or 3`.
     * The user prefers the primary monitor to be 1, the left monitor to be 2, and the right monitor
     * to be 3. To accomplish this, call the function without parameters; the defaults will follow
     * this order.
     *
     * @example
     * ;  ____________
     * ;  |    ||    |
     * ;  ------------
     * ;     ______
     * ;     |    |
     * ;     ------
     * MoveWindowToRightHalf(MonitorIndex, Hwnd) {
     *     ; Get a new list every function call in case the user plugs in / removes a monitor.
     *     List := dMon.GetOrder()
     *     ; Get the `dMon` instance.
     *     MonUnit := List[MonitorIndex]
     *     ; Move, fitting the window in the right-half of the monitor's work area.
     *     WinMove(MonUnit.MidXW, MonUnit.TW, MonUnit.WW / 2, MonUnit.HW, Hwnd)
     * }
     * @
     *
     * Perhaps the user has three monitors where one is on top, and beneath it two adjacent monitors,
     * and they want the top monitor to be 1, and the right monitor to be 2, and the left monitor to
     * be 3.
     *
     * @example
     * ;     ______
     * ;     |    |
     * ;     ------
     * ;  ____________
     * ;  |    ||    |
     * ;  ------------
     * List := dMon.GetOrder('X', L2R := false, T2B := true, OriginIs1 := false)
     * @
     *
     * Many people have a laptop but use an external monitor as their "primary", so it might be
     * more intuitive for them to have their "primary" monitor be referenced by index 1, instead of
     * the built-in display.
     *
     * @example
     * ; Left-most monitor would be 1. If two monitors both share the lowest X coordinate, the
     * ; monitor with the lowest Y coordinate between the two would be 1.
     * List := dMon.GetOrder(, , , OriginIs1 := false)
     * @
     *
     * If your script is going to be frequently referring to a monitor using the ordered Hmon index,
     * you can set {@link dMon.UseOrderedMonitors} to true and get a new `dMon` instance using item notation
     * and the index. This uses the default values.
     *
     * @example
     * dMon.UseOrderedMonitors := true
     * MonUnit := dMon[1] ; The primary monitor
     * MonUnit := dMon[2] ; The top-left monitor
     * @
     *
     * To use item notation with a different ordering schema, set `UseOrderedMonitors` to
     * an object with one or more properties that have the same name as the parameters you want
     * passed to `GetOrder`.
     *
     * @example
     * dMon.UseOrderedMonitors := { OriginIs1: false }
     * MonUnit := dMon[1] ; The top-left monitor
     * @
     *
     * @param {String} [Primary = 'X'] - Determines which axis is primarily considered when ordering
     * the monitors. When comparing two monitors, if their positions along the Primary axis are
     * equal, then the alternate axis is compared and used to break the tie. Otherwise, only the
     * Primary axis is used for comparison.
     * - X: Check horizontal first.
     * - Y: Check vertical first.
     * @param {Boolean} [LeftToRight = true] - If true, the monitors are ordered in ascending order
     * along the X axis when the dimension along the X axis is compared.
     * @param {Boolean} [TopToBottom = true] - If true, the monitors are ordered in ascending order
     * along the Y axis when the dimension along the Y axis is compared.
     * @returns {dMon[]}
     */
    static GetOrder(Primary := 'X', LeftToRight := true, TopToBottom := true, OriginIs1 := true) {
        Result := []
        constructor := this.FromPoint.Bind(this)
        if OriginIs1 {
            List := []
            loop Result.Capacity := List.Capacity := MonitorGetCount() {
                MonitorGet(A_Index, &L, &T)
                if !L && !T {
                    Result.Push(constructor(L, T))
                } else {
                    List.Push(constructor(L, T))
                }
            }
            Display_OrderRects(List, Primary, LeftToRight, TopToBottom)
            Result.Push(List*)
        } else {
            loop Result.Capacity := MonitorGetCount() {
                MonitorGet(A_Index, &L, &T)
                Result.Push(constructor(L, T))
            }
            Display_OrderRects(Result, Primary, LeftToRight, TopToBottom)
        }
        return Result
    }
    static __Enum(*) {
        i := 0
        n := MonitorGetCount()
        return _Enum

        _Enum(&Mon) {
            if ++i > n {
                return 0
            }
            Mon := dMon[i]
            return 1
        }
    }
    /**
     * @description - Returns a {@link dMon} object.
     * @param {Integer} [N = 1] - The monitor number as defined by the relative position. See
     * {@link dMon.GetOrder} for more information.
     * @returns {dMon}
     */
    static GetOrdered(N := 1, *) {
        return this.GetOrder()[N]
    }
    static __GetOrdered(N := 1, *) {
        Params := this.__UseOrderedMonitors
        return this(this.GetOrder(
            HasProp(Params, 'Primary') ? Params.Primary : unset
          , HasProp(Params, 'LeftToRight') ? Params.LeftToRight : unset
          , HasProp(Params, 'TopToBottom') ? Params.TopToBottom : unset
          , HasProp(Params, 'OriginIs1') ? Params.OriginIs1 : unset
        )[N])
    }

    static UseOrderedMonitors {
        Get => this.__UseOrderedMonitors
        Set {
            this.__UseOrderedMonitors := Value
            if Value {
                if IsObject(Value) {
                    this.DefineProp('__Item', { Get: this.__GetOrdered })
                } else {
                    this.DefineProp('__Item', { Get: this.GetOrdered })
                }
            } else {
                this.DefineProp('__Item', { Get: this.Get })
            }
        }
    }
    /**
     * @description - {@link dMon.__Item} is defined when {@link dMon.UseOrderedMonitors} is set.
     * When {@link dMon.__New} executes, {@link dMon.UseOrderedMonitors} is set as `true`. You can
     * adjust this at any time.
     *
     * Set {@link dMon.UseOrderedMonitors} to `true` to cause `dMon[index]` notation to return
     * a {@link dMon} object depending on the relative position of the monitors (as opposed to the
     * monitor number assigned by the operating system).
     *
     * Set {@link dMon.UseOrderedMonitors} to `false` to cause `dMon[index]` notation to return
     * a {@link dMon} object using the monitor number assigned by the operating system.
     *
     * Set {@link dMon.UseOrderedMonitors} with an object containing {@link dMon.GetOrder} parameters
     * as property : value pairs, where each property's name corresponds to a parameter name.
     * When your code gets a {@link dMon} object using `dMon[index]` notation, {@link dMon.GetOrder}
     * is called, passing the specified parameters to the function.
     */
    static __Item[N := 1] {
        ; This is overridden
    }

    /**
     * @description - An object with properties and methods to simplify working with a monitor's
     * dimensions in pixel units.
     * @param {Integer} Hmon - The monitor handle.
     */
    __New(Hmon) {
        this.Buffer := Buffer(40)
        this.Hmon := Hmon
        NumPut('Uint', 40, this.Buffer)
        if !DllCall('GetMonitorInfo', 'ptr', Hmon, 'ptr', this.Buffer, 'int') {
            throw OSError()
        }
    }

    GetPos(&X?, &Y?, &W?, &H?) {
        X := this.L
        Y := this.T
        W := this.W
        H := this.H
    }

    GetPosW(&X?, &Y?, &W?, &H?) {
        X := this.LW
        Y := this.TW
        W := this.WW
        H := this.HW
    }

    TL => Display_Point(this.L, this.T)
    BR => Display_Point(this.R, this.B)
    L => NumGet(this, 4, 'int')
    X => NumGet(this, 4, 'int')
    T => NumGet(this, 8, 'int')
    Y => NumGet(this, 8, 'int')
    R => NumGet(this, 12, 'int')
    B => NumGet(this, 16, 'int')
    W => this.R - this.L
    H => this.B - this.T
    MidX => (this.R - this.L) / 2
    MidY => (this.B - this.T) / 2
    Primary => NumGet(this, 36, 'Uint')
    TLW => Display_Point(this.LW, this.TW)
    BRW => Display_Point(this.RW, this.BW)
    LW => NumGet(this, 20, 'int')
    XW => NumGet(this, 20, 'int')
    TW => NumGet(this, 24, 'int')
    YW => NumGet(this, 24, 'int')
    RW => NumGet(this, 28, 'int')
    BW => NumGet(this, 32, 'int')
    WW => this.RW - this.LW
    HW => this.BW - this.TW
    MidXW => (this.RW - this.LW) / 2
    MidYW => (this.BW - this.TW) / 2
    Dpi => dMon.Dpi(this.Hmon)
    Dpi_Raw => dMon.Dpi(this.Hmon, 2) ; MDT_RAW
    Dpi_Angular => dMon.Dpi(this.Hmon, 1) ; MDT_ANGULAR

    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size

    /**
     * @classdesc - Returns the DPI of the monitor using various input types.
     *
     * The parameter `DpiType` can be one of the following:
     * - MDT_EFFECTIVE_DPI - 0
     * - MDT_ANGULAR_DPI - 1
     * - MDT_RAW_DPI - 2
     */
    class Dpi {
        /**
         * @description - Returns the monitor's DPI.
         * @param {Integer} Hmon - The monitor handle.
         * @param {Integer} [DpiType = 0] - One of the following:
         * - MDT_EFFECTIVE_DPI - 0
         * - MDT_ANGULAR_DPI - 1
         * - MDT_RAW_DPI - 2
         */
        static Call(Hmon, DpiType := 0) {
            if !DllCall('Shcore\GetDpiForMonitor', 'ptr', Hmon, 'UInt', DpiType, 'UInt*', &DpiX := 0, 'UInt*', &DpiY := 0, 'UInt') {
                return DpiX
            }
        }
        static Pos(Left, Top, Right, Bottom, DpiType := 0) => this(dMon.FromPosH(Left, Top, Right, Bottom), DpiType)
        static Rect(RectObj, DpiType := 0) => this(dMon.FromRectH(RectObj), DpiType)
        static Dimensions(X, Y, W, H, DpiType := 0) => this(dMon.FromDimensionsH(X, Y, W, H), DpiType)
        static Mouse(DpiType := 0) => this(dMon.FromMouseH(), DpiType)
        static Display_Point(X, Y, DpiType := 0) => this(dMon.FromPointH(X, Y), DpiType)
        static Win(Hwnd, DpiType := 0) => this(dMon.FromWinH(Hwnd), DpiType)
    }
}
/**
 * @description - Reorders the objects in an array according to the input options.
 * @param {Array} List - The array containing the objects to be ordered.
 * @param {String} [Primary = 'X'] - Determines which axis is primarily considered when ordering
 * the objects. When comparing two objects, if their positions along the Primary axis are
 * equal, then the alternate axis is compared and used to break the tie. Otherwise, the alternate
 * axis is ignored for that pair.
 * - X: Check horizontal first.
 * - Y: Check vertical first.
 * @param {Boolean} [LeftToRight = true] - If true, the objects are ordered in ascending order
 * along the X axis when the X axis is compared.
 * @param {Boolean} [TopToBottom = true] - If true, the objects are ordered in ascending order
 * along the Y axis when the Y axis is compared.
 */
Display_OrderRects(List, Primary := 'X', LeftToRight := true, TopToBottom := true) {
    ConditionH := LeftToRight ? (a, b) => a.L < b.L : (a, b) => a.L > b.L
    ConditionV := TopToBottom ? (a, b) => a.T < b.T : (a, b) => a.T > b.T
    if Primary = 'X' {
        _InsertionSort(List, _ConditionFnH)
    } else if Primary = 'Y' {
        _InsertionSort(List, _ConditionFnV)
    } else {
        throw ValueError('Unexpected ``Primary`` value.', -1, Primary)
    }

    return

    _InsertionSort(Arr, CompareFn) {
        i := 1
        loop Arr.Length - 1 {
            Current := Arr[++i]
            j := i - 1
            loop j {
                if CompareFn(Arr[j], Current) < 0
                    break
                Arr[j + 1] := Arr[j--]
            }
            Arr[j + 1] := Current
        }
    }
    _ConditionFnH(a, b) {
        if a.L == b.L {
            if ConditionV(a, b) {
                return -1
            }
        } else if ConditionH(a, b) {
            return -1
        }
        return 1
    }
    _ConditionFnV(a, b) {
        if a.T == b.T {
            if ConditionH(a, b) {
                return -1
            }
        } else if ConditionV(a, b) {
            return -1
        }
        return 1
    }
}
