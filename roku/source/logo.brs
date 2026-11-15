' ---------------------------------------------------------------------------
' The channels' pixel logos. The lineup carries each one as 32 rows of 32
' letters; a letter names a colour and "." is see-through. This mirrors how
' the website paints them, so a logo looks the same in both places.
'
' Plain data in, plain data out: no nodes here (see components/PixelLogo).
' ---------------------------------------------------------------------------

' is this something we can draw?
function LogoRows(mark as Dynamic) as Dynamic
    if type(mark) <> "roAssociativeArray" then return invalid
    if mark.type <> "pixel" then return invalid
    rows = mark.rows
    if type(rows) <> "roArray" then return invalid
    n = rows.Count()
    if n = 0 or n > 64 then return invalid
    for each r in rows
        if type(r) <> "roString" and type(r) <> "String" then return invalid
        if Len(r) <> n then return invalid
    end for
    return rows
end function

' Rows of letters as as few rectangles as will do: runs along a row, then
' identical runs stacked into one taller box. [{ x, y, w, h, t }]
function LogoRects(rows as Object) as Object
    out = []
    open = {}
    for y = 0 to rows.Count() - 1
        row = rows[y]
        n = Len(row)
        seen = {}
        x = 0
        while x < n
            c = Mid(row, x + 1, 1)
            e = x + 1
            while e < n
                if Mid(row, e + 1, 1) <> c then exit while
                e = e + 1
            end while
            if c <> "."
                key = x.ToStr() + ":" + (e - x).ToStr() + ":" + c
                r = open[key]
                grown = false
                if r <> invalid
                    if r.y + r.h = y
                        r.h = r.h + 1
                        grown = true
                    end if
                end if
                if not grown
                    r = { x: x, y: y, w: e - x, h: 1, t: c }
                    out.Push(r)
                    open[key] = r
                end if
                seen[key] = true
            end if
            x = e
        end while
        for each key in open.Keys()
            if not seen.DoesExist(key) then open.Delete(key)
        end for
    end for
    return out
end function

' ---- colour --------------------------------------------------------------------------

function LogoHexByte(s as String) as Integer
    return Val(s, 16)
end function

' [hue 0-360, saturation 0-100, value 0-100]
function LogoHsv(hex as String) as Object
    r = LogoHexByte(Mid(hex, 2, 2)) / 255
    g = LogoHexByte(Mid(hex, 4, 2)) / 255
    b = LogoHexByte(Mid(hex, 6, 2)) / 255
    hi = r
    if g > hi then hi = g
    if b > hi then hi = b
    lo = r
    if g < lo then lo = g
    if b < lo then lo = b
    d = hi - lo
    h = 0
    if d > 0
        if hi = r
            h = (g - b) / d
            if g < b then h = h + 6
        else if hi = g
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end if
        h = h / 6
    end if
    s = 0
    if hi > 0 then s = d / hi * 100
    return [h * 360, s, hi * 100]
end function

function LogoFromHsv(h as Float, s as Float, v as Float) as String
    s = s / 100
    v = v / 100
    out = "0x"
    hex = "0123456789ABCDEF"
    for each n in [5, 3, 1]
        k = n + h / 60
        k = k - 6 * Int(k / 6)
        f = k
        if 4 - k < f then f = 4 - k
        if f > 1 then f = 1
        if f < 0 then f = 0
        byte = Int(255 * (v - v * s * f) + 0.5)
        if byte < 0 then byte = 0
        if byte > 255 then byte = 255
        out = out + Mid(hex, byte \ 16 + 1, 1) + Mid(hex, byte mod 16 + 1, 1)
    end for
    return out + "FF"
end function

' turn a hue toward another by at most so many degrees, the short way round
function LogoHueToward(h as Float, toward as Float, most as Float) as Float
    d = toward - h + 540
    d = d - 360 * Int(d / 360) - 180
    move = Abs(d)
    if move > most then move = most
    out = h + Sgn(d) * move + 360
    return out - 360 * Int(out / 360)
end function

' letter -> "0xRRGGBBFF" for a channel of this colour ("#RRGGBB").
' c is the channel colour itself, d its shade, l its highlight; the rest are fixed inks.
function LogoPalette(color as Dynamic) as Object
    hex = "#666666"
    if color <> invalid
        if CreateObject("roRegex", "^#[0-9a-fA-F]{6}$", "").IsMatch(color) then hex = color
    end if
    hsv = LogoHsv(hex)
    shadeS = hsv[1] * 1.1
    if shadeS > 100 then shadeS = 100
    return {
        k: "0x0B0F26FF"
        n: "0x2A3580FF"
        s: "0x8899CCFF"
        p: "0xE8EAF0FF"
        g: "0xFFD740FF"
        o: "0xD2500CFF"
        c: "0x" + UCase(Mid(hex, 2)) + "FF"
        d: LogoFromHsv(LogoHueToward(hsv[0], 255, 14), shadeS, hsv[2] * 0.6)
        l: LogoFromHsv(LogoHueToward(hsv[0], 50, 10), hsv[1] * 0.6, hsv[2] + (100 - hsv[2]) * 0.6)
    }
end function
