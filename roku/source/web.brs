' ---------------------------------------------------------------------------
' The reading half of the browser: addresses, and turning an HTML page into
' plain lines with the links kept. There is no HTML engine on a Roku, so a
' page is read rather than rendered: text, links, images as links. No CSS,
' no scripts.
'
' Inside a line, Chr(1) opens a link and Chr(2) closes it; WebWrap swaps them
' for brackets and files each link under the line it starts on.
' ---------------------------------------------------------------------------

function WebHexVal(ch as String) as Integer
    c = Asc(UCase(ch))
    if c >= 48 and c <= 57 then return c - 48
    if c >= 65 and c <= 70 then return c - 55
    return -1
end function

' percent-decoding ("+" is left alone unless plusIsSpace)
function WebUnescape(s as String, plusIsSpace as Boolean) as String
    if Instr(1, s, "%") = 0 and not plusIsSpace then return s
    src = CreateObject("roByteArray")
    src.FromAsciiString(s)
    out = CreateObject("roByteArray")
    n = src.Count()
    i = 0
    while i < n
        b = src[i]
        if b = 37 and i + 2 < n + 0
            hi = WebHexVal(Chr(src[i + 1]))
            lo = WebHexVal(Chr(src[i + 2]))
            if hi >= 0 and lo >= 0
                out.Push(hi * 16 + lo)
                i = i + 3
            else
                out.Push(b)
                i = i + 1
            end if
        else if b = 43 and plusIsSpace
            out.Push(32)
            i = i + 1
        else
            out.Push(b)
            i = i + 1
        end if
    end while
    return out.ToAsciiString()
end function

' encodeURIComponent
function WebEscape(s as String) as String
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(s)
    hex = "0123456789ABCDEF"
    out = ""
    for each b in ba
        keep = (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122)
        if not keep then keep = (b = 45 or b = 95 or b = 46 or b = 126)
        if keep
            out = out + Chr(b)
        else
            out = out + "%" + Mid(hex, (b \ 16) + 1, 1) + Mid(hex, (b mod 16) + 1, 1)
        end if
    end for
    return out
end function

' "https" for "https://host/x", "" when the text has no scheme
function WebScheme(u as String) as String
    c = Instr(1, u, ":")
    if c < 2 then return ""
    s = LCase(Left(u, c - 1))
    for i = 1 to Len(s)
        ch = Mid(s, i, 1)
        ok = (ch >= "a" and ch <= "z") or (i > 1 and ((ch >= "0" and ch <= "9") or ch = "+" or ch = "-" or ch = "."))
        if not ok then return ""
    end for
    return s
end function

' What somebody typed into the address box, as an address
function WebFromTyped(text as String) as String
    t = text.Trim()
    if t = "" then return ""
    sc = WebScheme(t)
    if sc = "http" or sc = "https" then return t
    if Instr(1, t, " ") = 0 and Instr(1, t, ".") > 0 then return "https://" + t
    return WebSearchUrl(t)
end function

function WebSearchUrl(q as String) as String
    return "https://html.duckduckgo.com/html/?q=" + WebEscape(q.Trim())
end function

' Resolve a link found on the page at `base`. "" for links that go nowhere
' a reader can follow (scripts, mail, same-page anchors).
function WebResolve(base as String, href as String) as String
    h = href.Trim()
    if h = "" then return ""
    h = h.Replace("&amp;", "&")
    if Left(h, 1) = "#" then return ""
    hash = Instr(1, h, "#")
    if hash > 0 then h = Left(h, hash - 1)
    h = h.Replace(" ", "%20")
    sc = WebScheme(h)
    out = ""
    if sc <> ""
        if sc <> "http" and sc <> "https" and sc <> "meow" then return ""
        out = h
    else
        bs = WebScheme(base)
        if bs <> "http" and bs <> "https" then return ""
        rest = Mid(base, Len(bs) + 4)
        cut = Len(rest) + 1
        for each mark in ["/", "?", "#"]
            p = Instr(1, rest, mark)
            if p > 0 and p < cut then cut = p
        end for
        origin = bs + "://" + Left(rest, cut - 1)
        path = Mid(rest, cut)
        q = Instr(1, path, "#")
        if q > 0 then path = Left(path, q - 1)
        query = ""
        q = Instr(1, path, "?")
        if q > 0
            query = Mid(path, q)
            path = Left(path, q - 1)
        end if
        if path = "" then path = "/"
        if Left(h, 2) = "//"
            out = bs + ":" + h
        else if Left(h, 1) = "/"
            out = origin + h
        else if Left(h, 1) = "?"
            out = origin + path + h
        else
            tail = ""
            q = Instr(1, h, "?")
            if q > 0
                tail = Mid(h, q)
                h = Left(h, q - 1)
            end if
            segs = path.Split("/")
            if segs.Count() > 0 then segs.Pop()
            for each part in h.Split("/")
                segs.Push(part)
            end for
            keep = []
            last = segs.Count() - 1
            for i = 0 to last
                sg = segs[i]
                if sg = ".."
                    if keep.Count() > 1 then keep.Pop()
                    if i = last then keep.Push("")
                else if sg = "."
                    if i = last then keep.Push("")
                else if sg = "" and i > 0 and i < last
                    ' a doubled slash: drop it
                else
                    keep.Push(sg)
                end if
            end for
            joined = keep.Join("/")
            if Left(joined, 1) <> "/" then joined = "/" + joined
            out = origin + joined + tail
        end if
    end if
    ' search-result links that bounce through a redirect page
    p = Instr(1, out, "duckduckgo.com/l/?")
    if p > 0
        a = Instr(p, out, "uddg=")
        if a > 0
            v = Mid(out, a + 5)
            amp = Instr(1, v, "&")
            if amp > 0 then v = Left(v, amp - 1)
            v = WebUnescape(v, false)
            if WebScheme(v) = "http" or WebScheme(v) = "https" then out = v
        end if
    end if
    return out
end function

' "page" | "image" | "media" by the address alone
function WebKindOf(u as String) as String
    p = u
    q = Instr(1, p, "?")
    if q > 0 then p = Left(p, q - 1)
    dot = 0
    for i = Len(p) to 1 step -1
        ch = Mid(p, i, 1)
        if ch = "/" then exit for
        if ch = "."
            dot = i
            exit for
        end if
    end for
    if dot = 0 then return "page"
    ext = LCase(Mid(p, dot + 1))
    for each e in ["jpg", "jpeg", "png", "gif", "webp", "bmp"]
        if ext = e then return "image"
    end for
    for each e in ["mp4", "m4v", "mov", "mkv", "m3u8", "mpd", "mp3", "m4a", "aac", "flac", "wav", "ogg", "webm", "ts"]
        if ext = e then return "media"
    end for
    for each e in ["zip", "gz", "tar", "exe", "dmg", "iso", "apk", "7z", "rar", "pdf", "torrent", "bin", "msi", "deb", "epub"]
        if ext = e then return "file"
    end for
    return "page"
end function

function WebMediaFormat(u as String) as String
    p = u
    q = Instr(1, p, "?")
    if q > 0 then p = Left(p, q - 1)
    p = LCase(p)
    if Right(p, 5) = ".m3u8" then return "hls"
    if Right(p, 4) = ".mpd" then return "dash"
    if Right(p, 4) = ".mp3" then return "mp3"
    if Right(p, 4) = ".mkv" then return "mkv"
    if Right(p, 5) = ".flac" then return "flac"
    if Right(p, 4) = ".wav" then return "wav"
    if Right(p, 4) = ".ogg" then return "ogg"
    if Right(p, 5) = ".webm" then return "webm"
    return "mp4"
end function

' ---- text ----------------------------------------------------------------------------

function WebEntities(s as String) as String
    if Instr(1, s, "&") = 0 then return s
    names = ["&nbsp;", " ", "&lt;", "<", "&gt;", ">", "&quot;", Chr(34), "&#39;", "'", "&apos;", "'", "&mdash;", "—", "&ndash;", "–", "&hellip;", "…", "&copy;", "©", "&reg;", "®", "&trade;", "™", "&rsquo;", "’", "&lsquo;", "‘", "&ldquo;", "“", "&rdquo;", "”", "&middot;", "·", "&bull;", "•", "&raquo;", "»", "&laquo;", "«", "&rarr;", "→", "&larr;", "←", "&times;", "×", "&deg;", "°", "&euro;", "€", "&pound;", "£", "&eacute;", "é", "&uuml;", "ü", "&ouml;", "ö", "&auml;", "ä"]
    for i = 0 to names.Count() - 2 step 2
        if Instr(1, s, names[i]) > 0 then s = s.Replace(names[i], names[i + 1])
    end for
    if Instr(1, s, "&#") > 0
        parts = s.Split("&#")
        out = parts[0]
        for i = 1 to parts.Count() - 1
            p = parts[i]
            semi = Instr(1, p, ";")
            done = false
            if semi > 1 and semi <= 9
                num = Left(p, semi - 1)
                code = -1
                if LCase(Left(num, 1)) = "x"
                    code = 0
                    for k = 2 to Len(num)
                        hv = WebHexVal(Mid(num, k, 1))
                        if hv < 0
                            code = -1
                            exit for
                        end if
                        code = code * 16 + hv
                    end for
                else
                    code = num.ToInt()
                    if code = 0 then code = -1
                end if
                if code = 160 then code = 32
                if code > 8 and code < 1114112
                    out = out + Chr(code) + Mid(p, semi + 1)
                    done = true
                end if
            end if
            if not done then out = out + "&#" + p
        end for
        s = out
    end if
    return s.Replace("&amp;", "&")
end function

' value of one attribute of a tag's inside text, "" when absent
function WebAttr(ctx as Object, tag as String, name as String) as String
    rx = ctx.attrRx[name]
    if rx = invalid
        rx = CreateObject("roRegex", "(?:^|\s)" + name + "\s*=\s*(?:" + Chr(34) + "([^" + Chr(34) + "]*)" + Chr(34) + "|'([^']*)'|([^\s" + Chr(34) + "'>]+))", "i")
        ctx.attrRx[name] = rx
    end if
    hit = rx.Match(tag)
    if hit.Count() < 2 then return ""
    for i = 1 to hit.Count() - 1
        if hit[i] <> "" then return hit[i]
    end for
    return ""
end function

' Break one paragraph into lines of at most `width` characters and add them
' to page.lines as { t: text, links: [{ u, label }] }.
sub WebWrap(page as Object, text as String, links as Object, width as Integer, indent as String)
    open = Chr(1)
    shut = Chr(2)
    words = text.Split(" ")
    lines = []
    cur = indent
    curLen = Len(indent)
    for each w in words
        if w <> ""
            wl = Len(w)
            if curLen > Len(indent) and curLen + 1 + wl > width
                lines.Push(cur)
                cur = indent
                curLen = Len(indent)
            end if
            if curLen > Len(indent)
                cur = cur + " "
                curLen = curLen + 1
            end if
            cur = cur + w
            curLen = curLen + wl
        end if
    end for
    if curLen > Len(indent) then lines.Push(cur)
    li = 0
    inLink = false
    for each ln in lines
        mine = []
        if Instr(1, ln, open) > 0
            segs = ln.Split(open)
            for i = 1 to segs.Count() - 1
                label = segs[i]
                e = Instr(1, label, shut)
                if e > 0 then label = Left(label, e - 1)
                label = label.Trim()
                if li < links.Count()
                    if label = "" then label = links[li].u
                    mine.Push({ u: links[li].u, label: label })
                end if
                li = li + 1
            end for
        end if
        shown = ln.Replace(open, "[").Replace(shut, "]")
        page.lines.Push({ t: shown, links: mine })
    end for
end sub

sub WebFlush(page as Object, ctx as Object)
    if ctx.inLink then ctx.buf.Push(Chr(2))
    ctx.inLink = false
    if ctx.buf.Count() = 0
        ctx.links = []
        return
    end if
    text = ctx.ws.ReplaceAll(ctx.buf.Join(""), " ").Trim()
    ctx.buf = []
    links = ctx.links
    ctx.links = []
    if text = "" then return
    if ctx.gap and page.lines.Count() > 0
        if page.lines[page.lines.Count() - 1].t <> "" then page.lines.Push({ t: "", links: [] })
    end if
    ctx.gap = false
    WebWrap(page, text, links, ctx.width, ctx.indent)
    ctx.indent = ""
end sub

' Plain text (or anything that is not HTML) as lines
function WebPlainToPage(body as String, url as String, width as Integer) as Object
    page = { title: url, lines: [], base: url }
    rows = body.Replace(Chr(13), "").Split(Chr(10))
    for each r in rows
        if page.lines.Count() > 2500 then exit for
        if r.Trim() = ""
            page.lines.Push({ t: "", links: [] })
        else
            WebWrap(page, r.Replace(Chr(9), "    ").Replace(Chr(1), "").Replace(Chr(2), ""), [], width, "")
        end if
    end for
    return page
end function

' HTML as { title, base, lines: [{ t, links: [{ u, label }] }] }
function WebHtmlToPage(html as String, url as String, width as Integer) as Object
    page = { title: "", lines: [], base: url }
    ctx = {
        attrRx: {}
        ws: CreateObject("roRegex", "\s+", "")
        buf: []
        links: []
        gap: false
        indent: ""
        width: width
        form: invalid
        inLink: false
    }
    hit = CreateObject("roRegex", "<title[^>]*>(.*?)</title>", "is").Match(html)
    if hit.Count() > 1 then page.title = ctx.ws.ReplaceAll(WebEntities(hit[1]), " ").Trim()
    if page.title = "" then page.title = url

    ' things that are never read
    html = CreateObject("roRegex", "<!--.*?-->", "s").ReplaceAll(html, " ")
    for each tag in ["script", "style", "svg", "head", "template", "select", "textarea", "iframe", "canvas"]
        html = CreateObject("roRegex", "<" + tag + "\b.*?</" + tag + "\s*>", "is").ReplaceAll(html, " ")
    end for
    html = html.Replace(Chr(1), "").Replace(Chr(2), "")

    blocks = { p: 1, div: 1, br: 0, li: 0, tr: 0, ul: 1, ol: 1, table: 1, section: 1, article: 1, header: 1, footer: 1, nav: 1, aside: 1, main: 1, blockquote: 1, pre: 1, hr: 1, dd: 0, dt: 0, dl: 1, form: 1, h1: 1, h2: 1, h3: 1, h4: 1, h5: 1, h6: 1, figure: 1, figcaption: 0, address: 1, details: 1, summary: 0, title: 1, body: 1, center: 1, fieldset: 1, option: 0 }

    parts = html.Split("<")
    ctx.buf.Push(WebEntities(parts[0]))
    total = parts.Count()
    for i = 1 to total - 1
        if page.lines.Count() > 2500
            ctx.buf = []
            page.lines.Push({ t: "", links: [] })
            page.lines.Push({ t: "(This page is very long. The rest was left out.)", links: [] })
            exit for
        end if
        part = parts[i]
        gt = Instr(1, part, ">")
        first = Left(part, 1)
        isTag = gt > 0 and ((first >= "a" and first <= "z") or (first >= "A" and first <= "Z") or first = "/" or first = "!")
        if not isTag
            ctx.buf.Push("<" + WebEntities(part))
        else
            tag = Left(part, gt - 1)
            rest = Mid(part, gt + 1)
            closing = (first = "/")
            nm = tag
            if closing then nm = Mid(tag, 2)
            cut = Len(nm) + 1
            for each sp in [" ", Chr(10), Chr(13), Chr(9), "/"]
                p = Instr(1, nm, sp)
                if p > 0 and p < cut then cut = p
            end for
            nm = LCase(Left(nm, cut - 1))

            if blocks.DoesExist(nm)
                WebFlush(page, ctx)
                if blocks[nm] = 1 then ctx.gap = true
                if not closing
                    if nm = "li" then ctx.indent = "  • "
                    if nm = "h1" or nm = "h2" or nm = "h3" then ctx.indent = "# "
                    if nm = "dd" then ctx.indent = "    "
                    if nm = "form"
                        act = WebResolve(page.base, WebAttr(ctx, tag, "action"))
                        if act = "" then act = page.base
                        ctx.form = { action: act, get: LCase(WebAttr(ctx, tag, "method")) <> "post", extra: "", used: false }
                    end if
                else if nm = "form"
                    ctx.form = invalid
                end if
            else if nm = "a"
                if closing
                    if ctx.inLink then ctx.buf.Push(Chr(2))
                    ctx.inLink = false
                else
                    if ctx.inLink then ctx.buf.Push(Chr(2))
                    ctx.inLink = false
                    u = WebResolve(page.base, WebAttr(ctx, tag, "href"))
                    if u <> ""
                        ctx.links.Push({ u: u })
                        ctx.buf.Push(Chr(1))
                        ctx.inLink = true
                    end if
                end if
            else if nm = "img" and not closing
                src = WebAttr(ctx, tag, "src")
                if src = "" then src = WebAttr(ctx, tag, "data-src")
                u = ""
                if LCase(Left(src, 5)) <> "data:" then u = WebResolve(page.base, src)
                wide = WebAttr(ctx, tag, "width")
                small = false
                if wide <> ""
                    if wide.ToInt() > 0 and wide.ToInt() < 40 then small = true
                end if
                if u <> "" and not small
                    alt = WebEntities(WebAttr(ctx, tag, "alt")).Trim()
                    if Len(alt) > 60 then alt = Left(alt, 57) + "..."
                    label = "image"
                    if alt <> "" then label = "image: " + alt
                    ctx.links.Push({ u: u })
                    ctx.buf.Push(" " + Chr(1) + label + Chr(2) + " ")
                end if
            else if (nm = "video" or nm = "audio" or nm = "source" or nm = "embed") and not closing
                u = WebResolve(page.base, WebAttr(ctx, tag, "src"))
                if u <> ""
                    ctx.links.Push({ u: u })
                    ctx.buf.Push(" " + Chr(1) + "play media" + Chr(2) + " ")
                end if
            else if nm = "td" or nm = "th"
                ctx.buf.Push("   ")
            else if nm = "base" and not closing
                u = WebResolve(page.base, WebAttr(ctx, tag, "href"))
                if u <> "" then page.base = u
            else if nm = "meta" and not closing
                if LCase(WebAttr(ctx, tag, "http-equiv")) = "refresh"
                    c = WebAttr(ctx, tag, "content")
                    p = Instr(1, LCase(c), "url=")
                    if p > 0
                        u = WebResolve(page.base, Mid(c, p + 4).Replace("'", "").Replace(Chr(34), ""))
                        if u <> ""
                            ctx.links.Push({ u: u })
                            ctx.buf.Push(" " + Chr(1) + "This page moved: continue" + Chr(2) + " ")
                        end if
                    end if
                end if
            else if nm = "input" and not closing and ctx.form <> invalid
                kind = LCase(WebAttr(ctx, tag, "type"))
                name = WebAttr(ctx, tag, "name")
                if kind = "hidden"
                    if name <> "" then ctx.form.extra = ctx.form.extra + "&" + WebEscape(name) + "=" + WebEscape(WebEntities(WebAttr(ctx, tag, "value")))
                else if (kind = "" or kind = "text" or kind = "search") and name <> "" and ctx.form.get and not ctx.form.used
                    ctx.form.used = true
                    label = WebEntities(WebAttr(ctx, tag, "placeholder")).Trim()
                    if label = "" then label = WebEntities(WebAttr(ctx, tag, "aria-label")).Trim()
                    if label = "" then label = "Type here"
                    sep = "?"
                    if Instr(1, ctx.form.action, "?") > 0 then sep = "&"
                    ctx.links.Push({ u: "meow:ask|" + ctx.form.action + sep + Mid(ctx.form.extra, 2) + "|" + WebEscape(name) + "|" + label })
                    ctx.buf.Push(" " + Chr(1) + label + " ..." + Chr(2) + " ")
                end if
            end if
            if rest <> "" then ctx.buf.Push(WebEntities(rest))
        end if
    end for
    WebFlush(page, ctx)
    if page.lines.Count() = 0
        page.lines.Push({ t: "(This page has no text a reader can show. It probably builds itself with scripts.)", links: [] })
    end if
    return page
end function
