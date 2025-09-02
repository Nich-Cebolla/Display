
#include <DisplayConfig>


test()

class test {
    static Call() {
        this.EventHandler := EventHandler()
        g := this.g := dGui('+Resize', , this.EventHandler)
        tab := this.tab := dTab(g, 'Tab', 'w200 r2 vTab', ['Tab1', 'Tab2'])
        tab.UseTab()
        this.result := g.Add('Edit', 'w200 r5 vResult')
        this.input1 := g.Add('Edit', 'section w95 vInput1')
        this.input2 := g.Add('Edit', 'ys w95 vInput2')
        z := 0
        for prop in this.EventHandler.Base.OwnProps() {
            if prop = '__Class' {
                continue
            }
            if !z {
                g.Add('Button', 'xs section vBtnCall' prop, 'Call ' prop).OnEvent('Click', prop)
                z := 1
            } else if z == 1 {
                g.Add('Button', 'ys vBtnCall' prop, 'Call ' prop).OnEvent('Click', prop)
                z := 2
            } else {
                g.Add('Button', 'xs section vBtnCall' prop, 'Call ' prop).OnEvent('Click', prop)
                z := 1
            }
        }

        g.Show()
    }
    static SetResultText(text) {
        this.result.Text := text '`r`n`r`n' test.result.Text
    }
}

class EventHandler {
    GetText(*) {
        test.SetResultText(test.tab.GetTabText(test.input1.Text, 100))
    }
    SetText(*) {
        test.SetResultText(test.tab.SetTabText(test.input1.Text, test.input2.Text))
    }
    SetItemSize(*) {
        test.tab.SetItemSize(test.input1.Text, test.input2.Text, &width, &height)
        test.SetResultText('Width: ' width '; Height: ' height)
    }
    SetMinTabWidth(*) {
        test.SetResultText(test.tab.SetMinTabWidth(test.input1.text))
    }
    HighlightItem(*) {
        test.tab.HighlightItem(test.input1.text, test.input2.text || unset)
    }
}
