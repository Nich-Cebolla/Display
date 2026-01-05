
class Display_IntegerArray extends Buffer {
    /**
     * @description - A buffer object that can be used with Dll calls or other actions that require a
     * pointer to a buffer to be filled with integers.
     *
     * This class is intended to simplify the handling of any series of integers contained in a buffer;
     * the objects can be enumerated by calling it in a `for` loop, and the items can be accessed by index,
     * which is a slight convenience to using multiples of the byte size with `NumGet`. Negative indices
     * are treated as right-to-left.
     *
     * Note: To adhere to AHK's convention, the value at byte offset 0 is considered index 1.
     *
     * @example
     * ia := Display_IntegerArray(
     *     Capacity := 4,
     *     IntType := "int",
     *     IntSize := 4,
     *     ; Note I have only added 3 values.
     *     10, 23, 1991
     * )
     * MsgBox(ia[1]) ; 10
     * MsgBox(ia[-2]) ; 1991
     * ia[4] := 18
     * MsgBox(ia[-1]) ; 18
     * ; enumerate the values
     * s := ""
     * for n in ia {
     *     str .= n ", "
     * }
     * MsgBox(SubStr(str, 1, -2)) ; 10, 23, 1991, 18
     *
     * ; If I need to add more, I must increase the capacity.
     * ia.Capacity := 5
     * ia[5] := 30
     * MsgBox(ia[-1]) ; 30
     *
     * ; To use in a `DllCall`, just pass the object directly
     * DllCall('FunctionName', 'ptr', ia)
     * @
     *
     * The object does not track which indices are set; accessing an unset index will still return
     * a value but the value will be meaningless. Consequently, when enumerating the object in a
     * `for` loop, it will iterate the entire buffer even if you never added an integer to any index.
     *
     * You can call {@link Display_IntegerArray.Prototype.Enum} to restrict the range of indices which get
     * enumerated.
     *
     * @example
     * ia := Display_IntegerArray(
     *     Capacity := 6,
     *     IntType := "int",
     *     IntSize := 4,
     *     ; Note I have only added 3 values.
     *     10, 9, 10
     * )
     * iaEnumerator := ia.Enum(
     *     VarCount := 1,
     *     StartIndex := 1,
     *     StopIndex := 3
     * )
     * for n in iaEnumerator {
     *     ; work
     * }
     *
     * ; or call the enumerator inline
     * for n in ia.Enum(1, 1, 3) {
     *     ; work
     * }
     *
     * ; or call the enumerator in 2-param mode
     * s := ""
     * for i, n in ia.Enum(VarCount := 2, 1, 3) {
     *     s .= i ": " n ", "
     * }
     * MsgBox(SubStr(s, 1, -2)) ; 1: 10, 2: 9, 3: 10
     * @
     *
     * Regarding the {@link Display_IntegerArray.Prototype.__Item} property, -1 will always be the last position
     * according to the `Size` property, even if you never added a value there.
     *
     * @class
     *
     * @param {Integer} [Capacity = 0] - The maximum item count in number of items. This value is used
     * to set the {@link https://www.autohotkey.com/docs/v2/lib/Buffer.htm#Size Size} property of
     * the buffer object.
     *
     * @param {String} [IntType = "int"] - The type of integer. This gets used as the `Type` param
     * of {@link https://www.autohotkey.com/docs/v2/lib/NumGet.htm NumGet} and
     * {@link https://www.autohotkey.com/docs/v2/lib/NumPut.htm NumPut}. Also see
     * {@link https://www.autohotkey.com/docs/v2/lib/DllCall.htm#types}.
     *
     * @param {Integer} [IntSize = 4] - The size of the integer in bytes.
     *
     * @param {...Integer} [Values] - Any number of values to be added to the buffer.
     */
    __New(Capacity?, IntType := 'int', IntSize := 4, Values*) {
        this.IntSize := IntSize
        this.IntType := IntType
        if IsSet(Capacity) {
            this.Capacity := Capacity
            if Values.Length > Capacity {
                throw ValueError('The number of values exceeds the capacity.')
            }
        } else {
            this.Capacity := Values.Length
        }
        for Value in Values {
            if IsSet(Value) {
                NumPut(IntType, Value, this, (A_Index - 1) * this.IntSize)
            }
        }
    }

    Enum(VarCount := 1, StartIndex := 1, StopIndex := this.Capacity) {
        i := StartIndex - 1
        intSize := this.IntSize
        intType := this.IntType

        return _Enum%VarCount%

        _Enum1(&Value) {
            if ++i > StopIndex {
                return 0
            }
            Value := NumGet(this, (i - 1) * intSize, intType)
            return 1
        }
        _Enum2(&Index, &Value) {
            if ++i > StopIndex {
                return 0
            }
            Value := NumGet(this, (i - 1) * intSize, intType)
            Index := i
            return 1
        }
    }

    Capacity {
        Get => this.Size / this.IntSize
        Set => this.Size := Value * this.IntSize
    }

    __Enum(VarCount := 1) => this.Enum(VarCount)

    __Item[Index] {
        Get {
            if !Index {
                throw IndexError('Invalid index.', , Index)
            }
            if Abs(Index) > this.Capacity {
                throw IndexError('Index out of range.', , Index)
            }
            return NumGet(this, Index > 0 ? (Index - 1) * this.IntSize : this.Size + Index * this.IntSize, this.IntType)

        }
        Set {
            if !Index {
                throw IndexError('Invalid index.', , Index)
            }
            if Abs(Index) > this.Capacity {
                throw IndexError('Index out of range.', , Index)
            }
            If !IsInteger(Value) {
                throw TypeError('The value must be an integer.', , IsObject(Value) ? '' : Value)
            }
            NumPut(this.IntType, Value, this, Index > 0 ? (Index - 1) * this.IntSize : this.Size + Index * this.IntSize)
        }
    }
}
