
#include ..\src\dMon.ahk

class WinMover {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.MonNum := 1
        Proto.Presets := Map(
            1, { PosXQuotient: 0, PosYQuotient: 0, WidthQuotient: 0.5, HeightQuotient: 1 }
          , 2, { PosXQuotient: 0.5, PosYQuotient: 0, WidthQuotient: 0.5, HeightQuotient: 1 }
          , 3, { PosXQuotient: 0, PosYQuotient: 0, WidthQuotient: 1, HeightQuotient: 1 }
        )
        Proto.ChordTimerDuration := 2000
        Proto.TerminateMoveCallback := (*) => !GetKeyState('LButton', 'P')
        Proto.TerminateSizeCallback := (*) => !GetKeyState('RButton', 'P')
    }
    __New(Presets?) {
        if IsSet(Presets) {
            this.Presets := Presets
        }
        this.Active := 0
    }
    Call(Hwnd, PosXQuotient, PosYQuotient, WidthQuotient, HeightQuotient, MonNum?) {
        mon := dMon[MonNum ?? this.MonNum]
        WinMove(
            mon.LeftW + mon.WidthW * PosXQuotient
          , mon.TopW + mon.HeightW * posYQuotient
          , mon.WidthW * WidthQuotient
          , mon.HeightW * HeightQuotient
          , Hwnd
        )
    }
    CallHelper(Hwnd, PresetKey) {
        if this.Presets.Has(PresetKey) {
            preset := this.Presets.Get(PresetKey)
        } else if this.Base.Presets.Has(PresetKey) {
            preset := this.Base.Presets.Get(PresetKey)
        } else {
            throw UnsetItemError('Item not found.', -1, PresetKey)
        }
        this(Hwnd, preset.PosXQuotient, preset.PosYQuotient, preset.WidthQuotient, preset.HeightQuotient)
    }
    /**
     * @description - This is intended to be used with a key chord. For example, the user presses
     * the first hotkey which passes the monitor number to the method. Then, the next hotkey passes
     * an identifier to the method which corresponds with some value in the map `WinMoverObj.Presets`.
     * For example, this is how I define my hotkeys:
     * @example
     *  #include <WinMover>
     *  #SingleInstance force
     *  CapsLock & 1::WinMoveHelper(1)
     *  CapsLock & 2::WinMoveHelper(2)
     *  CapsLock & 3::WinMoveHelper(3)
     *
     *  global WinMoveObj := WinMover()
     *
     *  WinMoveHelper(Num) {
     *      global WinMoveObj
     *      WinMoveObj.Chord(Num)
     *      ; This is necessary because the caps lock is toggled when the key is lifted, so we
     *      ; must toggle it first so the second toggle returns it to its original state.
     *      SetCapsLockState(!GetKeyState('CapsLock', 'T'))
     *  }
     * @
     */
    Chord(Value) {
        if this.Active {
            this.CallHelper(WinGetId('A'), Value)
            this.Active := 0
        } else {
            this.MonNum := Value
            this.Active := 1
            SetTimer(_Timer, -1 * this.ChordTimerDuration)
        }
        _Timer() {
            this.Active := 0
        }
    }

    DynamicMove(*) {
        MouseMode := CoordMode('Mouse', 'Screen')
        DpiAwareness := DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
        MouseGetPos(&x, &y, &hwnd)
        WinGetPos(&wx, &wy, &ww, &wh, hwnd)
        cb := this.TerminateMoveCallback
        loop {
            if cb() {
                break
            }
            MouseGetPos(&x2, &y2)
            WinMove(wx + x2 - x, wy + y2 - y, , , hwnd)
            sleep 10
        }
        CoordMode('Mouse', MouseMode)
        DllCall('SetThreadDpiAwarenessContext', 'ptr', DpiAwareness, 'ptr')
    }

    DynamicResize(*) {
        MouseMode := CoordMode('Mouse', 'Screen')
        DpiAwareness := DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
        MouseGetPos(&x, &y, &hwnd)
        WinGetPos(&wx, &wy, &ww, &wh, hwnd)
        if x > wx + ww / 2 {
            x_quotient := 1
            GetX := XCallback1
        } else {
            x_quotient := -1
            GetX := XCallback2
        }
        if y > wy + wh / 2 {
            y_quotient := 1
            GetY := YCallback1
        } else {
            y_quotient := -1
            GetY := YCallback2
        }
        cb := this.TerminateSizeCallback
        loop {
            if cb() {
                break
            }
            MouseGetPos(&x2, &y2)
            WinMove(GetX(), GetY(), ww + (x2 - x) * x_quotient, wh + (y2 - y) * y_quotient, hwnd)
            sleep 10
        }
        XCallback1() {
            return wx
        }
        XCallback2() {
            return wx + x2 - x
        }
        YCallback1() {
            return wy
        }
        YCallback2() {
            return wy + y2 - y
        }
        CoordMode('Mouse', MouseMode)
        DllCall('SetThreadDpiAwarenessContext', 'ptr', DpiAwareness, 'ptr')
    }
}
