
#include ..\lib\ControlTextExtent.ahk
; I have not released TestInterface/ScriptParser yet. You cannot run this test.
#include <TestInterfaceConfig>
#include <ScriptParserConfig>
#SingleInstance force

test_cte()

class test_cte {
    static Call() {
        script := ScriptParser('..\lib\ControlTextExtent.ahk')
        Subjects := TestInterface.SubjectCollection(false)
        filter := PropsInfo.FilterGroup(_Filter)
        for fn in script.CollectionList[SPC_FUNCTION] {
            Subjects.AddFunc(%fn%)
        }
        G := this.G := TestInterface('ControlTextExtent', Subjects)

        _Filter(InfoItem) {
            return InfoItem.Name != 'Call'
        }
    }
}
