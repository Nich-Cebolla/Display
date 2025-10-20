
#include ..\lib\ComboBox.ahk
; I have not released TestInterface yet. You cannot run this test.
#include <TestInterfaceConfig>
#SingleInstance force

test_cb()
class test_cb {
    static Call() {
        G := this.G := Gui('+Resize -DPIScale ')
        G.SetFont('s11 q5', 'Roboto Mono')
        List := [
            'EQYOWVEVTM','PEZAQUHKJH','VCRFLUSWVC','PSBURTSICM','SKUMIPWTBN','ZUQAQLYPVI'
          , 'LUNASNWVNY','OJEUMCXLOL','PWJTOMACMC','KVYHVEBUBR','CWEQJYKTOK','YMUVAJSWVH'
          , 'EVOQXUQQRS','UCPOVJSIHR','NEHQLFHSZO','KWFOEMGIQE','ZJJUYQRSXR','URQJFNFJJI'
          , 'TSBPWVXUBG','LKVJFNXFVQ'
        ]
        cb := this.cb := G.Add('ComboBox', 'w200 r20 vcb', List)
        filter := this.filter := CbFilter(cb, list)
        G.Show()
        PropsInfoObj := GetPropsInfo(filter, , 'Base,Prototype', false)
        Subjects := TestInterface.SubjectCollection(false)
        initialValues := Map()
        Subjects.Add('ComboBox', PropsInfoObj, initialValues)
        TestInterface('ComboBox', Subjects)
        WinActivate(G.Hwnd)
    }
}
