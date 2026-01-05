# Display
An AutoHotkey (AHK) library that provides tools for deploying attractive, user-friendly user interfaces with minimal code.

This is a work in progress and will change frequently while I finish it. If you use this library in a project, do not use your git clone directory for the project. I will break things as I release updates.

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
