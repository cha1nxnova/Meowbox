sub init()
    m.count = 0      ' rectangles made so far; they are kept and reused
end sub

sub draw()
    mk = m.top.mark
    rows = invalid
    if mk <> invalid then rows = LogoRows(mk.logo)
    used = 0
    if rows <> invalid
        rects = LogoRects(rows)
        pal = LogoPalette(mk.color)
        cell = m.top.size / rows.Count()
        if rects.Count() > m.count
            m.top.createChildren(rects.Count() - m.count, "Rectangle")
            m.count = rects.Count()
        end if
        for each r in rects
            color = pal[r.t]
            if color = invalid then color = pal.p
            node = m.top.getChild(used)
            node.setFields({ translation: [r.x * cell, r.y * cell], width: r.w * cell, height: r.h * cell, color: color, visible: true })
            used = used + 1
        end for
    end if
    for i = used to m.count - 1
        m.top.getChild(i).visible = false
    end for
end sub
