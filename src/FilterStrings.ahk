
#include LibraryManager.ahk

class FilterStrings {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.CallbackFilter := FilterStrings_CallbackFilter
        proto.CallbackReset := ''
        proto.CaseSense := false
        proto.__timerPeriod := -50
        proto.EndThreshold := 500
        proto.HwndCtrl := 0
        proto.HwndCtrlEventHandler := 0
        proto.Priority := 0

        global g_msvcrt_memmove
        g_msvcrt_memmove := 0
        this.libraryToken := LibraryManager('msvcrt', [ 'memmove' ])
    }
    /**
     * @description - Filters strings in an array of strings as a function of an input string, such
     * that the filtered array contains only strings for which `CallbackFilter(Item, Input)` is true.
     * To allow for flexibility in its usage, {@link FilterStrings} requires some setup. See
     * file test\test-FilterStrings.ahk for an example setting up the function.
     *
     * If the filter process is invoked by an event handler, such as with a gui control, the event
     * handler should disable itself.
     *
     * The event handler should include something to the effect of the following example. In this
     * example, assume that `Ctrl.Filter` references an instance of {@link FilterStrings}, and `Ctrl`
     * references a `Gui.Control` object to which the event handler is associated. Basically,
     * the event handler must disable itself then call the {@link FilterStrings} object.
     *
     * @example
     * OnChangeEdit(Ctrl, *) {
     *     ; Disable the event handler.
     *     Ctrl.OnEvent('Change', OnChangeEdit, 0)
     *     ; Call the filter object.
     *     Ctrl.Filter.Call()
     * }
     * @
     *
     * When your code calls {@link FilterStrings.Prototype.Call}, it starts a process that
     * repeatedly calls {@link FilterStrings.Prototype.Call} until the filter criterion has not
     * changed for a period of time specified by `Options.EndThreshold`. This process is facilitated
     * by {@link https://www.autohotkey.com/docs/v2/lib/SetTimer.htm SetTimer}. After each iteration,
     * `SetTimer` is called to queue up the next iteration to execute in `Options.Delay` milliseconds.
     *
     * {@link FilterStrings.Prototype.Call} does not use any
     * {@link https://www.autohotkey.com/docs/v2/Functions.htm#closures Closures} or
     * {@link https://www.autohotkey.com/docs/v2/Functions.htm#static static variables}, so it is
     * safe to have multiple instances of {@link FilterStrings} active at a time.
     *
     * While the {@link FilterStrings} object is in use, if your code needs to add items to the array,
     * your code should call {@link FilterStrings.Prototype.Add} or
     * {@link FilterStrings.Prototype.AddMultiple}.
     *
     * While the {@link FilterStrings} object is in use, if your code needs to remove items from the
     * array, your code should call {@link FilterStrings.Prototype.Delete}.
     *
     * Regarding the callback functions, remember that you can omit one or more parameters from the
     * end of the callback's parameter list if the corresponding information is not needed, but in
     * this case an asterisk must be specified as the final parameter, e.g. `MyCallback(Param1, *)`.
     *
     * @class
     *
     * # Options
     *
     * @param {Object} Options - An object with options as property : value pairs. The following
     * properties are required:
     * - List
     * - CallbackAdd
     * - CallbackDelete
     * - CallbackGetCriterion
     *
     * The following properties are optional but generally should be set:
     * - CallbackEnd
     * - CallbackFilter
     * - HwndCtrl
     * - HwndCtrlEventHandler
     *
     * For each option, a property with the same name is defined on the {@link FilterStrings} object
     * with the same value as the option value.
     *
     * ## Required options
     *
     * @param {String[]} Options.List - The array of strings to associated with the filter.
     *
     * @param {*} Options.CallbackAdd - A `Func` or callable object that is called when an item
     * that was previously filtered has become unfiltered. When using {@link FilterStrings} with
     * a gui control, `Options.CallbackAdd` is generally expected to add the string as an item to
     * the control that displays the strings to the user.
     *
     * The function receives two different indices. The index passed to the first parameter is the
     * index of the string in the `Options.List` array. The index passed to the second parameter is
     * the recommended position to insert the string in a hypothetical separate list that contains
     * only unfiltered strings. For example, when using {@link FilterStrings} with a gui control,
     * the string should be inserted into the control's internal list of strings at this index.
     * Inserting the string at this index will retain the original order of the string in
     * `Options.List`. If your code does not insert the strings at this index, then
     * `Options.CallbackDelete` must employ a custom approach for deleting the string because the
     * index passed to the second parameter of `Options.CallbackDelete` will be invalid.
     *
     * Also see the description for `Options.HwndCtrl`.
     *
     * Also see:
     * - {@link FilterStrings_CallbackAddComboBox}
     * - {@link FilterStrings_CallbackAddListBox}
     * - {@link FilterStrings_InsertStringComboBox}
     * - {@link FilterStrings_InsertStringListBox}
     *
     * Parameters:
     * 1. **{Integer}** - The index of the string in `Options.List`.
     * 2. **{Integer}** - The recommended position to insert the string in a list of unfiltered
     *    strings (see the discussion above).
     * 3. **{FilterStrings}** - The {@link FilterStrings} object.
     *
     * Returns: **{Boolean}** - If the function returns a nonzero value, no further strings will be
     * compared to the current filter criterion (the string most recently returned by
     * `Options.CallbackGetCriterion`). The filter process will continue; `Options.CallbackGetCriterion`
     * will be called to retrieve a new criterion.
     *
     * @param {*} Options.CallbackDelete - A `Func` or callable object that is called when an item
     * becomes filtered. When using {@link FilterStrings} with a gui control, `Options.CallbackDelete`
     * is generally expected to remove the string from the control that displays the strings to
     * the user.
     *
     * The function receives two different indices. The index passed to the first parameter is the
     * index of the string in the `Options.List` array. The index passed to the second parameter is
     * the expected 1-based index of the string in a hypothetical list of unfiltered strings. While
     * {@link FilterStrings} does not actually create an array that only contains the currently
     * unfiltered strings, it tracks the expected position of the strings while executing the filter
     * process. As long as `Options.CallbackAdd` inserts the strings at the recommended index, the
     * index passed to the second parameter of `Options.CallbackDelete` should be correct. Otherwise,
     * your code will need to identify the correct index.
     *
     * Also see the description for `Options.HwndCtrl`.
     *
     * Also see {@link FilterStrings_CallbackDelete}.
     *
     * Parameters:
     * 1. **{Integer}** - The index of the word in `Options.List`.
     * 2. **{Integer}** - The expected 1-based index of the string in a list of unfiltered strings
     *    (see the discussion above).
     * 3. **{FilterStrings}** - The {@link FilterStrings} object.
     *
     * Returns: **{Boolean}** - If the function returns a nonzero value, no further words will be
     * compared to the current filter criterion (the string most recently returned by
     * `Options.CallbackGetCriterion`). The filter process will continue; `Options.CallbackGetCriterion`
     * will be called to retrieve a new criterion.
     *
     * @param {*} Options.CallbackGetCriterion - A `Func` or callable object that returns the
     * filter criterion. Generally this is expected to be a function that returns input from the
     * user to filter a list of strings. You can use {@link FilterStrings_GetControlTextFunc}
     * to get a function that returns a control's "Text" property.
     *
     * Parameters: None.
     *
     * Returns **{String}** - The string that will be passed to `CallbackFilter` with items
     * from the array.
     *
     * @example
     * #include <DisplayConfig>
     *
     * g := Gui()
     * g.Add("ListView", "w500 r5", [ "Words" ])
     * inputEdit := g.Add("Edit", "w500")
     * options := {}
     * options.CallbackGetCriterion := FilterStrings_GetControlTextFunc(inputEdit)
     * @
     *
     * ## Common options
     *
     * @param {*} [Options.CallbackEnd] - A `Func` or callable object that is called when the filter
     * process ends. If the filter process is invoked by an event handler, `Options.CallbackEnd`
     * should be defined with a function that enables the event handler.
     *
     * Also see the description for `Options.HwndCtrlEventHandler`.
     *
     * Parameters:
     * 1. **{FilterStrings}** - The {@link FilterStrings} object.
     *
     * The return value is ignored.
     *
     * @example
     * CallbackEnd(filterStringsObj) {
     *     ; Enable the event handler.
     *     filterStringsObj.CtrlEventHandler.OnEvent('Change', OnChangeEdit, 1)
     * }
     * OnChangeEdit(Ctrl, *) {
     *     ; Disable the event handler.
     *     Ctrl.OnEvent('Change', OnChangeEdit, 0)
     *     ; Call the filter object.
     *     Ctrl.Filter.Call()
     * }
     * @
     *
     * @param {*} [Options.CallbackFilter = FilterStrings_CallbackFilter] - The comparison function.
     * The default is {@link FilterStrings_CallbackFilter}.
     *
     * Parameters:
     * 1. **{String}** - The array item being evaluated.
     * 2. **{String}** - The filter criterion returned by `Options.CallbackGetCriterion`.
     *
     * Returns: **{Boolean}** - The function should return nonzero if the item is to be unfiltered.
     * The function should return zero or an empty string if the item is to be filtered.
     *
     * @param {Integer} [Options.HwndCtrl] - The handle to the control that is associated
     * with the array of words. The handle is not used directly by {@link FilterStrings};
     * it is included as an option because you will likely need the handle within the body of the
     * `Options.CallbackAdd` and `Options.CallbackDelete` functions. The value of `Options.HwndCtrl`
     * is set to property {@link FilterStrings#HwndCtrl}, and property
     * {@link FilterStrings.Prototype.Ctrl} returns a reference to the control object.
     *
     * @param {Integer} [Options.HwndCtrlEventHandler] - The handle to the control that is associated
     * with the event handler that initiates the filter process (i.e. the event handler that calls
     * {@link FilterStrings.Prototype.Call}). The handle is not used directly by {@link FilterStrings};
     * it is included as an option because, if the filter process is invoked by an event handler
     * associated with a gui control, you will likely need the handle within the body of the
     * `Options.CallbackEnd` function. The value of `Options.HwndCtrlEventHandler` is set to property
     * {@link FilterStrings#HwndCtrlEventHandler}, and property
     * {@link FilterStrings.Prototype.CtrlEventHandler} returns a reference to the control object.
     *
     * ## Other options
     *
     * @param {*} [Options.CallbackReset] - A `Func` or callable object that is called when the
     * filter criterion returned by `Options.CallbackGetCriterion` is an empty string. The function
     * is expected to process all currently filtered items so they become unfiltered. If
     * `Options.CallbackReset` is unset, the filter process simply calls `Options.CallbackAdd` for
     * each currently filtered item.
     *
     * Parameters:
     * 1. **{FilterStrings}** - The {@link FilterStrings} object.
     *
     * The return value is ignored.
     *
     * @param {Boolean} [Options.CaseSense = false] - At the start of each iteration of the filter
     * process, if `Options.CallbackGetCriterion` returns text, the process may evaluate one or both
     * of the following expressions:
     *
     * `if InStr(Criterion, PreviousCriterion, CaseSense) == 1`
     *
     * `if InStr(PreviousCriterion, Criterion, CaseSense) == 1`
     *
     * In the expressions, `Criterion` is the string returned by `Options.CallbackGetCriterion`.
     * `PreviousCriterion` is the string `Options.CallbackGetCriterion` returned at the start of the
     * previous iteration. `CaseSense` is the value of {@link FilterStrings#CaseSense}, which
     * is initially set with `Options.CaseSense`.
     *
     * The former expression checks to see if characters were added to the end of the filter text.
     * The latter checks to see if characters were removed. If either returns true, the code that
     * executes subsequently is optimized for that context.
     *
     * @param {Integer} [Options.Delay = 50] - Specifies the amount of time in milliseconds that
     * the filter loop idles between each iteration.
     *
     * @param {Integer} [Options.EndThreshold = 500] - Specifies the amount of time in
     * milliseconds that must pass without any change to the filter criterion (the value returned by
     * `Options.CallbackGetCriterion`) to end the filter process.
     *
     * @param {Integer} [Options.Priority = 0] - The value to pass to the `Priority` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/SetTimer.htm SetTimer} when queuing up the
     * next filter loop iteration.
     */
    __New(Options) {
        this.List := Options.List
        this.CallbackGetCriterion := Options.CallbackGetCriterion
        this.CallbackEnd := Options.CallbackEnd
        this.CallbackAdd := Options.CallbackAdd
        this.CallbackDelete := Options.CallbackDelete
        if HasProp(Options, 'CallbackFilter') {
            this.CallbackFilter := Options.CallbackFilter
        }
        if HasProp(Options, 'CallbackReset') {
            this.CallbackReset := Options.CallbackReset
        }
        if HasProp(Options, 'CaseSense') {
            this.CaseSense := Options.CaseSense
        }
        if HasProp(Options, 'Delay') {
            this.Delay := Options.Delay
        }
        if HasProp(Options, 'EndThreshold') {
            this.EndThreshold := Options.EndThreshold
        }
        if HasProp(Options, 'HwndCtrl') {
            this.HwndCtrl := Options.HwndCtrl
        }
        if HasProp(Options, 'HwndCtrlEventHandler') {
            this.HwndCtrlEventHandler := Options.HwndCtrlEventHandler
        }
        if HasProp(Options, 'Priority') {
            this.Priority := Options.Priority
        }
        this.Filtered := Buffer(Options.List.Length, 0)
        this.PreviousCriterion := ''
        this.Time := 0
    }
    Call() {
        if criterion := this.CallbackGetCriterion.Call() {
            if this.PreviousCriterion == criterion {
                if this.Time {
                    if A_TickCount - this.Time > this.EndThreshold {
                        if this.CallbackEnd {
                            this.CallbackEnd.Call(this)
                        }
                        this.Time := 0
                        return
                    }
                } else {
                    this.Time := A_TickCount
                }
            } else {
                originalCritical := Critical(-1)
                callbackAdd := this.CallbackAdd
                callbackDelete := this.CallbackDelete
                callbackFilter := this.CallbackFilter
                list := this.List
                ptr := this.Filtered.Ptr - 1
                i := 1
                if !this.PreviousCriterion || InStr(criterion, this.PreviousCriterion, this.CaseSense) == 1 {
                    loop list.Length {
                        if !NumGet(ptr, A_Index, 'char') {
                            if callbackFilter(list[A_Index], criterion) {
                                ++i
                            } else {
                                NumPut('char', 1, ptr, A_Index)
                                if callbackDelete(A_Index, i, this) {
                                    break
                                }
                            }
                        }
                    }
                } else if InStr(this.PreviousCriterion, criterion, this.CaseSense) == 1 {
                    loop list.Length {
                        if NumGet(ptr, A_Index, 'char') {
                            if callbackFilter(list[A_Index], criterion) {
                                NumPut('char', 0, ptr, A_Index)
                                if callbackAdd(A_Index, i++, this) {
                                    break
                                }
                            }
                        } else {
                            ++i
                        }
                    }
                } else {
                    loop list.Length {
                        if NumGet(ptr, A_Index, 'char') {
                            if callbackFilter(list[A_Index], criterion) {
                                NumPut('char', 0, ptr, A_Index)
                                if callbackAdd(A_Index, i++, this) {
                                    break
                                }
                            }
                        } else if callbackFilter(list[A_Index], criterion) {
                            ++i
                        } else {
                            NumPut('char', 1, ptr, A_Index)
                            if callbackDelete(A_Index, i, this) {
                                break
                            }
                        }
                    }
                }
            }
            this.PreviousCriterion := criterion
        } else {
            this.Reset()
        }
        this.Time := A_TickCount
        SetTimer(ObjBindMethod(this, 'Call'), this.__timerPeriod, this.Priority)
        if IsSet(originalCritical) {
            Critical(originalCritical)
        }
    }

    Add(Str, Index?) {
        originalCritical := Critical(-1)
        filtered := this.Filtered
        ptr := filtered.Ptr - 1
        filtered.Size := this.List.Length + 1
        if IsSet(Index) {
            Index--
            DllCall(
                g_msvcrt_memmove
              , 'ptr', filtered.Ptr + Index + 1
              , 'ptr', filtered.Ptr + Index
              , 'int', filtered.Size - Index - 1
              , 'cdecl'
            )
            if criterion := this.CallbackGetCriterion.Call() {
                i := 0
                loop Index {
                    if !NumGet(ptr, A_Index, 'char') {
                        ++i
                    }
                }
                this.List.InsertAt(++Index, Str)
                if this.CallbackFilter.Call(Str, criterion) {
                    this.CallbackAdd.Call(Index, ++i, this)
                    NumPut('char', 0, ptr, Index)
                } else {
                    NumPut('char', 1, ptr, Index)
                }
            } else {
                this.List.InsertAt(++Index, Str)
                this.CallbackAdd.Call(Index, Index, this)
                NumPut('char', 0, ptr, Index)
            }
        } else if criterion := this.CallbackGetCriterion.Call() {
            i := 0
            Index := this.List.Length
            loop Index {
                if !NumGet(ptr, A_Index, 'char') {
                    ++i
                }
            }
            this.List.Push(Str)
            if this.CallbackFilter.Call(Str, criterion) {
                this.CallbackAdd.Call(++Index, ++i, this)
                NumPut('char', 0, ptr, Index)
            } else {
                NumPut('char', 1, ptr, ++Index)
            }
        } else {
            this.List.Push(Str)
            i := this.List.Length
            this.CallbackAdd.Call(i, i, this)
            NumPut('char', 0, ptr, i)
        }
        Critical(originalCritical)
    }
    AddMultiple(Str, Index?) {
        originalCritical := Critical(-1)
        callbackAdd := this.CallbackAdd
        callbackFilter := this.CallbackFilter
        filtered := this.Filtered
        list := this.List
        filtered.Size := list.Length + Str.Length
        ptr := filtered.Ptr - 1
        if list.Capacity < filtered.Size {
            list.Capacity := filtered.Size
        }
        if IsSet(Index) {
            Index--
            DllCall(
                g_msvcrt_memmove
              , 'ptr', filtered.Ptr + Index + Str.Length
              , 'ptr', filtered.Ptr + Index
              , 'int', filtered.Size - Index - Str.Length
              , 'cdecl'
            )
            if criterion := this.CallbackGetCriterion.Call() {
                i := 0
                loop Index {
                    if !NumGet(ptr, A_Index, 'char') {
                        ++i
                    }
                }
                loop Str.Length {
                    list.InsertAt(++Index, Str[A_Index])
                    if callbackFilter(Str[A_Index], criterion) {
                        callbackAdd(Index, ++i, this)
                        NumPut('char', 0, ptr, Index)
                    } else {
                        NumPut('char', 1, ptr, Index)
                    }
                }
            } else {
                loop Str.Length {
                    list.InsertAt(++Index, Str[A_Index])
                    callbackAdd(Index, Index, this)
                    NumPut('char', 0, ptr, Index)
                }
            }
        } else if criterion := this.CallbackGetCriterion.Call() {
            i := 0
            Index := list.Length
            loop Index {
                if !NumGet(ptr, A_Index, 'char') {
                    ++i
                }
            }
            loop Str.Length {
                list.Push(Str[A_Index])
                if callbackFilter(Str[A_Index], criterion) {
                    callbackAdd(++Index, ++i, this)
                    NumPut('char', 0, ptr, Index)
                } else {
                    NumPut('char', 1, ptr, ++Index)
                }
            }
        } else {
            Index := list.Length
            loop Str.Length {
                list.Push(Str[A_Index])
                callbackAdd(++Index, Index, this)
                NumPut('char', 0, ptr, Index)
            }
        }
        Critical(originalCritical)
    }
    Delete(Index, Length := 1) {
        originalCritical := Critical(-1)
        callbackDelete := this.CallbackDelete
        callbackFilter := this.CallbackFilter
        filtered := this.Filtered
        list := this.List
        ptr := filtered.Ptr - 1
        k := Index - 1
        if criterion := this.CallbackGetCriterion.Call() {
            i := 0
            loop k {
                if !NumGet(ptr, A_Index, 'char') {
                    ++i
                }
            }
            ++i
            loop Length {
                if !NumGet(ptr, ++k, 'char') {
                    callbackDelete(k, i, this)
                }
            }
        } else {
            loop Length {
                callbackDelete(++k, Index, this)
            }
        }
        list.RemoveAt(Index, Length)
        DllCall(
            g_msvcrt_memmove
          , 'ptr', filtered.Ptr + Index
          , 'ptr', filtered.Ptr + Index + Length
          , 'int', filtered.Size - Index - Length
          , 'cdecl'
        )
        filtered.Size := list.Length
        Critical(originalCritical)
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
    Reset() {
        if this.CallbackReset {
            this.CallbackReset.Call(this)
            this.Filtered := Buffer(this.List.Length, 0)
        } else {
            callbackAdd := this.CallbackAdd
            list := this.List
            ptr := this.Filtered.Ptr - 1
            i := 1
            loop list.Length {
                if NumGet(ptr, A_Index, 'char') {
                    NumPut('char', 0, ptr, A_Index)
                    callbackAdd(A_Index, i++, this)
                } else {
                    ++i
                }
            }
        }
        this.PreviousCriterion := ''
    }

    Ctrl => GuiCtrlFromHwnd(this.HwndCtrl)
    CtrlEventHandler => GuiCtrlFromHwnd(this.HwndCtrlEventHandler)
    Delay {
        Get => this.__timerPeriod * -1
        Set => this.__timerPeriod := Abs(Value) * -1
    }
}

/**
 * @description - This function can be used as `Options.CallbackAdd` for combo box controls and
 * dropdown-list controls.
 * @param {Integer} indexList - The index of the string that is to be inserted.
 * @param {Integer} indexCtrl - The 1-based index at which the string should be inserted into the
 * control's list.
 * @param {FilterStrings} filterStringsObj - The {@link FilterStrings} object.
 * @throws {OSError} - "Sending CB_INSERTSTRING failed."
 * @throws {OSError} - "Sending CB_INSERTSTRING failed due to insufficient space."
 */
FilterStrings_CallbackAddComboBox(indexList, indexCtrl, filterStringsObj) {
    switch FilterStrings_InsertStringComboBox(filterStringsObj.HwndCtrl, indexList, indexCtrl, filterStringsObj.List) {
        case 0: throw OSError('Sending CB_INSERTSTRING failed.')
        case -1: throw OSError('Sending CB_INSERTSTRING failed due to insufficient space.')
    }
}
/**
 * @description - This function can be used as `Options.CallbackAdd` for listbox controls.
 * @param {Integer} indexList - The index of the string that is to be inserted.
 * @param {Integer} indexCtrl - The 1-based index at which the string should be inserted into the
 * control's list.
 * @param {FilterStrings} filterStringsObj - The {@link FilterStrings} object.
 * @throws {OSError} - "Sending LB_INSERTSTRING failed."
 * @throws {OSError} - "Sending LB_INSERTSTRING failed due to insufficient space."
 */
FilterStrings_CallbackAddListBox(indexList, indexCtrl, filterStringsObj) {
    switch FilterStrings_InsertStringListBox(filterStringsObj.HwndCtrl, indexList, indexCtrl, filterStringsObj.List) {
        case 0: throw OSError('Sending LB_INSERTSTRING failed.')
        case -1: throw OSError('Sending LB_INSERTSTRING failed due to insufficient space.')
    }
}
/**
 * @description - This function can be used as `Options.CallbackDelete` for combobox controls,
 * dropdown-list controls, and listbox controls.
 * @param {Integer} indexList - The index in `list` of the string that is to be inserted.
 * @param {Integer} indexCtrl - The 1-based index at which the string should be inserted into the
 * control's list.
 * @param {FilterStrings} filterStringsObj - The {@link FilterStrings} object.
 */
FilterStrings_CallbackDelete(indexList, indexCtrl, filterStringsObj) {
    filterStringsObj.Ctrl.Delete(indexCtrl)
}
/**
 * @description - Breaks `criterion` into a series of substrings, then searches `item` for
 * the presence of each substring. If the entirety of `criterion` is found in `item`, and if each
 * substring is found in the same order they occur in `criterion`, then
 * {@link FilterStrings_CallbackFilter} returns nonzero.
 *
 * For example, the following would satisfy the condition:
 * - Criterion := "sample"
 * - Item := "Thi**s** is an ex**ample** item"
 *
 * @param {String} item - The string to potentially filter.
 * @param {String} criterion - The filter criterion.
 * @param {Boolean} [caseSense = false] - If true, string comparisons are case sensitive.
 * @param {String} [ignoreChars = "\W"] - A
 * {@link https://www.autohotkey.com/docs/v2/misc/RegEx-QuickRef.htm regular expression} that
 * specifies which characters are ignored. The default value causes
 * {@link FilterStrings_CallbackFilter} to ignore all non-word characters.
 * @returns {Boolean} - If `criterion` matches with `item`, returns true. Else, returns false.
 */
FilterStrings_CallbackFilter(item, criterion, caseSense := false, ignoreChars := '\W') {
    leftOffsetCriterion := leftOffsetItem := 1
    rightOffsetCriterion := 0
    _criterion := RegExReplace(criterion, ignoreChars, '')
    _item := RegExReplace(item, ignoreChars, '')
    lenCriterion := StrLen(_criterion)
    lenItem := StrLen(_item)
    loop {
        subCriterion := SubStr(_criterion, leftOffsetCriterion, lenCriterion - leftOffsetCriterion - rightOffsetCriterion + 1)
        if pos := InStr(_item, subCriterion, caseSense, leftOffsetItem) {
            lenSubCriterion := StrLen(subCriterion)
            leftOffsetItem := pos + lenSubCriterion
            leftOffsetCriterion += lenSubCriterion
            if leftOffsetCriterion > lenCriterion {
                return true
            } else {
                rightOffsetCriterion := 0
            }
        } else {
            rightOffsetCriterion++
            if rightOffsetCriterion + leftOffsetCriterion > lenCriterion {
                return false
            }
        }
    }
    return false
}
/**
 * @description - Breaks `criterion` into a series of substrings, then searches `item` for
 * the presence of each substring. If the number of characters that match with a substring in
 * `item` divided by the total number of non-ignored characters in `criterion` is greater than or
 * equal to `threshold`, {@link FilterStrings_CallbackFilterEx} returns nonzero.
 *
 * @param {String} item - The string to potentially filter.
 *
 * @param {String} criterion - The filter criterion.
 *
 * @param {Boolean} [caseSense = false] - If true, string comparisons are case sensitive.
 *
 * @param {String} [ignoreChars = "\W"] - A
 * {@link https://www.autohotkey.com/docs/v2/misc/RegEx-QuickRef.htm regular expression} that
 * specifies which characters are ignored. The default value causes
 * {@link FilterStrings_CallbackFilter} to ignore all non-word characters.
 *
 * @param {Float} [threshold = 1] - `threshold` specifies the required ratio of characters in
 * `criterion` that must match with a substring in `item` for the function to return nonzero.
 * For example, if `threshold := 0.5`, then 50% of the characters in `criterion` must match with
 * a substring in `item`. If `threshold := 1`, then 100% of the characters in `criterion` must match
 * with a substring in `item` (this is the behavior of {@link FilterStrings_CallbackFilter}).
 *
 * @param {Boolean} [backtracking = false] - If true, the calculation permits backtracking. Setting
 * `backtracking` to true will typically increase the number of matches because substrings can be
 * matched at any point in `item`.
 *
 * If false, a matching substring only counts if it occurs after the end of the previous matches.
 * {@link FilterStrings_CallbackFilterEx} will still check for matching substrings that occur at a
 * position before the end of the previous match, and if the character length of a match exceeds the
 * sum of the lengths of matches within that range, then the former matches are removed from the
 * list of matches and are replaced with the new, longer match.
 *
 * @returns {Boolean} - If the number of characters that match with a substring in
 * `item` divided by the total number of non-ignored characters in `criterion` is greater than or
 * equal to `threshold`, {@link FilterStrings_CallbackFilterEx} returns nonzero.
 *
FilterStrings_CallbackFilterEx(item, criterion, caseSense := false, ignoreChars := '\W', threshold := 1, backtracking := false) {
    leftOffsetCriterion := leftOffsetItem := 1
    rightOffsetCriterion := chars := 0
    _criterion := RegExReplace(criterion, ignoreChars, '')
    _item := RegExReplace(item, ignoreChars, '')
    lenCriterion := StrLen(_criterion)
    lenItem := StrLen(_item)
    found := []
    if backtracking {
        loop {
            subCriterion := SubStr(_criterion, leftOffsetCriterion, lenCriterion - leftOffsetCriterion - rightOffsetCriterion + 1)
            if pos := InStr(_item, subCriterion, caseSense, leftOffsetItem) {
                lenSubCriterion := StrLen(subCriterion)
                if _Proc() {
                    break
                } else {
                    continue
                }
            } else {
                rightOffsetCriterion++
                if rightOffsetCriterion + leftOffsetCriterion > lenCriterion {
                    return false
                }
            }
        }
    } else {
        loop {
            subCriterion := SubStr(_criterion, leftOffsetCriterion, lenCriterion - leftOffsetCriterion - rightOffsetCriterion + 1)
            if pos := InStr(_item, subCriterion, caseSense, leftOffsetItem) {
                lenSubCriterion := StrLen(subCriterion)
                if _Proc() {
                    break
                } else {
                    continue
                }
            } else if pos := InStr(_item, subCriterion, caseSense) {
                lenSubCriterion := StrLen(subCriterion)
                i := found.Length + 1
                _chars := 0
                loop {
                    if --i < 1 || found[i].leftOffsetItem + found[i].lenSubCriterion < pos {
                        break
                    }
                    _chars += found[i].lenSubCriterion
                }
                if lenSubCriterion > _chars {
                    found.Length := i
                    if _Proc() {
                        break
                    } else {
                        continue
                    }
                }
            }
            rightOffsetCriterion++
            if rightOffsetCriterion + leftOffsetCriterion > lenCriterion {
                if ++leftOffsetCriterion > lenCriterion {
                    break
                }
                rightOffsetCriterion := 0
            }
        }
    }
    for foundInfo in found {
        chars += foundInfo.lenSubCriterion
    }
    return (chars / lenCriterion) >= threshold

    _Proc() {
        found.Push({ lenSubCriterion: lenSubCriterion, leftOffsetItem: leftOffsetItem })
        leftOffsetItem := pos + lenSubCriterion
        leftOffsetCriterion += lenSubCriterion
        if leftOffsetCriterion > lenCriterion {
            return 1
        } else {
            rightOffsetCriterion := 0
        }
    }
}
*/
/**
 * @description - Returns the text of the indicated item of a combo box control or a dropdown-list
 * control. See {@link https://learn.microsoft.com/en-us/windows/win32/controls/cb-getlbtext}.
 * @param {Integer} hwnd - The control's hwnd.
 * @param {Integer} index - The 1-based index of the item.
 * @returns {String} - The item's text.
 */
FilterStrings_GetComboBoxText(hwnd, index) {
    buf := Buffer(SendMessage(0x0149, index - 1, , hwnd) * 2) ; CB_GETLBTEXTLEN
    SendMessage(0x0148, index - 1, buf.Ptr, hwnd) ; CB_GETLBTEXT
    return StrGet(buf, buf.Size / 2)
}
/**
 * @description - Returns a function that can be assigned to `Options.CallbackGetCriterion`. The
 * function can be called with 0 parameters and it returns the value of the "Text" property of the
 * object.
 * @param {dGui.Control|Gui.Control} ctrl - The control object.
 * @returns {BoundFunc}
 */
FilterStrings_GetControlTextFunc(ctrl) {
    return Gui.Control.Prototype.GetOwnPropDesc('Text').Get.Bind(ctrl)
}
/**
 * @description - Returns the text of the indicated item of a listbox control.
 * See {@link https://learn.microsoft.com/en-us/windows/win32/controls/lb-gettext}.
 * @param {Integer} hwnd - The control's hwnd.
 * @param {Integer} index - The 1-based index of the item.
 * @returns {String} - The item's text.
 */
FilterStrings_GetListBoxText(hwnd, index) {
    buf := Buffer(SendMessage(0x018A, index - 1, , hwnd) * 2) ; LB_GETTEXTLEN
    SendMessage(0x0189, index - 1, buf.Ptr, hwnd) ; LB_GETTEXT
    return StrGet(buf, buf.Size / 2)
}
/**
 * @description - Inserts a string at the specified index.
 * See {@link https://learn.microsoft.com/en-us/windows/win32/controls/cb-insertstring}.
 * @param {Integer} hwnd - The handle associated with a combo box control or dropdown-list control.
 * @param {Integer} indexList - The index in `list` of the string that is to be inserted.
 * @param {Integer} indexCtrl - The 1-based index at which the string should be inserted into the
 * control's list.
 * @param {String[]} list - The array containing the string to insert.
 * @returns {Integer} - If successful, returns the 1-based index at which the string was inserted.
 * If unsuccessful, returns one of the following:
 * - 0 : An error occurred.
 * - -1 : There is insufficient space to store the new string.
 */
FilterStrings_InsertStringComboBox(hwnd, indexList, indexCtrl, list) {
    return SendMessage(0x014A, indexCtrl - 1, StrPtr(list[indexList]), hwnd) + 1 ; CB_INSERTSTRING
}
/**
 * @description - Inserts a string at the specified index.
 * See {@link https://learn.microsoft.com/en-us/windows/win32/controls/lb-insertstring}.
 * @param {Integer} hwnd - The handle associated with a listbox control.
 * @param {Integer} indexList - The index in `list` of the string that is to be inserted.
 * @param {Integer} indexCtrl - The 1-based index at which the string should be inserted into the
 * control's list.
 * @param {String[]} list - The array containing the string to insert.
 * @returns {Integer} - If successful, returns the 1-based index at which the string was inserted.
 * If unsuccessful, returns one of the following:
 * - 0 : An error occurred.
 * - -1 : There is insufficient space to store the new string.
 */
FilterStrings_InsertStringListBox(hwnd, indexList, indexCtrl, list) {
    return SendMessage(0x0181, indexCtrl - 1, StrPtr(list[indexList]), hwnd) + 1 ; LB_INSERTSTRING
}
