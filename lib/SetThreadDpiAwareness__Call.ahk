
#include ..\definitions\Define-Dpi.ahk
/**
 * @description - Enables the use of the "_S" suffix when calling functions that will have different
 * behavior depending on the thread dpi awareness context.
 */
SetThreadDpiAwareness__Call(Obj, Name, Params) {
    Split := StrSplit(Name, '_')
    if Obj.HasMethod(Split[1]) && Split[2] = 'S' {
        DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT_DEFAULT, 'ptr')
        if Params.Length {
            return Obj.%Split[1]%(Params*)
        } else {
            return Obj.%Split[1]%()
        }
    } else {
        throw PropertyError('Property not found.', -1, Name)
    }
}
