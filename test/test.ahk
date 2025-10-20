
#include <TestInterfaceConfig>
#include <DisplayConfig>


test()

class test {
    static Call() {
        Filter := PropsInfo.FilterGroup(FilterFunc)

        FilterFunc(InfoItem) {
            if InfoItem.Root is Class {
                if InfoItem.Root.Prototype.__Class = 'dGui' {
                    if InfoItem.Root.%InfoItem.Name% is Class {
                        return 1
                    }
                }
            }
        }
        Subjects := TestInterface.SubjectCollection()

        ; ComboBox
        Script1 := ScriptParser('C:\Users\Shared\001_Repos\Display\lib\ComboBox.ahk')
        ; CbFilter
        PropsInfo_CbFilter := GetPropsInfo(CbFilter, , '__Init,Prototype,Base', false)
        PropsInfo_CbFilter.FilterSet(Filter)
        Subjects.Add('CbFilter', PropsInfo_CbFilter, , Script1)
        Subjects.Get('CbFilter').InitialValues := Map()
        ; Methods
        Subjects.Get('CbFilter').InitialValues.Set('Call', [])

        ; ControlTextExtent
        Script2 := ScriptParser('C:\Users\Shared\001_Repos\Display\lib\ControlTextExtent.ahk')
        ; Functions
        Subjects.AddFunc(ControlGetTextExtent, , Script2)
        Subjects.Get('ControlGetTextExtent').InitialValues := []
        Subjects.AddFunc(ControlGetTextExtentEx, , Script2)
        Subjects.Get('ControlGetTextExtentEx').InitialValues := []
        Subjects.AddFunc(ControlGetTextExtentEx_LB, , Script2)
        Subjects.Get('ControlGetTextExtentEx_LB').InitialValues := []
        Subjects.AddFunc(ControlGetTextExtentEx_LV, , Script2)
        Subjects.Get('ControlGetTextExtentEx_LV').InitialValues := []
        Subjects.AddFunc(ControlGetTextExtentEx_Link, , Script2)
        Subjects.Get('ControlGetTextExtentEx_Link').InitialValues := []
        Subjects.AddFunc(ControlGetTextExtentEx_TV, , Script2)
        Subjects.Get('ControlGetTextExtentEx_TV').InitialValues := []
        Subjects.AddFunc(ControlGetTextExtent_LB, , Script2)
        Subjects.Get('ControlGetTextExtent_LB').InitialValues := []
        Subjects.AddFunc(ControlGetTextExtent_LV, , Script2)
        Subjects.Get('ControlGetTextExtent_LV').InitialValues := []
        Subjects.AddFunc(ControlGetTextExtent_Link, , Script2)
        Subjects.Get('ControlGetTextExtent_Link').InitialValues := []
        Subjects.AddFunc(ControlGetTextExtent_TV, , Script2)
        Subjects.Get('ControlGetTextExtent_TV').InitialValues := []
        Subjects.AddFunc(__ControlGetTextExtentEx_Process, , Script2)
        Subjects.Get('__ControlGetTextExtentEx_Process').InitialValues := []
        ; Dpi
        Script3 := ScriptParser('C:\Users\Shared\001_Repos\Display\lib\Dpi.ahk')
        ; Functions
        Subjects.AddFunc(AreDpiAwarenessContextsEqual, , Script3)
        Subjects.Get('AreDpiAwarenessContextsEqual').InitialValues := []
        Subjects.AddFunc(GetAwarenessFromDpiAwarenessContext, , Script3)
        Subjects.Get('GetAwarenessFromDpiAwarenessContext').InitialValues := []
        Subjects.AddFunc(GetDpiAwarenessContextForProcess, , Script3)
        Subjects.Get('GetDpiAwarenessContextForProcess').InitialValues := []
        Subjects.AddFunc(GetDpiForMonitor, , Script3)
        Subjects.Get('GetDpiForMonitor').InitialValues := []
        Subjects.AddFunc(GetDpiForSystem, , Script3)
        Subjects.Get('GetDpiForSystem').InitialValues := []
        Subjects.AddFunc(GetDpiForWindow, , Script3)
        Subjects.Get('GetDpiForWindow').InitialValues := []
        Subjects.AddFunc(GetDpiFromDpiAwarenessContext, , Script3)
        Subjects.Get('GetDpiFromDpiAwarenessContext').InitialValues := []
        Subjects.AddFunc(GetProcessDpiAwareness, , Script3)
        Subjects.Get('GetProcessDpiAwareness').InitialValues := []
        Subjects.AddFunc(GetSystemDpiForProcess, , Script3)
        Subjects.Get('GetSystemDpiForProcess').InitialValues := []
        Subjects.AddFunc(GetThreadDpiAwarenessContext, , Script3)
        Subjects.Get('GetThreadDpiAwarenessContext').InitialValues := []
        Subjects.AddFunc(GetWindowDpiAwarenessContext, , Script3)
        Subjects.Get('GetWindowDpiAwarenessContext').InitialValues := []
        Subjects.AddFunc(IsValidDpiAwarenessContext, , Script3)
        Subjects.Get('IsValidDpiAwarenessContext').InitialValues := []
        Subjects.AddFunc(SetThreadDpiAwarenessContext, , Script3)
        Subjects.Get('SetThreadDpiAwarenessContext').InitialValues := []
        ; FilterWords
        Script4 := ScriptParser('C:\Users\Shared\001_Repos\Display\lib\FilterWords.ahk')
        ; FilterWords
        PropsInfo_FilterWords := GetPropsInfo(FilterWords, , '__Init,Prototype,Base', false)
        PropsInfo_FilterWords.FilterSet(Filter)
        Subjects.Add('FilterWords', PropsInfo_FilterWords, , Script4)
        Subjects.Get('FilterWords').InitialValues := Map()
        ; Methods
        Subjects.Get('FilterWords').InitialValues.Set('Call', [])
        Subjects.Get('FilterWords').InitialValues.Set('FilterCallback', [])

        ; MetaSetThreadDpiAwareness
        Script5 := ScriptParser('C:\Users\Shared\001_Repos\Display\lib\MetaSetThreadDpiAwareness.ahk')
        ; Functions
        Subjects.AddFunc(MetaSetThreadDpiAwareness, , Script5)
        Subjects.Get('MetaSetThreadDpiAwareness').InitialValues := []
        ; Tab
        Script6 := ScriptParser('C:\Users\Shared\001_Repos\Display\lib\Tab.ahk')
        ; Functions
        Subjects.AddFunc(TabAdjustWindowRect, , Script6)
        Subjects.Get('TabAdjustWindowRect').InitialValues := []
        Subjects.AddFunc(TabGetDisplayTopLeft, , Script6)
        Subjects.Get('TabGetDisplayTopLeft').InitialValues := []
        ; Text
        Script7 := ScriptParser('C:\Users\Shared\001_Repos\Display\lib\Text.ahk')
        ; Functions
        Subjects.AddFunc(GetLineEnding, , Script7)
        Subjects.Get('GetLineEnding').InitialValues := []
        Subjects.AddFunc(GetMultiExtentPoints, , Script7)
        Subjects.Get('GetMultiExtentPoints').InitialValues := []
        Subjects.AddFunc(GetMultiTextExtentExPoint, , Script7)
        Subjects.Get('GetMultiTextExtentExPoint').InitialValues := []
        Subjects.AddFunc(GetTextExtentExPoint, , Script7)
        Subjects.Get('GetTextExtentExPoint').InitialValues := []
        Subjects.AddFunc(GetTextExtentPoint32, , Script7)
        Subjects.Get('GetTextExtentPoint32').InitialValues := []
        ; ControlFitText
        Script8 := ScriptParser('C:\Users\Shared\001_Repos\Display\src\ControlFitText.ahk')
        ; ControlFitText
        PropsInfo_ControlFitText := GetPropsInfo(ControlFitText, , '__Init,Prototype,Base', false)
        PropsInfo_ControlFitText.FilterSet(Filter)
        Subjects.Add('ControlFitText', PropsInfo_ControlFitText, , Script8)
        Subjects.Get('ControlFitText').InitialValues := Map()
        ; Methods
        Subjects.Get('ControlFitText').InitialValues.Set('__Call', [])
        Subjects.Get('ControlFitText').InitialValues.Set('Call', [])
        Subjects.Get('ControlFitText').InitialValues.Set('MaxWidth', [])
        Subjects.Get('ControlFitText').InitialValues.Set('TextExtentPadding', [])
        Subjects.Get('ControlFitText').InitialValues.Set('TextExtentPaddingCollection', [])

        ; ControlFitText.TextExtentPadding
        PropsInfo_TextExtentPadding := GetPropsInfo(ControlFitText.TextExtentPadding, , '__Init,Prototype,Base', false)
        PropsInfo_TextExtentPadding.FilterSet(Filter)
        Subjects.Add('ControlFitText.TextExtentPadding', PropsInfo_TextExtentPadding, , Script8)
        Subjects.Get('ControlFitText.TextExtentPadding').InitialValues := Map()
        ; Methods
        Subjects.Get('ControlFitText.TextExtentPadding').InitialValues.Set('Call', [])

        ; ControlFitText.TextExtentPaddingCollection
        PropsInfo_TextExtentPaddingCollection := GetPropsInfo(ControlFitText.TextExtentPaddingCollection, , '__Init,Prototype,Base', false)
        PropsInfo_TextExtentPaddingCollection.FilterSet(Filter)
        Subjects.Add('ControlFitText.TextExtentPaddingCollection', PropsInfo_TextExtentPaddingCollection, , Script8)
        Subjects.Get('ControlFitText.TextExtentPaddingCollection').InitialValues := Map()
        ; Methods
        Subjects.Get('ControlFitText.TextExtentPaddingCollection').InitialValues.Set('Call', [])

        ; SelectFontIntoDc
        Script9 := ScriptParser('C:\Users\Shared\001_Repos\Display\src\SelectFontIntoDc.ahk')
        ; SelectFontIntoDc
        PropsInfo_SelectFontIntoDc := GetPropsInfo(SelectFontIntoDc, , '__Init,Prototype,Base', false)
        PropsInfo_SelectFontIntoDc.FilterSet(Filter)
        Subjects.Add('SelectFontIntoDc', PropsInfo_SelectFontIntoDc, , Script9)
        Subjects.Get('SelectFontIntoDc').InitialValues := Map()
        ; Methods
        Subjects.Get('SelectFontIntoDc').InitialValues.Set('__New', [])
        Subjects.Get('SelectFontIntoDc').InitialValues.Set('Call', [])

        ; WrapText
        Script10 := ScriptParser('C:\Users\Shared\001_Repos\Display\src\WrapText.ahk')
        ; InsertHyphenationPoints
        PropsInfo_InsertHyphenationPoints := GetPropsInfo(InsertHyphenationPoints, , '__Init,Prototype,Base', false)
        PropsInfo_InsertHyphenationPoints.FilterSet(Filter)
        Subjects.Add('InsertHyphenationPoints', PropsInfo_InsertHyphenationPoints, , Script10)
        Subjects.Get('InsertHyphenationPoints').InitialValues := Map()
        ; Methods
        Subjects.Get('InsertHyphenationPoints').InitialValues.Set('Call', [])
        Subjects.Get('InsertHyphenationPoints').InitialValues.Set('GetPattern', [])

        ; WrapText
        PropsInfo_WrapText := GetPropsInfo(WrapText, , '__Init,Prototype,Base', false)
        PropsInfo_WrapText.FilterSet(Filter)
        Subjects.Add('WrapText', PropsInfo_WrapText, , Script10)
        Subjects.Get('WrapText').InitialValues := Map()
        ; Methods
        Subjects.Get('WrapText').InitialValues.Set('Call', [])
        Subjects.Get('WrapText').InitialValues.Set('Options', [])

        ; WrapText.Options
        PropsInfo_Options := GetPropsInfo(WrapText.Options, , '__Init,Prototype,Base', false)
        PropsInfo_Options.FilterSet(Filter)
        Subjects.Add('WrapText.Options', PropsInfo_Options, , Script10)
        Subjects.Get('WrapText.Options').InitialValues := Map()
        ; Methods
        Subjects.Get('WrapText.Options').InitialValues.Set('Call', [])

        ; dGui
        Script11 := ScriptParser('C:\Users\Shared\001_Repos\Display\src\dGui.ahk')
        ; dGui
        PropsInfo_dGui := GetPropsInfo(dGui, , '__Init,Prototype,Base', false)
        PropsInfo_dGui.FilterSet(Filter)
        Subjects.Add('dGui', PropsInfo_dGui, , Script11)
        Subjects.Get('dGui').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui').InitialValues.Set('__Call', [])
        Subjects.Get('dGui').InitialValues.Set('Call', [])
        Subjects.Get('dGui').InitialValues.Set('Initialize', [])
        Subjects.Get('dGui').InitialValues.Set('SetDpiChangedCallback', [])
        Subjects.Get('dGui').InitialValues.Set('SetDpiChangedHandler', [])
        Subjects.Get('dGui').InitialValues.Set('SetToggleCallback', [])

        ; dLv
        Script12 := ScriptParser('C:\Users\Shared\001_Repos\Display\src\dLv.ahk')
        ; dLv
        PropsInfo_dLv := GetPropsInfo(dLv, , '__Init,Prototype,Base', false)
        PropsInfo_dLv.FilterSet(Filter)
        Subjects.Add('dLv', PropsInfo_dLv, , Script12)
        Subjects.Get('dLv').InitialValues := Map()
        ; Methods
        Subjects.Get('dLv').InitialValues.Set('AddObj', [])
        Subjects.Get('dLv').InitialValues.Set('Call', [])
        Subjects.Get('dLv').InitialValues.Set('Cols', [])
        Subjects.Get('dLv').InitialValues.Set('Find', [])
        Subjects.Get('dLv').InitialValues.Set('GetRows', [])
        Subjects.Get('dLv').InitialValues.Set('Rows', [])
        Subjects.Get('dLv').InitialValues.Set('UpdateObj', [])
        Subjects.Get('dLv').InitialValues.Set('UpdateWithCompareFunc', [])

        ; dMon
        Script13 := ScriptParser('C:\Users\Shared\001_Repos\Display\src\dMon.ahk')
        ; dMon
        PropsInfo_dMon := GetPropsInfo(dMon, , '__Init,Prototype,Base', false)
        PropsInfo_dMon.FilterSet(Filter)
        Subjects.Add('dMon', PropsInfo_dMon, , Script13)
        Subjects.Get('dMon').InitialValues := Map()
        ; Methods
        Subjects.Get('dMon').InitialValues.Set('__Call', [])
        Subjects.Get('dMon').InitialValues.Set('__Enum', [])
        Subjects.Get('dMon').InitialValues.Set('__Item_Get_NotOrdered', [])
        Subjects.Get('dMon').InitialValues.Set('__Item_Get_Ordered_Default', [])
        Subjects.Get('dMon').InitialValues.Set('__Item_Get_Ordered_Params', [])
        Subjects.Get('dMon').InitialValues.Set('Call', [])
        Subjects.Get('dMon').InitialValues.Set('Dpi', [])
        Subjects.Get('dMon').InitialValues.Set('FromDimensions', [])
        Subjects.Get('dMon').InitialValues.Set('FromIndex', [])
        Subjects.Get('dMon').InitialValues.Set('FromMouse', [])
        Subjects.Get('dMon').InitialValues.Set('FromPoint', [])
        Subjects.Get('dMon').InitialValues.Set('FromPos', [])
        Subjects.Get('dMon').InitialValues.Set('FromRect', [])
        Subjects.Get('dMon').InitialValues.Set('FromWin', [])
        Subjects.Get('dMon').InitialValues.Set('GetNonvisiblePosition', [])
        Subjects.Get('dMon').InitialValues.Set('GetOrder', [])
        ; Get accessors
        Subjects.Get('dMon').InitialValues.Set('__Item', [])
        ; Get and set accessors
        Subjects.Get('dMon').InitialValues.Set('UseOrderedMonitors', Map('Get', [], 'Set', []))

        ; dMon.Dpi
        PropsInfo_Dpi := GetPropsInfo(dMon.Dpi, , '__Init,Prototype,Base', false)
        PropsInfo_Dpi.FilterSet(Filter)
        Subjects.Add('dMon.Dpi', PropsInfo_Dpi, , Script13)
        Subjects.Get('dMon.Dpi').InitialValues := Map()
        ; Methods
        Subjects.Get('dMon.Dpi').InitialValues.Set('__Call', [])
        Subjects.Get('dMon.Dpi').InitialValues.Set('__New', [])
        Subjects.Get('dMon.Dpi').InitialValues.Set('Call', [])
        Subjects.Get('dMon.Dpi').InitialValues.Set('Dimensions', [])
        Subjects.Get('dMon.Dpi').InitialValues.Set('Mouse', [])
        Subjects.Get('dMon.Dpi').InitialValues.Set('Point', [])
        Subjects.Get('dMon.Dpi').InitialValues.Set('Pos', [])
        Subjects.Get('dMon.Dpi').InitialValues.Set('Rect', [])
        Subjects.Get('dMon.Dpi').InitialValues.Set('Win', [])

        ; dTab
        Script14 := ScriptParser('C:\Users\Shared\001_Repos\Display\src\dTab.ahk')
        ; dTab
        PropsInfo_dTab := GetPropsInfo(dTab, , '__Init,Prototype,Base', false)
        PropsInfo_dTab.FilterSet(Filter)
        Subjects.Add('dTab', PropsInfo_dTab, , Script14)
        Subjects.Get('dTab').InitialValues := Map()
        ; Methods
        Subjects.Get('dTab').InitialValues.Set('Call', [])

        ; dWin
        Script15 := ScriptParser('C:\Users\Shared\001_Repos\Display\src\dWin.ahk')
        ; dWin
        PropsInfo_dWin := GetPropsInfo(dWin, , '__Init,Prototype,Base', false)
        PropsInfo_dWin.FilterSet(Filter)
        Subjects.Add('dWin', PropsInfo_dWin, , Script15)
        Subjects.Get('dWin').InitialValues := Map()
        ; Methods
        Subjects.Get('dWin').InitialValues.Set('__Call', [])
        Subjects.Get('dWin').InitialValues.Set('AdjustWindowRectEx', [])
        Subjects.Get('dWin').InitialValues.Set('AdjustWindowRectExForDpi', [])
        Subjects.Get('dWin').InitialValues.Set('BeginDeferWindowPos', [])
        Subjects.Get('dWin').InitialValues.Set('Call', [])
        Subjects.Get('dWin').InitialValues.Set('ChildWindowFromPoint', [])
        Subjects.Get('dWin').InitialValues.Set('ChildWindowFromPointEx', [])
        Subjects.Get('dWin').InitialValues.Set('DeferWindowPos', [])
        Subjects.Get('dWin').InitialValues.Set('EndDeferWindowPos', [])
        Subjects.Get('dWin').InitialValues.Set('FromPhysicalPoint', [])
        Subjects.Get('dWin').InitialValues.Set('FromPoint', [])
        Subjects.Get('dWin').InitialValues.Set('GetChildrenBoundingRect', [])
        Subjects.Get('dWin').InitialValues.Set('GetClientRect', [])
        Subjects.Get('dWin').InitialValues.Set('GetDpi', [])
        Subjects.Get('dWin').InitialValues.Set('GetWindowRect', [])
        Subjects.Get('dWin').InitialValues.Set('IsVisible', [])
        Subjects.Get('dWin').InitialValues.Set('LargestRectanglePreservingAspectRatio', [])
        Subjects.Get('dWin').InitialValues.Set('Move', [])
        Subjects.Get('dWin').InitialValues.Set('MoveByMouse', [])
        Subjects.Get('dWin').InitialValues.Set('MoveByWinH', [])
        Subjects.Get('dWin').InitialValues.Set('MoveByWinV', [])
        Subjects.Get('dWin').InitialValues.Set('MoveScaled', [])
        Subjects.Get('dWin').InitialValues.Set('PathFromTitle', [])
        Subjects.Get('dWin').InitialValues.Set('PhysicalToLogicalPoint', [])
        Subjects.Get('dWin').InitialValues.Set('RealChildWindowFromPoint', [])
        Subjects.Get('dWin').InitialValues.Set('ScalePreserveAspectRatio', [])
        Subjects.Get('dWin').InitialValues.Set('SetParent', [])
        Subjects.Get('dWin').InitialValues.Set('Show', [])
        Subjects.Get('dWin').InitialValues.Set('Snap', [])
        Subjects.Get('dWin').InitialValues.Set('ToRect', [])
        Subjects.Get('dWin').InitialValues.Set('WhichQuadrant', [])

        ; BufferArray
        Script16 := ScriptParser('C:\Users\Shared\001_Repos\Display\struct\BufferArray.ahk')
        ; IntegerArray
        Script17 := ScriptParser('C:\Users\Shared\001_Repos\Display\struct\IntegerArray.ahk')
        ; IntegerArray
        PropsInfo_IntegerArray := GetPropsInfo(IntegerArray, , '__Init,Prototype,Base', false)
        PropsInfo_IntegerArray.FilterSet(Filter)
        Subjects.Add('IntegerArray', PropsInfo_IntegerArray, , Script17)
        Subjects.Get('IntegerArray').InitialValues := Map()
        ; Methods
        Subjects.Get('IntegerArray').InitialValues.Set('Call', [])

        ; LOGFONT
        Script18 := ScriptParser('C:\Users\Shared\001_Repos\Display\struct\LOGFONT.ahk')
        ; LOGFONT
        PropsInfo_LOGFONT := GetPropsInfo(LOGFONT, , '__Init,Prototype,Base', false)
        PropsInfo_LOGFONT.FilterSet(Filter)
        Subjects.Add('LOGFONT', PropsInfo_LOGFONT, , Script18)
        Subjects.Get('LOGFONT').InitialValues := Map()
        ; Methods
        Subjects.Get('LOGFONT').InitialValues.Set('Call', [])

        ; Point
        Script19 := ScriptParser('C:\Users\Shared\001_Repos\Display\struct\Point.ahk')
        ; LogicalPoint
        PropsInfo_LogicalPoint := GetPropsInfo(LogicalPoint, , '__Init,Prototype,Base', false)
        PropsInfo_LogicalPoint.FilterSet(Filter)
        Subjects.Add('LogicalPoint', PropsInfo_LogicalPoint, , Script19)
        Subjects.Get('LogicalPoint').InitialValues := Map()
        ; Methods
        Subjects.Get('LogicalPoint').InitialValues.Set('Call', [])
        Subjects.Get('LogicalPoint').InitialValues.Set('ClientToScreen', [])
        Subjects.Get('LogicalPoint').InitialValues.Set('GetCaretPos', [])
        Subjects.Get('LogicalPoint').InitialValues.Set('ScreenToClient', [])
        Subjects.Get('LogicalPoint').InitialValues.Set('SetCaretPos', [])

        ; PhysicalPoint
        PropsInfo_PhysicalPoint := GetPropsInfo(PhysicalPoint, , '__Init,Prototype,Base', false)
        PropsInfo_PhysicalPoint.FilterSet(Filter)
        Subjects.Add('PhysicalPoint', PropsInfo_PhysicalPoint, , Script19)
        Subjects.Get('PhysicalPoint').InitialValues := Map()
        ; Methods
        Subjects.Get('PhysicalPoint').InitialValues.Set('Call', [])
        Subjects.Get('PhysicalPoint').InitialValues.Set('ClientToScreen', [])
        Subjects.Get('PhysicalPoint').InitialValues.Set('GetCaretPos', [])
        Subjects.Get('PhysicalPoint').InitialValues.Set('ScreenToClient', [])
        Subjects.Get('PhysicalPoint').InitialValues.Set('SetCaretPos', [])

        ; Point
        PropsInfo_Point := GetPropsInfo(Point, , '__Init,Prototype,Base', false)
        PropsInfo_Point.FilterSet(Filter)
        Subjects.Add('Point', PropsInfo_Point, , Script19)
        Subjects.Get('Point').InitialValues := Map()
        ; Methods
        Subjects.Get('Point').InitialValues.Set('Call', [])
        Subjects.Get('Point').InitialValues.Set('ClientToScreen', [])
        Subjects.Get('Point').InitialValues.Set('GetCaretPos', [])
        Subjects.Get('Point').InitialValues.Set('ScreenToClient', [])
        Subjects.Get('Point').InitialValues.Set('SetCaretPos', [])

        ; Rect
        Script20 := ScriptParser('C:\Users\Shared\001_Repos\Display\struct\Rect.ahk')
        ; Rect
        PropsInfo_Rect := GetPropsInfo(Rect, , '__Init,Prototype,Base', false)
        PropsInfo_Rect.FilterSet(Filter)
        Subjects.Add('Rect', PropsInfo_Rect, , Script20)
        Subjects.Get('Rect').InitialValues := Map()
        ; Methods
        Subjects.Get('Rect').InitialValues.Set('__Call', [])
        Subjects.Get('Rect').InitialValues.Set('Call', [])
        Subjects.Get('Rect').InitialValues.Set('FromControl', [])
        Subjects.Get('Rect').InitialValues.Set('FromDimensions', [])
        Subjects.Get('Rect').InitialValues.Set('FromPtr', [])
        Subjects.Get('Rect').InitialValues.Set('FromWin', [])
        Subjects.Get('Rect').InitialValues.Set('FromWinClient', [])
        Subjects.Get('Rect').InitialValues.Set('GetQuadrants', [])
        Subjects.Get('Rect').InitialValues.Set('Intersect', [])
        Subjects.Get('Rect').InitialValues.Set('Order', [])
        Subjects.Get('Rect').InitialValues.Set('Split', [])
        Subjects.Get('Rect').InitialValues.Set('Union', [])

        ; RectBase
        Script21 := ScriptParser('C:\Users\Shared\001_Repos\Display\struct\RectBase.ahk')
        ; RectBase
        PropsInfo_RectBase := GetPropsInfo(RectBase, , '__Init,Prototype,Base', false)
        PropsInfo_RectBase.FilterSet(Filter)
        Subjects.Add('RectBase', PropsInfo_RectBase, , Script21)
        Subjects.Get('RectBase').InitialValues := Map()
        ; Methods
        Subjects.Get('RectBase').InitialValues.Set('__Call', [])
        Subjects.Get('RectBase').InitialValues.Set('Call', [])

        ; Size
        Script22 := ScriptParser('C:\Users\Shared\001_Repos\Display\struct\Size.ahk')
        ; Size
        PropsInfo_Size := GetPropsInfo(Size, , '__Init,Prototype,Base', false)
        PropsInfo_Size.FilterSet(Filter)
        Subjects.Add('Size', PropsInfo_Size, , Script22)
        Subjects.Get('Size').InitialValues := Map()
        ; Methods
        Subjects.Get('Size').InitialValues.Set('Call', [])

        ; WINDOWINFO
        Script23 := ScriptParser('C:\Users\Shared\001_Repos\Display\struct\WINDOWINFO.ahk')
        ; WINDOWINFO
        PropsInfo_WINDOWINFO := GetPropsInfo(WINDOWINFO, , '__Init,Prototype,Base', false)
        PropsInfo_WINDOWINFO.FilterSet(Filter)
        Subjects.Add('WINDOWINFO', PropsInfo_WINDOWINFO, , Script23)
        Subjects.Get('WINDOWINFO').InitialValues := Map()
        ; Methods
        Subjects.Get('WINDOWINFO').InitialValues.Set('Call', [])

        TI := this.TI := TestInterface('Display', Subjects)

    }
}

/*

#include C:\Users\Shared\001_Repos\Display\lib\ComboBox.ahk
#include C:\Users\Shared\001_Repos\Display\lib\ControlTextExtent.ahk
#include C:\Users\Shared\001_Repos\Display\lib\Dpi.ahk
#include C:\Users\Shared\001_Repos\Display\lib\FilterWords.ahk
#include C:\Users\Shared\001_Repos\Display\lib\MetaSetThreadDpiAwareness.ahk
#include C:\Users\Shared\001_Repos\Display\lib\Tab.ahk
#include C:\Users\Shared\001_Repos\Display\lib\Text.ahk
#include C:\Users\Shared\001_Repos\Display\src\ControlFitText.ahk
#include C:\Users\Shared\001_Repos\Display\src\dGui.ahk
#include C:\Users\Shared\001_Repos\Display\src\dLv.ahk
#include C:\Users\Shared\001_Repos\Display\src\dMon.ahk
#include C:\Users\Shared\001_Repos\Display\src\dTab.ahk
#include C:\Users\Shared\001_Repos\Display\src\dWin.ahk
#include C:\Users\Shared\001_Repos\Display\src\SelectFontIntoDc.ahk
#include C:\Users\Shared\001_Repos\Display\src\WrapText.ahk
#include C:\Users\Shared\001_Repos\Display\struct\BufferArray.ahk
#include C:\Users\Shared\001_Repos\Display\struct\IntegerArray.ahk
#include C:\Users\Shared\001_Repos\Display\struct\LOGFONT.ahk
#include C:\Users\Shared\001_Repos\Display\struct\Point.ahk
#include C:\Users\Shared\001_Repos\Display\struct\Rect.ahk
#include C:\Users\Shared\001_Repos\Display\struct\RectBase.ahk
#include C:\Users\Shared\001_Repos\Display\struct\Size.ahk
#include C:\Users\Shared\001_Repos\Display\struct\WINDOWINFO.ahk


        ; dGui.ActiveX
        PropsInfo_ActiveX := GetPropsInfo(dGui.ActiveX, , '__Init,Prototype,Base', false)
        PropsInfo_ActiveX.FilterSet(Filter)
        Subjects.Add('dGui.ActiveX', PropsInfo_ActiveX, , Script11)
        Subjects.Get('dGui.ActiveX').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.ActiveX').InitialValues.Set('Call', [])

        ; dGui.Button
        PropsInfo_Button := GetPropsInfo(dGui.Button, , '__Init,Prototype,Base', false)
        PropsInfo_Button.FilterSet(Filter)
        Subjects.Add('dGui.Button', PropsInfo_Button, , Script11)
        Subjects.Get('dGui.Button').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Button').InitialValues.Set('Call', [])

        ; dGui.CheckBox
        PropsInfo_CheckBox := GetPropsInfo(dGui.CheckBox, , '__Init,Prototype,Base', false)
        PropsInfo_CheckBox.FilterSet(Filter)
        Subjects.Add('dGui.CheckBox', PropsInfo_CheckBox, , Script11)
        Subjects.Get('dGui.CheckBox').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.CheckBox').InitialValues.Set('Call', [])

        ; dGui.ComboBox
        PropsInfo_ComboBox := GetPropsInfo(dGui.ComboBox, , '__Init,Prototype,Base', false)
        PropsInfo_ComboBox.FilterSet(Filter)
        Subjects.Add('dGui.ComboBox', PropsInfo_ComboBox, , Script11)
        Subjects.Get('dGui.ComboBox').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.ComboBox').InitialValues.Set('Call', [])

        ; dGui.Control
        PropsInfo_Control := GetPropsInfo(dGui.Control, , '__Init,Prototype,Base', false)
        PropsInfo_Control.FilterSet(Filter)
        Subjects.Add('dGui.Control', PropsInfo_Control, , Script11)
        Subjects.Get('dGui.Control').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Control').InitialValues.Set('Call', [])

        ; dGui.Custom
        PropsInfo_Custom := GetPropsInfo(dGui.Custom, , '__Init,Prototype,Base', false)
        PropsInfo_Custom.FilterSet(Filter)
        Subjects.Add('dGui.Custom', PropsInfo_Custom, , Script11)
        Subjects.Get('dGui.Custom').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Custom').InitialValues.Set('Call', [])

        ; dGui.DDL
        PropsInfo_DDL := GetPropsInfo(dGui.DDL, , '__Init,Prototype,Base', false)
        PropsInfo_DDL.FilterSet(Filter)
        Subjects.Add('dGui.DDL', PropsInfo_DDL, , Script11)
        Subjects.Get('dGui.DDL').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.DDL').InitialValues.Set('Call', [])

        ; dGui.DateTime
        PropsInfo_DateTime := GetPropsInfo(dGui.DateTime, , '__Init,Prototype,Base', false)
        PropsInfo_DateTime.FilterSet(Filter)
        Subjects.Add('dGui.DateTime', PropsInfo_DateTime, , Script11)
        Subjects.Get('dGui.DateTime').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.DateTime').InitialValues.Set('Call', [])

        ; dGui.Edit
        PropsInfo_Edit := GetPropsInfo(dGui.Edit, , '__Init,Prototype,Base', false)
        PropsInfo_Edit.FilterSet(Filter)
        Subjects.Add('dGui.Edit', PropsInfo_Edit, , Script11)
        Subjects.Get('dGui.Edit').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Edit').InitialValues.Set('Call', [])

        ; dGui.GroupBox
        PropsInfo_GroupBox := GetPropsInfo(dGui.GroupBox, , '__Init,Prototype,Base', false)
        PropsInfo_GroupBox.FilterSet(Filter)
        Subjects.Add('dGui.GroupBox', PropsInfo_GroupBox, , Script11)
        Subjects.Get('dGui.GroupBox').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.GroupBox').InitialValues.Set('Call', [])

        ; dGui.Hotkey
        PropsInfo_Hotkey := GetPropsInfo(dGui.Hotkey, , '__Init,Prototype,Base', false)
        PropsInfo_Hotkey.FilterSet(Filter)
        Subjects.Add('dGui.Hotkey', PropsInfo_Hotkey, , Script11)
        Subjects.Get('dGui.Hotkey').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Hotkey').InitialValues.Set('Call', [])

        ; dGui.Link
        PropsInfo_Link := GetPropsInfo(dGui.Link, , '__Init,Prototype,Base', false)
        PropsInfo_Link.FilterSet(Filter)
        Subjects.Add('dGui.Link', PropsInfo_Link, , Script11)
        Subjects.Get('dGui.Link').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Link').InitialValues.Set('Call', [])

        ; dGui.ListBox
        PropsInfo_ListBox := GetPropsInfo(dGui.ListBox, , '__Init,Prototype,Base', false)
        PropsInfo_ListBox.FilterSet(Filter)
        Subjects.Add('dGui.ListBox', PropsInfo_ListBox, , Script11)
        Subjects.Get('dGui.ListBox').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.ListBox').InitialValues.Set('Call', [])

        ; dGui.ListView
        PropsInfo_ListView := GetPropsInfo(dGui.ListView, , '__Init,Prototype,Base', false)
        PropsInfo_ListView.FilterSet(Filter)
        Subjects.Add('dGui.ListView', PropsInfo_ListView, , Script11)
        Subjects.Get('dGui.ListView').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.ListView').InitialValues.Set('Call', [])

        ; dGui.MonthCal
        PropsInfo_MonthCal := GetPropsInfo(dGui.MonthCal, , '__Init,Prototype,Base', false)
        PropsInfo_MonthCal.FilterSet(Filter)
        Subjects.Add('dGui.MonthCal', PropsInfo_MonthCal, , Script11)
        Subjects.Get('dGui.MonthCal').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.MonthCal').InitialValues.Set('Call', [])

        ; dGui.Pic
        PropsInfo_Pic := GetPropsInfo(dGui.Pic, , '__Init,Prototype,Base', false)
        PropsInfo_Pic.FilterSet(Filter)
        Subjects.Add('dGui.Pic', PropsInfo_Pic, , Script11)
        Subjects.Get('dGui.Pic').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Pic').InitialValues.Set('Call', [])

        ; dGui.Progress
        PropsInfo_Progress := GetPropsInfo(dGui.Progress, , '__Init,Prototype,Base', false)
        PropsInfo_Progress.FilterSet(Filter)
        Subjects.Add('dGui.Progress', PropsInfo_Progress, , Script11)
        Subjects.Get('dGui.Progress').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Progress').InitialValues.Set('Call', [])

        ; dGui.Radio
        PropsInfo_Radio := GetPropsInfo(dGui.Radio, , '__Init,Prototype,Base', false)
        PropsInfo_Radio.FilterSet(Filter)
        Subjects.Add('dGui.Radio', PropsInfo_Radio, , Script11)
        Subjects.Get('dGui.Radio').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Radio').InitialValues.Set('Call', [])

        ; dGui.Slider
        PropsInfo_Slider := GetPropsInfo(dGui.Slider, , '__Init,Prototype,Base', false)
        PropsInfo_Slider.FilterSet(Filter)
        Subjects.Add('dGui.Slider', PropsInfo_Slider, , Script11)
        Subjects.Get('dGui.Slider').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Slider').InitialValues.Set('Call', [])

        ; dGui.StatusBar
        PropsInfo_StatusBar := GetPropsInfo(dGui.StatusBar, , '__Init,Prototype,Base', false)
        PropsInfo_StatusBar.FilterSet(Filter)
        Subjects.Add('dGui.StatusBar', PropsInfo_StatusBar, , Script11)
        Subjects.Get('dGui.StatusBar').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.StatusBar').InitialValues.Set('Call', [])

        ; dGui.Tab
        PropsInfo_Tab := GetPropsInfo(dGui.Tab, , '__Init,Prototype,Base', false)
        PropsInfo_Tab.FilterSet(Filter)
        Subjects.Add('dGui.Tab', PropsInfo_Tab, , Script11)
        Subjects.Get('dGui.Tab').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Tab').InitialValues.Set('Call', [])

        ; dGui.Text
        PropsInfo_Text := GetPropsInfo(dGui.Text, , '__Init,Prototype,Base', false)
        PropsInfo_Text.FilterSet(Filter)
        Subjects.Add('dGui.Text', PropsInfo_Text, , Script11)
        Subjects.Get('dGui.Text').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.Text').InitialValues.Set('Call', [])

        ; dGui.TreeView
        PropsInfo_TreeView := GetPropsInfo(dGui.TreeView, , '__Init,Prototype,Base', false)
        PropsInfo_TreeView.FilterSet(Filter)
        Subjects.Add('dGui.TreeView', PropsInfo_TreeView, , Script11)
        Subjects.Get('dGui.TreeView').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.TreeView').InitialValues.Set('Call', [])

        ; dGui.UpDown
        PropsInfo_UpDown := GetPropsInfo(dGui.UpDown, , '__Init,Prototype,Base', false)
        PropsInfo_UpDown.FilterSet(Filter)
        Subjects.Add('dGui.UpDown', PropsInfo_UpDown, , Script11)
        Subjects.Get('dGui.UpDown').InitialValues := Map()
        ; Methods
        Subjects.Get('dGui.UpDown').InitialValues.Set('Call', [])
