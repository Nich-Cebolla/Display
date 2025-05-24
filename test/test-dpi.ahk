
#include ..\config\ProjectConfig.ahk

DllCall('SetThreadDpiAwarenessContext', 'ptr', -3, 'ptr')
g := Gui('-DPIScale +Resize')
DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
t := g.Add('Text', 'w400 r2', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
g.defineProp('dpi', { get: (self) => DllCall('GetDpiForWindow', 'ptr', self.hWnd, 'int') })
lf := LOGFONT(t.hwnd)
sz := ControlGetTextExtent(t)

g.add('text', 'section vtxtdpi', 'dpi')
g.add('edit', 'ys w100 veditdpi', g.dpi)
g.add('button', 'ys vbtndpi', 'dpi').Onevent('click', setdpi)
g.add('text', 'section xs vtxtheight', 'height')
g.add('edit', 'ys w100 veditheight', lf.height)
g.add('button', 'ys vbtnheight', 'height').Onevent('click', setheight)
g.add('text', 'section xs vtxtsize', 'size')
g.add('edit', 'ys w100 veditsize', lf.fontsize)
g.add('button', 'ys vbtnsize', 'size').Onevent('click', setsize)
g.add('button', 'ys vbtnsetsize2', 'set size').Onevent('click', setsize2)
g.add('button', 'ys vbtnsetsize3', 'ctrl.setfont').Onevent('click', setsize3)
g.add('text', 'section xs vtxtextent', 'text w: ' sz.Width '; h: ' sz.Height)

stats := [_obj()]
g.add('edit', 'xs w250 h300 vstats', stringify(stats[1]))
g['stats'].getpos(, &cy, , &ch)

g.scroller := ItemScroller(g, { Array: stats, Callback: handlescroll, startx: 10, starty: cy + ch + g.marginy })
g.show()

setdpi(*) {

}
setheight(*) {
    global
    lf.height := g['editheight'].text
    lf.Apply()
    lf.get()
    sz := ControlGetTextExtent(t)
    _update()
}
setsize(*) {
    global
    DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
    lf.OnDpiChanged(g.dpi)
    _update()
}
setsize2(*) {
    global
    lf.setfontsize(g['editsize'].text)
    _update()
}
setsize3(*) {
    global
    f := g['editsize'].text * g.dpi / 96
    t.setfont('s' f)
    _update()
}
set(*) {
    global
    DllCall('SetThreadDpiAwarenessContext', 'ptr', -4, 'ptr')
    lf.OnDpiChanged(g.dpi)
    _update()
}

handlescroll(index, scroller, *) {
    global
    g['stats'].text := stringify(scroller[index])
}
_obj() {
    global
    return  { dpi: g.dpi, height: lf.height, size: lf.fontsize, lfdpi: lf.dpi, textW: sz.Width, textH: sz.Height }
}

_update() {
    global
    sz := ControlGetTextExtent(t)
    lf.get()
    g['txtextent'].text := 'text w: ' sz.Width '; h: ' sz.Height
    g['editdpi'].text := g.dpi
    g['editheight'].text := lf.height
    g['editsize'].text := lf.fontsize
    stats.Push(_obj())
    g['stats'].text := stringify(stats[-1]) '`r`n`r`n' g['stats'].text
}
