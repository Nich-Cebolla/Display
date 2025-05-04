#include ..\lib\ControlTextExtent.ahk
#include ..\struct\IntegerArray.ahk
#include ..\struct\SIZE.ahk
#include <Object.Prototype.Stringify_V1.0.0>

class test_ControlTextExtent {
    static Fonts := ['', 'Mono', 'Calisto', 'Aptos']
    , FontOpt := ['', 'bold', 'italic', 'strike', 'underline']
    , FontSize := [4, 8, 12, 40, 100]
    , FontQuality := [1, 2, 3, 4, 5]
    , FontWeight := [100, 200, 300, 400, 500, 600, 700, 800, 900, 950]
    , FontColor := ['Red', 'Black', 'White']
    , Controls := ['Button', 'CheckBox', 'ComboBox', 'Control', 'DateTime', 'Edit', 'GroupBox', 'Radio', 'StatusBar', 'Text']
    , Text1 := 'Lorem ipsum dolor sit amet consectetur adipiscing,`r`nelit nostra interdum ut ad nec bibendum,`r`nsemper quis lacinia condimentum blandit.'
    static Call() {
        local _opt, _size, _quality, _weight, _color, _family, i
        Result := []
        ; To validate the text extent functions, we compare their return values with the values returned
        ; by `Gui.Control.Prototype.GetPos`. We are going to construct one text control for each
        ; combination of options.
        DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
        Controls := Map()
        CG := Gui('-DPIScale')
        Txt := CG.Add('Text', 'vCtrl_0', this.Text1)
        Txt.GetPos(, , &w, &h)
        Controls.Set('0', { w: w, h: h, i: 0 })
        _Loop(MakeControl_1)
        for CtrlType in this.Controls {
            Process_Generic(CtrlType)
        }
        Process_LB()
        Process_Link()
        Process_LV()
        Process_TV()




        _Loop(Callback) {
            i := 0
            loop this.FontOpt.Length {
                _opt := this.FontOpt[A_Index]
                loop this.FontSize.Length {
                    _size := this.FontSize[A_Index]
                    loop this.FontQuality.Length {
                        _quality := this.FontQuality[A_Index]
                        loop this.FontWeight.Length {
                            _weight := this.FontWeight[A_Index]
                            loop this.FontColor.Length {
                                _color := this.FontColor[A_Index]
                                loop this.Fonts.Length {
                                    _family := this.Fonts[A_Index]
                                    Callback()
                                }
                            }
                        }
                    }
                }
            }
        }
        Process_Generic(CtrlType) {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
            G := Gui('-DPIScale')
            _Measure(Controls.Get('0'), _Add(0))
            _Loop(MakeControl)
            G.Destroy()

            _Add(n) {
                return G.Add(CtrlType, 'vCtrl_' n, this.Text1)
            }
            MakeControl() {
                DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
                _Measure(_SetFont(G), _Add(++i))
            }
            _Measure(compare, Ctrl) {
                sz := ControlGetTextExtent_LB(Ctrl)
                if sz.Width !== compare.w || sz.Height !== compare.h {
                    _AddToResult(sz, compare, Ctrl)
                }
            }
        }
        Process_LB() {
            Items := StrSplit(this.Text1, '`r`n')
            DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
            G := Gui('-DPIScale')
            _Measure(Controls.Get('0'), _Add(0))
            _Loop(MakeControl)
            G.Destroy()

            _Add(n) {
                Ctrl := G.Add('ListBox', 'x1 y1 r3 Multi Choose1 vCtrl_' n, Items)
                Ctrl.Choose(2)
                Ctrl.Choose(3)
                return Ctrl
            }
            MakeControl() {
                DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
                _Measure(_SetFont(G), _Add(++i))
            }
            _Measure(compare, Ctrl) {
                sz := ControlGetTextExtent_LB(Ctrl)
                if Max(sz[1].Width, sz[2].Width, sz[3].Width) !== compare.w || _GetH() !== compare.h {
                    _AddToResult(sz, compare, Ctrl)
                }
                _GetH() {
                    h := 0
                    for item in sz {
                        h += item.size.Height
                    }
                    return h
                }
            }
        }
        Process_Link() {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
            G := Gui('-DPIScale')
            _Measure(Controls.Get('0'), _Add(0))
            _Loop(MakeControl)
            G.Destroy()

            _Add(n) {
                return G.Add('Link', '+Wrap vCtrl_' n, '<a href="https://www.autohotkey.com">' this.Text1 '</a>')
            }
            MakeControl() {
                DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
                _Measure(_SetFont(G), _Add(++i))
            }
            _Measure(compare, Ctrl) {
                sz := ControlGetTextExtent_Link(Ctrl)
                if sz.Width !== compare.w || sz.Height !== compare.h {
                    _AddToResult(sz, compare, Ctrl)
                }
            }
        }
        Process_LV() {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
            G := Gui('-DPIScale')
            _Measure(Controls.Get('0'), _Add(0))
            _Loop(MakeControl)
            G.Destroy()
            _Add(n) {
                Ctrl := G.Add('ListView', 'vCtrl_' n, ['Header1', 'Header2'])
                Ctrl.Add(, 'Lorem ipsum dolor sit amet consectetur adipiscing,', 'nelit nostra interdum ut ad nec bibendum,')
                Ctrl.Add(, 'semper quis lacinia condimentum blandit.')
                return Ctrl
            }
            MakeControl() {
                DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
                _Measure(_SetFont(G), _Add(++i))
            }
            _Measure(compare, Ctrl) {
                sz := ControlGetTextExtent_LV(Ctrl)
                if Max(sz[1].Width, sz[2].Width, sz[3].Width) !== compare.w || sz[1].Height + sz[2].Height + sz[3].Height !== compare.h {
                    _AddToResult(sz, compare, Ctrl)
                }
            }
        }
        Process_TV() {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
            G := Gui('-DPIScale')
            _Measure(Controls.Get('0'), _Add(0))
            _Loop(MakeControl)
            G.Destroy()
            _Add(n) {
                Ctrl := G.Add('TreeView', 'vCtrl_' n)
                Ctrl.Add(
                    'semper quis lacinia condimentum blandit.'
                      , Ctrl.Add('nelit nostra interdum ut ad nec bibendum,'
                          , Ctrl.Add('Lorem ipsum dolor sit amet consectetur adipiscing,'
                )))
                return Ctrl
            }
            MakeControl() {
                DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
                _Measure(_SetFont(G), _Add(++i))
            }
            _Measure(compare, Ctrl) {
                sz := ControlGetTextExtent_LV(Ctrl, 0, 0)
                if Max(sz[1].Width, sz[2].Width, sz[3].Width) !== compare.w || sz[1].Height + sz[2].Height + sz[3].Height !== compare.h {
                    _AddToResult(sz, compare, Ctrl)
                }
            }
        }
        MakeControl_1() {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
            Txt := CG.Add('Text', 'x1 y1 vCtrl' (++i), this.Text1)
            Txt.GetPos(,, &w, &h)
            Controls.Set(opt ':' _family, { w: w, h: h, i: i })
        }
        _AddToResult(sz, compare, Ctrl) {
            Result.Push({ i: i, Size: sz, compare: compare, ctrl: Ctrl, type: CtrlType, font: { opt: _opt, size: _size, quality: _quality, weight: _weight, color: _color, family: _family } })
        }
        _SetFont(G) {
            G.SetFont(opt := Format('{} s{} q{} w{} c{}', _opt, _size, _quality, _weight, _color), _family || unset)
            return Controls.Get(opt ':' _family)
        }
    }
}


