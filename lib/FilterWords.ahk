﻿/*
    Github:
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @classdesc - Filters strings in an array of strings as a function of an input string, such that
 * the filtered array contains only strings for which `FilterCallback(Item, Input)` is true. To
 * allow for flexibility in its usage, `FilterWords` requires some setup. See the test file
 * "test-files\test-FilterWords.ahk" for an example setting up the function.
 */
class FilterWords {

    static FilterCallback(Item, Input) {
        LeftOffsetInput := LeftOffsetItem := 1
        RightOffsetInput := 0
        _Input := RegExReplace(Input, '\s', '')
        _Item := RegExReplace(Item, '\s', '')
        LenInput := SubLen := StrLen(_Input)
        LenItem := StrLen(_Item)
        found := []
        found.Capacity := LenInput

        loop {
            ssInput := SubStr(_Input, LeftOffsetInput, LenInput - LeftOffsetInput - RightOffsetInput + 1)
            if pos := InStr(_Item, ssInput, , LeftOffsetItem) {
                LenSsInput := StrLen(ssInput)
                LeftOffsetItem := pos + LenSsInput
                LeftOffsetInput += LenSsInput
                found.Push(LeftOffsetInput, LenInput - LeftOffsetInput - RightOffsetInput + 1, pos)
                if LeftOffsetInput > LenInput {
                    return found
                } else {
                    RightOffsetInput := 0
                }
            } else {
                RightOffsetInput++
                if RightOffsetInput + LeftOffsetInput > LenInput {
                    return 0
                }
            }
        }
        return 0
    }

    /**
     * Creates an instance of `FilterWords`, which should be used as part of an event handler. The
     * event handler should include something to the effect of the following example. In this example,
     * assume that `Ctrl.Gui.Filter` references an instance of `FilterWords`, and `Ctrl` references
     * a `Gui.Control` object to which the event handler is associated. Basically, the event handler
     * must disable itself, call the `FilterWords` object, then re-enable itself.
     * @example
     *  HChangeEdit(Ctrl, *) {
     *      ; Disable the event handler.
     *      Ctrl.OnEvent('Change', HChangeEdit, 0)
     *      ; Call the `FilterWords` object.
     *      Ctrl.Gui.Filter.Call()
     *      ; Enable the event handler.
     *      Ctrl.OnEvent('Change', HChangeEdit, 1)
     *  }
     * @
     *
     * While the `FilterWords` object is active and associated with an array, if your code needs to
     * add or remove items from the array, you must call `FilterWords.Prototype.Add` or
     * `FilterWords.Prototype.Delete`. These are not the same as the `AddCallback` and `DeleteCallback`
     * parameters.
     *
     * Items that have been filtered out of the `List` array (first parameter) are available from
     * the property `FilterWordsObj.Filtered`, also an array.
     *
     * The callback functions are assigned to properties "CbGetText", "CbAdd", "CbDelete", "CbFilter",
     * so your code can set any of those properties with a new function object instead of creating a
     * new instance of `FilterWords`, if needed.
     *
     * Similarly, the `List` array is set to the "List" property, so if it is more efficient in
     * the context of your code, you could swap out that property with a new array as well. You'll
     * need to handle any items from the "Filtered" array.
     * @example
     *   List := FilterWordsObj.List
     *   FilterWordsObj.List := NewList
     *   if FilterWordsObj.Filtered.Length {
     *       List.Push(FilterWordsObj.Filtered*)
     *       FilterWordsObj.Filtered := []
     *   }
     *   FilterWordsObj.Capacity := NewList.Length
     * @
     * @class
     * @param {Array} List - The array of strings that will be associated with the filter.
     * @param {*} GetTextCallback - A `Func` or callable object that returns the text that is used
     * as input for filtering the items in `List`.
     * @param {*} AddCallback - A `Func` or callable object that is called when adding items that
     * were previously filtered out back into `List`. The function should accept one parameter,
     * the string being added back to `List`. The function should **not** add the string to `List`;
     * `FilterWords` does this.
     * @param {*} DeleteCallback - A `Func` or callable object that is called when removing items
     * from `List`. The function should accept one parameter, the integer index of the item's position
     * in `List`. The function should **not** remove the string from `List`; `FilterWords` does this
     * after calling `DeleteCallback`, so your code will still be able to identify the string using
     * `List[index]` if needed.
     * @param {*} [FilterCallback = InStr] - The comparison function. The parameters passed to the
     * function are:
     * - 1. The array item being evaluated.
     * - 2. the input string returned from `GetTextCallback`.
     *
     * The default is `InStr`. The function should return nonzero if the item is to be kept in the
     * active list, which is the `List` array. The function should return zero or an empty string
     * if the item is to be filtered out of the array. See "test-files\test-FilterWords.ahk" for
     * a more robust comparison function.
     */
    __New(List, GetTextCallback, AddCallback, DeleteCallback, FilterCallback := InStr) {
        this.CbGetText := GetTextCallback
        this.CbAdd := AddCallback
        this.CbDelete := DeleteCallback
        this.CbFilter := FilterCallback
        this.Transition := []
        this.Filtered := []
        this.List := List
        Indices := this.Indices := []
        Indices.Length := List.Length
        loop List.Length {
            Indices[A_Index] := A_Index
        }
        this.Transition.Capacity := this.Filtered.Capacity := List.Capacity
        this.PreviousText := ''
    }
    Call() {
        CbGetText := this.CbGetText
        CbAdd := this.CbAdd
        CbDelete := this.CbDelete
        CbFilter := this.CbFilter
        this.Time := A_TickCount
        Indices := this.Indices
        List := this.List
        Filtered := this.Filtered
        loop {
            if Text := CbGetText() {
                ; If the user added a character, then we only need to filter our current
                ; this.filtered this.list, not the entire this.list.
                if !this.PreviousText || (StrLen(Text) > StrLen(this.PreviousText) && InStr(Text, this.PreviousText) == 1) {
                    i := 0
                    loop Indices.Length {
                        if !CbFilter(List[Indices[++i]], Text) {
                            Index := Indices.RemoveAt(i)
                            CbDelete(Index, i--)
                            Filtered.Push(Index)
                        }
                    }
                } else if Text {
                    currentLen := Indices.Length
                    i := 0
                    loop Filtered.Length {
                        if CbFilter(List[Filtered[++i]], Text) {
                            Index := Filtered.RemoveAt(i)
                            CbAdd(Index, i--)
                            Indices.Push(Index)
                        }
                    }
                    i := 0
                    loop currentLen {
                        if !CbFilter(List[Indices[++i]], Text) {
                            Index := Indices.RemoveAt(i)
                            CbDelete(Index, i--)
                            Filtered.Push(Index)
                        }
                    }
                } else {
                    Reset()
                }
            } else {
                Reset()
            }
            this.PreviousText := Text
            if this.PreviousText == CbGetText() {
                if A_TickCount - this.Time > 500 {
                    break
                }
                sleep 50
            } else {
                this.Time := A_TickCount
            }
        }
        this.Time := 0

        return

        Reset() {
            loop Filtered.Length {
                Index := Filtered.Pop()
                CbAdd(Index, Filtered.Length + 1)
                Indices.Push(Index)
            }
        }
    }

    Add(Str) {
        this.List.Push(Str)
        if (text := this.CbGetText.Call()) {
            if this.CbFilter.Call(Str, text) {
                this.Indices.Push(this.List.Length)
                this.CbAdd.Call(this.List.Length)
            } else {
                this.Filtered.Push(this.List.Length)
            }
        } else {
            this.Indices.Push(this.List.Length)
            this.CbAdd.Call(this.List.Length)
        }
    }
    Delete(Index) {
        if (text := this.CbGetText.Call()) {
            if this.CbFilter.Call(this.List[Index], text) {
                _LoopItems()
            } else {
                n := this.List.Length
                this.List.RemoveAt(Index)
                for i in this.Filtered {
                    if i = n {
                        this.Filtered.RemoveAt(A_Index)
                        return
                    }
                }
                for i in this.Indices {
                    if i = n {
                        this.Indices.RemoveAt(A_Index)
                        return
                    }
                }
            }
        } else {
            _LoopItems()
        }

        _LoopItems() {
            for i in this.Indices {
                if Index = i {
                    this.Indices.RemoveAt(A_Index)
                    this.CbDelete.Call(Index, A_Index)
                    return
                }
            }
        }
    }
    Dispose() {
        list := []
        for prop in this.OwnProps() {
            list.Push(prop)
        }
        for prop in list {
            this.DeleteProp(prop)
        }
    }
}
