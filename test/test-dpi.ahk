
#include ..\src\dGui.ahk
#include ..\lib\dpi.ahk
; I have not released TestInterface/ScriptParser yet. You cannot run this test.
#include <TestInterfaceConfig>
#include <ScriptParserConfig>
#SingleInstance force

global tlb, tlink, tlv, ttv, tcb, tddl

test_dpi()

class test_dpi {
    static Call() {
        global tlb, tlink, tlv, ttv, tcb, tddl
        script := ScriptParser('..\lib\Dpi.ahk')
        Subjects := TestInterface.SubjectCollection(false)
        for fn in script.CollectionList[SPC_FUNCTION] {
            Subjects.AddFunc(%fn%)
        }

        G := this.G := dGui('+Resize')
        items := ['Item1', 'Item2', 'Item3', 'Item4', 'Item5']
        tlb := G.Add('ListBox', 'w200 r5 vLb', items)
        tlink := G.Add('Link', , '<a href="https://www.autohotkey.com">Text</a>')
        tlv := G.Add('ListView', 'w200 r6 vLv', ['Column1', 'Column2', 'Column3'])
        i := 0
        loop 5 {
            ++i
            items := []
            loop 3 {
                items.Push('Text-' i '_' A_Index)
            }
            tlv.Add(, items*)
        }
        loop 3 {
            tlv.ModifyCol(A_Index, 'AutoHdr')
        }
        ttv := G.Add('TreeView', 'w200 r5 vTv')
        id := ttv.Add('Text1', 0)
        id := ttv.Add('Text1-1', id)
        ttv.Add('Text1-1-1', id)
        id := ttv.Add('Text2', 0)
        ttv.Add('Text2-1', id)
        tcb := G.Add('ComboBox', 'w200 r5', items)
        tddl := G.Add('DDL', 'w200 r5', items)
        objects := Map('ListBox', tlb, 'Link', tlink, 'ListView', tlv, 'TreeView', ttv, 'ComboBox', tcb, 'DDL', tddl)
        for t in ['Button', 'CheckBox', 'Edit', 'GroupBox', 'Radio', 'StatusBar', 'Text'] {
            objects.Set(t, G.Add(t, , 'Text'))
        }

        Subjects.Get('AreDpiAwarenessContextsEqual').InitialValues := ['']
        Subjects.Get('GetAwarenessFromDpiAwarenessContext').InitialValues := ['']
        Subjects.Get('GetDpiAwarenessContextForProcess').InitialValues := ['']
        Subjects.Get('GetDpiForMonitor').InitialValues := ['']
        Subjects.Get('GetDpiForSystem').InitialValues := ['']
        Subjects.Get('GetDpiForWindow').InitialValues := ['']
        Subjects.Get('GetDpiFromDpiAwarenessContext').InitialValues := ['']
        Subjects.Get('GetProcessDpiAwareness').InitialValues := ['']
        Subjects.Get('GetSystemDpiForProcess').InitialValues := ['']
        Subjects.Get('GetThreadDpiAwarenessContext').InitialValues := ['']
        Subjects.Get('GetWindowDpiAwarenessContext').InitialValues := ['']
        Subjects.Get('IsValidDpiAwarenessContext').InitialValues := ['']
        Subjects.Get('SetThreadDpiAwarenessContext').InitialValues := ['']

        G.Show()

        TI := this.TI := TestInterface('ControlTextExtent', Subjects)

        for t, o in objects {
            TI.AddReference(o, t, t)
        }

        return
    }
}
