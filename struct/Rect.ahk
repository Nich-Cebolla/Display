#include RectBase.ahk
#include ..\lib\SetThreadDpiAwareness__Call.ahk

class Rect extends RectBase {
    __New(L?, T?, R?, B?) {
        this.Size := 16
        if IsSet(L) {
            NumPut('Int', L, this, 0)
        }
        if IsSet(T) {
            NumPut('Int', T, this, 4)
        }
        if IsSet(R) {
            NumPut('Int', R, this, 8)
        }
        if IsSet(B) {
            NumPut('Int', B, this, 12)
        }
    }

    static FromControl(Ctrl) {
        Ctrl.GetPos(&X, &Y, &W, &H)
        return this.FromDimensions(X, Y, W, H)
    }

    static FromDimensions(X, Y, W, H) => Rect(X, Y, X + W, Y + H)

    static FromPtr(Ptr) {
        R := Rect()
        Rect.Ptr := Ptr
        return R
    }

    static FromWin(Hwnd) {
        if DllCall('User32.dll\GetWindowRect', 'Ptr', Hwnd, 'Ptr', RectObj := this()) {
            return RectObj
        }
    }

    static FromWinClient(Hwnd) {
        if DllCall('User32.dll\GetClientRect', 'Ptr', Hwnd, 'Ptr', RectObj := this()) {
            return RectObj
        }
    }

    static GetQuadrants(RectObj) {

    }

    /**
     * @description - Returns the intersection of two rectangles.
     * @param {Rect} Rect1 - The first rectangle.
     * @param {Rect} Rect2 - The second rectangle.
     * @returns {Rect} - If successful, the intersection of the two rectangles. If
     * unsuccessful, an empty string.
     */
    static Intersect(Rect1, Rect2) {
        if DLLCall('User32.dll\IntersectRect', 'Ptr', Rect := this(), 'Ptr', Rect1, 'Ptr', Rect2) {
            return Rect
        }
    }

    /**
     * @description - Reorders the objects in an array according to the input options.
     * @example
     *  List := [
     *      { L: 100, T: 100, Name: 1 }
     *    , { L: 100, T: 150, Name: 2 }
     *    , { L: 200, T: 100, Name: 3 }
     *    , { L: 200, T: 150, Name: 4 }
     *  ]
     *  Rect.Order(List, L2R := true, T2B := true, 'H')
     *  OutputDebug(_GetOrder()) ; 1 2 3 4
     *  Rect.Order(List, L2R := true, T2B := true, 'V')
     *  OutputDebug(_GetOrder()) ; 1 3 2 4
     *  Rect.Order(List, L2R := false, T2B := true, 'H')
     *  OutputDebug(_GetOrder()) ; 3 4 1 2
     *  Rect.Order(List, L2R := false, T2B := false, 'H')
     *  OutputDebug(_GetOrder()) ; 4 3 2 1
     *
     *  _GetOrder() {
     *      for item in List {
     *          Str .= item.Name ' '
     *      }
     *      return Trim(Str, ' ')
     *  }
     * @
     * @param {Array} List - The array containing the objects to be ordered.
     * @param {String} [Primary='X'] - Determines which axis is primarily considered when ordering
     * the objects. When comparing two objects, if their positions along the Primary axis are
     * equal, then the alternate axis is compared and used to break the tie. Otherwise, the alternate
     * axis is ignored for that pair.
     * - X: Check horizontal first.
     * - Y: Check vertical first.
     * @param {Boolean} [LeftToRight=true] - If true, the objects are ordered in ascending order
     * along the X axis when the X axis is compared.
     * @param {Boolean} [TopToBottom=true] - If true, the objects are ordered in ascending order
     * along the Y axis when the Y axis is compared.
     * @param {Func} [LeftGetter=(Obj) => Obj.L] - A function that retrieves the left value from the objects.
     * @param {Func} [TopGetter=(Obj) => Obj.T] - A function that retrieves the top value from the objects.
     */
    static Order(List, Primary := 'X', LeftToRight := true, TopToBottom := true
    , LeftGetter := (Obj) => Obj.L, TopGetter := (Obj) => Obj.T) {
        ConditionH := LeftToRight ? (a, b) => LeftGetter(a) < LeftGetter(b) : (a, b) => LeftGetter(a) > LeftGetter(b)
        ConditionV := TopToBottom ? (a, b) => TopGetter(a) < TopGetter(b) : (a, b) => TopGetter(a) > TopGetter(b)
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

    /**
     * @description - Splits a length into equivalent segments. The first index in the array
     * is always the same as `Pos`, then each subsequent value is the rounded sum of the previous
     * item's value and `Length` / `Divisor`.
     * @param {Integer} Pos - The starting position.
     * @param {Integer} Length - The length to split.
     * @param {Integer} Divisor - The number of segments to split the length into.
     */
    static Split(Pos, Length, Divisor) {
        Result := [Pos]
        Delta := Length / Divisor
        Result.Capacity := Divisor + 1
        loop Divisor {
            Result.Push(Round(Pos += Delta, 0))
        }
        return Result
    }

    static Union(Rect1, Rect2) {
        if DllCall('UnionRect', 'ptr', rc := Rect(), 'ptr', Rect1, 'ptr', Rect2, 'int') {
            return rc
        }
    }
}
