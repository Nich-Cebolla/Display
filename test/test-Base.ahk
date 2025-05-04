#include <Stringify>

class test_Base {
    static PathEditor := 'code-insiders' ; change to your preferred text editing program. Enclose in quotes if path has spaces
    , Result := []

    static CheckResult() {
        Final := []
        for Obj in this.Result {
            if Obj.Result.Length {
                Final.Push(Obj)
            }
        }
        return Final.Length ? Final : ''
    }

    static OpenEditor() {
        Run(A_ComSpec ' /C ' this.PathEditor ' ' this.Pathout)
    }

    static WriteOut(Results) {
        f := FileOpen(this.PathOut, 'w')
        f.Write(Results is String ? Results : Stringify(Results))
        f.Close()
    }
}
