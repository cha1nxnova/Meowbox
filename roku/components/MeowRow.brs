sub init()
    m.bar = m.top.findNode("bar")
    m.dial = m.top.findNode("dial")
    m.chip = m.top.findNode("chip")
    m.title = m.top.findNode("title")
    m.value = m.top.findNode("value")
    m.lit = false
    m.watched = invalid
end sub

sub fill()
    c = m.top.itemContent
    if c = invalid then return
    ' rows are reused as the list scrolls: follow the "value" of whichever
    ' record this row is showing now, so a tag can change without a rebuild
    if m.watched <> invalid
        if not m.watched.isSameNode(c)
            m.watched.unobserveFieldScoped("value")
            m.watched = invalid
        end if
    end if
    if m.watched = invalid and c.hasField("value")
        c.observeFieldScoped("value", "fill")
        m.watched = c
    end if
    m.title.text = c.title
    dial = ""
    if c.hasField("dial") then dial = c.dial
    m.dial.text = dial
    chip = ""
    if c.hasField("chip") then chip = c.chip
    m.chip.visible = (chip <> "")
    if chip <> "" then m.chip.color = chip
    value = ""
    if c.hasField("value") then value = c.value
    m.value.text = value
    place()
end sub

' rows with a dial number are indented to make room for it
sub place()
    w = m.top.width
    if w <= 0 then w = 456
    m.bar.width = w
    left = 20
    if m.dial.text <> "" or m.chip.visible then left = 98
    ' the title gets whatever the tag at the right does not need
    tag = 0
    if m.value.text <> "" then tag = Len(m.value.text) * 12 + 28
    m.title.translation = [left, 7]
    m.title.width = w - left - tag - 12
    m.value.translation = [w - 166, 11]
end sub

sub glow()
    p = m.top.focusPercent
    if not m.top.listHasFocus then p = 0
    m.bar.opacity = p
    lit = (p > 0.5)
    if lit = m.lit then return
    m.lit = lit
    if lit
        m.title.color = "0x120E1FFF"
        m.dial.color = "0x120E1FFF"
        m.value.color = "0x120E1FFF"
    else
        m.title.color = "0xF6EEDDFF"
        m.dial.color = "0xFFA630FF"
        m.value.color = "0xA99FBFFF"
    end if
end sub
