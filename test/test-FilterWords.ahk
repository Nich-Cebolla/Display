#include ..\templates\DisplayConfig.ahk

; There are several components to using `FilterStrings`

; A list of words
words := ['numerically','swathe','viverrine','debility','numb','sameness','parablast','disbud'
,'insoluble','indubitable','proposer','niccolite','immesh','seaboard','epicycle','petrify','boss'
,'mignonette','deference','beauxite','dimera','pintado','suzerain','synalepha','silken']

; An object that uses the words for something. In this example, we display them using a ListView.
g := gui('+Resize')
lv := g.Add('ListView', 'w300 r11 vcb', ['Word'])
; Add the words to the listview
for w in words {
    lv.Add(, w)
}

; A function that returns the text used for filtering. Typically this would be some input from
; the user, so in this case we will accomplish this by using an Edit control and defining the function
; to return its text value.
edt := g.Add('Edit', 'w300 r1 Section vEdtInput')
GetTextCallback(*) {
    global edt
    return edt.Text
}

; A function that adds items to the object. The function should have one to two parameters.
;   1. The index of the string in the array.
;   2. The filtered index, which is the index of the index in the "Indices" array. I can't think
;      of a good way to describe this in a way that would make more sense than simply looking at the
;      class definition to see what the "Indices" array is used for.
; In this case, we need to add the string to the ListView control. We exclude the second parameter
; because we don't need it here.
AddCallback(Index, *) {
    global lv
    lv.Add( , Words[Index])
}

; A function that deletes items from the object. The function should have one to two parameters.
;   1. The index of the string in the array.
;   2. The filtered index, which is the index of the index in the "Indices" array. As long as the
;      listview's contents has not been sorted or changed by he user, the `FilteredIndex` should be
;      the correct index to delete the string. However, if one's code cannot guarantee that this is
;      true, then it would be better to iterate the ListView's contents and find the string.
DeleteCallback(Index, *) {
    global lv
    loop lv.GetCount() {
        if lv.GetText(A_Index, 1) = words[index] {
            lv.Delete(A_Index)
            return
        }
    }
}

; An event that calls the filter.
HChangeEdit(*) {
    global edt
    ; Our event handler must disable the event handler, call the filter, then re-enable the event
    ; handler before returning.
    edt.OnEvent('Change', HChangeEdit, 0)
    edt.Gui.Filter.Call()
}
edt.OnEvent('Change', HChangeEdit)

; A function that re-enables the event handler
EndCallback(*) {
    global edt
    edt.OnEvent('Change', HChangeEdit, 1)
}

; In this example I assign the `FilterStrings` instance to a property on the gui object. This is usually
; a convenient choice, but isn't strictly necessary. The reference must be accessible from the event
; handler that calls the filter, and from any event handlers or functions that handle adding or
; deleting items from the array. While the `FilterStrings` function is active, to add items to the array
; you must call `FilterStrings.Prototype.Add`, and to delete items you must call `FilterStrings.Prototype.Delete`.
; If you don't do this, the filter and the list of words will be out of sync.
g.Filter := FilterStrings({
    list: words,
    callbackGetCriterion: GetTextCallback,
    callbackAdd: AddCallback,
    callbackDelete: DeleteCallback,
    callbackEnd: EndCallback
})

; Let's also add a couple buttons and another edit control to demonstrate adding and deleting items.
g.Add('Button', 'w93 xs ys+40 Section vBtnAdd', 'Add').OnEvent('Click', HClickButtonAdd)
g.Add('Button', 'w93 ys vBtnDelete', 'Delete').OnEvent('Click', HClickButtonDelete)
g.Add('Button', 'w93 ys vBtnClear', 'Clear').OnEvent('Click', (Ctrl, *) => Ctrl.Gui['EdtInput2'].Text := '')
g.Add('Edit', 'w300 xs vEdtInput2')

HClickButtonAdd(Ctrl, *) {
    g := Ctrl.Gui
    if g['EdtInput2'].Text {
        if g.HasOwnProp('TxtMessage') {
            g.TxtMessage.Text := ''
        }
        g.Filter.Add(g['EdtInput2'].Text)
    } else {
        Helper(g, 'Enter a word to add.')
    }
}
HClickButtonDelete(Ctrl, *) {
    g := Ctrl.Gui
    if g['EdtInput2'].Text {
        if g.HasOwnProp('TxtMessage') {
            g.TxtMessage.Text := ''
        }
        g.Filter.Delete(, g['EdtInput2'].Text)
    } else {
        Helper(g, 'Enter a word to delete.')
    }
}
Helper(g, msg) {
    if g.HasOwnProp('TxtMessage') {
        g.TxtMessage.Text := msg
    } else {
        g.TxtMessage := g.Add('Text', 'xs w300', msg)
        g.TxtMessage.GetPos(, &txty, , &txth)
        g.Show('h' (txty + txth + g.MarginY))
    }
}
g.show()
g.OnEvent('Close', (*) => ExitApp())


/* Description of `FilterCallback`:

`FilterCallback` will include strings for which `InStr(Item, Input)` returns nonzero, and also
includes strings that can be described as:
- If we break the input string into a series of substrings, `FilterCallback` will return nonzero if
both of the following are true:
- Each substring is found in the item.
- The substrings are represented in the item in the same order in which they appear in the input.

The process ignores case and whitespace.

To also ignore any non-word character, change these lines-
_Input := RegExReplace(Input, '\s', '')
_Item := RegExReplace(Item, '\s', '')

to-
_Input := RegExReplace(Input, '\W', '')
_Item := RegExReplace(Item, '\W', '')

For example, the following would satisfy the condition:
Item := "This is an example item"
Input := "Is ample"

But the following would not, because the substrings are not in the correct order:
Item := "This is an example item"
Input := "Is this an item"

Though `FilterStrings` doesn't make use of it, for each found substring `FilterCallback` populates an
array with integers representing these values:
[ <InputSubstringStartPos>, <InputSubstringLength>, <ItemFoundPos>, ... ]
These could be used to, for example, embolden the found substrings in a rich text control. The
handler function would need to calculate the lengths and positions including the whitespace
characters that were excluded from `FilterCallback`'s process.
