
/**
 * @classdesc - This is unfinished, do not use.
 */
class BufferArray extends Buffer {
    /**
     * Constructs an `BufferArray` instance.
     * @param {Integer} [Capacity=0] - The maximum item count in number of items. This value is used
     * to set the `Size` property of the buffer object, which directs the AHK interpreter to allocate
     * the memory and perform other necessary actions. There is also a `Capacity` property on the
     * isntance that you can use to change the maximum number of items. Remember, when working with
     * the `Capacity` property, use indices, and when working with the `Size` property, use bytes
     * (items * 4).
     * See {@link https://www.autohotkey.com/docs/v2/lib/Buffer.htm} for the details about
     * `BufferObj.Size`.
     * @param {String} [IntType='int'] - The type of integer. This gets used as the `Type` param
     * of `NumGet` and `NumPut`. See {@link https://www.autohotkey.com/docs/v2/lib/DllCall.htm#types}
     * @param {...Integer} [Values] - Any number of values to be added to the buffer. Be mindful
     * of the the limitations of whichever type of integer you are working. For undertanding bytes
     * and integers, see {@link https://www.autohotkey.com/docs/v2/Concepts.htm#pure-numbers}.
     * @returns {BufferArray}
     * @class
     */
    __New(ValueType, ItemSize, Capacity := 0, Values*) {
        if Values.Length > Capacity {
            throw ValueError('Insufficient memory allocated for quantity of values.', -1, 'Capacity: ' Capacity '; Quantity: ' Values.Length)
        }
        this.Type := ValueType
        this.ItemSize := ItemSize
        this.Capacity := Capacity
        for Value in Values {
            NumPut(IntType, Value, this, (A_Index - 1) * 4)
        }
    }

    /**
     * @description - Returns an enumerator. Supports 1- or 2-param mode `for` loops. In 1-param mode,
     * the variable receives the value at that index. In 2-param mode, the first variable receives
     * the item's index, and the second variable receives the item's value.
     * @param {Integer} VarCount - The number of parameters used in the `for` loop. Typically AHK
     * sets this parameter to the correct value, but if you need to call `iArr.__Enum` directly,
     * you have to set this to the correct number of variables used in your `for` loop.
     */
    __Enum(VarCount, End?) {
        i := 0
        if !IsSet(End) {
            End := this.Size / this.ItemSize
        }
        return VarCount == 1 ? _Enum : _Enum2

        _Enum(&Value) {
            if ++i > End {
                return 0
            }
            Value := NumGet(this, (i - 1) * this.ItemSize, this.Type)
            return 1
        }
        _Enum2(&Index, &Value) {
            if ++i > End {
                return 0
            }
            Value := NumGet(this, (i - 1) * this.ItemSize, this.Type)
            Index := i
            return 1
        }
    }

    /**
     * @property BufferArray.Prototype.Capacity - Gets or sets the maximum number of items that
     * can be contained in the BufferArray.
     */
    Capacity {
        Get => this.Size / this.ItemSize
        Set => this.Size := Value * this.ItemSize
    }

    /**
     * @property Size - The size of the buffer in number of bytes. `Size` is on the base object,
     * and so is not actually seen here.
     */

    /**
     * @property BufferArray.Prototype.__Item - Gets or sets an integer using an index position.
     * `BufferArray` instances use a 1-based index.
     * @param {Integer} Index - The 1-based index to get or set.
     */
    __Item[Index] {
        Get {
            if Abs(Index) > this.Size / this.ItemSize || !Index {
                throw IndexError('Index out of range.', -1, 'Index: ' Index '; Length: ' (this.Size / this.ItemSize))
            }
            return NumGet(this, Index > 0 ? (Index - 1) * this.ItemSize : this.Size + Index * this.ItemSize, 'int')

        }
        Set {
            if Abs(Index) > this.Size / this.ItemSize || !Index {
                throw IndexError('Index out of range.', -1, 'Index: ' Index '; Length: ' (this.Size / this.ItemSize))
            }
            If !IsNumber(Value) {
                throw TypeError('``Value`` must be a number.', -1, 'Type(Value) == ' Type(Value))
            }
            NumPut(this.Type, Value, this, Index > 0 ? (Index - 1) * this.ItemSize : this.Size + Index * this.ItemSize)
        }
    }
}
