
/**
 * @description - Adds one or more rows to the list-view using an array of arrays.
 * @param {Gui.ListView} LvCtrl - The `Gui.ListView` control.
 * @param {Array[]} List - An array of arrays. Each nested array represents a row to be added. The
 * rows are added using the expression `LvCtrl.Add(Opt, obj*)` where `obj` is a nested array.
 * @param {String} [Opt = ""] - A string containing options passed to
 * {@link https://www.autohotkey.com/docs/v2/lib/ListView.htm#Add Gui.ListView.Prototype.Add}.
 */
LvAddListArray(LvCtrl, List, Opt := '') {
    for obj in List {
        LvCtrl.Add(Opt, obj*)
    }
}
/**
 * @description - Adds one or more rows to the list-view using an array of `Map` objects.
 * @param {Gui.ListView} LvCtrl - The `Gui.ListView` control.
 * @param {Map[]} List - An array of `Map` objects. Each `Map` represents a row to be added. The `Map`
 * objects are expected to have items using keys that correspond with column headers. For each
 * column header, if the `Map` has an item with the same name, the item's value is added to
 * that column. If the `Map` does not have an item, the cell is empty.
 * @param {String} [Opt = ""] - A string containing options passed to
 * {@link https://www.autohotkey.com/docs/v2/lib/ListView.htm#Add Gui.ListView.Prototype.Add}.
 */
LvAddListMap(LvCtrl, List, Opt := '') {
    values := []
    headers := []
    loop values.Length := headers.Capacity := LvCtrl.GetCount('Col') {
        headers.Push(LvCtrl.GetText(0, A_Index))
    }
    for obj in List {
        for header in headers {
            values[A_Index] := obj.Has(header) ? obj.Get(header) : ''
        }
        LvCtrl.Add(Opt, values*)
    }
}
/**
 * @description - Adds one or more rows to the list-view using an array of `Object` objects.
 * @param {Gui.ListView} LvCtrl - The `Gui.ListView` control.
 * @param {Object[]} List - An array of `Object` objects. Each `Object` represents a row to be added.
 * The `Object` objects are expected to have properties with the same name as the column headers.
 * For each column header, if the `Object` has a property with the same name, the property's value
 * is added to that column. If the `Object` does not have a property, the cell is empty.
 * @param {String} [Opt = ""] - A string containing options passed to
 * {@link https://www.autohotkey.com/docs/v2/lib/ListView.htm#Add Gui.ListView.Prototype.Add}.
 */
LvAddListObject(LvCtrl, List, Opt := '') {
    values := []
    headers := []
    loop values.Length := headers.Capacity := LvCtrl.GetCount('Col') {
        headers.Push(LvCtrl.GetText(0, A_Index))
    }
    for obj in List {
        for header in headers {
            values[A_Index] := HasProp(obj, header) ? obj.%header% : ''
        }
        LvCtrl.Add(Opt, values*)
    }
}
/**
 * @description - Enumerates the columns in the ListView control. You can call this in a `for` loop.
 * @example
 * for ColName in ListViewCols(LvCtrl) {
 *     ; do work ...
 * }
 * @
 * @param {Gui.ListView} LvCtrl - The `Gui.ListView` control.
 * @returns {Func} - An enumerator function that can be used to iterate over the columns.
 */
LvCols(LvCtrl) {
    i := 0
    n := LvCtrl.GetCount('Col')

    return _Enum

    _Enum(&ColName) {
        if ++i > n {
            return 0
        }
        ColName := LvCtrl.GetText(0, i)
        return 1
    }
}
/**
 * @description - Searches a list-view for a string.
 * @param {dGui.ListView} LvCtrl - The `Gui.ListView` control.
 * @param {String} Text - The text to search for. The cell's contents must match `Text` in the
 * expression `LvCtrl.GetText(RowIndex, ColIndex) = Text`.
 * @param {Integer|Integer[]} [Col] - If set, either an array of integers or just an integer, each
 * value representing the index of a column to search within. When searching, each row is iterated
 * and the indicated columns are all checked before moving on to the next row. If unset, all
 * columns are checked.
 * @returns {Integer} - If a match is found, the row number of the match. Else, an empty string.
 */
LvFind(LvCtrl, Text, Col?) {
    if IsSet(Col) {
        if !IsObject(Col) {
            loop LvCtrl.GetCount() {
                if LvCtrl.GetText(A_Index, Col) = Text {
                    return A_Index
                }
            }
            return
        }
    } else {
        Col := []
        loop Col.Capacity := LvCtrl.GetCount('Col') {
            Col.Push(A_Index)
        }
    }
    i := 0
    loop LvCtrl.GetCount() {
        ++i
        for k in Col {
            if LvCtrl.GetText(i, k) = Text {
                return i
            }
        }
    }
}
/**
 * @description - Iterates the rows in a list-view, passing a cell's text to a callback function.
 * When the function returns nonzero, the search ends and the row number is returned.
 *
 * @param {dGui.ListView} LvCtrl - The `Gui.ListView` control.
 *
 * @param {*} Callback - The callback function.
 *
 * Parameters:
 * 1. **{String}** - The cell's text.
 * 2. **{Integer}** - The column index.
 * 3. **{Integer}** - The row index.
 * 4. **{Gui.ListView}** - The `Gui.ListView` control.
 *
 * If the function returns zero or an empty string, the search proceeds. If the function returns
 * a nonzero value, the search ends.
 *
 * @param {Integer|Integer[]} [Col] - If set, either an array of integers or just an integer, each
 * value representing the index of a column to search within. When searching, each row is iterated
 * and the indicated columns are all checked before moving on to the next row. If unset, all
 * columns are checked.
 *
 * @returns {Integer} - If a match is found, the row number associated with the match. Else, an empty
 * string.
 */
LvRows(LvCtrl, Callback, Col?) {
    if IsSet(Col) {
        if !IsObject(Col) {
            loop LvCtrl.GetCount() {
                if Callback(LvCtrl.GetText(A_Index, Col), Col, A_Index, LvCtrl) {
                    return A_Index
                }
            }
            return
        }
    } else {
        Col := []
        loop Col.Capacity := LvCtrl.GetCount('Col') {
            Col.Push(A_Index)
        }
    }
    i := 0
    loop LvCtrl.GetCount() {
        ++i
        for k in Col {
            if Callback(LvCtrl.GetText(i, k), k, i, LvCtrl) {
                return i
            }
        }
    }
}
/**
 * @description - Iterates the rows in the list-view using
 * {@link https://www.autohotkey.com/docs/v2/lib/ListView.htm#GetNext Gui.ListView.Prototype.GetNext}.
 * For each row, a callback function is called.
 *
 * @param {Gui.ListView} LvCtrl - The `Gui.ListView` control.
 *
 * @param {*} Callback - The callback function.
 *
 * Parameters:
 * 1. **{Integer}** - The row index.
 * 2. **{Gui.ListView}** - The `Gui.ListView` control.
 *
 * The function can return a nonzero value to end the process early.
 *
 * @param {String} [RowType = "C"] - One of the following:
 * - Blank or unset: Iterates the selected/highlighted rows.
 * - "C" or "Checked": Iterates the checked rows.
 * - "F" or "Focused": If a row is focused, calls `Callback` for that row. Else, does not call `Callback`.
 *
 * @param {Boolean} [Uncheck = true] - If true, and if `RowType` is "C" or "Checked",
 * {@link LvGetRows} unchecks the rows.
 *
 * @returns {Integer} - If `Callback` returns a nonzero value, the row number when that occurred. Else,
 * an empty string.
 */
LvRowsEx(LvCtrl, Callback, RowType := 'C', Uncheck := false) {
    i := 0
    if RowType {
        switch SubStr(RowType, 1, 1), 0 {
            case 'C':
                if Uncheck {
                    while i := LvCtrl.GetNext(i, RowType) {
                        LvCtrl.Modify(i, '-Check')
                        if Callback(i, LvCtrl) {
                            return i
                        }
                    }
                } else {
                    return _Proc()
                }
            case 'F':
                if i := LvCtrl.GetNext(0, RowType) {
                    if Callback(i, LvCtrl) {
                        return i
                    }
                }
            default: throw ValueError('Invalid row type.', , RowType)
        }
    } else {
        return _Proc()
    }

    return

    _Proc() {
        while i := LvCtrl.GetNext(i, RowType) {
            if Callback(i, LvCtrl) {
                return i
            }
        }
    }
}
