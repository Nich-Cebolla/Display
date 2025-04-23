
/**
 * @class
 * @description - A buffer object that can be used with Dll calls. This should only be used with
 * integers.
 */
class IntegerArray extends Buffer {
    __New(Size := 0, Values*) {
        if Values.Length * 4 > Size {
            throw ValueError('Insufficient size allocated for quantity of values.', -1, 'Size: ' Size '; Quantity: ' Values.Length)
        }
        this.Size := Size
        for Value in Values {
            NumPut('int', Value, this, (A_Index - 1) * 4)
        }
    }
    __Enum(VarCount) {
        i := 0
        iMax := this.Size / 4
        return VarCount == 1 ? _Enum : _Enum2

        _Enum(&Value) {
            if ++i > iMax {
                return 0
            }
            Value := NumGet(this, (i - 1) * 4, 'int')
            return 1
        }
        _Enum2(&Index, &Value) {
            if ++i > iMax {
                return 0
            }
            Value := NumGet(this, (i - 1) * 4, 'int')
            Index := i
            return 1
        }
    }
    __Item[Index] {
        Get {
            if Index > this.Size / 4 {
                throw IndexError('Index out of bounds.', -1, 'Index: ' Index '; Size: ' this.Size)
            }
            if Index < 1 {
                throw IndexError('Index must be greater than 0.', -1, 'Index: ' Index)
            }
            return NumGet(this, (Index - 1) * 4, 'int')
        }
        Set {
            If not Value is Number {
                throw TypeError('Value must be a number.', -1, 'Invalid type: ' Type(Value))
            }
            if Index > this.Size / 4 {
                throw IndexError('Index out of bounds.', -1, 'Index: ' Index '; Size: ' this.Size)
            }
            if Index < 1 {
                throw IndexError('Index must be greater than 0.', -1, 'Index: ' Index)
            }
            NumPut('int', Value, this, (Index - 1) * 4)
        }
    }
}
