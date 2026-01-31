# Display
An AutoHotkey (AHK) library that provides tools for deploying attractive, user-friendly user interfaces with minimal code.

This is a work in progress and will change frequently while I finish it. If you use this library in a project, do not use your git clone directory for the project. I will break things as I release updates.

# Notes on dpi awareness context

## Controls

If you call [`DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")`](https://www.autohotkey.com/docs/v2/misc/DPIScaling.htm#Workarounds)
(or -3) before creating the gui window, and if you use the
[-DPIScale](https://www.autohotkey.com/docs/v2/lib/Gui.htm#DPIScale) option, then you will not need
to adjust dpi awareness context when interacting with controls.

# FilterStrings

There are seven components to using `FilterStrings`.

1. A list of words (array of strings).

```ahk
words := ['numerically','swathe','viverrine','debility','numb','sameness','parablast','disbud'
,'insoluble','indubitable','proposer','niccolite','immesh','seaboard','epicycle','petrify','boss'
,'mignonette','deference','beauxite','dimera','pintado','suzerain','synalepha','silken']
```

2. An object that uses the words for something. In this example, we display them using a ListView.

```ahk
g := gui('+Resize')
lv := g.Add('ListView', 'w300 r11 vcb', [ 'Word' ])
; Add the words to the listview
for w in words {
    lv.Add(, w)
}
```

3. A function that returns the text used for filtering. Typically this would be some input from
the user, so in this case we will accomplish this by using an Edit control and defining the function
to return its text value.

```ahk
edt := g.Add('Edit', 'w300 r1 Section vEdtInput')
GetTextCallback := (*) => edt.Text
```

4. A function that adds items to the object. The function should have one to two parameters.
  1. The index of the string in the array.
  2. The filtered index, which is the index of the index in the "Indices" array. I can't think
     of a good way to describe this in a way that would make more sense than simply looking at the
     class definition to see what the "Indices" array is used for.
In this case, we need to add the string to the ListView control. We exclude the second parameter
because we don't need it here.
AddCallback := (Index, *) => lv.Add( , Words[Index])

5. A function that deletes items from the object. The function should have one to two parameters.
  1. The index of the string in the array.
  2. The filtered index, which is the index of the index in the "Indices" array. As long as the
     listview's contents has not been sorted or changed by he user, the `FilteredIndex` should be
     the correct index to delete the string. However, if one's code cannot guarantee that this is
     true, then it would be better to iterate the ListView's contents and find the string.
DeleteCallback(Index, *) {
    loop lv.GetCount() {
        if lv.GetText(A_Index, 1) = words[index] {
            lv.Delete(A_Index)
            return
        }
    }
}

6. A function that compares the strings. The function should have two parameters.
  1. The array item (string) being evaluated.
  2. The input string returned from #3 above.
The function should return:
- Nonzero if the array item (parameter 1) is to be kept in the active list and, if appropriate,
  `AddCallback` will be called.
- Zero or an empty string if the array item is to be filtered out of the list and, if appropriate,
  `DeleteCallback` will be called.
You could use a simple function like `InStr`, but let's use something more complex. Details about
`FilterCallback` here are at the bottom of this page.
FilterCallback(Item, Input) {
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
}

7. An event that calls the filter.
HChangeEdit(Ctrl, *) {
    ; Our event handler must disable the event handler, call the filter, then re-enable the event
    ; handler before returning.
    Ctrl.OnEvent('Change', HChangeEdit, 0)
    Ctrl.Gui.Filter.Call()
    Ctrl.OnEvent('Change', HChangeEdit, 1)
}
edt.OnEvent('Change', HChangeEdit)

In this example I assign the `FilterStrings` instance to a property on the gui object. This is usually
a convenient choice, but isn't strictly necessary. The reference must be accessible from the event
handler that calls the filter, and from any event handlers or functions that handle adding or
deleting items from the array. While the `FilterStrings` function is active, to add items to the array
you must call `FilterStrings.Prototype.Add`, and to delete items you must call `FilterStrings.Prototype.Delete`.
If you don't do this, the filter and the list of words will be out of sync.
g.Filter := FilterStrings(words, GetTextCallback, AddCallback, DeleteCallback, FilterCallback)

Let's also add a couple buttons and another edit control to demonstrate adding and deleting items.
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


<!--
The WinAPI text functions require string length measured in WORDs. `StrLen()` handles this
for us, as noted here: https://www.autohotkey.com/docs/v2/lib/Chr.htm
"Unicode supplementary characters (where Number is in the range 0x10000 to 0x10FFFF) are counted
as two characters. That is, the length of the return value as reported by StrLen may be 1 or 2.
For further explanation, see String Encoding.
https://www.autohotkey.com/docs/v2/Concepts.htm#string-encoding

The functions all require a device context handle. Use the `SelectFontIntoDc` function to get
an object that handles the boilerplate code.

```ahk
context := SelectFontIntoDc(hWnd)
sz := GetTextExtentPoint32(context.hdc, 'Hello, world!')
context() ; release the device context
```

If you need help understanding how to handle OS errors, read the section "OSError" here:
https://www.autohotkey.com/docs/v2/lib/Error.htm
