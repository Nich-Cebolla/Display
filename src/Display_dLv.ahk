

class dLv {


    /**
     * @description - Searches a listview column for a matching string.
     * @param {Gui.ListView} Self - The ListView control object. If calling this from an instance,
     * exclude this parameter.
     * @param {String} Text - The text to search for.
     * @param {Number} [Col=1] - The column to search in. If omitted, the search will be performed
     * on all columns.
     * @returns {Number|Object} - If Col is provided, the function returns the row number where the
     * text was found. If Col is omitted, the function returns an object with two properties: Row and Col.
     * Row is the row number where the text was found, and Col is the column number where the text was found.
     */
    static Find(Self, Text, Col := 1) {
        if Col {
            loop Self.GetCount() {
                if Self.GetText(A_Index, Col) = Text
                    return A_Index
            }
        } else {
            i := 0
            loop Self.GetCount('Col') {
                i++
                loop Self.GetCount() {
                    if Self.GetText(A_Index, i) = Text
                        return  { Row: A_Index, Col: i }
                }
            }
        }
    }

    /**
     * @description - Returns an array of checked rows.
     * @param {Gui.ListView} Self - The ListView control object. If calling this from an instance,
     * exclude this parameter.
     * @param {Boolean} [Uncheck=true] - If true, rows are unchecked during the process.
     * @param {Function} [Callback=(LV, Row, Result) => Result.Push({ Row: Row, Text: LV.GetText(Row, 1) })] -
     * If provided, the callback is called for each checked row. The callback will receive three parameters:
     * the ListView control object, the row number, and the result array. The callback does not need to
     * return anything, and if it does, it is ignored. The callback should either take some action on the row,
     * or it should fill the Result array, which will be returned at the end of the `GetChecked` function.
     * The default callback fills the Result array with an object for each checked row, the object having
     * two properties: Row and Text. The Text is obtained from the first column in the ListView.
     */
    static GetRows(Self, RowType := 'Checked', Uncheck := true
     , Callback := (LV, Row, Result) => Result.Push({ Row: Row, Text: LV.GetText(Row, 1) })) {
        Row := 0, Result := []
        if SubStr(RowType, 1, 1) == 'C' {
            if Uncheck && Callback
                return _ProcessUncheckCallback()
            if Callback
                return _ProcessCallback()
            if Uncheck
                return _ProcessUncheck()
        } else if SubStr(RowType, 1, 1) == 'F' {
            if Callback
                return _ProcessCallback()
        }
        return _Process()

        _Process() {
            Loop {
                Row := Self.GetNext(Row, RowType)
                if !Row
                    return Result.Length ? Result : ''
                Result.Push(Row)
            }
        }
        _ProcessCallback() {
            Loop {
                Row := Self.GetNext(Row, RowType)
                if !Row
                    return Result.Length ? Result : ''
                Callback(Self, Row, Result)
            }
        }
        _ProcessUncheck() {
            Loop {
                Row := Self.GetNext(Row, RowType)
                if !Row
                    return Result.Length ? Result : ''
                Self.Modify(Row, '-check')
                Result.Push(Row)
            }
        }
        _ProcessUncheckCallback() {
            Loop {
                Row := Self.GetNext(Row, RowType)
                if !Row
                    return Result.Length ? Result : ''
                Self.Modify(Row, '-check')
                Callback(Self, Row, Result)
            }
        }
    }

    /**
     * @description - Adds an object or an array of objects to the ListView control. The column names
     * are used a map keys / object properties to access values to add to the ListView row. For property
     * names, if there are illegal characters in the column name, they are removed.
     * @param {Gui.ListView} Self - The ListView control object. If calling this from an instance,
     * exclude this parameter.
     * @param {Object|Array} Obj - The object or array of objects to add to the ListView. The objects
     * should have keys / properties corresponding to the column names. The objects do not need to have
     * every value; absent keys and properties will default to an empty string.
     * @param {String} [Opt] - A string containing options for the ListView. The options are the same
     * as those used in the `Modify` method.
     * @returns {Number} - The row number where the object was added.
     */
    static AddObj(Self, Obj, Opt?) {
        local Row
        if Obj is Array {
            for O in Obj
                _Process(O)
        } else
            _Process(Obj)
        return Row

        _Process(Obj) {
            Row := Self.Add(Opt ?? unset)
            if Obj is Map {
                for Col in Self.Cols(, 1) {
                    Col := RegExReplace(Col, '[^a-zA-Z0-9_]', '')
                    Self.Modify(Row, 'Col' A_Index, Obj.Has(Col) ? Obj.Get(Col) : '')
                }
            } else {
                for Col in Self.Cols(, 1) {
                    Col := RegExReplace(Col, '[^a-zA-Z0-9_]', '')
                    Self.Modify(Row, 'Col' A_Index, Obj.HasOwnProp(Col) ? Obj.%Col% : '')
                }
            }
        }
    }

    /**
     * @description - Updates an object or an array of objects within the ListView control. The column
     * names are used a map keys / object properties to access values to add to the ListView row. For
     * property names, if there are illegal characters in the column name, they are removed.
     * @param {Gui.ListView} Self - The ListView control object. If calling this from an instance,
     * exclude this parameter.
     * @param {Object|Array} Obj - The object or array of objects to update in the ListView. The objects
     * should have keys / properties corresponding to the column names. The objects do not need to have
     * every value; absent keys and properties will default to an empty string.
     * @param {Number} [MatchCol=1] - The column to match the object on. For example, if my ListView
     * has a column "Name" that I want to use for this purpose, my objects must all have a property
     * or key "Name" that matches with a row of text in the ListView.
     * @param {Number} [StartCol=1] - The column to start updating from.
     * @param {Number} [EndCol] - The column to stop updating at.
     * @param {String} [Opt] - A string containing options for the ListView. The options are the same
     * as those used in the `Modify` method.
     */
    static UpdateObj(Self, Obj, MatchCol := 1, StartCol := 1, EndCol?, Opt?) {
        if !IsSet(EndCol)
            EndCol := Self.GetCount('Col')
        MaxRow := Self.GetCount()

        if Obj is Array {
            if Obj[1] is Map {
                Name := Self.GetText(0, MatchCol)
                for O in Obj
                    ListObjs .= O[Name] '`n'
                for RowTxt in Self.Rows(MatchCol)
                    ListRows .= Txt '`n'
                ListObjs := StrSplit(Sort(Trim(ListObjs, '`n')), '`n')
                ListRows := StrSplit(Sort(Trim(ListRows, '`n')), '`n')
                Row := i := 0
                for ObjName in ListObjs {
                    ++i
                    while ++Row <= MaxRow {
                        if ListRows[Row] == ObjName {
                            k := StartCol - 1
                            while ++k <= EndCol {
                                ColName := Self.GetText(0, k)
                                Self.Modify(Row, 'Col' k, Obj[i].Has(ColName) ? Obj[i].Get(ColName) : '')
                            }
                            if IsSet(Opt)
                                Self.Modify(Row, Opt)
                            break
                        }
                    }
                }
                if i !== ListObjs.Length
                    throw Error('Not all objects were found in the ListView.'
                    'The unmatched object is:`r`n' Obj[i].Stringify(), -1)
            } else {
                Name := RegExReplace(Self.GetText(0, MatchCol), '[^a-zA-Z0-9_]', '')
                Columns := []
                z := StartCol - 1
                while ++z <= EndCol
                    Columns.Push(RegExReplace(Self.GetText(0, z), '[^a-zA-Z0-9_]', ''))
                for O in Obj
                    ListObjs .= O.%Name% '`n'
                for Txt in Self.Rows(MatchCol)
                    ListRows .= Txt '`n'
                ListObjs := StrSplit(Sort(Trim(ListObjs, '`n')), '`n')
                ListRows := StrSplit(Sort(Trim(ListRows, '`n')), '`n')
                Row := i := 0
                for ObjName in ListObjs {
                    ++i
                    while ++Row <= MaxRow {
                        if ListRows[Row] == ObjName {
                            k := StartCol - 1
                            while ++k <= EndCol {
                                Self.Modify(Row, 'Col' k, Obj[i].HasOwnProp(Columns[A_Index]) ? Obj[i].%Columns[A_Index]% : '')
                            }
                            if IsSet(Opt)
                                Self.Modify(Row, Opt)
                            break
                        }
                    }
                }
                if i !== ListObjs.Length
                    throw Error('Not all objects were found in the ListView.'
                    'The unmatched object is:`r`n' Obj[i].Stringify(), -1)
            }
        } else {
            if Obj is Map {
                for RowText in Self.Rows(MatchCol) {
                    if Obj[Name] == RowText {
                        while ++k <= EndCol {
                            ColName := Self.GetText(0, k)
                            Self.Modify(A_Index, 'Col' k, Obj[i].Has(ColName) ? Obj[i].Get(ColName) : '')
                        }
                        if IsSet(Opt)
                            Self.Modify(A_Index, Opt)
                        break
                    }
                }
            } else {
                for RowText in Self.Rows(MatchCol) {
                    if Obj.%RegExReplace(Name, '[^a-zA-Z0-9_]', '')% == RowText {
                        while ++k <= EndCol {
                            ColName := RegExReplace(Self.GetText(0, k), '[^a-zA-Z0-9_]', '')
                            Self.Modify(A_Index, 'Col' k, Obj[i].HasOwnProp(ColName) ? Obj[i].%ColName% : '')
                        }
                        if IsSet(Opt)
                            Self.Modify(A_Index, Opt)
                        break
                    }
                }
            }
        }
    }

    /**
     * @description - Enumerates the columns in the ListView control.
     * @example
       ;   Name            |     Age     |   Favorite Anime Character
       ; --------------------------------------------------------
       ; Johnny Appleseed  |      27     |    Holo
       ; Albert Einstein   |   Relative  |    Kurisu Makise
       ; The Rock          |      53     |    Konata Izumi

        for ColName in ListView.Cols()
            MsgBox(ColName) ; Name, Age, Favorite Anime Character
        for ColName, RowText in ListView.Cols(2)
            MsgBox(RowText) ; Albert Einstein, Relative, Kurisu Makise
     * @
     * @param {Gui.ListView} Self - The ListView control object. If calling this from an instance,
     * exclude this parameter.
     * @param {Number} [Row=1] - If using the enumerator in its two-parameter mode, you can specify
     * a row from which to obtain the text which gets passed to the second parameter.
     * @param {Number} [VarCount=1] - Specify if you are calling the enumerator in its 1-parameter mode
     * ( `for ColName in LV.Cols(, 1)` ) or its 2-parameter mode ( `for ColName, RowText in LV.Cols(RowNum, 2)` ).
     * @returns {Enumerator} - An enumerator function that can be used to iterate over the columns.
     */
    static Cols(Self, Row := 1, VarCount := 1) {
        i := 0, MaxCol := Self.GetCount('Col')
        if VarCount == 1 {
            return Enum1
        } else if VarCount == 2 {
            return Enum2
        }

        Enum1(&ColName) {
            if ++i > MaxCol
                return 0
            ColName := Self.GetText(0, i)
        }

        Enum2(&ColName, &RowText) {
            if ++i > MaxCol
                return 0
            ColName := Self.GetText(0, i)
            RowText := Self.GetText(Row, i)
        }
    }

    static Rows(Self, Col := 1, RowType := 0, VarCount := 1) {
        if SubStr(RowType, 1, 1) = 'C' ||  SubStr(RowType, 1, 1) = 'F' {
            i :=0
            if VarCount == 1 {
                return EnumSpecial1
            } else if VarCount == 2 {
                return EnumSpecial2
            }
        } else if !RowType {
            MaxRow := Self.GetCount()
            i := 0
            if VarCount == 1 {
                return EnumRow1
            } else if VarCount == 2 {
                return EnumRow2
            }
        } else
            throw Error('Invalid row type: ' RowType, -1)

        EnumRow1(&Text) {
            if ++i > MaxRow
                return 0
            Text := Self.GetText(i, Col)
        }

        EnumRow2(&Row, &Text) {
            if ++i > MaxRow
                return 0
            Row := i
            Text := Self.GetText(i, Col)
        }

        EnumSpecial1(&Row) {
            if !(i := (Self.GetNext(i, RowType)))
                return 0
            Row := i
        }

        EnumSpecial2(&Row, &Text) {
            if !(i := (Self.GetNext(i, RowType)))
                return 0
            Row := i
            Text := Self.GetText(i, Col)
        }
    }



    /**
     * @description - Updates an object or an array of objects within the ListView control. The other
     * `UpdateObj` function connects an object to a row by comparing the text content of an object
     * property / item value to the text content of a cell in the ListView. This may not be possible if
     * every value on the row / object has been changed. `UpdateWithCompareFunc` addresses that problem
     * by accepting a function parameter. The function should accept two input parameters:
     * - The text content of a cell in the ListView. The cell is at the intersection of `MatchCol` and
     * the current row being iterated.
     * - The text content of the property / item on the object that corresponds to the column name of
     * `MatchCol`.
     * The function should return a nonzero value if the object is associated with that row.
     * @param {Gui.ListView} Self - The ListView control object. If calling this from an instance,
     * exclude this parameter.
     * @param {Object|Array} Obj - The object or array of objects to update in the ListView. The objects
     * should have keys / properties corresponding to the column names. The objects do not need to have
     * every value; absent keys and properties will default to an empty string.
     * @param {Function} CompareFunc - The function that compares the text content of a cell in the ListView
     * to the text content of a property / item on the object. The function should return a nonzero value
     * if the object is associated with that row.
     * @param {Number} [MatchCol=1] - The column to match the object on. For example, if my ListView
     * has a column "Name" that I want to use for this purpose, my objects must all have a property
     * or key "Name" that matches with a row of text in the ListView.
     * @param {Number} [StartCol=1] - The column to start updating from.
     * @param {Number} [EndCol] - The column to stop updating at.
     * @param {String} [Opt] - A string containing options for the ListView. The options are the same
     * as those used in the `Modify` method.
     */
    static UpdateWithCompareFunc(Self, Obj, CompareFunc, MatchCol := 1, StartCol := 1, EndCol?, Opt?) {
        if !IsSet(EndCol)
            EndCol := Self.GetCount('Col')
        MaxRow := Self.GetCount()

        if Obj[1] is Map {
            Name := Self.GetText(0, MatchCol)
            for O in Obj
                ListObjs .= O[Name] '`n'
            for RowTxt in Self.Rows(MatchCol)
                ListRows .= Txt '`n'
            ListObjs := StrSplit(Sort(Trim(ListObjs, '`n')), '`n')
            ListRows := StrSplit(Sort(Trim(ListRows, '`n')), '`n')
            Row := i := 0
            for ObjName in ListObjs {
                ++i
                while ++Row <= MaxRow {
                    if CompareFunc(ListRows[Row], ObjName) {
                        k := StartCol - 1
                        while ++k <= EndCol {
                            ColName := Self.GetText(0, k)
                            Self.Modify(Row, 'Col' k, Obj[i].Has(ColName) ? Obj[i].Get(ColName) : '')
                        }
                        if IsSet(Opt)
                            Self.Modify(Row, Opt)
                        break
                    }
                }
            }
            if i !== ListObjs.Length
                throw Error('Not all objects were found in the ListView.'
                'The unmatched object is:`r`n' Obj[i].Stringify(), -1)
        } else {
            Name := RegExReplace(Self.GetText(0, MatchCol), '[^a-zA-Z0-9_]', '')
            Columns := []
            z := StartCol - 1
            while ++z <= EndCol
                Columns.Push(RegExReplace(Self.GetText(0, z), '[^a-zA-Z0-9_]', ''))
            for O in Obj
                ListObjs .= O.%Name% '`n'
            for Txt in Self.Rows(MatchCol)
                ListRows .= Txt '`n'
            ListObjs := StrSplit(Sort(Trim(ListObjs, '`n')), '`n')
            ListRows := StrSplit(Sort(Trim(ListRows, '`n')), '`n')
            Row := i := 0
            for ObjName in ListObjs {
                ++i
                while ++Row <= MaxRow {
                    if CompareFunc(ListRows[Row], ObjName) {
                        k := StartCol - 1
                        while ++k <= EndCol {
                            Self.Modify(Row, 'Col' k, Obj[i].HasOwnProp(Columns[A_Index]) ? Obj[i].%Columns[A_Index]% : '')
                        }
                        if IsSet(Opt)
                            Self.Modify(Row, Opt)
                        break
                    }
                }
            }
            if i !== ListObjs.Length
                throw Error('Not all objects were found in the ListView.'
                'The unmatched object is:`r`n' Obj[i].Stringify(), -1)
        }
    }

}
